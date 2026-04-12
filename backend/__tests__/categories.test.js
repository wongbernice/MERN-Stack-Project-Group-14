const request = require('supertest');
const { ObjectId } = require('mongodb');

jest.mock('../db', () => ({
  client: {
    db: jest.fn()
  }
}));

jest.mock('../middleware/authMiddleware', () => {
  return (req, res, next) => {
    const { ObjectId } = require('mongodb');
    req.user = { id: new ObjectId().toString() };
    next();
  };
});

jest.mock('../routes/authRoutes', () => {
  const express = require('express');
  return express.Router();
});

const { client } = require('../db');
const app = require('../server');

describe('Categories API routes', () => {
  let mockDb;
  let mockTransactionsCollection;
  let mockCategoriesCollection;

  const categoryId = new ObjectId().toString();

  beforeEach(() => {
    mockCategoriesCollection = {
      find: jest.fn(),
      findOne: jest.fn(),
      insertOne: jest.fn(),
      updateOne: jest.fn(),
      deleteOne: jest.fn()
    };

    mockTransactionsCollection = {
      deleteMany: jest.fn()
    };

    mockDb = {
      collection: jest.fn((name) => {
        if (name === 'Categories') return mockCategoriesCollection;
        if (name === 'Transactions') return mockTransactionsCollection;
        return null;
      })
    };

    client.db.mockReturnValue(mockDb);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  test('GET /api/categories returns all categories for a user', async () => {
    const fakeCategories = [
      { _id: new ObjectId(), name: 'Groceries', budgetLimit: 200 },
      { _id: new ObjectId(), name: 'Entertainment', budgetLimit: 500 }
    ];

    const toArray = jest.fn().mockResolvedValue(fakeCategories);
    mockCategoriesCollection.find.mockReturnValue({ toArray });

    const res = await request(app).get('/api/categories');

    expect(res.statusCode).toBe(200);
    expect(res.body.categories).toEqual([
      {
        _id: fakeCategories[0]._id.toString(),
        name: 'Groceries',
        budgetLimit: 200
      },
      {
        _id: fakeCategories[1]._id.toString(),
        name: 'Entertainment',
        budgetLimit: 500
      }
    ]);
    expect(res.body.error).toBe('');
  });

  test('POST /api/categories creates a category', async () => {
    mockCategoriesCollection.findOne.mockResolvedValue(null);
    mockCategoriesCollection.insertOne.mockResolvedValue({
      insertedId: new ObjectId()
    });

    const payload = {
      name: 'Bills',
      budgetLimit: 200
    };

    const res = await request(app)
      .post('/api/categories')
      .send(payload);

    expect(res.statusCode).toBe(201);
    expect(res.body.error).toBe('');
    expect(mockCategoriesCollection.findOne).toHaveBeenCalled();
    expect(mockCategoriesCollection.insertOne).toHaveBeenCalled();
  });

  test('PUT /api/categories/:id updates a category', async () => {
    mockCategoriesCollection.updateOne.mockResolvedValue({ matchedCount: 1 });

    const payload = {
      name: 'Revised Bills',
      budgetLimit: 1200
    };

    const res = await request(app)
      .put(`/api/categories/${categoryId}`)
      .send(payload);

    expect(res.statusCode).toBe(200);
    expect(res.body.error).toBe('');
    expect(mockCategoriesCollection.updateOne).toHaveBeenCalled();
  });

  test('DELETE /api/categories/:id deletes a category', async () => {
    mockCategoriesCollection.deleteOne.mockResolvedValue({ deletedCount: 1 });

    const res = await request(app).delete(`/api/categories/${categoryId}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.error).toBe('');
    expect(mockCategoriesCollection.deleteOne).toHaveBeenCalled();
  });

  test('PUT /api/categories/:id/reset resets a category', async () => {
    mockCategoriesCollection.findOne.mockResolvedValue({
      _id: new ObjectId(categoryId),
      name: 'Bills',
      budgetLimit: 200,
      budgetSpent: 75
    });

    mockTransactionsCollection.deleteMany.mockResolvedValue({ deletedCount: 3 });
    mockCategoriesCollection.updateOne.mockResolvedValue({ modifiedCount: 1 });

    const res = await request(app).put(`/api/categories/${categoryId}/reset`);

    expect(res.statusCode).toBe(200);
    expect(res.body.error).toBe('');
    expect(mockCategoriesCollection.findOne).toHaveBeenCalled();
    expect(mockTransactionsCollection.deleteMany).toHaveBeenCalled();
    expect(mockCategoriesCollection.updateOne).toHaveBeenCalled();
  });
});