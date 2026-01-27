import { jwt_secret } from "../config/config.js";
import User from "../model/User.js";
import jwt from "jsonwebtoken";
import bcrypt from "bcrypt";

/**  REGISTER  **/
export const registerUser = async (req, res) => {
  try {
    const { email, username, password, role } = req.body;

    // check if user exists
    const existingUser = await User.findOne({
      $or: [
        { email: email.toLowerCase() },
       
    

      ],
    });

    if (existingUser) {
      return res.status(400).json({ message: "Email ka ama Nambarka mid ayaa hore loo diwan galiyay" });
    }

    const userInfo = new User({
      email: email.toLowerCase(),
      username: username.toLowerCase(),
      password,
      
      // role optional: default = 'user' haddii aan la dirin
      ...(role && { role }),
    });

    await userInfo.save();
    res.status(201).json({ message: "User registered successfully" });
  } catch (error) {
    console.error("Error in registering user:", error);
    res.status(500).json({ message: "Error in registering user" });
  }
};

// /**  LOGIN  **/
export const loginUser = async (req, res) => {
  try {
    const { username, password } = req.body;

    const user = await User.findOne({ username: username }).select(
      "+password"
    );
    if (!user) {
      return res.status(400).json({ message: "Username does not exist" });
    }
    // Note: status field removed - all users are active by default


    const isPasswordCorrect = await user.comparePassword(password);
    if (!isPasswordCorrect) {
      return res.status(400).json({ message: "Invalid password" });
    }

    const expirein  = 7 * 24 * 60 * 60 * 1000; // 7 days
        // const token = jwt.sign({ _id: isuserExist._id}, jwt_secret, {expirein});
        const token = jwt.sign({ _id: user._id, role: user.role }, jwt_secret, {expiresIn: expirein});
        res.cookie("token", token, {
            httpOnly: true,
            secure: false,
            maxAge: expirein * 1000 // Convert to milliseconds

        });

        res.status(200).send({...user.toJSON(), expirein});

    }catch(error){
        console.log("Error in logging in user:", error);
        res.status(400).send({message: "Error in logging in user"});
    }
}

// get all users
export const getAllUsers = async (req, res) => {
  try { 
    const users = await User.find().select("-password");
    res.status(200).json({
      success: true,
      data: users
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error fetching users",
      error: error.message
    });
  } 
};



