

function GetXMLHttpRequest() {
	var
		XHR = null,
		browserUtente = navigator.userAgent.toUpperCase();

	if(typeof(XMLHttpRequest) === "function" || typeof(XMLHttpRequest) === "object")
		XHR = new XMLHttpRequest();
		else if(window.ActiveXObject && browserUtente.indexOf("MSIE 4") < 0) {
			if(browserUtente.indexOf("MSIE 5") < 0)
				XHR = new ActiveXObject("Msxml2.XMLHTTP");
			else
				XHR = new ActiveXObject("Microsoft.XMLHTTP");
		}
		return XHR;
};

// funzione per prendere un elemento con id univoco
function prendiElementoDaId(id_elemento) {
	var elemento;
		if(document.getElementById)
			elemento = document.getElementById(id_elemento);
		else
			elemento = document.all[id_elemento];
		return elemento;
};



function CNV( path , testo ){
	

  
	ajax = GetXMLHttpRequest(); //Creo l'oggetto xmlhttp
  var nocache = new Date().getTime();
  
	if(ajax){
				 
		  
			ajax.open("GET", path + 'CTL_Library/functions/CNV.asp?TXT=' + escape( testo ) + '&nocache=' + nocache, false);
			 
			ajax.send(null);


			//ajax.onreadystatechange = function() {
			if(ajax.readyState == 4) {
				if(ajax.status == 200)
				{
					return ajax.responseText;
				}
			}
			//}

	}
	return '???' + testo;
}


function CNV_AsyncInnerHTML( path , testo , Obj ){
	

	ajax = GetXMLHttpRequest(); //Creo l'oggetto xmlhttp

	if(ajax){
				 
		
			ajax.open("GET", path + 'CTL_Library/functions/CNV.asp?TXT=' + escape( testo ) , true);
			 


			ajax.onreadystatechange = function() {
			if(ajax.readyState == 4) {
				if(ajax.status == 200)
				{
					prendiElementoDaId( Obj ).innerHTML =  ajax.responseText;
				}
			}
			}
			ajax.send(null);
		return true;
	}
	return false;
	
}


