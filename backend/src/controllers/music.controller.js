import {
    searchTracks,
    getPopularTracks,
    getTrackById
} from "../services/jamendo.service.js";

// Validate pagination parameters.
const getPagination = (req) => {
    const limit = Math.min(
        Math.max(parseInt(req.query.limit, 10) || 20, 1),
        50
    );

    const offset = Math.max(
        parseInt(req.query.offset, 10) || 0,
        0
    );

    return { limit, offset };
};

// Search music tracks.
export const searchMusic = async (req, res) => {
    const query = req.query.q;

    if (typeof query !== "string" || !query.trim()) {
        return res.status(400).json({
            success: false,
            message: "Please provide a search query"
        });
    }

    const { limit, offset } = getPagination(req);

    const tracks = await searchTracks(query, limit, offset);

    return res.status(200).json({
        success: true,
        count: tracks.length,
        tracks
    });
};

// Get popular tracks.
export const getTrendingMusic = async (req, res) => {
    const { limit, offset } = getPagination(req);

    const tracks = await getPopularTracks(limit, offset);

    return res.status(200).json({
        success: true,
        count: tracks.length,
        tracks
    });
};

// Get a single track by its Jamendo ID.
export const getMusicById = async (req, res) => {
    const { id } = req.params;

    const track = await getTrackById(id);

    if (!track) {
        return res.status(404).json({
            success: false,
            message: "Track not found"
        });
    }

    return res.status(200).json({
        success: true,
        track
    });
};