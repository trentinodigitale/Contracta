//window.onload = OnLoadPage;

$(document).ready(function () {
	OnLoadPage();
});


function OnLoadPage() {
	// var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
}


// Apro l'URL fornito da GGAP per compleare il lavoro su GGAP
function OpenGgapPage() {
	var idPfu = idpfuUtenteCollegato;
	var idPfuParam = 'idPfu=' + idPfu;

	var idAzi = idaziAziendaCollegata;
	var idAziParam = 'idAzi=' + idAzi;

	var idDocRichiestaCig = getObj('IDDOC').value;
	var idRichiestaCigParam = 'idRichiestaCig=' + idDocRichiestaCig;

	var url = "/SimogGgapApi/Gara/GetGgapLandingPage?" + idPfuParam + "&" + idRichiestaCigParam + "&" + idAziParam;

	ajax = GetXMLHttpRequest();
	ajax.open("GET", url, false);
	ajax.send(null);

	if (ajax.readyState == 4) {
		if (ajax.status === 200) {
			var responseArray = ajax.responseText.split('#');
			var response = responseArray[1].replaceAll('"', '');

			if (responseArray[0].includes('1')) {
				console.log('response: ' + response); // TODO
				window.open(response, '_blank');
			}
			else // if (responseArray[0].includes('0'))
			{
				index = response.indexOf('Error');
				if (index > -1)
					var responseError = response.slice(index); // var responseError = response.substr(index);
				else
					var responseError = response;

				DMessageBox('../', 'NO_ML###Errore nel ottenere l\'url per apprire la pagina di GGAP. - ' + responseError, 'Attenzione', 1, 400, 300);
			}
		}
		else {
			var ajaxError = "Error: " + JSON.parse(ajax.responseText).Message + ' - Status: ' + ajax.status + ', ' + ajax.statusText;
			DMessageBox('../', 'NO_ML###Errore nel chiamare il web server per ottenere la pagina di GGAP. - ' + ajaxError, 'Attenzione', 1, 600, 400);
		}
	}
}
