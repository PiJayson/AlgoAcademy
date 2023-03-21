//      --libraries--       //
const pool = require("./../db")
const express = require("express");
const path = require("path");
const fs = require('fs');
const { validateCookie } = require("./../validation");
const router = express.Router();

//      --SUBMIT IMPLEMENTATION--      //

//      --GET--      //

router.get("/languages", async(req, res) => {
    try {
        const query = await pool.query('SELECT * FROM "ProgrammingLanguage"');

        res.json(query.rows);
    } catch (err) {
        res.json(err.message);
        console.error(err);
    }
});


router.get("/submits", validateCookie, async(req, res) => {
    try {
        const query = await pool.query(`SELECT * FROM showSubmits(${req.username.username})`);

        res.json(query.rows);
    } catch (err) {
        res.json(err.message);
        console.error(err);
    }
});

router.get("/file/:id", async(req, res) => {
    try {
        const { id } = req.params;
        const query = await pool.query(`SELECT "Code" FROM "Submission" WHERE "SubmissionId" = ${id}`);

        res.sendFile(path.join(__dirname + `../../../Components/submits/${id}.txt`));
    } catch (err) {
        res.json(err.message);
        console.error(err);
    }
});

//      --INSERT--      //

router.post("/", validateCookie, async(req, res) => {
    try {
        const { problemId, programmingLanguageINT, problemText } = req.body;
        const userId = req.username.username;
        const getLastSubmit = await pool.query(`SELECT last_value FROM "Submission_SubmissionId_seq"`);
        const submitId = parseInt(getLastSubmit.rows[0].last_value) + 1;
        const pathFile = path.join(__dirname + `../../../Components/submits/${submitId}.txt`);

        const newProblem = await pool.query(`CALL submit(${userId}::INTEGER, ${problemId}::INTEGER, null, ${programmingLanguageINT}::INTEGER, '${pathFile}'::TEXT)`);

        fs.writeFile(pathFile, problemText, () => { console.log("DONE")});

        res.json("DONE");
    } catch (err) {
        res.json(err.message);
        console.error(err.message);
    }
});


//      --DELETE--      //

module.exports = router;