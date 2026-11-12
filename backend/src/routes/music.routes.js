import express from "express";

import {
    searchMusic,
    getTrendingMusic,
    getMusicById,
    getMoodMusic
} from "../controllers/music.controller.js";

const router = express.Router();

// Search tracks
router.get("/search", searchMusic);

// Get popular tracks
router.get("/trending", getTrendingMusic);
// Get tracks by mood
router.get("/mood/:mood", getMoodMusic);

// Get track details
router.get("/:id", getMusicById);

export default router;