const express = require('express');
const router = express.Router();
const protect = require('../middleware/authMiddleware');
const { createCategory, getCategories, updateCategory, deleteCategory, resetCategory } = require('../controllers/categoryController');

router.post('/', protect, createCategory);
router.get('/', protect, getCategories);
router.put('/:id', protect, updateCategory);
router.delete('/:id', protect, deleteCategory);
router.put('/:id/reset', protect, resetCategory);

module.exports = router;