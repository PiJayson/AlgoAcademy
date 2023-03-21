import React, { Fragment, useEffect, useState } from "react";
import { useLocation } from 'react-router-dom';

const SubmitSubpage = (e) => {
  const location = useLocation();
  const [submition, setSubmition] = useState(location.state);          // default values
  const [submitText, setText] = useState();

  console.log("eee");
  console.log(submition);

  const getCode = async () => {
    try {
      const response = await fetch(`http://localhost:5000/submit/submits`, {
        method: "GET",
        credentials: 'include'
      });
      const jsonData = await response.json();

      console.log(jsonData);

      setText(jsonData);
    } catch (err) {
      console.error(err.message);
    }
  };

  const getContentOfProblem = async () => {
    try {
      const response = await fetch(`http://localhost:5000/submit/file/${location.state.SubmissionId}`, {
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
        <h1 className="text-center mt-5">Your submit</h1>
        <div class="form-group mb-3 row">
          <h4 class="col-sm-12">
            <label for="exampleFormControlTextarea3">Kod</label>
            <span class="badge badge-warning float-right"> {location.state.ResultName} </span>
          </h4>
            <textarea class="form-control bg-light" id="exampleFormControlTextarea3" rows="15" value={ submitText }></textarea>
        </div>
      </div>
    </Fragment>
  );
};

export default SubmitSubpage;
