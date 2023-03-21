import React, { Fragment, useEffect, useState } from "react";
import { Navigate, useLocation, useNavigate } from 'react-router-dom';

const SubmitForm = (e) => {
  const location = useLocation();
  const navigate = useNavigate();
  const [problemId, setProblems] = useState(location.state.ProblemId);          // default values
  const [programmingLanguage, setProgrammingLanguage] = useState(null);
  const [listOfPL, setListOfPL] = useState([]);
  const [mess, setMess] = useState();
  const [problemText, setText] = useState(null);

  const onSubmitForm = async e => {
    e.preventDefault();
    try {
      var programmingLanguageINT = parseInt(programmingLanguage);
      const body = { problemId, programmingLanguageINT, problemText};

      console.log(body);
      console.log(JSON.stringify(body));
      console.log("inside onSubmit");

      const response = await fetch(`http://localhost:5000/submit`, {
        method: "POST",
        credentials: 'include',
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
      }).then(e => e.json().then(ee =>
        appendNotification(ee)
      ));

      // window.location.reload();
    } catch (err) {
      console.error(err.message);
    }
  };

  const getProgrammingLanguages = async () => {
    try {
      const response = await fetch(`http://localhost:5000/submit/languages`, {
        method: "GET"
      });
      const jsonData = await response.json();

      console.log("programming Languages");
      console.log(jsonData);

      setListOfPL(jsonData);
    } catch (err) {
      console.error(err.message);
    }
  };

  useEffect(() => {
    getProgrammingLanguages();
  }, []);

  const appendNotification = (mess) => {
    if(mess == "DONE") {navigate('/submits'); return;}
    setMess(mess);
    document.getElementById('mainContainer').appendChild(document.getElementById('mainAlert').firstChild.cloneNode(true));
  }


  return (
      <Fragment>
        <div class="container">
          <h1 className="text-center mt-5">{`${location.state.Name}`}</h1>
          <div class="form-group">
              <label for="exampleFormControlTextarea3" class="blockquote">Paste your code</label>
              <textarea class="form-control" id="exampleFormControlTextarea3" rows="20" value={ problemText } onChange={(e) => setText(e.target.value)}></textarea>
          </div>
          <div class="mb-3 row">
          <div class="col-sm-12">
            <select name="cars1" class="custom-select w-50" value={programmingLanguage} onChange={e => setProgrammingLanguage(e.target.value)} >
              <option value="0">Choose Your Language</option>
                { listOfPL.map(val => <option value={ val.ProgrammingLanguageId }>{ val.Name }</option>) }
              </select>
            <button type="button" class="btn btn-warning float-right" data-dismiss="modal" onClick={e => onSubmitForm(e)}>
              Submit
            </button>
          </div>
          </div>
        </div>
    </Fragment>
  );
};

export default SubmitForm;
