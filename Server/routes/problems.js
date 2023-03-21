//      --libraries--       //
const pool = require("./../db")
const express = require("express");
const router = express.Router();

//      --PROBLEM TABLE--      //

//      --GET--      //

router.get("/", async(req, res) => {
    try {
        const query = await pool.query(`SELECT * FROM "Problem"`);

        res.json(query.rows);
    } catch (err) {
        res.json(err.message);
        console.error(err);
    }
});

//      --INSERT--      //

router.post("/", async(req, res) => {
    try {
        const { nameu, toggleVal, difficulty, quality } = req.body;
        const newProblem = await pool.query("INSERT INTO problem (sourceid, difficulty, quality, isPublic, name) VALUES(123, $1, $2, $3, $4) RETURNING *", [difficulty, quality, toggleVal, nameu]);

        res.json(newProblem.rows[0]);
    } catch (err) {
        res.json(err.message);
        console.error(err.message);
    }
});

//      --DELETE--      //

router.delete("/:id", async(req, res) => {
    try {
        const {id} = req.params;
        const deleteToDo = await pool.query("DELETE FROM problem WHERE problemid = $1 ", [id]);

        res.json("Deleted");
    } catch (err) {
        res.json(err.message);
        console.error(err);
    }
});

module.exports = router;