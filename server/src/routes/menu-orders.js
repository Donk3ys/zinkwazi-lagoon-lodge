const {verify} = require('jsonwebtoken');

const router = require('express').Router();

const db = require('../services/db').getDb();
const cache = require('../services/cache').getCache();

// Auth
const veryify = require('../services/verify_token');

// Loop sleep time to check for order status updates
const CACHE_LAST_ORDER = "last_order";
const CACHE_PAYMENT_IDS = "payment_ids";
const CACHE_ORDER_ID= "order_";

let dailyOrderNumber = 1;


// Set daily order number
async function setDailyOrderNumber() {
	let lastOrder;
	let lastOrderTimestamp;

	// Get last order from cache or database
	try {
		// Get last order from cache if fail then get form database
		lastOrder = JSON.parse(await cache.get(CACHE_LAST_ORDER));
		lastOrderTimestamp = new Date(lastOrder.createdAt);

	} catch (error) {
		try {
			console.log(`No daily or number in cache ${error}`);
			// SQL Query > Get last order
			lastOrderDb =	await db.query("SELECT number, created_at FROM orders ORDER BY created_at DESC LIMIT 1");
			lastOrder =	lastOrderDb.rows[0];
			lastOrderTimestamp = new Date(lastOrder.created_at);
		} catch (error) {
			console.log(`No daily or number in db ${error}`);
		}
	}

	try {
		const currentTimestamp = new Date();

		//console.log(lastOrderTimestamp);
		//console.log(currentTimestamp);

		if (lastOrderTimestamp.setHours(0,0,0,0) == currentTimestamp.setHours(0,0,0,0)) {
			dailyOrderNumber = 	lastOrder.number + 1;
			//console.log('Dates match');
		} else {
			dailyOrderNumber = 1;
			console.log('Resetting dailyOrderNumber...');
		}

	} catch (error) {
		console.log(`Daily order number set error: ${error}`);
	}
}


// Orders

// Create Order {payment_id, order}
router.post('/order/place', async (req, res) => {
	console.log("Create order with " + req.body.payment_id);

	// Get current timestamp
	const timestamp = new Date();

	// Set daily order number
	await setDailyOrderNumber();

	// Get paymentIds from cache
	let paymentIds = await cache.smembers(CACHE_PAYMENT_IDS);
	console.log("Payment IDs: " + paymentIds);

	// Check if payment id hasnt been used yet
	if (!paymentIds.includes(req.body.payment_id)) { res.status(500).send("payment id doesnt exist"); }

	try {
		// SQL Query > Insert Data into orders table
		const order =
				await	db.query("INSERT INTO orders(payment_id, number, price, created_at) VALUES($1, $2, $3, $4) RETURNING *",
			[req.body.payment_id, dailyOrderNumber, req.body.price, timestamp.toISOString()]
		);

		// Add items to order_item_links table
		if (order.rows) {
			for (item of req.body.items) {
				const orderItemLink =
						await db.query("INSERT INTO order_item_links(order_id, item_id) VALUES($1, $2) RETURNING id",
					[order.rows[0].id, item.item_id]
				);

				// Add options to item_option_to_order_item_links table
				for (optionId of item.option_ids) {
					await db.query("INSERT INTO item_option_to_order_item_links(order_item_link_id, item_option_id) VALUES($1, $2)",
						[orderItemLink.rows[0].id, optionId]
					);
				}
			}
		} else {
			return res.status(500).send('Error placing order');
		}

		// Remove payment id
		await cache.srem([CACHE_PAYMENT_IDS, req.body.payment_id]);
		paymentIds = await cache.smembers(CACHE_PAYMENT_IDS);

		// Save current order to last order placed for Daily Order Number
		await cache.set(CACHE_LAST_ORDER, JSON.stringify({ createdAt: timestamp, number : order.rows[0].number}));

		// Save current order to socket map
		await cache.set(`${CACHE_ORDER_ID}${order.rows[0].id}`, req.body.socket_id)
		console.log(`Added order to cache ${order.rows[0].id} ${req.body.socket_id}`);

		console.log(`Created order: ${dailyOrderNumber} ${timestamp}`);
		return res.send(order.rows[0]);
	} catch(error) {
		console.log(`Order Create Error: ${dailyOrderNumber} ${timestamp}`);
		return res.status(500).send(error);
	}
});


