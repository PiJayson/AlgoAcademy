//      --libraries--       //
const pool = require("./../db")
const express = require("express");
const path = require("path");
const router = express.Router();

//      --SUBPROBLEM--      //

//      --GET--      //

router.get("/content", async(req, res) => {
    try {
        const query = await pool.query('SELECT * FROM showProblems');

        res.json(query.rows);
    } catch (err) {
        res.json(err.message);
        console.error(err);
    }
});

router.get("/difficulty", async(req, res) => {
    try {
        const query = await pool.query('SELECT * FROM "Difficulty"');

        res.json(query.rows);
    } catch (err) {
        res.json(err.message);
        console.error(err);
    }
});

router.get("/tags", async(req, res) => {
    try {
        const query = await pool.query('SELECT * FROM "Tag"');

        res.json(query.rows);
    } catch (err) {
        res.json(err.message);
        console.error(err);
    }
});

router.get("/file/:id", async(req, res) => {
    try {
        const { id } = req.params;
        const query = await pool.query(`SELECT "Path" FROM "Problem" WHERE "ProblemId" = ${id}`);

        res.sendFile(path.join(__dirname + `../../../Components/problems/${id}.txt`));
    } catch (err) {
        res.json(err.message);
        console.error(err);
    }
});

module.exports = router;