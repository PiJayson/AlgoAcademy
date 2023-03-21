import React, { Fragment, useEffect, useState } from "react";
import { useNavigate } from 'react-router-dom';

const Ranking = () => {
  const [problem, setProblems] = useState([]);          // default values
  const [textFilter, setFilter] = useState('');
  const navigate = useNavigate();

  const getRanking = async () => {
    try {
      const response = await fetch(`http://localhost:5000/ranking`, {
        method: "GET"
      });
      const jsonData = await response.json();

      setProblems(jsonData);
    } catch (err) {
      console.error(err.message);
    }
  };

  useEffect(() => {
    getRanking();
  }, []);

  return (
      <Fragment>
    <h1 className="text-center mt-5">Ranking</h1>
    <div class="container">

    <div class="form-group row justify-content-center">
        <input type="text" className="form-control mt-5 w-75" value={textFilter} onChange={(e) => setFilter(e.target.value)} />
    </div>
      <table class="table mt-5 text-center">
        <thead>
          <tr>
            <th>Place</th>
            <th>Name</th>
            <th>Solved Problems</th>
          </tr>
        </thead>
        <tbody>
          {problem.filter(id => id.User.substring(0, textFilter.length).toLowerCase().indexOf(textFilter) >= 0).map((problemList, index) => (
            <tr key={problemList.Index}>
              <td>{problemList.Index}</td>
              <td>{problemList.User}</td>
              <td>{problemList['Solved Problems']}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
    </Fragment>
  );
};

export default Ranking;
