import express from "express";
import {
    registerUser,
    loginUser,
    getCurrentUser,
    refreshToken,
    logoutUser
} from "../controllers/auth.controller.js";
import authMiddleware from "../middleware/auth.middleware.js";

const router = express.Router();

router.post("/register", registerUser);
router.post("/login", loginUser);
router.get("/me", authMiddleware, getCurrentUser);
router.post("/refresh", refreshToken);
router.post("/logout", logoutUser);

export default router;
