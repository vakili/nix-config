
// see https://janjongerden.nl/blog/remove-a-div.html
// ==UserScript==
// @name        sx-pretty
// @include     https://stackoverflow.com/*
// @include     https://*.stackexchange.com/*
// @version     1
// @grant       none
// @noframes
// ==/UserScript==

(function(){
    "use strict";
    if (document.readyState != 'loading') hide();
    else document.addEventListener('DOMContentLoaded', hide);

    function hide() {
        var e=document.getElementsByClassName('s-btn s-btn__muted p8 js-dismiss');
        e && e[0].click();
    }

})();
