const express = require('express');
const router = express.Router();
const { registerUser, loginUser, verifyCode, resetPassword, verifyReset} = require('../controllers/authController');

router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/verify', verifyCode);
router.post('/resetpassword', resetPassword);
router.post('/verifyreset', verifyReset);

module.exports = router;