import React from "react";
import ReactDOM from "react-dom";
import "./index.css";
import App from "./App";

let mainUserData = "a";
function setMainUserData(value) {mainUserData = value;}

export { mainUserData, setMainUserData};

ReactDOM.render(<App />, document.getElementById("root"));
