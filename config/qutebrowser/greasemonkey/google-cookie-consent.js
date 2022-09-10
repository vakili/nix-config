// source https://greasyfork.org/en/scripts/412348-google-dismiss-cookies-warning
// ==UserScript==
// @name         Google - dismiss cookies warning
// @name:fr      Google - supprimer l'avertissement de cookies
// @namespace    https://github.com/Procyon-b
// @version      0.1
// @description  Agrees to the cookies dialog to make it disappear forever
// @description:fr  Confirme l'acceptation des cookies pour le faire disparaître définitivement
// @author       Achernar
// @include      https://consent.google.*/*
// @run-at       document-start
// @grant        none
// ==/UserScript==

(function(){
"use strict";
if (document.readyState != 'loading') consent();
else document.addEventListener('DOMContentLoaded', consent);

function consent() {
  var e=document.querySelector('#introAgreeButton');
  e && e.click();
  }

})();