// Get all non delivered orders
router.get('/orders/current', veryify, async (_, res) => {
	console.log(`Checking current orders`);

	try {
		// SQL Query > Get all orders
		const orders = await	db.query('SELECT * FROM orders WHERE delivered=false');

		// Check if orders found
		if (orders.rowCount === 0) {
			//console.log(`No current orders found`);
			return res.send([]);
		}

		// Get items for each order
		for (order of orders.rows) {
			// Get items from order_item_link_tables
			// SQL Query > Get all item ids for requested order
			const itemIds = await	db.query(
				'SELECT id, item_id ' +
				`FROM order_item_links WHERE order_id=${order.id}`
			);

			let items = [];
			if (itemIds.rowCount != 0) {
				for (itemId of itemIds.rows) {
					// SQL Query > Get data for selected item
					const item = await	db.query(
						'SELECT items.id, items.name, types.type, items.subheading, items.price ' +
						`FROM items ` +
						'INNER JOIN types ON items.type=types.id ' +
						`WHERE items.id=${itemId.item_id}`
					);


					// Get all options for order
					// Get option ids
					const optionIds = await	db.query(
						'SELECT item_option_id ' +
						`FROM item_option_to_order_item_links WHERE order_item_link_id=${itemId.id}`
					);

					let options = [];
					if (optionIds.rowCount != 0) {
						// Get option data from option ids
						for (optionId of optionIds.rows) {
							const option = await	db.query(
								'SELECT id, name, type ' +
								`FROM item_options ` +
								`WHERE id=${optionId.item_option_id};`
							);

							// Add option to item option list
							options.push(option.rows[0]);
						}
					}

					// Add options to item
					item.rows[0].selectedOptions = options;

					// Add item to item_list
					items.push(item.rows[0]);
				}
			} else {
				return res.status(500).send('No items in order');
			}
			order.item_list = items;
		}

		console.log(`Sending current orders`);
		return res.send(orders.rows);
	} catch(error) {
		console.log(error);
		return res.status(500).send(error);
	}
});


// Get all orders between dates
router.post('/orders/dates', veryify, async (req, res) => {
	try {
		// SQL Query > Get all orders
		const orders = await	db.query(
			'SELECT * FROM orders ' +
				`WHERE created_at BETWEEN '${req.body.beginDate}'::timestamp AND '${req.body.endDate}'::timestamp`
		);

		// Check if orders found
		if (orders.rowCount === 0) {
			console.log(`No orders found between ${req.body.beginDate} & ${req.body.endDate}`);
			return res.send([]);
		}

		// Get items for each order
		for (order of orders.rows) {
			// Get items from order_item_link_tables
			// SQL Query > Get all item ids for requested order
			const itemIds = await	db.query(
				'SELECT id, item_id ' +
				`FROM order_item_links WHERE order_id=${order.id}`
			);

			let items = [];
			if (itemIds.rowCount != 0) {
				for (itemId of itemIds.rows) {
					// SQL Query > Get data for selected item
					const item = await	db.query(
						'SELECT items.id, items.name, types.type, items.subheading, items.price ' +
						`FROM items ` +
						'INNER JOIN types ON items.type=types.id ' +
						`WHERE items.id=${itemId.item_id}`
					);


					// Get all options for order
					// Get option ids
					const optionIds = await	db.query(
						'SELECT item_option_id ' +
						`FROM item_option_to_order_item_links WHERE order_item_link_id=${itemId.id}`
					);

					let options = [];
					if (optionIds.rowCount != 0) {
						// Get option data from option ids
						for (optionId of optionIds.rows) {
							const option = await	db.query(
								'SELECT id, name, type ' +
								`FROM item_options ` +
								`WHERE id=${optionId.item_option_id};`
							);

							// Add option to item option list
							options.push(option.rows[0]);
						}
					}

					// Add options to item
					item.rows[0].selectedOptions = options;

					// Add item to item_list
					items.push(item.rows[0]);
				}

			} else {
				return res.status(500).send('No items in order');
			}

			order.item_list = items;
		}

		console.log(`Fetched orders between ${req.body.beginDate} & ${req.body.endDate}`);
		return res.send(orders.rows);
	} catch(error) {
		return res.status(500).send(error);
	}
});


