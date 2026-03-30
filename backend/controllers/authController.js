const { client } = require('../db');

// POST /api/auth/register
exports.registerUser = async (req, res) => {
  const { email, password } = req.body;
  const db = client.db('BudgetTracker');

  try {
    const existing = await db.collection('Users').findOne({ email });
    if (existing) {
      return res.status(400).json({ id: -1, error: 'Email already taken' });
    }
    const result = await db.collection('Users').insertOne({ email, password });
    res.status(201).json({ id: result.insertedId, error: '' });
  } catch(e) {
    res.status(500).json({ id: -1, error: e.toString() });
  }
};

// POST /api/auth/login
exports.loginUser = async (req, res) => {
  const { email, password } = req.body;
  const db = client.db('BudgetTracker');

  try {
    const user = await db.collection('Users').findOne({ email, password });
    if (!user) {
      return res.status(400).json({ id: -1, error: 'Invalid email/password' });
    }
    res.status(200).json({ id: user._id, email: user.email, error: '' });
  } catch(e) {
    res.status(500).json({ id: -1, error: e.toString() });
  }
};