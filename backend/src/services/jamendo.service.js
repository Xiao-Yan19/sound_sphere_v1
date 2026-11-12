const JAMENDO_API_URL = 'https://api.jamendo.com/v3.0/tracks/';

const getClientId = () => {
    const clientId = process.env.JAMENDO_CLIENT_ID;
    if (!clientId) {
        throw new Error('JAMENDO_CLIENT_ID is not set in environment variables');
    }
    return clientId;
};

const fetchTracks = async (params = {}) => {

    const url = new URL(JAMENDO_API_URL);
    const queryParams = {
        client_id: getClientId(),
        format: 'json',
        ...params
    };

    url.search = new URLSearchParams(queryParams).toString();

    const response = await fetch(url, {
        signal: AbortSignal.timeout(5000) // 5 seconds timeout
    });

    if (!response.ok) {
        throw new Error(`Jamendo API request failed with status ${response.status}`);
    }

    const data = await response.json();

    if(data?.headers?.status !== "success") {
        throw new Error(
            data?.headers?.error_message || 'Jamendo API returned an error'
        );
    }
    return data.results || [];

};

// Search tracks by track name, artist name, or album name
export const searchTracks  = async (query, limit = 20, offset = 0) => {
    if(!query || !query.trim()) {
        return [];
    }

    return fetchTracks({
        search:query.trim(),
        limit:String(limit),
        offset:String(offset),
        type:"single albumtrack",
        audioformat:"mp32",
        imagesize:"300",
    });
}
// Get popular tracks for the Home Page.
export const getPopularTracks = async (limit = 20, offset = 0) => {
    return fetchTracks({
        order: "popularity_week",
        limit: String(limit),
        offset: String(offset),
        type: "single albumtrack",
        audioformat: "mp32",
        imagesize: "300"
    });
};

// Mood-based track collections.
const MOOD_TAGS = {
    relax: ["relaxation", "ambient", "chillout"],
    romance: ["love", "romantic"],
    workout: ["dance", "electronic", "rock"],
    "feel-good": ["happy", "upbeat", "pop"],
    sleep: ["ambient", "meditation", "instrumental"]
};

export const getTracksByMood = async (
    mood,
    limit = 20,
    offset = 0
) => {
    const tags = MOOD_TAGS[mood];

    if (!tags) {
        return null;
    }

    return fetchTracks({
        fuzzytags: tags.join(" "),
        limit: String(limit),
        offset: String(offset),
        type: "single albumtrack",
        audioformat: "mp32",
        imagesize: "300",
        include: "musicinfo"
    });
};


// Get details of one track using its Jamendo ID.
export const getTrackById = async (trackId) => {
    if (!trackId || !/^\d+$/.test(String(trackId))) {
        throw new Error("Invalid Jamendo track ID");
    }

    const results = await fetchTracks({
        id: String(trackId),
        limit: "1",
        type: "single albumtrack",
        audioformat: "mp32",
        imagesize: "300"
    });

    return results[0] || null;
};