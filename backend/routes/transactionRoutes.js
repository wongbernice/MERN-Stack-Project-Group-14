const express = require('express');
const router = express.Router();

const {
  getTransactions,
  getTransactionById,
  createTransaction,
  updateTransaction,
  deleteTransaction,
  getRecentTransactions
} = require('../controllers/transactionController');

// GET
router.get('/', getTransactions);

// RECENT
router.get('/recent', getRecentTransactions);

// GET BY ID
router.get('/:id', getTransactionById);

// CREATE
router.post('/', createTransaction);

// UPDATE
router.put('/:id', updateTransaction);

// DELETE
router.delete('/:id', deleteTransaction);

module.exports = router;
