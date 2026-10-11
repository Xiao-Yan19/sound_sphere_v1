import express from "express";
import {
    getMyProfile,
    updateMyProfile,
    getPublicProfile,
    deleteMyAccount,
    getUserActivity
} from "../controllers/user.controller.js";
import authMiddleware from "../middleware/auth.middleware.js";

const router = express.Router();

// "/me" routes must stay above "/:username"
router.get("/me", authMiddleware, getMyProfile);
router.patch("/me", authMiddleware, updateMyProfile);
router.delete("/me", authMiddleware, deleteMyAccount);

router.get("/:id/activity", authMiddleware, getUserActivity);
router.get("/:username", getPublicProfile);

export default router;
