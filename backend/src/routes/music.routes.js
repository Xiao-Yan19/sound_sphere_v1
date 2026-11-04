import express from "express";

import {
    searchMusic,
    getTrendingMusic,
    getMusicById
} from "../controllers/music.controller.js";

const router = express.Router();

// Search tracks
router.get("/search", searchMusic);

// Get popular tracks
router.get("/trending", getTrendingMusic);

// Get track details
router.get("/:id", getMusicById);

export default router;