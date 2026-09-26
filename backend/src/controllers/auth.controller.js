import bcrypt from "bcrypt";
import User from "../models/user.model.js";
import jwt from "jsonwebtoken";
import {
    generateAccessToken,
    generateRefreshToken
} from "../utils/jwt.js";

import Session from "../models/session.model.js";

export const registerUser = async (req, res) => {
    try {
        const { username, email, password } = req.body;

  
        if (!username || !email || !password) {
            return res.status(400).json({
                success: false,
                message: "Username, email and password are required"
            });
        }


        const existingUser = await User.findOne({
            $or: [
                { username },
                { email }
            ]
        });

        if (existingUser) {
            return res.status(409).json({
                success: false,
                message: "Username or email already exists"
            });
        }


        const hashedPassword = await bcrypt.hash(password, 12);

  
        const user = await User.create({
            username,
            email,
            password: hashedPassword
        });


        return res.status(201).json({
            success: true,
            message: "User registered successfully",
            user: {
                id: user._id,
                username: user.username,
                email: user.email,
                avatar: user.avatar,
                bio: user.bio
            }
        });

    } catch (error) {
        console.error("Register error:", error);

        return res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};
export const loginUser = async (req, res) => {

    try{
        const {email, password} = req.body;

        //Validate Input
        if(!email || !password){
            return res.status(400).json({
                success: false,
                message: "Email and password are required"
            });
        };
        //Find User and Validate Password
        const user = await User
        .findOne({email:email.toLowerCase()})
        .select("+password");

        if(!user){
            return res.status(401).json({
                success: false,
                message: "Invalid email or password"
            });
        }
        //Compare Passwords
        const passwordMatch = await bcrypt.compare
        (password, user.password);
        if(!passwordMatch){
            return res.status(401).json({
                success: false,
                message: "Invalid email or password"
            });
        }
        //Generate Tokens
        const accessToken = generateAccessToken(user._id);
        const refreshToken = generateRefreshToken(user._id);

        const expiresAt = new Date(
        Date.now() + 7 * 24 * 60 * 60 * 1000
            );

            await Session.create({
                userId: user._id,
                refreshToken,
                expiresAt
            });

        //Store Refresh Token in HttpOnly Cookie
        res.cookie("refreshToken", refreshToken, {
            httpOnly: true,
            secure: process.env.NODE_ENV === "production",
            sameSite: "strict",
            maxAge: 7 * 24 * 60 * 60 * 1000 // 7 days
        });

        //Send Response
        return res.status(200).json({
            success: true,
            message: "Login successful",
            accessToken,
            user: {
                id: user._id,
                username: user.username,
                email: user.email,
                avatar: user.avatar,
                bio: user.bio
            }
        });
    }
    catch(error){
        console.error("Login error:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }

};
export const getCurrentUser = async (req, res) => {
    try{
        const user = await User.findById(req.userId);

        if(!user){
            return res.status(404).json({
                success: false,
                message: "User not found"
            });
        }
        return res.status(200).json({
            success: true,
            user: {
                id: user._id,
                username: user.username,
                email: user.email,
                avatar: user.avatar,
                bio: user.bio
            }
        });
    }catch(error){
        console.error("Get current user error:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }

};
export const refreshToken = async (req, res) => {
    try{
        const refreshToken = req.cookies.refreshToken;
        if(!refreshToken){
            return res.status(401).json({
                success: false,
                message: "Refresh token not found"
            });
        }
        const session = await Session.findOne({refreshToken});
        if(!session){
            return res.status(401).json({
                success: false,
                message: "Invalid refresh token"
            });
        }
        if(session.expiresAt < new Date()){
            await Session.deleteOne({ _id: session._id });
            return res.status(401).json({
                success: false,
                message: "Refresh token expired"
            });
        }
        const decoded = jwt.verify(
            refreshToken,
            process.env.JWT_REFRESH_SECRET
        );

        if(decoded.id !== session.userId.toString()){
            return res.status(401).json({
                success: false,
                message: "Invalid refresh token"
            });
        }
        const newAccessToken = generateAccessToken(session.userId);
        return res.status(200).json({
            success: true,
            accessToken: newAccessToken
        });
    }
    catch(error){
        console.error("Refresh token error:", error);
        return res.status(401).json({
            success: false,
            message: "Invalid or expired refresh token"
        });
    }

};
export const logoutUser = async (req, res) => {
    try{
        const refreshToken = req.cookies.refreshToken;
        if(refreshToken){
            await Session.deleteOne({refreshToken});
            res.clearCookie("refreshToken", {
                httpOnly: true,
                secure: process.env.NODE_ENV === "production",
                sameSite: "strict"
            });
        }
        return res.status(200).json({
            success: true,
            message: "User logged out successfully"
        });
    } catch(error){
        console.error("Logout error:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }

}