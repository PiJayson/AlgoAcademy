//      --libraries--       //
const pool = require("./../db")
const express = require("express");
const { validateCookie } = require("./../validation");
const router = express.Router();

//      --Admin panel - dynamically created table--      //

//      --GET--      //

router.get("/tablecontent/:tableName", validateCookie, async(req, res) => {
    try {
        const { tableName } = req.params;
        const query = await pool.query(`SELECT * FROM "${tableName}" ORDER BY 1`);

        res.json(query.rows);
    } catch (err) {
        res.json(err.message);
        console.error(err);
    }
});

router.get("/tables", async(req, res) => {
    try {
        const query = await pool.query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY 1;");

        res.json(query.rows);
    } catch (err) {
        res.json(err.message);
        console.error(err);
    }
});

router.get("/columns/:tableName", async(req, res) => {
    try {
        const { tableName } = req.params;
        const query = await pool.query(`SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = '${tableName}'`);

        res.json(query.rows);
    } catch (err) {
        res.json(err.message);
        console.error(err);
    }
});


//      --INSERT--      //

router.post("/:tableName", async(req, res) => {
    try {
        // change array to casted one eg. [a, b, c] -> 'a'::text, 'b'::text, 'c'::text 
        var toAdd = "";
        Object.values(req.body).forEach(e => toAdd += "'" + e + "'::text,");
        toAdd = toAdd.slice(0, -1);

        const tableName = req.params;
        const query = await pool.query(`SELECT ${tableName.tableName.toLowerCase()}_insert(${toAdd})`);
        

        res.json("DONE");
    } catch (err) {
        res.json(err.message);
        console.error(err.message);
    }
});

//      --UPDATE--      //

// only for Problem - has to be upgraded
router.put("/:id", async(req, res) => {
    try {
        const {id} = req.params;
        const {description} = req.body; 
        const uptadeTodo = await pool.query(`UPDATE "Problem" SET "Name" = $1 WHERE "ProblemId" = $2`, [description, id]);

        res.json("Updated");
    } catch (err) {
        console.error(err);
    }
});


//      --DELETE--      //

router.delete("/:id/:tableName/:columnName", async(req, res) => {
    try {
        const {id, tableName, columnName} = req.params;
        const query = await pool.query(`DELETE FROM "${tableName}" WHERE "${columnName}" = ${id}`);

        res.json("Deleted");
    } catch (err) {
        res.json(err.message);
        console.error(err);
    }
});

module.exports = router;