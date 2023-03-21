//      --libraries--       //
const pool = require("./../db")
const express = require("express");
const router = express.Router();

//      --RANKING TABLE--      //

//      --GET--      //

router.get("/", async(req, res) => {
    try {
        const allTodos = await pool.query(`SELECT * FROM showRanking()`);

        res.json(allTodos.rows);
    } catch (err) {
        console.error(err);
    }
});

module.exports = router;