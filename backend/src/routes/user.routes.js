import express from "express";

import{
    getMyProfile,
    updateMyProfile,
    getPublicProfile,
    deleteMyAccount,
    getUserActivity
} from "../controllers/user.controller.js";
import authMiddleware from "../middleware/auth.middleware.js";

const router = express.Router();

router.get("/me", authMiddleware, getMyProfile);
router.patch("/me", authMiddleware, updateMyProfile);
router.get("/:username", getPublicProfile);
router.delete("/me", authMiddleware, deleteMyAccount); //Not completed yet, will be modified later
router.get("/:id/activity", getUserActivity); //will be modified Later

export default router;