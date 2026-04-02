const { client } = require('../db');
const { ObjectId } = require('mongodb');

// POST /api/categories
exports.createCategory = async (req, res) => {
  const { name, budgetLimit } = req.body;
  const db = client.db('BudgetTracker');

  try {
    const result = await db.collection('Categories').insertOne({
      name, budgetLimit, budgetSpent: 0
    });
    res.status(201).json({ id: result.insertedId, error: '' });
  } catch(e) {
    res.status(500).json({ id: -1, error: e.toString() });
  }
};

// GET /api/categories
exports.getCategories = async (req, res) => {
  const db = client.db('BudgetTracker');

  try {
    const categories = await db.collection('Categories').find({}).toArray();
    res.status(200).json({ categories, error: '' });
  } catch(e) {
    res.status(500).json({ categories: [], error: e.toString() });
  }
};

// PUT /api/categories/:id
exports.updateCategory = async (req, res) => {
  const { id } = req.params;
  const { name, budgetLimit } = req.body;
  const db = client.db('BudgetTracker');

  try {
    await db.collection('Categories').updateOne(
      { _id: new ObjectId(id) },
      { $set: { name, budgetLimit } }
    );
    res.status(200).json({ error: '' });
  } catch(e) {
    res.status(500).json({ error: e.toString() });
  }
};

// DELETE /api/categories/:id
exports.deleteCategory = async (req, res) => {
  const { id } = req.params;
  const db = client.db('BudgetTracker');

  try {
    await db.collection('Categories').deleteOne({ _id: new ObjectId(id) });
    res.status(200).json({ error: '' });
  } catch(e) {
    res.status(500).json({ error: e.toString() });
  }
};

// PUT /api/categories/:id/reset
exports.resetCategory = async (req, res) => {
  const { id } = req.params;
  const db = client.db('BudgetTracker');

  try {
    await db.collection('Transactions').deleteMany({ categoryId: new ObjectId(id) });
    await db.collection('Categories').updateOne(
      { _id: new ObjectId(id) },
      { $set: { budgetSpent: 0 } }
    );
    res.status(200).json({ error: '' });
  } catch(e) {
    res.status(500).json({ error: e.toString() });
  }
};