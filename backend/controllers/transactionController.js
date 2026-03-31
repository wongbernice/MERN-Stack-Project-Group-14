const { client } = require('../db');
const { ObjectId } = require('mongodb');

// GET
exports.getTransactions = async (req, res) => {
  const { userId } = req.query;
  const db = client.db('BudgetTracker');

  try {
    const transactions = await db.collection('Transactions')
      .find({ userId: new ObjectId(userId) })
      .toArray();

    res.status(200).json({ transactions, error: '' });
  } catch (e) {
    res.status(500).json({ transactions: [], error: e.toString() });
  }
};

// GET BY ID
exports.getTransactionById = async (req, res) => {
  const { id } = req.params;
  const db = client.db('BudgetTracker');

  try {
    const transaction = await db.collection('Transactions')
      .findOne({ _id: new ObjectId(id) });

    if (!transaction) {
      return res.status(404).json({ error: 'Not found' });
    }

    res.status(200).json({ transaction, error: '' });
  } catch (e) {
    res.status(500).json({ error: e.toString() });
  }
};

// CREATE
exports.createTransaction = async (req, res) => {
  const { userId, categoryId, amount, date, note } = req.body;
  const db = client.db('BudgetTracker');

  try {
    const transaction = {
      userId: new ObjectId(userId),
      categoryId: new ObjectId(categoryId),
      amount,
      date,
      note
    };

    const result = await db.collection('Transactions').insertOne(transaction);

    await db.collection('Categories').updateOne(
      { _id: new ObjectId(categoryId) },
      { $inc: { budgetSpent: amount } }
    );

    res.status(201).json({ id: result.insertedId, error: '' });

  } catch (e) {
    res.status(500).json({ id: -1, error: e.toString() });
  }
};

// UPDATE
exports.updateTransaction = async (req, res) => {
  const { id } = req.params;
  const { categoryId, amount, date, note } = req.body;
  const db = client.db('BudgetTracker');

  try {
    const existing = await db.collection('Transactions')
      .findOne({ _id: new ObjectId(id) });

    if (!existing) {
      return res.status(404).json({ error: 'Not found' });
    }

    const oldAmount = existing.amount;
    const oldCategoryId = existing.categoryId.toString();

    if (oldCategoryId === categoryId) {
      const diff = amount - oldAmount;

      await db.collection('Categories').updateOne(
        { _id: new ObjectId(categoryId) },
        { $inc: { budgetSpent: diff } }
      );
    } else {
      await db.collection('Categories').updateOne(
        { _id: new ObjectId(oldCategoryId) },
        { $inc: { budgetSpent: -oldAmount } }
      );

      await db.collection('Categories').updateOne(
        { _id: new ObjectId(categoryId) },
        { $inc: { budgetSpent: amount } }
      );
    }

    await db.collection('Transactions').updateOne(
      { _id: new ObjectId(id) },
      {
        $set: {
          categoryId: new ObjectId(categoryId),
          amount,
          date,
          note
        }
      }
    );

    res.status(200).json({ error: '' });

  } catch (e) {
    res.status(500).json({ error: e.toString() });
  }
};

// DELETE
exports.deleteTransaction = async (req, res) => {
  const { id } = req.params;
  const db = client.db('BudgetTracker');

  try {
    const transaction = await db.collection('Transactions')
      .findOne({ _id: new ObjectId(id) });

    if (!transaction) {
      return res.status(404).json({ error: 'Not found' });
    }

    await db.collection('Categories').updateOne(
      { _id: new ObjectId(transaction.categoryId) },
      { $inc: { budgetSpent: -transaction.amount } }
    );

    await db.collection('Transactions')
      .deleteOne({ _id: new ObjectId(id) });

    res.status(200).json({ error: '' });

  } catch (e) {
    res.status(500).json({ error: e.toString() });
  }
};

// RECENT
exports.getRecentTransactions = async (req, res) => {
  const { userId } = req.query;
  const db = client.db('BudgetTracker');

  try {
    const transactions = await db.collection('Transactions')
      .find({ userId: new ObjectId(userId) })
      .sort({ date: -1 })
      .limit(5)
      .toArray();

    res.status(200).json({ transactions, error: '' });
  } catch (e) {
    res.status(500).json({ transactions: [], error: e.toString() });
  }
};
