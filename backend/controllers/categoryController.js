const { client } = require('../db');
const { ObjectId } = require('mongodb');

// POST /api/categories
exports.createCategory = async (req, res) => {
  const { name, budgetLimit } = req.body;
  const userId = req.user.id;
  const db = client.db('BudgetTracker');

  try {
    // Prevent duplicate category names per user
    const existing = await db.collection('Categories').findOne({
      name,
      userId: new ObjectId(userId)
    });

    if (existing) {
      return res.status(400).json({
        id: -1,
        error: 'Category already exists for this user'
      });
    }

    const result = await db.collection('Categories').insertOne({
      name,
      budgetLimit,
      budgetSpent: 0,
      userId: new ObjectId(userId)
    });

    res.status(201).json({ id: result.insertedId, error: '' });
  } catch (e) {
    res.status(500).json({ id: -1, error: e.toString() });
  }
};

// GET /api/categories
exports.getCategories = async (req, res) => {
  const userId = req.user.id;
  const db = client.db('BudgetTracker');

  try {
    const categories = await db.collection('Categories')
      .find({ userId: new ObjectId(userId) })
      .toArray();

    res.status(200).json({ categories, error: '' });
  } catch (e) {
    res.status(500).json({ categories: [], error: e.toString() });
  }
};

// PUT /api/categories/:id
exports.updateCategory = async (req, res) => {
  const { id } = req.params;
  const { name, budgetLimit } = req.body;
  const userId = req.user.id;
  const db = client.db('BudgetTracker');

  try {
    const result = await db.collection('Categories').updateOne(
      {
        _id: new ObjectId(id),
        userId: new ObjectId(userId)
      },
      {
        $set: { name, budgetLimit }
      }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({
        error: 'Not found or unauthorized'
      });
    }

    res.status(200).json({ error: '' });
  } catch (e) {
    res.status(500).json({ error: e.toString() });
  }
};

// DELETE /api/categories/:id
exports.deleteCategory = async (req, res) => {
  const { id } = req.params;
  const userId = req.user.id;
  const db = client.db('BudgetTracker');

  try {
    const result = await db.collection('Categories').deleteOne({
      _id: new ObjectId(id),
      userId: new ObjectId(userId)
    });

    if (result.deletedCount === 0) {
      return res.status(404).json({
        error: 'Not found or unauthorized'
      });
    }

    res.status(200).json({ error: '' });
  } catch (e) {
    res.status(500).json({ error: e.toString() });
  }
};

// PUT /api/categories/:id/reset
exports.resetCategory = async (req, res) => {
  const { id } = req.params;
  const userId = req.user.id;
  const db = client.db('BudgetTracker');

  try {
    // Check ownership first
    const category = await db.collection('Categories').findOne({
      _id: new ObjectId(id),
      userId: new ObjectId(userId)
    });

    if (!category) {
      return res.status(404).json({
        error: 'Not found or unauthorized'
      });
    }

    // Delete transactions tied to this category
    await db.collection('Transactions').deleteMany({
      categoryId: new ObjectId(id)
    });

    // Reset budgetSpent
    await db.collection('Categories').updateOne(
      { _id: new ObjectId(id) },
      { $set: { budgetSpent: 0 } }
    );

    res.status(200).json({ error: '' });
  } catch (e) {
    res.status(500).json({ error: e.toString() });
  }
};