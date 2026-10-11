// Shared validation helpers (used by auth + user controllers)

export const USERNAME_REGEX = /^[a-z0-9_.]{3,30}$/;
export const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// Usernames that would clash with routes or look official
export const RESERVED_USERNAMES = new Set([
    "me", "admin", "api", "root", "system", "support", "soundsphere"
]);

// Returns a trimmed string, or "" if the value is not a string.
// This blocks NoSQL operator injection such as {"$ne": null}.
export const asString = (value) =>
    typeof value === "string" ? value.trim() : "";

export const isObjectId = (value) =>
    typeof value === "string" && /^[a-f\d]{24}$/i.test(value);
