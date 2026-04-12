const request = require('supertest');
const { ObjectId } = require('mongodb');

jest.mock('../db', () => ({
  client: {
    db: jest.fn()
  }
}));

jest.mock('../routes/authRoutes', () => {
  const express = require('express');
  return express.Router();
});

jest.mock('../routes/categoryRoutes', () => {
  const express = require('express');
  return express.Router();
});

const { client } = require('../db');
const app = require('../server');

describe('Transaction API routes', () => {
  let mockDb;
  let mockTransactionsCollection;
  let mockCategoriesCollection;

  const userId = new ObjectId().toString();
  const categoryId = new ObjectId().toString();
  const transactionId = new ObjectId().toString();

  beforeEach(() => {
    mockTransactionsCollection = {
      find: jest.fn(),
      findOne: jest.fn(),
      insertOne: jest.fn(),
      updateOne: jest.fn(),
      deleteOne: jest.fn()
    };

    mockCategoriesCollection = {
      updateOne: jest.fn()
    };

    mockDb = {
      collection: jest.fn((name) => {
        if (name === 'Transactions') return mockTransactionsCollection;
        if (name === 'Categories') return mockCategoriesCollection;
        return null;
      })
    };

    client.db.mockReturnValue(mockDb);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  test('GET /api/transactions returns all transactions for a user', async () => {
    const fakeTransactions = [
      { _id: new ObjectId(), amount: 20, note: 'Lunch' },
      { _id: new ObjectId(), amount: 50, note: 'Gas' }
    ];

    const toArray = jest.fn().mockResolvedValue(fakeTransactions);
    mockTransactionsCollection.find.mockReturnValue({ toArray });

    const res = await request(app).get(`/api/transactions?userId=${userId}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.transactions).toEqual([
      { _id: fakeTransactions[0]._id.toString(), amount: 20, note: 'Lunch' },
      { _id: fakeTransactions[1]._id.toString(), amount: 50, note: 'Gas' }
    ]);
    expect(res.body.error).toBe('');
  });

  test('GET /api/transactions/recent returns recent transactions', async () => {
    const fakeTransactions = [
      { _id: new ObjectId(), amount: 70, note: 'Groceries' }
    ];

    const toArray = jest.fn().mockResolvedValue(fakeTransactions);
    const limit = jest.fn().mockReturnValue({ toArray });
    const sort = jest.fn().mockReturnValue({ limit });

    mockTransactionsCollection.find.mockReturnValue({ sort });

    const res = await request(app).get(`/api/transactions/recent?userId=${userId}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.transactions).toEqual([
      { _id: fakeTransactions[0]._id.toString(), amount: 70, note: 'Groceries' }
    ]);
    expect(res.body.error).toBe('');
    expect(sort).toHaveBeenCalledWith({ date: -1 });
    expect(limit).toHaveBeenCalledWith(5);
  });

  test('GET /api/transactions/:id returns one transaction', async () => {
    const fakeTransaction = { _id: transactionId, amount: 40, note: 'Coffee' };
    mockTransactionsCollection.findOne.mockResolvedValue(fakeTransaction);

    const res = await request(app).get(`/api/transactions/${transactionId}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.transaction).toEqual(fakeTransaction);
    expect(res.body.error).toBe('');
  });

  test('POST /api/transactions creates a transaction', async () => {
    mockTransactionsCollection.insertOne.mockResolvedValue({
      insertedId: new ObjectId()
    });
    mockCategoriesCollection.updateOne.mockResolvedValue({ modifiedCount: 1 });

    const payload = {
      userId,
      categoryId,
      amount: 25,
      date: '2026-04-12',
      note: 'Snacks'
    };

    const res = await request(app)
      .post('/api/transactions')
      .send(payload);

    expect(res.statusCode).toBe(201);
    expect(res.body.error).toBe('');
    expect(mockTransactionsCollection.insertOne).toHaveBeenCalled();
    expect(mockCategoriesCollection.updateOne).toHaveBeenCalled();
  });

  test('PUT /api/transactions/:id updates a transaction in same category', async () => {
    mockTransactionsCollection.findOne.mockResolvedValue({
      _id: new ObjectId(transactionId),
      categoryId: new ObjectId(categoryId),
      amount: 20
    });

    mockCategoriesCollection.updateOne.mockResolvedValue({ modifiedCount: 1 });
    mockTransactionsCollection.updateOne.mockResolvedValue({ modifiedCount: 1 });

    const payload = {
      categoryId,
      amount: 35,
      date: '2026-04-12',
      note: 'Updated note'
    };

    const res = await request(app)
      .put(`/api/transactions/${transactionId}`)
      .send(payload);

    expect(res.statusCode).toBe(200);
    expect(res.body.error).toBe('');
    expect(mockCategoriesCollection.updateOne).toHaveBeenCalled();
    expect(mockTransactionsCollection.updateOne).toHaveBeenCalled();
  });

  test('DELETE /api/transactions/:id deletes a transaction', async () => {
    mockTransactionsCollection.findOne.mockResolvedValue({
      _id: new ObjectId(transactionId),
      categoryId: new ObjectId(categoryId),
      amount: 15
    });

    mockCategoriesCollection.updateOne.mockResolvedValue({ modifiedCount: 1 });
    mockTransactionsCollection.deleteOne.mockResolvedValue({ deletedCount: 1 });

    const res = await request(app).delete(`/api/transactions/${transactionId}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.error).toBe('');
    expect(mockCategoriesCollection.updateOne).toHaveBeenCalled();
    expect(mockTransactionsCollection.deleteOne).toHaveBeenCalled();
  });
});