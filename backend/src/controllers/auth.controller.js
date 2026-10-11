import bcrypt from "bcrypt";
import crypto from "crypto";
import User from "../models/user.model.js";
import Session from "../models/session.model.js";
import {
    generateAccessToken,
    generateRefreshToken,
    verifyRefreshToken,
    getTokenExpiry
} from "../utils/jwt.js";
import {
    USERNAME_REGEX,
    EMAIL_REGEX,
    RESERVED_USERNAMES,
    asString
} from "../utils/validators.js";

// Refresh tokens are stored hashed so a database leak cannot be replayed.
const hashToken = (token) =>
    crypto.createHash("sha256").update(token).digest("hex");

const publicUser = (user) => ({
    id: user._id,
    username: user.username,
    displayName: user.displayName,
    email: user.email,
    avatar: user.avatar,
    bio: user.bio
});

const fail = (res, status, message) =>
    res.status(status).json({ success: false, message });

// Compared against when the email is unknown, so "no such user" takes as
// long as "wrong password" (prevents timing-based email discovery).
const DUMMY_HASH = bcrypt.hashSync("not-a-real-password", 12);

// The Flutter register screen only collects Full Name, email and password,
// so when no username is sent we derive a unique one from the email.
const generateUniqueUsername = async (email) => {
    let base = email
        .split("@")[0]
        .toLowerCase()
        .replace(/[^a-z0-9_.]/g, "")
        .slice(0, 20);
    if (base.length < 3) base = `${base}user`;

    for (let i = 0; i < 6; i++) {
        const candidate =
            i === 0 ? base : `${base}${Math.floor(1000 + Math.random() * 9000)}`;
        if (
            !RESERVED_USERNAMES.has(candidate) &&
            !(await User.exists({ username: candidate }))
        ) {
            return candidate;
        }
    }
    return `${base}${Date.now().toString().slice(-6)}`;
};

// ---------------------------------------------------------------
// REGISTER
// body: { email, password, displayName?, username? }
// ---------------------------------------------------------------
export const registerUser = async (req, res) => {
    try {
        const email = asString(req.body.email).toLowerCase();
        const password =
            typeof req.body.password === "string" ? req.body.password : "";
        const displayName = asString(req.body.displayName).slice(0, 50);
        let username = asString(req.body.username).toLowerCase();

        if (!email || !password) {
            return fail(res, 400, "Email and password are required");
        }
        if (!EMAIL_REGEX.test(email)) {
            return fail(res, 400, "Invalid email address");
        }
        // bcrypt only uses the first 72 bytes of a password
        if (password.length < 8 || password.length > 72) {
            return fail(res, 400, "Password must be 8-72 characters");
        }

        if (username) {
            if (!USERNAME_REGEX.test(username) || RESERVED_USERNAMES.has(username)) {
                return fail(
                    res,
                    400,
                    "Username must be 3-30 characters: letters, numbers, _ or ."
                );
            }
            if (await User.exists({ username })) {
                return fail(res, 409, "Username already taken");
            }
        }

        if (await User.exists({ email })) {
            return fail(res, 409, "Email already registered");
        }

        if (!username) {
            username = await generateUniqueUsername(email);
        }

        const hashedPassword = await bcrypt.hash(password, 12);

        const user = await User.create({
            username,
            email,
            displayName,
            password: hashedPassword
        });

        return res.status(201).json({
            success: true,
            message: "User registered successfully",
            user: publicUser(user)
        });
    } catch (error) {
        // Unique index violation (two sign-ups at the same moment)
        if (error.code === 11000) {
            const field = Object.keys(error.keyPattern ?? {})[0];
            return fail(
                res,
                409,
                field === "username"
                    ? "Username already taken"
                    : "Email already registered"
            );
        }
        if (error.name === "ValidationError") {
            return fail(res, 400, "Invalid registration details");
        }
        console.error("Register error:", error);
        return fail(res, 500, "Internal server error");
    }
};

// ---------------------------------------------------------------
// LOGIN
// body: { email, password }
// ---------------------------------------------------------------
export const loginUser = async (req, res) => {
    try {
        const email = asString(req.body.email).toLowerCase();
        const password =
            typeof req.body.password === "string" ? req.body.password : "";

        if (!email || !password) {
            return fail(res, 400, "Email and password are required");
        }

        const user = await User.findOne({ email }).select("+password");

        const passwordMatch = await bcrypt.compare(
            password,
            user ? user.password : DUMMY_HASH
        );

        if (!user || !passwordMatch) {
            return fail(res, 401, "Invalid email or password");
        }

        const accessToken = generateAccessToken(user._id);
        const refreshToken = generateRefreshToken(user._id);

        await Session.create({
            userId: user._id,
            refreshToken: hashToken(refreshToken),
            expiresAt: getTokenExpiry(refreshToken)
        });

        // Flutter keeps both tokens in flutter_secure_storage.
        return res.status(200).json({
            success: true,
            message: "Login successful",
            accessToken,
            refreshToken,
            user: publicUser(user)
        });
    } catch (error) {
        console.error("Login error:", error);
        return fail(res, 500, "Internal server error");
    }
};

// ---------------------------------------------------------------
// CURRENT USER  (authMiddleware sets req.userId)
// ---------------------------------------------------------------
export const getCurrentUser = async (req, res) => {
    try {
        const user = await User.findById(req.userId);
        if (!user) {
            return fail(res, 404, "User not found");
        }
        return res.status(200).json({
            success: true,
            user: publicUser(user)
        });
    } catch (error) {
        console.error("Get current user error:", error);
        return fail(res, 500, "Internal server error");
    }
};

// ---------------------------------------------------------------
// REFRESH  (rotation: every refresh returns a NEW refresh token)
// body: { refreshToken }
// ---------------------------------------------------------------
export const refreshToken = async (req, res) => {
    try {
        const token = req.body?.refreshToken;
        if (!token || typeof token !== "string") {
            return fail(res, 401, "Refresh token not found");
        }

        // 1. Signature + expiry first, so junk never reaches MongoDB
        let decoded;
        try {
            decoded = verifyRefreshToken(token);
        } catch {
            return fail(res, 401, "Invalid or expired refresh token");
        }

        // 2. Swap old session token for a new one in ONE atomic update.
        //    If two requests arrive with the same token, only one wins.
        const newRefreshToken = generateRefreshToken(decoded.id);

        const session = await Session.findOneAndUpdate(
            {
                refreshToken: hashToken(token),
                userId: decoded.id,
                expiresAt: { $gt: new Date() }
            },
            {
                refreshToken: hashToken(newRefreshToken),
                expiresAt: getTokenExpiry(newRefreshToken)
            }
        );

        if (!session) {
            return fail(res, 401, "Invalid refresh token");
        }

        return res.status(200).json({
            success: true,
            accessToken: generateAccessToken(decoded.id),
            refreshToken: newRefreshToken
        });
    } catch (error) {
        console.error("Refresh token error:", error);
        return fail(res, 500, "Internal server error");
    }
};

// ---------------------------------------------------------------
// LOGOUT  (always succeeds; removes the session if the token is known)
// body: { refreshToken }
// ---------------------------------------------------------------
export const logoutUser = async (req, res) => {
    try {
        const token = req.body?.refreshToken;
        if (token && typeof token === "string") {
            await Session.deleteOne({ refreshToken: hashToken(token) });
        }
        return res.status(200).json({
            success: true,
            message: "User logged out successfully"
        });
    } catch (error) {
        console.error("Logout error:", error);
        return fail(res, 500, "Internal server error");
    }
};
