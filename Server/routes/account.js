//      --libraries--       //
const pool = require("./../db");
const express = require("express");
const jwt = require('jsonwebtoken');
const { validateCookie } = require("./../validation");
const router = express.Router();

//      --Account - everything about user--      //

//      --Verification process--      //

router.get("/isvalidated", validateCookie, async(req, res) => {
    try {
        const query = await pool.query(`SELECT * FROM isUserVerified(${req.username.username})`);

        res.json(query.rows[0].isuserverified);
    } catch (err) {
        res.json(err.message);
        console.error(err);
    }
});

router.post("/verify", validateCookie, async(req, res) => {
    try {
        const query = await pool.query(`SELECT * FROM verifyUser(${req.username.username}::INTEGER)`);

        res.json("DONE");
    } catch (err) {
        res.json(err.message);
        console.error(err.message);
    }
});


//      --DELETE--      //

module.exports = router;