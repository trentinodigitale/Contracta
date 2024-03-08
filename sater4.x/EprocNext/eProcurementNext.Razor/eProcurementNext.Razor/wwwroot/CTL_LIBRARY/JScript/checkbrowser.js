
var nVer = navigator.appVersion;
var nAgt = navigator.userAgent;
var browserName  = '';
var fullVersion  = 0; 
var majorVersion = 0;

// In Internet Explorer, the true version is after "MSIE" in userAgent
if ((verOffset=nAgt.indexOf("MSIE"))!=-1) {
 browserName  = "Microsoft Internet Explorer";
 fullVersion  = parseFloat(nAgt.substring(verOffset+5));
 majorVersion = parseInt(''+fullVersion);
}

// In Opera, the true version is after "Opera" 
else if ((verOffset=nAgt.indexOf("Opera"))!=-1) {
 browserName  = "Microsoft Internet Explorer";
 fullVersion  = parseFloat(nAgt.substring(verOffset+6));
 majorVersion = parseInt(''+fullVersion);
}

// In most other browsers, "name/version" is at the end of userAgent 
else if ( (nameOffset=nAgt.lastIndexOf(' ')+1) < (verOffset=nAgt.lastIndexOf('/')) ) 
{
 browserName  = nAgt.substring(nameOffset,verOffset);
 fullVersion  = parseFloat(nAgt.substring(verOffset+1));
 if (!isNaN(fullVersion)) majorVersion = parseInt(''+fullVersion);
 else {fullVersion  = 0; majorVersion = 0;}
}

// Finally, if no name and/or no version detected from userAgent...
if (browserName.toLowerCase() == browserName.toUpperCase()
 || fullVersion==0 || majorVersion == 0 )
{
 browserName  = navigator.appName;
 fullVersion  = parseFloat(nVer);
 majorVersion = parseInt(nVer);
}


