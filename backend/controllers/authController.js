require('dotenv').config();
const { client } = require('../db');
const bcrypt = require('bcryptjs');
const nodemailer = require("nodemailer");
const jwt = require('jsonwebtoken');

const generateToken = (userId) => {
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, { expiresIn: '7d' });
};

// POST /api/auth/register
exports.registerUser = async (req, res) => {
  const { First, Last, email, password } = req.body;
  const db = client.db('BudgetTracker');

  try {
    const existing = await db.collection('Users').findOne({ email });
    if (existing) {
      return res.status(400).json({ id: -1, error: 'Email already taken' });
    }
    const hashedPassword = await bcrypt.hash(password, 10);

    // Generate verification code + expiry time
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    const verificationCodeExpires = new Date(Date.now() + 15 * 60 * 1000); // 15 mins

    const result = await db.collection('Users').insertOne({ First, Last, email, password: hashedPassword, isVerified: false, verificationCode, verificationCodeExpires });

    // Send email with verification code
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });
    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Ducky Dollars: Email Verification',
      text: `Your verification code is: ${verificationCode}`,
    });

    const token = generateToken(result.insertedId);
    res.status(201).json({ id: result.insertedId, token, error: '' });
  } catch(e) {
    res.status(500).json({ id: -1, error: e.toString() });
  }
};

// POST /api/auth/login
exports.loginUser = async (req, res) => {
  const { email, password } = req.body;
  const db = client.db('BudgetTracker');

  try {
    const user = await db.collection('Users').findOne({ email });
    if (!user) {
      return res.status(400).json({ id: -1, error: 'Invalid email/password' });
    }
    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.status(400).json({ id: -1, error: 'Invalid email/password' });
    }
    if (!user.isVerified) {
      return res.status(400).json({ id: -1, error: 'Email not verified' });
    }
    res.status(200).json({ id: user._id, First: user.First, Last: user.Last, email: user.email, error: '' });
  } catch(e) {
    res.status(500).json({ id: -1, error: e.toString() });
  }
};

// POST /api/auth/verify
exports.verifyCode = async (req, res) => {
  const { email, code } = req.body;
  const db = client.db('BudgetTracker');

  try {
    const user = await db.collection('Users').findOne({ email });
    if (!user) {
      return res.status(400).json({ id: -1, error: 'Invalid email' });
    }
    if (user.verificationCode !== code) {
      return res.status(400).json({ id: -1, error: 'Invalid verification code' });
    }
    if (user.verificationCodeExpires < new Date()) {
      return res.status(400).json({ id: -1, error: 'Verification code expired' });
    }

    // Set user as verified and remove verification code fields
    await db.collection('Users').updateOne(
      { email }, 
      { 
        $set: { isVerified: true },
        $unset: {
          verificationCode: "", 
          verificationCodeExpires: "" 
        }
      }
    );
    const token = generateToken(user._id);
    res.status(200).json({ id: user._id, First: user.First, Last: user.Last, email: user.email, token, error: '' });
  } catch(e) {
    res.status(500).json({ id: -1, error: e.toString() });
  }
};