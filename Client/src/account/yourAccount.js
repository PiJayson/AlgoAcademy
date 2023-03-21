//      --libraries--       //
import React, { Fragment, useEffect, useState } from "react";

const YourAccount = () => {
  const [ isVerified, setIsVerified ] = useState(false);

  const verify = async e => {
    e.preventDefault();
    try {
      const response = await fetch(`http://localhost:5000/account/verify`, {
        method: "POST",
        credentials: 'include',
      }).then(e => e.json().then(ee =>
        ee == "DONE" ? window.location.reload() : null
      ));
    } catch (err) {
      console.error(err.message);
    }
  };

  function getCookie(cookieName) {
    let cookie = {};
    document.cookie.split(';').forEach(function(el) {
      let [key,value] = el.split('=');
      cookie[key.trim()] = value;
    })
    return cookie[cookieName];
  }

  const getIsVerified = async () => {
    try {
      const response = await fetch(`http://localhost:5000/account/isvalidated`, {
        method: "GET",
        credentials: 'include'
      });
      const jsonData = await response.json();

      setIsVerified(jsonData);
    } catch (err) {
      console.error(err.message);
    }
  };

  useEffect(() => {
    getIsVerified();
  }, []);

  return (
      <Fragment>
    <h1 className="text-center mt-5">{ getCookie("username") }</h1>
    <div class="container">
        <div class="col-md-12 mt-5 text-center">
            { isVerified ? <div>Verified</div> : 
            <button className="btn btn-success text-center" onClick={(e) => verify(e)}>
                Verify
            </button>}
        </div>
    </div>
    </Fragment>
  );
};

export default YourAccount;
