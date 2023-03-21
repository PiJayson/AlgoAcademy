import React, { Fragment, useEffect, useState } from "react";
import { useNavigate } from 'react-router-dom';

import { mainUserData, setMainUserData } from '../index.js'

const MainProblemGet = () => {
  const [problem, setProblems] = useState([]);          // default values
  const [difficultyList, setDifficultyList] = useState([]);
  const [tagList, setTagList] = useState([]);
  const [textFilter, setFilter] = useState('');
  const [tagFilter, setTagFilter] = useState(null);
  const [difficulty, setDifficulty] = useState(null);
  const [quality, setQuality] = useState(null);
  const navigate = useNavigate();

  console.log("yo: " + mainUserData.Username);

  const getProblem = async () => {
    try {
      const response = await fetch(`http://localhost:5000/subproblem/content`, {
        method: "GET"
      });

      const jsonData = await response.json();

      const a = jsonData[4];
      console.log(toString(a.TagName));

      setProblems(jsonData);
    } catch (err) {
      console.error(err.message);
    }
  };

  const getDifficultyList = async () => {
    try {
      const response = await fetch(`http://localhost:5000/subproblem/difficulty`, {
        method: "GET"
      });
      const jsonData = await response.json();

      console.log(jsonData);

      setDifficultyList(jsonData);
    } catch (err) {
      console.error(err.message);
    }
  };

  const getTags = async () => {
    try {
      const response = await fetch(`http://localhost:5000/subproblem/tags`, {
        method: "GET"
      });
      const jsonData = await response.json();

      setTagList(jsonData);
    } catch (err) {
      console.error(err.message);
    }
  };

  useEffect(() => {
    getDifficultyList();
  }, []);

  useEffect(() => {
    getTags();
  }, []);

  useEffect(() => {
    getProblem();
  }, []);

  return (
      <Fragment>
    <h1 className="text-center mt-5">Problems</h1>
    <div class="container">
      <div class="form-group row">
          <input type="text" className="form-control mt-5" value={textFilter} onChange={(e) => setFilter(e.target.value)} />
          <div>
              <select name="cars1" class="custom-select" value={difficulty} onChange={e => setDifficulty(e.target.value)} >
                  <option value="0">Difficulty</option>
                  { difficultyList.map(val => <option value={ val.DifficultyId }>{ val.Name }</option>) }
              </select>
          </div>
          <div>
              <select name="cars" class="custom-select" value={quality} onChange={e => setQuality(e.target.value)} >
                  <option value="0">Quality</option>
                  <option value="1">1</option>
                  <option value="2">2</option>
                  <option value="3">3</option>
                  <option value="4">4</option>
                  <option value="5">5</option>
              </select>
          </div>
          <div>
              <select name="cars3" class="custom-select" value={tagFilter} onChange={e => setTagFilter(e.target.value)} >
                  <option value="0">Tag</option>
                  { tagList.map(val => <option value={ val.TagId }>{ val.Name }</option>) }
              </select>
          </div>
      </div>

      <table class="table mt-5 text-center">
        <thead>
          <tr>
            <th>Name</th>
            <th>Difficulty</th>
            <th>Quality</th>
            <th>Tags</th>
            <th>Result</th>
            <th>Submit</th>
            <th>Open</th>
          </tr>
        </thead>
        <tbody>
          {problem.filter(id => id.Name.substring(0, textFilter.length).toLowerCase().indexOf(textFilter) >= 0
                            && ( difficulty == null || difficulty == 0 || id.Difficulty == difficulty)
                            && ( quality == null || quality == 0 || id.Quality == quality)
                            && ( tagFilter == null || tagFilter == 0 || (new Array(id.TagName)).join().indexOf(tagList[tagFilter-13].Name) >=0 || console.log(tagFilter))).map(problemList => (
            <tr key={problemList.ProblemId}>
              <td>{problemList.Name}</td>
              <td>{difficultyList[problemList.Difficulty - 1].Name}</td>
              <td>{problemList.Quality}</td>
              <td>{ (new Array(problemList.TagName)).join()}</td>
              <td>Not done</td>
              <td>
                <button className="btn btn-warning" onClick={() => navigate(`./submit/${problemList.ProblemId}`, {state: problemList})}>
                  Send
                </button>
              </td>
              <td>
                <button className="btn btn-success" onClick={() => navigate(`./${problemList.ProblemId}`, {state: problemList})}>
                  Enter
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

export default MainProblemGet;
