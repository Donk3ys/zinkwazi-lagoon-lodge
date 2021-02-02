const Joi = require('joi');

// Register User Validation
function registerValidation(user) {
	const schema = Joi.object({
		username: Joi.string().min(3).max(40).required(),
		password: Joi.string().min(6).max(60).required(),
		role: Joi.string().min(5).max(8).required().pattern(new RegExp(`\\b(super|admin|kitchen)\\b`)),
		email: Joi.string().min(5).max(30).email().allow(null).allow("")
	});

	return schema.validate(user);
}


// Login User Validation
function loginValidation(user) {
	const schema = Joi.object({
		username: Joi.string().min(3).max(30).required(),
		password: Joi.string().max(250).required()
	});

	return schema.validate(user);
}


module.exports.registerValidation = registerValidation;
module.exports.loginValidation = loginValidation;
