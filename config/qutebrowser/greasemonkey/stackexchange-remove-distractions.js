// see https://janjongerden.nl/blog/remove-a-div.html
// ==UserScript==
// @name        sx-pretty
// @include     https://stackoverflow.com/*
// @include     https://*.stackexchange.com/*
// @version     1
// @grant       none
// @noframes
// ==/UserScript==

document.getElementsByClassName('d-block p0 m0')[0].remove(); // "the overflow blog", "featured on meta"
// document.getElementsByClassName('orange tagged tex2jax_ignore clc-jobs-multi')[0].remove() // jobs
document.getElementsByClassName('s-btn s-btn__muted s-btn__icon js-notice-close')[0].click(); // cookies
document.getElementsByClassName('grid--cell s-btn s-btn__muted s-btn__icon px8 js-dismiss')[0].click(); // "join stackexchange" bottom bar
// document.getElementsByClassName('s-btn s-btn__muted p8 js-dismiss')[0].click(); // "join stackexchange" top bar
