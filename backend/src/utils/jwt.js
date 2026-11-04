import jwt from "jsonwebtoken";
import crypto from "crypto";

const ALGORITHM = "HS256";

export const generateAccessToken = (userId) =>
    jwt.sign(
        { id: String(userId) },
        process.env.JWT_ACCESS_SECRET,
        {
            algorithm: ALGORITHM,
            expiresIn: process.env.JWT_ACCESS_EXPIRY || "15m"
        }
    );

// jwtid makes every refresh token unique, even if two are issued in the
// same second. Rotation and the unique index on Session rely on this.
export const generateRefreshToken = (userId) =>
    jwt.sign(
        { id: String(userId) },
        process.env.JWT_REFRESH_SECRET,
        {
            algorithm: ALGORITHM,
            expiresIn: process.env.JWT_REFRESH_EXPIRY || "7d",
            jwtid: crypto.randomUUID()
        }
    );

export const verifyAccessToken = (token) =>
    jwt.verify(token, process.env.JWT_ACCESS_SECRET, {
        algorithms: [ALGORITHM]
    });

export const verifyRefreshToken = (token) =>
    jwt.verify(token, process.env.JWT_REFRESH_SECRET, {
        algorithms: [ALGORITHM]
    });

// Session expiry always matches the token's own expiry
export const getTokenExpiry = (token) =>
    new Date(jwt.decode(token).exp * 1000);
