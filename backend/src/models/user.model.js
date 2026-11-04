import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
    {
        // Stored lowercase so "Alice" and "alice" cannot both exist.
        // Use displayName for how the name looks on screen.
        username: {
            type: String,
            required: [true, "Username is required"],
            unique: true,
            trim: true,
            lowercase: true,
            minlength: 3,
            maxlength: 30,
            match: [/^[a-z0-9_.]+$/, "Username may contain letters, numbers, _ and ."]
        },

        email: {
            type: String,
            required: [true, "Email is required"],
            unique: true,
            lowercase: true,
            trim: true,
            match: [/^[^\s@]+@[^\s@]+\.[^\s@]+$/, "Invalid email address"]
        },

        // Holds the bcrypt hash, never the raw password
        password: {
            type: String,
            required: [true, "Password is required"],
            select: false
        },

        avatar: {
            type: String,
            default: null
        },

        bio: {
            type: String,
            maxlength: 250,
            default: ""
        },

        displayName: {
            type: String,
            maxlength: 50,
            trim: true,
            default: ""
        },

        isEmailVerified: {
            type: Boolean,
            default: false
        }
    },
    {
        timestamps: true
    }
);

const User = mongoose.model("User", userSchema);

export default User;
