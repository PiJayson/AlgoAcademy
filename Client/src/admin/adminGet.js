import React, { Fragment, useEffect, useState } from "react";

import AdminEdit from "./adminEdit";

const AdminGet = () => {
  const [problem, setProblems] = useState([]);          // default values
  const [headers, setHeaders] = useState([]);

  const [tableName, setTableName] = useState(window.location.hash.substr(1));


  const deleteProblem = async currProblem => {
    try {
      const deleteTodo = await fetch(`http://localhost:5000/list/${Object.values(currProblem)[0]}/${tableName}/${Object.keys(currProblem)[0]}`, {
        method: "DELETE"
      });

      setProblems(problem.filter(rows => Object.values(rows)[0] !== Object.values(currProblem)[0]));
    } catch (err) {
      console.error(err.message);
    }
  };

  const getProblem = async () => {
    try {
      const response = await fetch(`http://localhost:5000/list/tablecontent/${tableName}`, {
        method: "GET",
        credentials: 'include'
      });
      const jsonData = await response.json();

      setProblems(jsonData);
      setHeaders(jsonData[0]);
    } catch (err) {
      console.error(err.message);
    }
  };

  useEffect(() => {
    getProblem();
  }, []);

  return (
    <Fragment>
      <table class="table mt-5 text-center">
        <thead>
          <tr>
            { headers != null ? Object.keys(headers).map((key) => (
              <th>{key}</th>
            )) : <th>Add Something</th>}
            <th>Edit</th>
            <th>Delete</th>
          </tr>
        </thead>
        <tbody>
          {problem.map(problemList => (
            <tr key={problemList.problemid}>

            {Object.keys(headers).map((key) => (
              <th> { typeof problemList[key] == "boolean" ? (problemList.IsPublic == true ? (<div>true</div>) : (<div>false</div>)) : problemList[key] }</th>
            ))}
              <td>
                <AdminEdit mainList={problemList} />
              </td>
              <td>
                <button
                  className="btn btn-danger"
                  onClick={() => deleteProblem(problemList)}
                >
                  Delete
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </Fragment>
  );
};

export default AdminGet;
