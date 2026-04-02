const express = require('express');
const router = express.Router();
const { registerUser, loginUser, verifyCode } = require('../controllers/authController');

router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/verify', verifyCode);

module.exports = router;