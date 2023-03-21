const jwt = require('jsonwebtoken');

const ACCESS_TOKEN = "Jkks&28jdh228H2882jdd";

const validateCookie = (req, res, next) => {
    const token = req.cookies.token;
    try {
        const user = jwt.verify(token, ACCESS_TOKEN);
        req.username = user;
        next();
    } catch (err) {
        res.json(err.message);
        console.log(err.message);
    }
}


module.exports = { validateCookie };