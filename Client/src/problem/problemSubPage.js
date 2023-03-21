import React, { Fragment, useEffect, useState } from "react";
import { useLocation } from 'react-router-dom';

const ProblemSubpage = (e) => {
  const location = useLocation();
  const [problem, setProblems] = useState([location.state]);          // default values
  const [problemText, setText] = useState();

  const getProblem = async () => {
    try {
      const response = await fetch(`http://localhost:5000/subproblem/content/5`, {
        method: "GET"
      });
      const jsonData = await response.json();

      console.log(location.state);

      setProblems(jsonData);
    } catch (err) {
      console.error(err.message);
    }
  };

  const getContentOfProblem = async () => {
    try {
      const response = await fetch(`http://localhost:5000/subproblem/file/${location.state.ProblemId}`, {
        method: "GET"
      });
      const jsonData = await response.text();

      console.log("inside");
      console.log(jsonData);

      setText(jsonData);
    } catch (err) {
      console.error(err.message);
    }
  };

//   useEffect(() => {
//     getProblem();
//   }, []);

  useEffect(() => {
    getContentOfProblem();
  }, []);

  return (
    <Fragment>
      <div class="container">
        <h1 className="text-center mt-5">{`${location.state.Name}`}</h1>
        <div class="form-group">
            <label for="exampleFormControlTextarea3">Treść</label>
            <textarea class="form-control" id="exampleFormControlTextarea3" rows="15" value={ problemText }></textarea>
        </div>
      </div>
    </Fragment>
  );
};

export default ProblemSubpage;
