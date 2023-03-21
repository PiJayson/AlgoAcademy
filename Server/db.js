//      --libraries--       //
const Pool = require("pg").Pool;

//      --database setup--       //

/* If you want, you can move variables to '.env' */
const pool = new Pool({
    user: "postgres",
    password: "aaaa",
    host: "localhost",
    port: 5432,
    database: "algoacademy"
});

module.exports = pool;