import React, { Fragment, useEffect, useState, CSSProperties} from "react";
import { useLocation } from 'react-router-dom';
import { useNavigate } from 'react-router-dom';
import "./loginPage.css";

const LoginPage = (e) => {

  const location = useLocation();
  const navigate = useNavigate();
  const [username, setUsername] = useState(null);          // default values
  const [password, setPassword] = useState(null);
  const [email, setEmail] = useState(null);
  const [country, setCountry] = useState(null);

  const [countries, setCountries] = useState([]);
  const [mess, setMess] = useState();

  const getCountries = async () => {
    try {
      const response = await fetch(`http://localhost:5000/login/`, {
        method: "GET"
      });
      const jsonData = await response.json();

      setCountries(jsonData);
    } catch (err) {
      console.error(err.message);
    }
  };

  const onLogin = async e => {
    e.preventDefault();
    try {
      const body = { username, password }
      const response = await fetch(`http://localhost:5000/login/login/`, {
        method: "POST",
        credentials: 'include',
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
      }).then(a => a.json().then(ee =>
        appendNotification(ee)
      ));
    } catch (err) {
      console.error(err.message);
    }
  };

  const onRegister = async e => {
    e.preventDefault();
    try {
      const body = { username, password, email, country }
      const response = await fetch(`http://localhost:5000/login/register/`, {
        method: "POST",
        credentials: 'include',
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
      }).then(a => a.json().then(ee =>
        appendNotification(ee)
      ));
    } catch (err) {
      console.error(err.message);
    }
  };

  useEffect(() => {
    getCountries();
  }, []);

  const appendNotification = (mess) => {
    if(mess == true) {
      navigate('/problems');
      return;
    }
    if(mess == false) mess = "Wrong pass";
    setMess(mess);
    document.getElementById('mainContainer').appendChild(document.getElementById('mainAlert').firstChild.cloneNode(true));
  }


  return (
    <Fragment>
      <section>
      <div class="container w-50 login">

        <h1 className="text-center mt-5">Login</h1>
        <div id="mainContainer"></div>
        <div hidden id="mainAlert">
          <div class="alert alert-danger" role="alert">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <strong>{ mess }</strong>
          </div>
        </div>

        <form class="mt-5">
            <div class="input-group mb-3">
                <div class="input-group-prepend">
                <span class="input-group-text">🕺</span>
                </div>
                <input type="text" class="form-control" placeholder="Username" value = { username } onChange = {e => setUsername(e.target.value)}/>
            </div>

            <div class="input-group mb-3">
                <div class="input-group-prepend">
                <span class="input-group-text">🔒</span>
                </div>
                <input type="password" class="form-control" placeholder="Password" value = { password } onChange = {e => setPassword(e.target.value)}/>
            </div>
        </form>

        <button type="button" class="btn btn-warning" data-dismiss="modal" onClick={e => onLogin(e)} >
            Login
        </button>

        <p class="row justify-content-center">
            <button class="btn btn-primary" type="button" data-toggle="collapse" data-target="#collapseExample" aria-expanded="false" aria-controls="collapseExample">
                Register
            </button>
        </p>
        <div class="collapse" id="collapseExample">
            <form>
                <div class="input-group mb-3">
                    <div class="input-group-prepend">
                    <span class="input-group-text">🕺</span>
                    </div>
                    <input type="text" class="form-control" placeholder="Username" value = { username } onChange = {e => setUsername(e.target.value)}/>
                </div>

                <div class="input-group mb-3">
                    <div class="input-group-prepend">
                    <span class="input-group-text">✉️</span>
                    </div>
                    <input type="text" class="form-control" placeholder="Email" value = { email } onChange = {e => setEmail(e.target.value)}/>
                </div>

                <div class="input-group mb-3">
                    <div class="input-group-prepend">
                    <span class="input-group-text">🔒</span>
                    </div>
                    <input type="password" class="form-control" placeholder="Password" value = { password } onChange = {e => setPassword(e.target.value)}/>
                </div>

                <div class="mb-3">
                    <select name="cars1" class="custom-select" value={country} onChange={e => setCountry(e.target.value)} >
                        <option value="0">Country</option>
                        { countries.map(val => <option value={ val.CountryId }>{ val.Name }</option>) }
                    </select>
                </div>

                <button type="button" class="btn btn-success" data-dismiss="modal" onClick={e => onRegister(e)} >
                    Register
                </button>

            </form>
        </div>
      </div>
      <div class="blob">
        <svg viewBox="0 0 800 500" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg" xmlnsXlink="http://www.w3.org/1999/xlink" width="100%" id="blobSvg">
          <g transform="translate(122.29136657714844, 3.9562835693359375)">
            <defs>
              <linearGradient id="gradient" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" class="start-1"></stop>
                <stop offset="100%" class="start-2"></stop>
              </linearGradient>
            </defs>
            <path fill="url(#gradient)">
              <animate attributeName="d"
                dur="8s"
                repeatCount="indefinite"
                
                values="M451,322.5Q449,395,376,404.5Q303,414,246,426.5Q189,439,146,398Q103,357,92,303.5Q81,250,79,187Q77,124,132.5,92Q188,60,250,60Q312,60,367,92.5Q422,125,437.5,187.5Q453,250,451,322.5Z;
                        M417.5,302.5Q394,355,355,404Q316,453,252.5,445.5Q189,438,140.5,401.5Q92,365,61.5,307.5Q31,250,60,191.5Q89,133,142,107Q195,81,256,62Q317,43,359,91.5Q401,140,421,195Q441,250,417.5,302.5Z;
                        M395,299.5Q386,349,353.5,409.5Q321,470,256.5,450Q192,430,154.5,388Q117,346,101.5,298Q86,250,69,178Q52,106,127.5,105.5Q203,105,254,93Q305,81,369.5,98.5Q434,116,419,183Q404,250,395,299.5Z;
                        M451,322.5Q449,395,376,404.5Q303,414,246,426.5Q189,439,146,398Q103,357,92,303.5Q81,250,79,187Q77,124,132.5,92Q188,60,250,60Q312,60,367,92.5Q422,125,437.5,187.5Q453,250,451,322.5Z"
                ></animate>
            </path>
          </g>
        </svg>
      </div>
      <div class="blob">
        <svg viewBox="0 0 800 500" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg" xmlnsXlink="http://www.w3.org/1999/xlink" width="100%" id="blobSvg">
          <g transform="translate(122.29136657714844, 3.9562835693359375)">
            <defs>
              <linearGradient id="gradient" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" class="start-1"></stop>
                <stop offset="100%" class="start-2"></stop>
              </linearGradient>
            </defs>
            <path fill="url(#gradient)">
              <animate attributeName="d"
                dur="8s"
                repeatCount="indefinite"
                
                values="M451,322.5Q449,395,376,404.5Q303,414,246,426.5Q189,439,146,398Q103,357,92,303.5Q81,250,79,187Q77,124,132.5,92Q188,60,250,60Q312,60,367,92.5Q422,125,437.5,187.5Q453,250,451,322.5Z;
                        M417.5,302.5Q394,355,355,404Q316,453,252.5,445.5Q189,438,140.5,401.5Q92,365,61.5,307.5Q31,250,60,191.5Q89,133,142,107Q195,81,256,62Q317,43,359,91.5Q401,140,421,195Q441,250,417.5,302.5Z;
                        M395,299.5Q386,349,353.5,409.5Q321,470,256.5,450Q192,430,154.5,388Q117,346,101.5,298Q86,250,69,178Q52,106,127.5,105.5Q203,105,254,93Q305,81,369.5,98.5Q434,116,419,183Q404,250,395,299.5Z;
                        M451,322.5Q449,395,376,404.5Q303,414,246,426.5Q189,439,146,398Q103,357,92,303.5Q81,250,79,187Q77,124,132.5,92Q188,60,250,60Q312,60,367,92.5Q422,125,437.5,187.5Q453,250,451,322.5Z"
                ></animate>
            </path>
          </g>
        </svg>
      </div>
      </section>
      {/* <div class="bubbles">
        <span style={{ "--i": 11 }}></span>
        <span style={{ "--i": 12 }}></span>
        <span style={{ "--i": 13 }}></span>
      </div> */}
    </Fragment>
  );
};

export default LoginPage;
