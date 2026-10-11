import bcrypt from "bcrypt";
import User from "../models/user.model.js";
import Session from "../models/session.model.js";
import Activity from "../models/activity.model.js";
import {
    USERNAME_REGEX,
    RESERVED_USERNAMES,
    asString,
    isObjectId
} from "../utils/validators.js";

const fail = (res, status, message) =>
    res.status(status).json({ success: false, message });

const privateUser = (user) => ({
    id: user._id,
    username: user.username,
    displayName: user.displayName,
    email: user.email,
    avatar: user.avatar,
    bio: user.bio,
    isEmailVerified: user.isEmailVerified,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt
});

// ---------------------------------------------------------------
// GET /api/users/me
// ---------------------------------------------------------------
export const getMyProfile = async (req, res) => {
    try {
        const user = await User.findById(req.userId);
        if (!user) {
            return fail(res, 404, "User not found");
        }
        return res.status(200).json({
            success: true,
            user: privateUser(user)
        });
    } catch (error) {
        console.error("Get my profile error:", error);
        return fail(res, 500, "Error fetching user profile");
    }
};

// ---------------------------------------------------------------
// PATCH /api/users/me
// body: any of { username, displayName, bio, avatar }
// ---------------------------------------------------------------
export const updateMyProfile = async (req, res) => {
    try {
        const body = req.body ?? {};

        const user = await User.findById(req.userId);
        if (!user) {
            return fail(res, 404, "User not found");
        }

        if (body.username !== undefined) {
            const username = asString(body.username).toLowerCase();
            if (!USERNAME_REGEX.test(username) || RESERVED_USERNAMES.has(username)) {
                return fail(
                    res,
                    400,
                    "Username must be 3-30 characters: letters, numbers, _ or ."
                );
            }
            if (username !== user.username) {
                const taken = await User.exists({
                    username,
                    _id: { $ne: req.userId }
                });
                if (taken) {
                    return fail(res, 409, "Username already taken");
                }
                user.username = username;
            }
        }

        if (body.displayName !== undefined) {
            if (typeof body.displayName !== "string") {
                return fail(res, 400, "Invalid display name");
            }
            const displayName = body.displayName.trim();
            if (displayName.length > 50) {
                return fail(res, 400, "Display name must be at most 50 characters");
            }
            user.displayName = displayName;
        }

        if (body.bio !== undefined) {
            if (typeof body.bio !== "string") {
                return fail(res, 400, "Invalid bio");
            }
            const bio = body.bio.trim();
            if (bio.length > 250) {
                return fail(res, 400, "Bio must be at most 250 characters");
            }
            user.bio = bio;
        }

        if (body.avatar !== undefined) {
            if (body.avatar === null || body.avatar === "") {
                user.avatar = null;
            } else if (
                typeof body.avatar === "string" &&
                body.avatar.length <= 500 &&
                /^https:\/\/\S+$/.test(body.avatar)
            ) {
                user.avatar = body.avatar;
            } else {
                return fail(res, 400, "Avatar must be an https URL");
            }
        }

        await user.save();

        return res.status(200).json({
            success: true,
            message: "Profile updated successfully",
            user: privateUser(user)
        });
    } catch (error) {
        if (error.code === 11000) {
            return fail(res, 409, "Username already taken");
        }
        if (error.name === "ValidationError") {
            return fail(res, 400, "Invalid profile details");
        }
        console.error("Update profile error:", error);
        return fail(res, 500, "Error updating user profile");
    }
};

// ---------------------------------------------------------------
// GET /api/users/:username   (public)
// ---------------------------------------------------------------
export const getPublicProfile = async (req, res) => {
    try {
        const username = asString(req.params.username).toLowerCase();
        const user = await User.findOne({ username });
        if (!user) {
            return fail(res, 404, "User not found");
        }
        // id is included because the app needs it for activity, follows, etc.
        return res.status(200).json({
            success: true,
            user: {
                id: user._id,
                username: user.username,
                displayName: user.displayName,
                avatar: user.avatar,
                bio: user.bio,
                createdAt: user.createdAt
            }
        });
    } catch (error) {
        console.error("Get public profile error:", error);
        return fail(res, 500, "Error fetching public user profile");
    }
};

// ---------------------------------------------------------------
// DELETE /api/users/me
// body: { password }   (re-confirms identity before deleting)
// ---------------------------------------------------------------
export const deleteMyAccount = async (req, res) => {
    try {
        const password =
            typeof req.body?.password === "string" ? req.body.password : "";
        if (!password) {
            return fail(res, 400, "Password is required to delete your account");
        }

        const user = await User.findById(req.userId).select("+password");
        if (!user) {
            return fail(res, 404, "User not found");
        }

        const match = await bcrypt.compare(password, user.password);
        if (!match) {
            return fail(res, 401, "Incorrect password");
        }

        await Promise.all([
            Session.deleteMany({ userId: user._id }),
            Activity.deleteMany({
                $or: [{ userId: user._id }, { targetUserId: user._id }]
            }),
            User.deleteOne({ _id: user._id })
        ]);

        return res.status(200).json({
            success: true,
            message: "Account deleted successfully"
        });
    } catch (error) {
        console.error("Delete account error:", error);
        return fail(res, 500, "Error deleting user account");
    }
};

// ---------------------------------------------------------------
// GET /api/users/:id/activity?limit=20&before=<ISO date>
// ---------------------------------------------------------------
export const getUserActivity = async (req, res) => {
    try {
        const { id } = req.params;
        if (!isObjectId(id)) {
            return fail(res, 400, "Invalid user id");
        }

        const limit = Math.min(
            Math.max(parseInt(req.query.limit, 10) || 20, 1),
            50
        );

        const filter = { userId: id };
        if (req.query.before) {
            const before = new Date(String(req.query.before));
            if (Number.isNaN(before.getTime())) {
                return fail(res, 400, "Invalid 'before' date");
            }
            filter.createdAt = { $lt: before };
        }

        const activities = await Activity.find(filter)
            .sort({ createdAt: -1 })
            .limit(limit);

        return res.status(200).json({
            success: true,
            activities,
            // Pass this back as ?before= to load the next page
            nextCursor:
                activities.length === limit
                    ? activities[activities.length - 1].createdAt
                    : null
        });
    } catch (error) {
        console.error("Get user activity error:", error);
        return fail(res, 500, "Error fetching user activity");
    }
};
