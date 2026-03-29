const { client } = require('../db');

// POST /api/auth/register
exports.registerUser = async (req, res) => {
  const { username, password } = req.body;
  const db = client.db('BudgetTracker');

  try {
    const existing = await db.collection('Users').findOne({ username });
    if (existing) {
      return res.status(400).json({ id: -1, error: 'Username already taken' });
    }
    const result = await db.collection('Users').insertOne({ username, password });
    res.status(201).json({ id: result.insertedId, error: '' });
  } catch(e) {
    res.status(500).json({ id: -1, error: e.toString() });
  }
};

// POST /api/auth/login
exports.loginUser = async (req, res) => {
  const { username, password } = req.body;
  const db = client.db('BudgetTracker');

  try {
    const user = await db.collection('Users').findOne({ username, password });
    if (!user) {
      return res.status(400).json({ id: -1, error: 'Invalid username/password' });
    }
    res.status(200).json({ id: user._id, username: user.username, error: '' });
  } catch(e) {
    res.status(500).json({ id: -1, error: e.toString() });
  }
};