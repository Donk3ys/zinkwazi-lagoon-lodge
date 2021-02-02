const jwt = require('jsonwebtoken');

const ERROR_ACCESS_DENIED = '401 - Access Denied!';
const ERROR_INVALID_TOKEN = '400 - Invalid token';

module.exports = function (req, res, next) {
	// Check for token in header
	const token = req.header('auth-token');
	if (!token) { return res.status(401).send(ERROR_ACCESS_DENIED); }

	try {
		// token created from {id: user.id}
		const hashToken = jwt.verify(token, process.env.JWT_SECERET);
		req.jwt = hashToken; // {id, created, expires}
		next();

	} catch(e) {
		return res.status(400).send(ERROR_INVALID_TOKEN);
	}
}
