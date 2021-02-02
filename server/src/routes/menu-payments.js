const router = require('express').Router();
const md5 = require('md5');

const db = require('../services/db').getDb();
const cache = require('../services/cache').getCache();


let testing = true;
if (process.env.NODE_ENV === "production") {
	testing = false;
}


// PayFast

// Make payment
router.post('/order/payment', async (req, res) => {
	const url = testing ? 'https://sandbox.payfast.co.za/eng/process' : 'https://www.payfast.co.za/eng/process';
	console.log('Making payment: ' + url);

	// Init transaction details
	const merchantId = testing ? "10019266" : "16217441"
	const merchantKey = testing ? 'faitni8vyejwk' : '0lqays1rguqz5';

	const amount = req.body.amount;
	const itemName = `Meal_Order}`;
	const paymentId = `${req.body.payment_id}`;

	// Store payment id in cache set (list with no duplicates)
	await cache.sadd(['payment_ids', paymentId]);

	const transactionDetails = [
		// Merchant details
		{	"merchant_id"		: merchantId },
		{ "merchant_key"	: merchantKey },
		{ "return_url"		: `${req.body.public_ip}/api/v1/menu/payment/return` },
		{ "cancel_url"		: `${req.body.public_ip}/api/v1/menu/payment/cancel/${paymentId}` },
		{ "notify_url"		: `${req.body.public_ip}/api/v1/menu/payment/notify` },
		// Buyer details
		//"name_first"		: 'First Name',
		//"name_last"			: 'Last Name',
		//{"email_address" : 'sbtu01@payfast.co.za'},
		// Transaction details
		{ "m_payment_id"	: paymentId}, //Unique payment ID to pass through to notify_url
		// Amount needs to be in ZAR
		// If multicurrency system its conversion has to be done before building this array
		{ "amount"				: amount },
		{ "item_name"			: itemName }
		//"item_description" : 'Item Description',
	];

	// Create parameter string
	let output = '';
	for (let detail of transactionDetails) {
	//	console.log(`${Object.keys(detail)} : ${Object.values(detail)}`);
		if (Object.values(detail)[0]) {
				output += `${Object.keys(detail)[0]}=${encodeURIComponent(Object.values(detail)[0].trim())}&`;
				//console.log(output);
		}
	}
	// Remove last ampersand
	let getString = output.substring(0, output.length - 1);
	//console.log(getString);

	// Hash getString
	let signature = md5(getString);
	transactionDetails.push({ "signature" : signature });
	console.log(`signature: ${signature}`);


	// Create html form
	let formFields = "";
	for (var detail of transactionDetails) {
//		console.log(`${Object.keys(detail)} : ${Object.values(detail)}`);
		formFields += `<input type='hidden' name='${Object.keys(detail)[0]}' value='${Object.values(detail)[0].trim()}' >\n`;

	}
  res.header("Access-Control-Allow-Origin", "*");
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept"
  );
	res.writeHead(200, { "Content-Type": "text/html" });
	res.write(
      '<html><head><title>Merchant Checkout Page</title></head><body style="background-color:#383838;"><center><h1>Loading...</h1></center><form method="post" action="' +
        url +
        '" name="f1">\n' +
        formFields +
        '</form><script type="text/javascript">document.f1.submit();</script></body></html>'
  );
	res.end();
});


// Cancel / Error Payment
router.get('/payment/cancel/:payment_id', async (req, res) => {
	let paymentIds = await cache.smembers("payment_ids");
	console.log("Payment IDs: " + paymentIds);
	// Check if payment id is in paymentIds list
	if (!paymentIds.includes(req.params.payment_id)) { return res.sendStatus(404); }

	// Remove paymentId from cache
	await cache.srem(['payment_ids', req.params.payment_id]);
	paymentIds = await cache.smembers("payment_ids");

	console.log('Payment canceled ' + req.params.payment_id);
	return res.send('cancel');
});


// Successful payment Return
router.get('/payment/return', async (_, res) => {
	return res.send('return');
});


// Successful payment Notify
router.post('/payment/notify', async (req, res) => {
	console.log('Checking Payment Notification');

	res.sendStatus(200);
	console.log("Payment Status: " + req.body.payment_status);

	//name={Object.keys(detail)[0] value=Object.values(detail)[0].trim()
	//let output = '';
	//for (var detail of JSON.parse(req.body)) {
	//	console.log(`${Object.keys(detail)} : ${Object.values(detail)}`);
		//if (Object.values(detail)[0] && Object.keys(detail)[0] != "signature") {

		//console.log(detail)
//		if (Object.values(detail)[0]) {
//				output += `${Object.keys(detail)[0]}=${encodeURIComponent(Object.values(detail)[0].trim())}&`;
//				//console.log(output);
//		}
//	}
//
//	// Remove last ampersand
//	let getString = output.substring(0, output.length - 1);
//	//console.log(getString);
//
//	// Check signature
//	let signature = md5(getString);
//	console.log(`signature match: ${signature === req.body.signature}`);

});


module.exports = router;
