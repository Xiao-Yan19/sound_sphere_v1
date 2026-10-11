import express from "express";
import cors from "cors";
import helmet from "helmet";
import rateLimit from "express-rate-limit";

import authRoutes from "./routes/auth.routes.js";
import userRoutes from "./routes/user.routes.js";

const app = express();


app.use(helmet());

app.use(cors());

app.use(express.json({ limit: "10kb" }));

const tooMany = {
    success: false,
    message: "Too many requests, please try again later"
};

const apiLimiter = rateLimit({
    windowMs: 60 * 1000,
    limit: 120,
    standardHeaders: true,
    legacyHeaders: false,
    message: tooMany
});

// Stricter limit on credential endpoints (brute-force protection).
// Raise `limit` if many students share one campus Wi-Fi IP during demos.
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 30,
    standardHeaders: true,
    legacyHeaders: false,
    message: tooMany
});

app.use("/api", apiLimiter);
app.use("/api/auth/login", authLimiter);
app.use("/api/auth/register", authLimiter);

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);

app.get("/", (req, res) => {
    res.status(200).json({
        success: true,
        message: "SoundSphere API is running"
    });
});

// Unknown route -> JSON (not HTML) so Dio can parse it
app.use((req, res) => {
    res.status(404).json({ success: false, message: "Route not found" });
});

// Central error handler (e.g. malformed JSON body)
app.use((err, req, res, next) => {
    if (err.type === "entity.parse.failed") {
        return res.status(400).json({ success: false, message: "Invalid JSON body" });
    }
    if (err.type === "entity.too.large") {
        return res.status(413).json({ success: false, message: "Request body too large" });
    }
    console.error("Unhandled error:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
});

export default app;