// Check if order prepared
router.get('/order/:id/prepared/:socketId', veryify, async (req, res) => {
	console.log("\nChecking order prepared status: id: " + req.params.id);

	try {
		if (req.params.socketId == null) { return res.status(500); }

		// Save current order to socket map
		await cache.set(`${CACHE_ORDER_ID}${req.params.id}`, req.params.socketId);
		console.log(`Updated order to socket ${req.params.id} ${req.params.socketId}`);

		// SQL Query > Get order delivered status
		const order = await	db.query(
			'SELECT prepared, prepared_at ' +
			'FROM orders ' +
			`WHERE id = ${req.params.id};`
		);

		//console.log("Checking order prepared " + req.params.id);
		return res.send(order.rows[0]);

	} catch(error) {
		console.log(error);
		return res.status(500).send(error);
	}
});


// Check if order delivered
router.get('/order/:id/delivered/:socketId', veryify, async (req, res) => {
	console.log("\nChecking order delivery status: id: " + req.params.id);

	try {
		if (req.params.socketId == null) { return res.status(500); }

		// Save current order to socket map
		await cache.set(`${CACHE_ORDER_ID}${req.params.id}`, req.params.socketId)
		console.log(`Updated order to socket ${req.params.id} ${req.params.socketId}`);

		// SQL Query > Get order delivered status
		const order = await	db.query(
			'SELECT prepared_at, delivered, delivered_at ' +
			'FROM orders ' +
			`WHERE id = ${req.params.id};`
		);

		if (order.rows[0].delivered) {
			// Delete current order to socket map
			await cache.del(`${CACHE_ORDER_ID}${req.params.id}`)
			console.log(`Delete order to socket ${req.params.id} ${req.params.socketId}`);
		} else {
			// Save current order to socket map
			await cache.set(`${CACHE_ORDER_ID}${req.params.id}`, req.params.socketId)
			console.log(`Updated order to socket ${req.params.id} ${req.params.socketId}`);
		}

		//console.log("Checked order deliverd " + req.params.id);
		return res.send(order.rows[0]);

	} catch(error) {
		console.log(error);
		return res.status(500).send(error);
	}
});


module.exports = router;

// Mark order as prepared
//router.post('/order/:id/prepared', async (req, res) => {
//	const timestamp = new Date().toISOString();
//
//	try {
//		// SQL Query > Update order prepared status
//		const order = await	db.query(
//			'UPDATE orders ' +
//			`SET prepared=true, prepared_at='${timestamp}'` +
//			`WHERE id = ${req.params.id} ` +
//			'RETURNING prepared, prepared_at;'
//		);
//
//		if (order.rows[0].prepared != true) {
//			console.log(`Error prepared order id: ${req.params.id}`);
//			return res.status(500).send('Errror order prepared');
//		}
//
//		// Mark order in cache to prepared
//		await cache.set(`${CACHE_CURRENT_ORDER}${req.params.id}`, JSON.stringify({prepared : true, delivered : false}))
//		//console.log(currentOrders);
//
//		// Save current order changed to cache
//		await cache.set(CACHE_CURRENT_ORDERS_CHANGED, JSON.stringify(true));
//
//		console.log(`Prepared order id: ${req.params.id}`);
//		return res.send(order.rows[0]);
//	} catch(error) {
//		return res.status(500).send(error);
//	}
//});
//
//
//// Mark order as delivered
//router.post('/order/:id/delivered', async (req, res) => {
//	const timestamp = new Date().toISOString();
//
//	try {
//		// SQL Query > Update order delivery status
//		const order = await	db.query(
//			'UPDATE orders ' +
//			`SET delivered=true, delivered_at='${timestamp}' ` +
//			`WHERE id = ${req.params.id} ` +
//			'RETURNING delivered, delivered_at;'
//		);
//
//		if (order.rows[0].delivered != true) {
//			console.log(`Error deliverd order id: ${req.params.id}`);
//			return res.status(500).send('Order not delivered');
//		}
//
//		// Mark order in cache to deliverd
//		await cache.set(`${CACHE_CURRENT_ORDER}${req.params.id}`, JSON.stringify({prepared : true, delivered : true}))
//		//console.log(currentOrders);
//
//		// Save current order changed to cache
//		await cache.set(CACHE_CURRENT_ORDERS_CHANGED, JSON.stringify(true));
//
//		console.log(`Deliverd order id: ${req.params.id}, ${order.rows[0].delivered_at}`);
//		return res.send(order.rows[0]);
//	} catch(error) {
//		return res.status(500).send(error);
//	}
//});
