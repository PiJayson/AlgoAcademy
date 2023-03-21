import React, { Fragment, useEffect, useState } from "react";
import { useNavigate } from 'react-router-dom';

//      --ADD--      //
const AdminAdd = () => {
  const [mess, setMess] = useState();

  const [toSend, setToSend] = useState([]);
  const [tables, setTables] = useState([]);
  const [columns, setColumns] = useState([]);

  
  const onSubmitForm = async e => {
    e.preventDefault();
    try {
      const body = Object.keys(toSend).reduce( (acc, key) => {
        return {...acc, [toSend[key].column_name]: toSend[key].data_type};
      }, {});
      const response = await fetch(`http://localhost:5000/list/${window.location.hash.substr(1)}`, {
        method: "POST",
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



  const getTables = async () => {
    try {
      const response = await fetch("http://localhost:5000/list/tables");
      const jsonData = await response.json();

      setTables(jsonData);

    } catch (err) {
      console.error(err.message);
    }
  };

  const getColumn = async () => {
    try {
      const body = null;
      const response = await fetch(`http://localhost:5000/list/columns/${window.location.hash.substr(1)}`, {
        method: "GET"
      });
      const jsonData = await response.json();
      const jsonDataCopy = JSON.parse(JSON.stringify(jsonData));

      jsonDataCopy.map( e => e.data_type = null );
      
      setToSend(jsonDataCopy);
      setColumns(jsonData);
    } catch (err) {
      console.error(err.message);
    }
  };

  useEffect(() => {
    getTables();
  }, []);

  useEffect(() => {
    getColumn();
  }, []);
  
  const handleChange = (value, index) => {
      const newData = [...toSend];
      newData[index].data_type = value;
      setToSend( newData );
  };

  const appendNotification = (mess) => {
    if(mess == "DONE") {window.location.reload(); return;}
    setMess(mess);
    document.getElementById('mainContainer').appendChild(document.getElementById('mainAlert').firstChild.cloneNode(true));
  }

  const goToSubpage = (values) => {
    window.location.href = `/admin/#${Object.values(values)[0]}`;
    window.location.reload();
  }

//      --FUNCTIONALITY--      //

  return (
    <Fragment>
      <h1 className="text-center mt-5">Problem - Admin</h1>
      <div id="mainContainer"></div>
        <div hidden id="mainAlert">
          <div class="alert alert-danger" role="alert">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <strong>{ mess }</strong>
          </div>
        </div>
      <div class="dropdown text-center" id="mainDiv">
        
        <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
          Tables
        </button>
        <div class="dropdown-menu" onClick={console.log("owoe")}>
          {tables.map(values =>(
            <a class="dropdown-item" onClick={()=> goToSubpage(values)}>{Object.values(values)[0]}</a>
          ))}
        </div>
        
        
        <button
          type="button"
          className="btn btn-success"
          data-toggle="modal"
          data-target={`#myModal`}
        >
          Add
        </button>


        <div
          class="modal"
          id="myModal"
        >
          <div className="modal-dialog">
            <div className="modal-content">
              <div className="modal-header">
                <h4 className="modal-title">Add new {window.location.hash.substr(1)}</h4>
                <button type="button" class="close" data-dismiss="modal" >
                  &times;
                </button>
              </div>

              <div class="modal-body">

                  <form>
                    { columns.map( (data, index) => (
                      <div class="mb-3 custom-control custom-switch" key={index}>
                        <label class="form-label required">{Object.values(data)[0]}</label>
                        {Object.values(data)[1] == "text" ? <input type="text" className="form-control" value={toSend.data_type} onChange={(e) => handleChange(e.target.value, index)} /> :
                         Object.values(data)[1] == "integer" ? <input type="text" className="form-control" value={toSend.data_type} onChange={(e) => handleChange(e.target.value, index)} /> :
                         Object.values(data)[1] == "boolean" ? [<div class="custom-control custom-switch">
                          <input type="checkbox" class="custom-control-input" id="switch1" value={toSend.data_type} onChange={(e) => handleChange(e.target.checked, index)}/>
                          <label class="custom-control-label" for="switch1"></label>
                      </div>] : null}
                    </div>
                    )) }
                  </form>
              </div>


              <div class="modal-footer">
                <button type="button" class="btn btn-warning" data-dismiss="modal" onClick={e => onSubmitForm(e)} >
                  Send
                </button>
                <button type="button" class="btn btn-danger" data-dismiss="modal">
                  Close
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
      
    </Fragment>
  );
};

export default AdminAdd;
