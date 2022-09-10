// source https://gist.github.com/ragog/c48828edc349b8bef82a2c99fdcecddb

// ==UserScript==
// @name         Github - dismiss cookies warning
// @include      https://github.com/*
// @run-at       document-start
// @grant        none
// ==/UserScript==



(function(){
"use strict";
if (document.readyState != 'loading') reject();
else document.addEventListener('DOMContentLoaded', reject);

function reject() {
  var e=document.querySelector('.js-cookie-consent-reject');
  e && e.click();
  }

})();
