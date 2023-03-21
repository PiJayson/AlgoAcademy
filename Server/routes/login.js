//      --libraries--       //
const pool = require("./../db")
const express = require("express");
const jwt = require('jsonwebtoken');
const router = express.Router();

//      --Login and SignUp--      //

ACCESS_TOKEN="Jkks&28jdh228H2882jdd"

//      --GET--      //

router.get("/", async(req, res) => {
    try {
        const query = await pool.query(`SELECT * FROM "Country"`);

        res.json(query.rows);
    } catch (err) {
        res.json(err.message);
        console.error(err);
    }
});

router.get("/data/:username", async(req, res) => {
    try {
        const { username } = req.params;
        const query = await pool.query(`SELECT "UserId", "RoleId", "Username" FROM "User" WHERE "Username" = '${username}'`);

        res.json(query.rows[0]);
    } catch (err) {
        res.json(err.message);
        console.error(err);
    }
});


//      --INSERT--      //

router.post("/login", async(req, res) => {
    try {
        const newProblem = await pool.query('SELECT login($1::text, $2::text)', Object.values(req.body));
        const getUserId = await pool.query(`SELECT * FROM getUserId('${req.body.username}')`);
        const userId = getUserId.rows[0].getuserid;

        inizializeCookie(res, req.body, userId);
    } catch (err) {
        res.json(err.message);
        console.error(err.message);
    }
});

router.post("/register", async(req, res) => {
    try {
        const query = await pool.query('SELECT createaccount($1::text, $2::text, $3::email, $4::integer)', Object.values(req.body));
        const getUserId = await pool.query(`SELECT * FROM getUserId('${req.body.username}')`);
        const userId = getUserId.rows[0].getuserid;

        inizializeCookie(res, req.body, userId);
    } catch (err) {
        res.json(err.message);
        console.error(err.message);
    }
});

const inizializeCookie = (res, data, userId) => {

    const variable = { username: userId };
    const accessToken = jwt.sign(variable, ACCESS_TOKEN, { expiresIn: "1h" });

    res.cookie("token", accessToken);
    res.cookie("username", data.username);
    res.header('Access-Control-Allow-Origin', 'http://localhost:8000');
    res.header('Access-Control-Allow-Credentials','true');
    res.json(true);
}

//      --VALIDATION--      //

module.exports = router;