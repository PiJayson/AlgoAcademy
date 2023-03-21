import React, { Fragment, useContext, useEffect, useState } from "react";
import { useLocation } from 'react-router-dom';

const NavBar = () => {

    function getCookie(cookieName) {
        let cookie = {};
        document.cookie.split(';').forEach(function(el) {
          let [key,value] = el.split('=');
          cookie[key.trim()] = value;
        })
        return cookie[cookieName];
      }

      function removeCookie(cookieName) {
        console.log("logout");
        document.cookie.split(";").forEach((c) => {
            document.cookie = c
            .replace(/^ +/, "")
            .replace(/=.*/, "=;expires=" + new Date().toUTCString() + ";path=/");
        });

      }

    const location = useLocation();

  return (
      <Fragment>
        <nav class="navbar navbar-expand-sm bg-dark navbar-dark">
            <ul class="navbar-nav mr-auto">
                <li class="nav-item">
                    <a class="nav-link" href="/admin/#Country">Tables</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="/problems">Problems</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="/submits">Submits</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="/ranking">Ranking</a>
                </li>
            </ul>
            
            <ul class="navbar-nav">
                <li class="nav-item">
                    <a class="nav-link" href="/account">YourAccount</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="/login" onClick ={ () => {removeCookie()}}>Logout</a>
                </li>
            </ul>
            <span class="navbar-text" style={{ color: "white", fontWeight: "bold"}}>
                { getCookie("username") }
            </span>
        </nav>
      </Fragment>
  );
};

export default NavBar;
