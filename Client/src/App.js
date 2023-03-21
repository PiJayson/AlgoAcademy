//      --libraries--       //
import React, { Fragment } from "react";
import "./App.css";
import { BrowserRouter as Router, Route, Routes } from "react-router-dom"

//      --components--       //

import Algoacademyadminproblems from "./_problem_test_/algoacademyadminproblems";

import AdminAdd from "./admin/adminAdd";
import AdminGet from "./admin/adminGet";
import MainProblemGet from "./problem/problemPage";
import ProblemSubpage from "./problem/problemSubPage";
import SubmitForm from "./problem/submitForm";
import LoginPage from "./login/loginPage";
import NavBar from "./navBar/navBar";
import Ranking from "./ranking/ranking";
import SubmitPage from "./submits/submitPage";
import SubmitSubpage from "./submits/submitSubpage";
import YourAccount from "./account/yourAccount";
import HomePage from "./homePage/homePage";

export const MainContext = React.createContext(0);

function App(e) {
  return (
    <Router>
      <Fragment>
        <div className="">
          <Routes>
              <Route index element={<HomePage/>}/>
              <Route exact path='/login' element={<LoginPage/>}/>
          </Routes>
          <Routes>
              <Route exact path='/admin' element={[<NavBar/>, <AdminAdd/>, <AdminGet/>]}/>

              <Route exact path='/testproblems' element={[<NavBar/>, <Algoacademyadminproblems/>]}/>

              <Route exact path='/problems' element={[<NavBar/>, <MainProblemGet/>]}/>
              <Route exact path='/problems/:id' element={[<NavBar/>, <ProblemSubpage/>]}/>
              <Route exact path='/problems/submit/:id' element={[<NavBar/>, <SubmitForm/>]}/>

              <Route exact path='/ranking' element={[<NavBar/>, <Ranking/>]}/>

              <Route exact path='/submits' element={[<NavBar/>, <SubmitPage/>]}/>
              <Route exact path='/submits/:id' element={[<NavBar/>, <SubmitSubpage/>]}/>

              <Route exact path='/account' element={[<NavBar/>, <YourAccount/>]}/>
                
          </Routes>
        </div>
      </Fragment>
    </Router>
  );
}

export default App;
