require('dotenv').config();
const jwt = require('jsonwebtoken');

const protect = async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Not authorized, no token' });
  }
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = { id: decoded.id };
    next();
  } catch(e) {
    res.status(401).json({ error: 'Token invalid' });
  }
};

module.exports = protect;