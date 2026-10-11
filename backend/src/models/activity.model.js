import mongoose from "mongoose";

const activitySchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true
        },
        type: {
            type: String,
            required: true,
            enum: [
                "SONG_LIKED",
                "SONG_PLAYED",
                "PLAYLIST_CREATED",
                "PLAYLIST_LIKED",
                "USER_CONNECTED"
            ]
        },
        songId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Song",
            default: null
        },
        playlistId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Playlist",
            default: null
        },
        targetUserId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            default: null
        }
    },
    { timestamps: true }
);

// Serves "latest activity of a user" and its pagination
activitySchema.index({ userId: 1, createdAt: -1 });

const Activity = mongoose.model("Activity", activitySchema);

export default Activity;
