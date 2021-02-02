require('dotenv').config({path:'/Users/donk3y/projects/Zinkwazi-Lagoon-Lodge/docker/.env'});

const cors = require('cors')
const bodyParser = require("body-parser");

// Config express
const express = require('express');
const app = express();

async function startServer () {
	// Config Middleware
	app.use(cors());
	app.use(express.json());
	app.use(bodyParser.urlencoded({extended : true}));


	// Connect to Database & cache
	await require('./src/services/db').connectDb();
	await require('./src/services/cache').connectCache();


	// Config Routes
	const authRoutes = require('./src/routes/auth');
	app.use('/api/auth', authRoutes);

	const menuPath = `/api/v1/menu`;
	const menuItemRoutes = require('./src/routes/menu-items');
	const menuOrderRoutes = require('./src/routes/menu-orders');
	const menuPaymentRoutes = require('./src/routes/menu-payments');
	const menuTypeRoutes = require('./src/routes/menu-types');
	app.use(menuPath, menuItemRoutes);
	app.use(menuPath, menuOrderRoutes);
	app.use(menuPath, menuPaymentRoutes);
	app.use(menuPath, menuTypeRoutes);


	// Config socket server
	const io = require('socket.io')(app.listen(
		process.env.EXPRESS_PORT,
		() => console.log(`Server Listening...  PORT: ${process.env.EXPRESS_PORT}`)
	));
	// Run socket
	require('./src/services/socket').runSocketIO(io);


//	app.listen(
//		process.env.EXPRESS_PORT,
//		() => console.log(`Server Listening...  PORT: ${process.env.EXPRESS_PORT}`)
//	);

}

startServer();
