const router = require('express').Router();

// Auth
const veryify = require('../services/verify_token');

// Data
const db = require('../services/db').getDb();
const cache = require('../services/cache').getCache();


// Menu Item Types

// Add menu item type
router.post('/item/type', veryify, async (req, res) => {
	try {
		// SQL Query > Insert Data
		await	db.query("INSERT INTO types(type) VALUES($1)",
			[req.body.type]
		);

		// Set database updated timestamp
		let timestamp = new Date().toISOString();
		await cache.set("db_updated_timestamp", timestamp);

		console.log(`Type Added: ${req.body.type} @ ${timestamp}`);
		return res.send('Type Added');
	} catch(error) {
		return res.status(500).send(error);
	}
});


// Get all menu item types
//router.get('/item/types', async (_, res) => {
//	try {
		// SQL Query > Get all items
//		const types = await	db.query('SELECT * FROM types');

//		console.log('Fetched all menu item types');

//		return res.send(types.rows);
//	} catch(error) {
//		return res.status(500).send(error);
//	}
// });

module.exports = router;
