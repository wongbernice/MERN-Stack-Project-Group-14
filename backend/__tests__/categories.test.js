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

describe('Categories API Routes', () => {
    let mockDb;
    let mockTransactionsCollection;
    let mockCategoriesCollection;

    const userId = new ObjectId().toString();
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
            findOne: jest.fn(),
            updateOne: jest.fn(),
            deleteOne: jest.fn(),
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

    test('GET /api/categories returns all categories for a user', async () => {
        const fakeCategories = [
            { _id: new ObjectId(), name: 'Groceries', budgetLimit: 200 },
            { _id: new ObjectId(), name: 'Entertainment', budgetLimit: 500 }
        ];

        const toArray = jest.fn().mockResolvedValue(fakeCategories);
        mockCategoriesCollection.find.mockReturnValue({ toArray });

        const res = await request(app).get(`/api/categories?userId=${userId}`);

        expect(res.statusCode).toBe(200);
        expect(res.body.categories).toEqual([
            { _id: fakeCategories[0]._id.toString(), name: 'Groceries', budgetLimit: 200 },
            { _id: fakeCategories[1]._id.toString(), name: 'Entertainment', budgetLimit: 500 }
        ]);
        expect(res.body.error).toBe('');
    });

    test('GET /api/categories/:id returns one category', async () => {
        const fakeCategory = { _id: categoryId,  };
        mockCategoriesCollection.findOne.mockResolvedValue(fakeCategory);

        const res = await request(app).get(`/api/categories/${categoryId}`);

        expect(res.statusCode).toBe(200);
        expect(res.body.category._id).toBe(categoryId);
    });

    test('POST /api/categories creates a category', async () => {
        mockCategoriesCollection.insertOne.mockResolvedValue({
            insertedId: new ObjectId()
        });

        const payload = {
            userId,
            name: 'Bills',
            budgetLimit: 200,
            budgetPeriod: 'monthly',
            budgetSpend: 0
        };

        const res = await request(app)
            .post('/api/categories')
            .send(payload);

        expect(res.statusCode).toBe(201);
        expect(mockCategoriesCollection.insertOne).toHaveBeenCalled();
    });

    test('PUT /api/categories/:id updates a category', async () => {
        mockCategoriesCollection.findOne.mockResolvedValue({ modifiedCount: 1});

        const payload = {
            name: 'Revised Bills',
            budgetLimit: 1200
        };

        const res = await request(app)
            .put(`/api/categories/${categoryId}`)
            .send(payload);

        expect(res.statusCode).toBe(200);
        expect(mockCategoriesCollection.updateOne).toHaveBeenCalled();
    });

    test('DELETE /api/categories/:id deletes a category', async () => {
        mockCategoriesCollection.findOne.mockResolvedValue({ deleteCount: 1 });

        const res = await request(app).delete(`/api/categories/${categoryId}`);

        expect(res.statusCode).toBe(200);
        expect(mockCategoriesCollection.updateOne).toHaveBeenCalled();
    });
});