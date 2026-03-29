const express = require('express');
const router = express.Router();
const { createCategory, getCategories, updateCategory, deleteCategory, resetCategory } = require('../controllers/categoryController');

router.post('/', createCategory);
router.get('/:userId', getCategories);
router.put('/:id', updateCategory);
router.delete('/:id', deleteCategory);
router.put('/:id/reset', resetCategory);

module.exports = router;