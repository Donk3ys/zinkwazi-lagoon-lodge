const router = require('express').Router();
const bcrypt = require('bcryptjs');

// Json Web Token
const jwt = require('jsonwebtoken');
const veryify = require('../services/verify_token');

// Datatbase instance
const db = require('../services/db').getDb();

// Validators
const registerValidation = require('../services/validation').registerValidation;
const loginValidation = require('../services/validation').loginValidation;

// Consts
const JWT_DURATION = process.env.JWT_ACCESS_TIME;
const ERROR_USERNAME_ALREADY_USED = 'Username has already been used';
const ERROR_USERNAME_OR_PASSWORD = 'Username or password are incorrect';
const ERROR_USER_NOT_FOUND = 'User not found!';
const ERROR_USER_HIDDEN = 'User account deactivated';


// ROUTES

// Register User
router.post('/register', veryify, async (req, res) => {
	// Validate request fields correct
	const { error } = registerValidation(req.body);
	if (error) { return res.status(400).send(error.details[0].message); }

	try {
		// Fetch user from db
		const user = (await db.query(`SELECT role FROM users WHERE  id='${req.jwt.id}'`)).rows[0];
		// Check if user exists
		if (!user) { return res.status(400).send(ERROR_USER_NOT_FOUND); }


		// Check new user role can be made
		let roleCorrect = false;
		if (user.role == "super") { roleCorrect = true; }
		else if (user.role == "admin" && req.body.role == "kitchen") { roleCorrect = true; }
		if (!roleCorrect) { return res.status(400).send("Auth level cannot create user of selected role"); }

		// Check if username already exists
		const foundUser = (await db.query(`SELECT username FROM users WHERE username='${req.body.username}'`)).rows[0];
		if (foundUser) { return res.status(400).send(ERROR_USERNAME_ALREADY_USED); }

		// Hash password
		const salt = await bcrypt.genSalt(12);
		const hashedPassword = await bcrypt.hash(req.body.password, salt);

		// Set timestamp
		const timeNow = new Date().toISOString();

		// Insert user into database
		const newUser  =
				(await	db.query("INSERT INTO users(username, email, password, role, updated_at, created_at) VALUES($1, $2, $3, $4, $5, $6) RETURNING *",
			[req.body.username, req.body.email , hashedPassword, req.body.role, timeNow, timeNow]
		)).rows[0];

		// Check user response for failure
		if (!newUser) { return res.status(500).send("User insert into db error"); }

		// Remove password from user
		delete newUser.password;

		// Create token
		const token = jwt.sign(
			{ id: user.id },
			process.env.JWT_SECERET,
			{ expiresIn: JWT_DURATION }
		);

		// Add token to header
		res.header('auth-token', token);

		console.log(`${newUser.username}: created successfully`);
		return res.send(newUser);

	} catch (e) {
		console.warn('[ERROR]: /register user could not register');
		console.warn(e);
		return res.status(500).send('Server error!');
	}
});


// Login User {username, password}
router.post('/login', async (req, res) => {
	console.log(`${req.body.username}: login attempt`);

	// Validate request fields correct
	const { error } = loginValidation(req.body);
	if (error) { return res.status(400).send(error.details[0].message); }

	try {
		// Check if username already used or user is hidden
		const foundUser = (await db.query(`SELECT * FROM users WHERE username='${req.body.username}'`)).rows[0];
		//console.log(foundUser);
		if (!foundUser) { return res.status(400).send(ERROR_USERNAME_OR_PASSWORD); }
		if (!foundUser.active) { return res.status(400).send(ERROR_USER_HIDDEN); }

		// Check password match
		console.log(req.body.password);
		if (! await bcrypt.compare(req.body.password, foundUser.password)) { return res.status(400).send(ERROR_USERNAME_OR_PASSWORD); }

		// Remove password from user
		delete foundUser.password;

		// Create token
		const token = jwt.sign(
			{ id: foundUser.id },
			process.env.JWT_SECERET,
			{ expiresIn: JWT_DURATION }
		);

		// Add token to header
		res.header('auth-token', token);
		foundUser.authToken = token;

		console.log(`${foundUser.username}: login success`);
		return res.send(foundUser);

	} catch (e) {
		console.warn('[ERROR]: /login user could not login');
		console.warn(e);
		return res.status(500).send('Server error!');
	}
});


// Get all user with auth-token
router.get('/users/:role', veryify, async (req, res) => {
	try {
		// Fetch user from db
		const user = (await db.query(`SELECT role FROM users WHERE  id='${req.jwt.id}'`)).rows[0];
		// Check if user exists
		if (!user) { return res.status(400).send(ERROR_USER_NOT_FOUND); }


		// Fetch users from db
		let foundUsers = [];
		if (user.role == "super") {
			foundUsers = (await db.query(`SELECT * FROM users`)).rows;
		} else if (user.role == "admin") {
			foundUsers = (await db.query(`SELECT * FROM users WHERE role='kitchen'`)).rows;
		}
		// Check if user exists
		if (!foundUsers) { return res.status(400).send(ERROR_USER_NOT_FOUND); }

		// Create token
		const token = jwt.sign(
			{ id: req.header("auth-token") },
			process.env.JWT_SECERET,
			{ expiresIn: JWT_DURATION }
		);

		// Remove passwords from user
		for (var tempUser of foundUsers) {
			delete tempUser.password;
		}

		// Add token to header
		res.header('auth-token', token);

		return res.send(foundUsers);

	} catch(e) {
		console.warn('[ERROR] /users could not get user with auth-token');
		console.warn(e);
		return res.status(500).send('Server error!');
	};
});


