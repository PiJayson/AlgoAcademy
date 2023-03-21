//      --libraries--       //
const express = require("express");
const app = express();
const cors = require("cors");
const cookieParser = require("cookie-parser");

//      --Middleware--      //

var corsOptions = {
    origin: 'http://localhost:8000',
    credentials:  true
  }

app.use(cors(corsOptions));
app.use(express.json());             // get a json data from request
app.use(cookieParser());

//      --Routes--      //

const problemRoute = require("./routes/problems");
const listRoute = require("./routes/list");
const subproblemRoute = require("./routes/subproblem");
const loginRoute = require("./routes/login");
const rankingRoute = require("./routes/ranking");
const submitRoute = require("./routes/submit");
const accountRoute = require("./routes/account");

app.use('/problem', problemRoute);
app.use('/list', listRoute);
app.use('/subproblem', subproblemRoute);
app.use('/login', loginRoute);
app.use('/ranking', rankingRoute);
app.use('/submit', submitRoute);
app.use('/account', accountRoute);

//      --server start--      //

app.listen(5000, () => {
    console.log("server has started");
})