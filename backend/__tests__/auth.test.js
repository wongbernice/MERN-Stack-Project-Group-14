const request = require('supertest');
const { ObjectId } = require('mongodb');
const bcrypt = require('bcryptjs');

jest.mock('../db', () => ({
    client: {
        db: jest.fn()
    }
}));

jest.mock('bcryptjs', () => ({
    compare: jest.fn(),
    hash: jest.fn().mockResolvedValue('hashedPassword')
}));

jest.mock('resend', () => {
    return {
        Resend: jest.fn().mockImplementation(() => ({
            emails: {
                send: jest.fn().mockResolvedValue({ data: {}, error: null })
            }
        }))
    };
});

jest.mock('../routes/transactionRoutes', () => {
    const express = require('express');
    return express.Router();
});

jest.mock('../routes/categoryRoutes', () => {
    const express = require('express');
    return express.Router();
});

const { client } = require('../db');
const app = require('../server');

describe('Auth API routes', () => {
    let mockDb;
    let mockUsersCollection;

    const userId = new ObjectId().toString();

    beforeEach(() => {
        mockUsersCollection = {
            findOne: jest.fn(),
            insertOne: jest.fn(),
            updateOne: jest.fn(),
        };

        mockDb = {
            collection: jest.fn((name) => {
                if (name === 'Users') return mockUsersCollection;
                return null;
            })
        };

        client.db.mockReturnValue(mockDb);
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    //-----------------------------------------------------------------------------------------------//

    test('POST /api/auth/register creates a new user', async () => {
        mockUsersCollection.findOne.mockResolvedValue(null);

        mockUsersCollection.insertOne.mockResolvedValue({
            insertedId: new ObjectId()
        });

        const payload = {
            First: 'Test',
            Last: 'User',
            email: 'testuser@example.com',
            password: 'password123'
        };

        const res = await request(app)
            .post('/api/auth/register')
            .send(payload);

        expect(res.statusCode).toBe(201);
        expect(res.body.error).toBe('');
        expect(res.body.token).toBeDefined();
        expect(mockUsersCollection.findOne).toHaveBeenCalled();
        expect(mockUsersCollection.insertOne).toHaveBeenCalled();
    });

    //-----------------------------------------------------------------------------------------------//

    test('POST /api/auth/login logs in a user (verified)', async () => {
        mockUsersCollection.findOne.mockResolvedValue({
            _id: new ObjectId(userId),
            First: 'Test',
            Last: 'User',
            email: 'testuser@example.com',
            password: 'hashedPassword',
            isVerified: true
        });

        bcrypt.compare.mockResolvedValue(true);

        const payload = {
            email: 'testuser@example.com',
            password: 'password123'
        };

        const res = await request(app)
            .post('/api/auth/login')
            .send(payload);

        expect(res.statusCode).toBe(200);
        expect(res.body.isVerified).toBe(true);
        expect(res.body.error).toBe('');
        expect(res.body.token).toBeDefined();
        expect(mockUsersCollection.findOne).toHaveBeenCalled();
        expect(bcrypt.compare).toHaveBeenCalled();
    });

    //-----------------------------------------------------------------------------------------------//

    test('POST /api/auth/login returns error when logging in a user (unverified)', async () => {
        mockUsersCollection.findOne.mockResolvedValue({
            _id: new ObjectId(userId),
            First: 'Test',
            Last: 'User',
            email: 'testuser@example.com',
            password: 'hashedPassword',
            isVerified: false
        });

        bcrypt.compare.mockResolvedValue(true);

        const payload = {
            email: 'testuser@example.com',
            password: 'password123'
        };

        const res = await request(app)
            .post('/api/auth/login')
            .send(payload);

        expect(res.statusCode).toBe(200);
        expect(res.body.isVerified).toBe(false);
        expect(res.body.error).toBe('Needs Verification');
        expect(res.body.token).toBeUndefined();
        expect(mockUsersCollection.findOne).toHaveBeenCalled();
        expect(bcrypt.compare).toHaveBeenCalled();
    });

    //-----------------------------------------------------------------------------------------------//

    test('POST /api/auth/verify verifies a user has valid verification code', async () => {
        mockUsersCollection.findOne.mockResolvedValue({
            _id: new ObjectId(userId),
            First: 'Test',
            Last: 'User',
            email: 'testuser@example.com',
            verificationCode: '123456',
            verificationCodeExpires: new Date(Date.now() + 15 * 60 * 1000)
        });
        
        mockUsersCollection.updateOne.mockResolvedValue({ modifiedCount: 1 });
        
        const payload = {
            email: 'testuser@example.com',
            code: '123456'
        };
        
        const res = await request(app)
            .post('/api/auth/verify')
            .send(payload);
        
        expect(res.statusCode).toBe(200);
        expect(res.body.error).toBe('');
        expect(res.body.token).toBeDefined();
        expect(mockUsersCollection.updateOne).toHaveBeenCalled();
        expect(mockUsersCollection.findOne).toHaveBeenCalled();
    });

    //-----------------------------------------------------------------------------------------------//

    test('POST /api/auth/resendverification sends new verification email', async () => {
        mockUsersCollection.findOne.mockResolvedValue({
            _id: new ObjectId(userId),
            email: 'testuser@example.com'
        });

        mockUsersCollection.updateOne.mockResolvedValue({ modifiedCount: 1 });

        const res = await request(app)
            .post('/api/auth/resendverification')
            .send({email: 'testuser@example.com'});

        expect(res.statusCode).toBe(201);
        expect(res.body.error).toBe('');
        expect(res.body.token).toBeDefined();
        expect(mockUsersCollection.updateOne).toHaveBeenCalled();
        expect(mockUsersCollection.findOne).toHaveBeenCalled();
    });

    //-----------------------------------------------------------------------------------------------//

    test('POST /api/auth/resetpassword sends a reset password code to user email', async () => {
        mockUsersCollection.findOne.mockResolvedValue({
            _id: new ObjectId(userId),
            email: 'testuser@example.com',
        });

        mockUsersCollection.updateOne.mockResolvedValue({ modifiedCount: 1 });

        const res = await request(app)
            .post('/api/auth/resetpassword')
            .send({ email: 'testuser@example.com' });

        expect(res.statusCode).toBe(200);
        expect(res.body.error).toBe('');
        expect(res.body.message).toContain('Reset code sent');
        expect(mockUsersCollection.updateOne).toHaveBeenCalled();
        expect(mockUsersCollection.findOne).toHaveBeenCalled();
    });

    //-----------------------------------------------------------------------------------------------//

    test('POST /api/auth/verifyreset sets a new password', async () => {
        mockUsersCollection.findOne.mockResolvedValue({
        _id: new ObjectId(userId),
        email: 'testuser@example.com',
        resetCode: '123456',
        resetCodeExpires: new Date(Date.now() + 15 * 60 * 1000) // 15 mins in future
        });

        mockUsersCollection.updateOne.mockResolvedValue({ modifiedCount: 1 });

        const res = await request(app)
        .post('/api/auth/verifyreset')
        .send({ 
            email: 'testuser@example.com', 
            code: '123456', 
            password: 'newPassword123' 
        });

        expect(res.statusCode).toBe(200);
        expect(res.body.error).toBe('');
        expect(res.body.token).toBeDefined();
        expect(res.body.message).toContain('successfully reset');
        expect(mockUsersCollection.updateOne).toHaveBeenCalled();
        expect(bcrypt.hash).toHaveBeenCalled();
    });
});