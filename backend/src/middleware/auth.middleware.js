import { verifyAccessToken } from "../utils/jwt.js";

const authMiddleware = (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader) {
            return res.status(401).json({
                success: false,
                code: "NO_TOKEN",
                message: "Authorization header missing"
            });
        }

        const [scheme, token] = authHeader.split(" ");

        if (scheme !== "Bearer" || !token) {
            return res.status(401).json({
                success: false,
                code: "BAD_AUTH_FORMAT",
                message: "Invalid authorization format"
            });
        }

        const decoded = verifyAccessToken(token);
        req.userId = decoded.id;

        next();
    } catch (error) {
        // The Flutter Dio interceptor refreshes ONLY on TOKEN_EXPIRED
        if (error.name === "TokenExpiredError") {
            return res.status(401).json({
                success: false,
                code: "TOKEN_EXPIRED",
                message: "Access token expired"
            });
        }

        return res.status(401).json({
            success: false,
            code: "INVALID_TOKEN",
            message: "Invalid access token"
        });
    }
};

export default authMiddleware;
