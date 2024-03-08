var prefsLoaded = false;
var defaultFontSize = 100;
var currentFontSize = defaultFontSize;
var fontSizeTitle;
var bigger;
var smaller;
var reset;
var biggerTitle;
var smallerTitle;
var resetTitle;

function setFontSize(fontSize) {
	document.body.style.fontSize = fontSize + '%';
}

function changeFontSize(sizeDifference) {
	currentFontSize = parseInt(currentFontSize, 10) + parseInt(sizeDifference * 5, 10);
	if (currentFontSize > 180) {
		currentFontSize = 180;
	} else if (currentFontSize < 60) {
		currentFontSize = 60;
	}
	setFontSize(currentFontSize);
}

function revertStyles() {
	currentFontSize = defaultFontSize;
	changeFontSize(0);
}

function writeFontSize(value) 
{
	Cookie.write("fontSize", value, {duration: 180});
}

function readFontSize() 
{
	return Cookie.read("fontSize");
}

function setUserOptions() 
{
	if (!prefsLoaded) {
		var size = readFontSize();
		currentFontSize = size ? size : defaultFontSize;
		setFontSize(currentFontSize);
		prefsLoaded = true;
	}
}

function addControls() 
{
	var container = document.id('links_top_access');
	var virtualDir = GetVirtualDirectory();
	
	//var content = '<a href="/' + virtualDir + '/index.php?template=aflinktemplate3_contrast" title="contrasto">Alto contrasto</a>|<!--<h3>Dimensione font:</h3>--><a title="Aumenta dimensioni font" href="#" onclick="changeFontSize(2); return false">A(+)</a>|<a href="#" title="Ripristina dimensioni font" onclick="revertStyles(); return false">Ripristina font</a>|<a href="#" title="Riduci dimensione font" onclick="changeFontSize(-2); return false">a(-)</a>';
	
	var content = '<h3 id="dimensione_font">Dimensione font:</h3><a title="Aumenta dimensioni font" href="#" onclick="changeFontSize(2); return false">A(+)</a>|<a href="#" title="Ripristina dimensioni font" onclick="revertStyles(); return false">Ripristina font</a>|<a href="#" title="Riduci dimensione font" onclick="changeFontSize(-2); return false">a(-)</a>';
	
	container.set('html', content);
}

function GetVirtualDirectory() 
{
	var url = window.location.href;
	url = url.replace("http://","");
	url = url.replace("https://","");
	
	var url_parts = url.split('/');
	return url_parts[1];
}

function saveSettings() 
{
	writeFontSize(currentFontSize);
}

window.addEvent('domready', setUserOptions);
window.addEvent('domready', addControls);
window.addEvent('unload', saveSettings);