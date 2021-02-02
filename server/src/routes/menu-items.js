const router = require('express').Router();
const md5 = require('md5');

// Auth
const veryify = require('../services/verify_token');

// Data
const db = require('../services/db').getDb();
const cache = require('../services/cache').getCache();


// Get timestamp last time item in db updated
router.get('/items/updated', async (_, res) => {
	try {
		let timestamp = await cache.get("db_updated_timestamp");

		// Check if timestam not null
		if (!timestamp) {
			timestamp = new Date().toISOString();
			await cache.set("db_updated_timestamp", timestamp);
		}

		console.log(`Checking item db updated: ${timestamp}`);
		return res.send({"db_updated": timestamp});
	} catch(error) {
		return res.status(500).send(error);
	}
});



// Menu Items

// Add menu item
router.post('/item', veryify, async (req, res) => {
	try {

		// Check if item type exists in database
		let type = await db.query(`SELECT id FROM types WHERE type = '${req.body.type}'`);

		// If type doesnt exist create new type
		if(type.rowCount == 0) {

			type = await db.query("INSERT INTO types(type) VALUES($1) RETURNING id",
				[req.body.type]
			);

			console.log(`Added new menu type: ${req.body.type}`);
		}

		// SQL Query > Insert Data
		await	db.query("INSERT INTO items(name, subheading, type, price, description) VALUES($1, $2, $3, $4, $5)",
			[req.body.name, req.body.subheading, type.rows[0].id, req.body.price, req.body.description]
		);

		// Set database updated timestamp
		let timestamp = new Date().toISOString();
		await cache.set("db_updated_timestamp", timestamp);

		console.log(`Item Added: ${req.body.name} @ ${timestamp}`);
		return res.sendStatus(200);
	} catch(error) {
		return res.status(500).send(error);
	}
});


// Update menu item
router.patch('/item/update', veryify, async (req, res) => {
	// Set database updated timestamp
	let timestamp = new Date().toISOString();

	try {
		// SQL Query > Update item by id
		const item = await	db.query(
			'UPDATE items ' +
			`SET name='${req.body.name}', subheading='${req.body.subheading}', price=${req.body.price}, description='${req.body.description}', updated_at=now() ` +
			`WHERE id = ${req.body.id} ` +
			'RETURNING *;'
		);

		// Check if item returned
		if (!item) {
			console.log(`Error item update: ${req.body.name} @ ${timestamp}`);
			return res.status(500).send('Error Updating item');
		}


		// Update item options
		for (option of req.body.options) {
			// Check if option exists
			if (option.id) {
				// Check if options set for delete
				if (option.delete) {
					// SQL Query > Delete option by id
					await	db.query(
						'DELETE FROM item_options ' +
						`WHERE id='${option.id}'`
					);

				} else {
					// Update
					await	db.query(
						'UPDATE item_options ' +
						`SET name='${option.name}', type='${option.type}' ` +
						`WHERE id = ${option.id};`
					);
				}
			} else {
				// Create New
				const newOption = await	db.query("INSERT INTO item_options(item_id, name, type) VALUES($1, $2, $3) RETURNING id",
					[req.body.id, option.name, option.type]
				);

				// Set id of option to new created option id
				option.id = newOption.rows[0].id;
			}
		}

		// Set response options
		item.rows[0].options = req.body.options.filter(option => !option.delete);

		// Set database updated timestamp
		await cache.set("db_updated_timestamp", timestamp);

		console.log(`Item updated: ${req.body.name} @ ${timestamp}`);
		return res.send(item.rows[0]);
	} catch(error) {
		return res.status(500).send(error);
	}
});


// Activate / Deactivate menu item
router.patch('/item/activate/:id/:activate', veryify, async (req, res) => {
	// Set database updated timestamp
	let timestamp = new Date().toISOString();

	try {
		// SQL Query > Update item by id
		const item = await	db.query(
			'UPDATE items ' +
			`SET active=${req.params.activate} ` +
			`WHERE id = ${req.params.id} ` +
			'RETURNING *;'
		);

		// Check if item returned
		if (!item) {
			console.log(`Error item update: ${req.body.name} @ ${timestamp}`);
			return res.status(500).send('Error Updating item');
		}

		// Set database updated timestamp
		await cache.set("db_updated_timestamp", timestamp);

		console.log(`Item activate: id:${req.params.id} : ${req.params.activate} @ ${timestamp}`);
		return res.send(item.rows[0]);
	} catch(error) {
		return res.status(500).send(error);
	}
});


// Get all menu items
router.get('/items', async (_, res) => {
	try {
		// SQL Query > Get all items
		const items = await	db.query(
			'SELECT items.id, items.name, items.subheading, types.type, items.price, items.description, items.active, items.updated_at ' +
			'FROM items ' +
			'INNER JOIN types ON items.type=types.id'
		);

		// Add item options to each item
		for (item of items.rows) {

			// SQL Query > Get options for selected item
			const options = await	db.query(
				'SELECT id, name, type ' +
				`FROM item_options ` +
				`WHERE item_id=${item.id}`
			);

			item.options = options.rows;
		}

		console.log('Fetched all menu items');
		return res.send(items.rows);
	} catch(error) {
		return res.status(500).send(error);
	}
});


// Get all active menu items
router.get('/items/active', async (_, res) => {
	try {
		// SQL Query > Get all items
		const items = await	db.query(
			'SELECT items.id, items.name, items.subheading, types.type, items.price, items.description, items.active, items.updated_at ' +
			'FROM items ' +
			'INNER JOIN types ON items.type=types.id ' +
			'WHERE items.active=TRUE'
		);

		// Add item options to each item
		for (item of items.rows) {

			// SQL Query > Get options for selected item
			const options = await	db.query(
				'SELECT id, name, type ' +
				`FROM item_options ` +
				`WHERE item_id=${item.id}`
			);

			item.options = options.rows;
		}

		console.log('Fetched all menu items');
		return res.send(items.rows);
	} catch(error) {
		return res.status(500).send(error);
	}
});


// DELETE item by id
router.delete('/item/:id', veryify, async (req, res) => {
	try {
		// SQL Query > Delete item by id
		const success = await	db.query(
			'DELETE FROM items ' +
			`WHERE id='${req.params.id}'`
		);

		// TODO DELETE ITEM OPTIONS

		if (success.rowCount != 1) { return res.sendStatus(500); }

		// Set database updated timestamp
		let timestamp = new Date().toISOString();
		await cache.set("db_updated_timestamp", timestamp);

		console.log('Deleted item successfully @ ' + timestamp);
		return res.sendStatus(200);
	} catch(error) {
		return res.status(500).send(error);
	}
});


module.exports = router;
