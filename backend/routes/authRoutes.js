const express = require('express');
const router = express.Router();
const { registerUser, loginUser, verifyCode, resetPassword, verifyReset, resendVerification } = require('../controllers/authController');

router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/verify', verifyCode);
router.post('/resetpassword', resetPassword);
router.post('/verifyreset', verifyReset);
router.post('/resendverification', resendVerification);

module.exports = router;