import React, { Fragment, useEffect, useState } from "react";
import { useNavigate } from 'react-router-dom';

const SubmitPage = () => {
  const [submits, setSubmits] = useState([]);          // default values
  const [textFilter, setFilter] = useState('');
  const navigate = useNavigate();

  const getSubmits = async () => {
    try {
      const response = await fetch(`http://localhost:5000/submit/submits`, {
        method: "GET",
        credentials: 'include'
      });
      const jsonData = await response.json();

      setSubmits(jsonData);
    } catch (err) {
      console.error(err.message);
    }
  };

  useEffect(() => {
    getSubmits();
  }, []);

  return (
      <Fragment>
        <h1 className="text-center mt-5">Submit</h1>
        <div class="container">

        <div class="form-group row justify-content-center">
            <input type="text" className="form-control mt-5 w-75" value={textFilter} onChange={(e) => setFilter(e.target.value)} />
        </div>
          <table class="table mt-5 text-center">
            <thead>
              <tr>
                <th>SubmitId</th>
                <th>Problem</th>
                <th>Subbmition Date</th>
                <th>Result</th>
                <th>Points</th>
                <th>Check</th>
              </tr>
            </thead>
            <tbody>
              {submits.filter(id => toString(id.SubmissionId).substring(0, textFilter.length).toLowerCase().indexOf(textFilter) >= 0).map((submissionList, index) => (
                <tr key={submissionList.SubmissionId}>
                  <td>{submissionList.SubmissionId}</td>
                  <td>{submissionList.ProblemId}</td>
                  <td>{submissionList.SubmittedAt}</td>
                  <td>{submissionList.ResultName}</td>
                  <td>{submissionList.Points}</td>
                  <td>
                    <button className="btn btn-warning" onClick={() => navigate(`./${submissionList.ProblemId}`, {state: submissionList})}>
                      Check
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
    </Fragment>
  );
};

export default SubmitPage;
