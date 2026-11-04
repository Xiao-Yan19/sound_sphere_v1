import "dotenv/config"; // loads .env before anything else runs
import app from "./app.js";
import connectDatabase from "./config/database.js";

const required = ["MONGO_URI", "JWT_ACCESS_SECRET", "JWT_REFRESH_SECRET"];
const missing = required.filter((key) => !process.env[key]);

if (missing.length > 0) {
    console.error(`Missing environment variables: ${missing.join(", ")}`);
    process.exit(1);
}

if (process.env.JWT_ACCESS_SECRET === process.env.JWT_REFRESH_SECRET) {
    console.error("JWT_ACCESS_SECRET and JWT_REFRESH_SECRET must be different");
    process.exit(1);
}

const PORT = process.env.PORT || 5000;

const startServer = async () => {
    try {
        await connectDatabase();

        app.listen(PORT, "0.0.0.0", () => {
            console.log(`Server running on port ${PORT}`);
        });
    } catch (error) {
        console.error("Server startup failed:", error.message);
        process.exit(1);
    }
};

startServer();
