// Get db & cache
const db = require('../services/db').getDb();
const cache = require('../services/cache').getCache();

// Auth
const jwt = require('jsonwebtoken');
const ERROR_INVALID_TOKEN = '400 - Invalid token';

const CACHE_LAST_ORDER = "last_order";
const CACHE_PAYMENT_IDS = "payment_ids";
const CACHE_ORDER_ID= "order_";


async function verify(token) {

	// Check for token in header
	if (!token) {
		return false; 
	}

	try {
		// token created from {id: user.id}
		jwt.verify(token, process.env.JWT_SECERET);
		//const hashToken = jwt.verify(token, process.env.JWT_SECERET);
		//req.jwt = hashToken; // {id, created, expires}
		return true;

	} catch(e) {
		return false;
	}
}


module.exports.runSocketIO = function runSocket(io) {
	// Client Connects
	io.on('connection', (client) => {
		// Send Connection Message
		console.log(`${client.id}: connected`);
		console.log(Object.keys(io.sockets.sockets));
		console.log("");

		// Connection closed
		client.on('disconnect', () => {
			client.disconnect();
			console.log(`${client.id} : disconnected -> ${client.disconnected}\n`);
			console.log(Object.keys(io.sockets.sockets));
		});

		// Called when order is placed
		client.on("updateOrder", async () => {
			console.log("Update to order from client: " + client.id);
			io.emit("updateCurrentOrders", "Order Placed");
		});

		// Called when status of order updated
		client.on("orderStatusUpdated", async (order) => {
			console.log(`\nUpdating order`);
			try {
				if (!verify(order.jwt)) { throw ERROR_INVALID_TOKEN; }
				
				let query = 'UPDATE orders ';
				query += order.delivered
					? `SET delivered='${order.delivered}', delivered_at='${order.delivered_at}' `
					: `SET prepared='${order.prepared}', prepared_at='${order.prepared_at}' `;
				query += `WHERE id = ${order.id} RETURNING id, prepared, prepared_at, delivered, delivered_at;`

				// SQL Query > Update order delivery status
				const updatedOrder = await	db.query(query);

				// Get socket id
				const toSocketId = await cache.get(`${CACHE_ORDER_ID}${order.id}`);

				// Check if any senders socketId is defined and send message
				if (toSocketId != 'undefined') {
					// Send updated order to reviceving socket
					//console.log(updatedOrder.rows[0]);
					io.to(toSocketId).emit('orderStatusUpdated', updatedOrder.rows[0]);
					//io.emit('orderStatusUpdated', updatedOrder.rows[0]);
					console.log("Sent updated order " + order.id + " to socket: " + toSocketId);
				}

				// if delivered then remove from cache
				if (order.delivered) {
					await cache.del(`${CACHE_ORDER_ID}${order.id}`);
					console.log("Clearing order from cache: " + order.id);
				}

				// Send signal to web admin to update current order list
				io.emit("updateCurrentOrders", "Order Updated");
			} catch (error) {
				console.log(`Order Status Update Error: ${error}`);
			}
		});


	}); // connection
} // runSocket
