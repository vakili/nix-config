// ==UserScript==
// @name          Nitter Teleporter
// @namespace     lousando
// @match         https://*/*
// @match         http://*/*
// @exclude-match https://nitter.net*
// @grant         GM_getValue
// @run-at        document-idle
// @version       0.1
// @author        Louis Sandoval
// @description   Converts Twitter links to Nitter ones
// ==/UserScript==

// allow for overriding of Nitter instance
const nitterDomain = GM_getValue("nitter_domain", "nitter.net");

const convertTwitterLinks = () => { 
  const twitterRegex = /twitter\.com?/i;
  
  // links
  Array.from(document.body.querySelectorAll("a[href]")).filter(link => {
    return twitterRegex.test(link.href);
  }).forEach(link => {
    link.innerText = link.innerText.replace(twitterRegex, nitterDomain);
    link.setAttribute("href", link.href.replace(twitterRegex, nitterDomain));
  });
};

// Create an observer instance linked to the callback function
const observer = new MutationObserver(convertTwitterLinks);

convertTwitterLinks();

// Start observing the target node for configured mutations
observer.observe(document, {
  childList: true, 
  subtree: true
});
