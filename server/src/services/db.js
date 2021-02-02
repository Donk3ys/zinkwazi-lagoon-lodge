const { Pool } = require('pg');
const assert = require('assert');

// Create postgres connection pool
const postgresPool = new Pool({
	user:			process.env.PG_USER,
	host:			process.env.PG_HOST,
	database: process.env.PG_DATABASE,
	password: process.env.PG_PASSWORD,
	port:			process.env.PG_PORT
});

module.exports.connectDb = async function connectDb() {
	// Connect to postgres server & database
	let retries = 5;
	while (retries > 0) {
		try {
			await postgresPool.connect();
			console.log('Database connected success');
			break;
		} catch(error) {
			console.log(`Database connect error: ${error}`);
		}

		retries--;
		await new Promise(res => setTimeout(res, 2000));
	}
}

module.exports.getDb = function getDb() {
    assert.ok(postgresPool, "Database has not been initialized.");
    return postgresPool;
}
