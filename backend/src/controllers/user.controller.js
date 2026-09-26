import User from "../models/user.model.js";
import Activity from "../models/activity.model.js";

export const getMyProfile = async (req, res) => {
    try{
        const user = await User.findById(req.userId);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: "User not found"
            });
        }
        return res.status(200).json({
            success: true,
            user:{
                id: user._id,
                username: user.username,
                displayName: user.displayName,
                email: user.email,
                avatar: user.avatar,
                bio: user.bio,
                isEmailVerified: user.isEmailVerified,
                createdAt: user.createdAt,
                updatedAt: user.updatedAt
            }
        });
    } catch (error) {
        return res.status(500).json({
            success: false,
            message: "Error fetching user profile",
            error: error.message
        });
    }
};
export const updateMyProfile = async (req, res) => {
    try{
        const { username, displayName, avatar, bio } = req.body;

        const user = await User.findById(req.userId);

        if(!user){
            return res.status(404).json({
                success: false,
                message: "User not found"
            });
        }

        if(username !== undefined){
            const existingUser = await User.findOne({
                username,
                _id:{$ne:req.userId}
            });
            if(existingUser){
                return res.status(400).json({
                    success: false,
                    message: "Username already taken"
                });
            }
            user.username = username;
        }
        if(displayName !== undefined){
            user.displayName = displayName;
        }

        if(bio !== undefined){
            user.bio = bio;
        }
        if(avatar !== undefined){
            user.avatar = avatar;
        }
        await user.save();

        return res.status(200).json({
            success: true,
            message: "Profile updated successfully",
            username: user.username,
            displayName: user.displayName,
            email: user.email,
            avatar: user.avatar,
            bio:user.bio


        });
    } catch (error) {
        return res.status(500).json({
            success: false,
            message: "Error updating user profile",
            error: error.message
        });
    }

};
export const getPublicProfile = async (req, res) => {
    try{
        const { username } = req.params;
        const user = await User.findOne({ username });
        if (!user) {
            return res.status(404).json({
                success: false,
                message: "User not found"
            });
        }
        return res.status(200).json({
            success: true,
            user:{
                //id: user._id,
                username: user.username,
                displayName: user.displayName,
                avatar: user.avatar,
                bio: user.bio,
                createdAt: user.createdAt,
               
            }
        });
    } catch (error) {
        console.error("Get public user profile error:", error);
        return res.status(500).json({
            success: false,
            message: "Error fetching public user profile",
            error: error.message
        });
    }

};
export const deleteMyAccount = async (req, res) => {
    try{
        const user = await User.findById(req.userId);

        if(!user){
            return res.status(404).json({
                success: false,
                message: "User not found"
            });
        }
        await User.deleteOne({
            _id: req.userId
        });

        return res.status(200).json({
            success: true,
            message: "Account deleted successfully"
        });
    } catch (error) {
        console.error("Delete user account error:", error);
        return res.status(500).json({
            success: false,
            message: "Error deleting user account",
            error: error.message
        });
    }

};
export const getUserActivity = async (req, res) => {
    try{
        const{id} = req.params;

        const activities = await Activity.find({
            userId: id
        })
        .sort({ createdAt: -1 })
        .limit(50);

        return res.status(200).json({
            success: true,
            activities
        });
    } catch (error) {
        console.error("Get user activity error:", error);
        return res.status(500).json({
            success: false,
            message: "Error fetching user activity",
            error: error.message
        });
    }

}