// Activate / Deactivate user
router.patch('/user/activate/:id/:activate', veryify, async (req, res) => {
	// Set database updated timestamp
	let timestamp = new Date().toISOString();

	try {
		// SQL Query > Update item by id
		const user = (await	db.query(
			'UPDATE users ' +
			`SET active=${req.params.activate}, updated_at='${timestamp}' ` +
			//`SET active=${req.params.activate} ` +
			`WHERE id=${req.params.id} ` +
			'RETURNING *;'
		)).rows[0];

		// Check if item returned
		if (!user) {
			console.log(`Error user update: ${req.body.username} @ ${timestamp}`);
			return res.status(500).send('Error Updating user');
		}

		// Remove password from user
		delete user.password;

		console.log(`User activate: id:${req.params.id} : ${req.params.activate} @ ${timestamp}`);
		return res.send(user);
	} catch(error) {
		console.log(error);
		return res.status(500).send(error);
	}
});


// Update User Password
router.patch('/user/newpassword', veryify, async (req, res) => {
	// Set database updated timestamp
	let timestamp = new Date().toISOString();

	// Validate new password >= 6 character length
	if (req.body.newPassword < 6) { return res.status(400).send("New Password Length < 6"); }

	try {
		// Fetch user from db
		const adminUser = (await db.query(`SELECT role FROM users WHERE  id='${req.jwt.id}'`)).rows[0];
		// Check if user exists
		if (!adminUser) { return res.status(400).send(ERROR_USER_NOT_FOUND); }

		// Fetch user from db
		const updateUser = (await db.query(`SELECT role FROM users WHERE  id='${req.body.userId}'`)).rows[0];
		// Check if user exists
		if (!updateUser) { return res.status(400).send(ERROR_USER_NOT_FOUND); }

		// Check user role can make changes to user
		let roleCorrect = false;
		if (adminUser.role == "super") { roleCorrect = true; }
		else if (adminUser.role == "admin" && (updateUser == "admin" || updateUser == "kitchen")) { roleCorrect = true; }
		if (!roleCorrect) { return res.status(400).send("Auth level cannot update user of selected role"); }

		// Hash password
		const salt = await bcrypt.genSalt(12);
		const hashedPassword = await bcrypt.hash(req.body.newPassword, salt);

		// SQL Query > Update item by id
		const updatedUser = (await	db.query(
			'UPDATE users ' +
			`SET password='${hashedPassword}', updated_at='${timestamp}' ` +
			`WHERE id=${req.body.userId} ` +
			'RETURNING username;'
		)).rows[0];

		// Check user response for failure
		if (!updatedUser) { return res.status(500).send("User password update db error"); }

		// Create token
		const token = jwt.sign(
			{ id: adminUser.id },
			process.env.JWT_SECERET,
			{ expiresIn: JWT_DURATION }
		);

		// Add token to header
		res.header('auth-token', token);

		console.log(`${updatedUser.username}: password update successful`);
		return res.send(updatedUser);

	} catch (e) {
		console.warn('[ERROR]: /user/newpassword user could not update password');
		console.warn(e);
		return res.status(500).send('Server error!');
	}
});

module.exports = router;

// Get User From Email
//router.post('/user/email', veryify, async (req, res) => {
//	try {
//		// TODO validate email is an actual email address
//
//		// Fetch user from db
//		const foundUser = await db.collection(USER_COLLECTION).findOne({ email: req.body.email }, { projection: { password: 0 } });
//
//		// Check if user exists
//		if (!foundUser) { return res.status(400).send(ERROR_USER_NOT_FOUND); }
//
//		// Reformat _id to id from user
//		foundUser.id = foundUser._id;
//		delete foundUser._id
//
//		// Create token from user who sent request
//		const token = jwt.sign(
//			{ id: req.jwt.id },
//			process.env.JWT_SECERET,
//			{ expiresIn: JWT_DURATION }
//		);
//
//		// Add token to header
//		res.header('auth-token', token);
//		return res.send(foundUser);
//
//	} catch(e) {
//		console.warn('[ERROR] /user could not get user with email');
//		console.warn(e);
//		return res.status(500).send('Server error!');
//	};
//});

// Get User From Id
//router.get('/user/:id', veryify, async (req, res) => {
//	try {
//
//		// Fetch user from db
//		const foundUser = (await db.query(`SELECT * FROM users WHERE  id='${req.params.id}'`)).rows[0];
//
//		// Check if user exists
//		if (!foundUser) { return res.status(400).send(ERROR_USER_NOT_FOUND); }
//
//
//		// Create token from user who sent request
//		const token = jwt.sign(
//			{ id: req.jwt.id },
//			process.env.JWT_SECERET,
//			{ expiresIn: JWT_DURATION }
//		);
//
//		// Remove password from user
//		delete foundUser.password;
//
//		// Add token to header
//		res.header('auth-token', token);
//		return res.send(foundUser);
//
//	} catch(e) {
//		console.warn('[ERROR] /user could not get user with id');
//		console.warn(e);
//		return res.status(500).send('Server error!');
//	};
//});
