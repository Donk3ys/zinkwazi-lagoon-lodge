const assert = require("assert");
const redis = require("async-redis");
const client = redis.createClient({
	host: process.env.REDIS_HOST,
	port: process.env.REDIS_PORT,
});

module.exports.connectCache = async function connectCache() {
	let retries = 5;
	while (retries > 0) {
		try {
			client.on("error", function (error) {
				throw error;
			});
			break;
		} catch(error) {
			console.log(`Cache connect error: ${error}`);
		}
		retries--;
		await new Promise(res => setTimeout(res, 2000));
	}

	console.log("Cache connected success")
}

module.exports.getCache = function getCache() {
    assert.ok(client, "Cache has not been initialized.");
    return client;
}
