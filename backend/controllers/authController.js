require('dotenv').config();
const { client } = require('../db');
const bcrypt = require('bcryptjs');
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
    const result = await db.collection('Users').insertOne({ First, Last, email, password: hashedPassword });
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
    const token = generateToken(user._id);
    res.status(200).json({ id: user._id, First: user.First, Last: user.Last, email: user.email, token, error: '' });
  } catch(e) {
    res.status(500).json({ id: -1, error: e.toString() });
  }
};