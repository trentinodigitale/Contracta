BrowseInPage = 0;
function VisualizzaDocumenti(grid, r, c) {
	//-- recupero il codice della riga passata

	var CodiceFornitore;
	try {
		CodiceFornitore = getObj('R' + r + '_CodiceFornitore')[0].value;
	} catch (e) {
		CodiceFornitore = getObj('R' + r + '_CodiceFornitore').value;
	}

	ShowSearchDoc('CARCodiceFornitore#~#\'' + CodiceFornitore + '\'#~# = ');

}


function VisualizzaDocFromArt(grid, r, c) {
	//-- recupero il codice della riga passata

	var CodiceArticolo;
	try {
		CodiceArticolo = getObj('R' + r + '_artCode')[0].value;
	} catch (e) {
		CodiceArticolo = getObj('R' + r + '_artCode').value;
	}

	ShowSearchDoc('Codice Articolo#~#\'' + CodiceArticolo + '\'#~# = ');

}

function ShowSearchDoc(Filtro) {
	var STR;
	STR = '<link rel=stylesheet href="../CTL_Library/Themes/SinteticHelp.css" type="text/css">';

	STR = STR + '<table class="SinteticHelp" width="100%" height="100%" ><tr><td class="SinteticHelp_label" width="100%" height="100%" align="center" valign="center" >';
	STR = STR + CNV('../', 'Loading ...');
	STR = STR + '</td></tr></table>';
	parent.ViewerFiltro.document.body.innerHTML = STR


	var URL;
	URL = 'ViewerFiltro.asp?STORED_SQL=yes&JSIN=no&Table=DASHBOARD_SP_DOSSIER&OWNER=&IDENTITY=IdMsg&TOOLBAR=DASHBOARD_SP_DOSSIER_TOOLBAR&DOCUMENT=ORDINE_DA_RDF&PATHTOOLBAR=../customdoc/&JSCRIPT=DASHBOARD_SP_DOSSIER&AreaAdd=no&Caption=';
	//    URL = URL  + '&Height=260,100*,210&numRowForPag=15&Sort=Data&SortOrder=desc';
	URL = URL + '&Height=260,100*,210&numRowForPag=15&Sort=&SortOrder=';
	URL = URL + '&Filter=' + escape(Filtro);
	URL = URL + '&FilteredOnly=yes&ACTIVESEL=1&ONSUBMIT=WiewLoading();';

	parent.ViewerFiltro.location = URL;

	//-- inserire il titolo, e la scritta filtra
	var objDescFolder;
	objDescFolder = parent.parent.frames['intestazione'].getObj('DescFolder');
	objDescFolder.innerText = CNV('../', 'Dossier / Documenti');



	STR = '<link rel=stylesheet href="../CTL_Library/Themes/SinteticHelp.css" type="text/css">';

	STR = STR + '<table class="SinteticHelp" width="100%" height="100%" ><tr><td class="SinteticHelp_label" width="100%" height="100%" align="center" valign="center" >';
	STR = STR + CNV('../', 'E\' necessario completare i parametri di ricerca nei campi di filtro oppure premere filtra');
	STR = STR + '</td></tr></table>';
	//parent.ViewerGriglia.document.body.innerHTML = STR
	document.body.innerHTML = STR;
}


function VisualizzaAziFromArt(grid, r, c) {
	//-- recupero il codice della riga passata

	var CodiceArticolo;
	try {
		CodiceArticolo = getObj('R' + r + '_artCode')[0].value;
	} catch (e) {
		CodiceArticolo = getObj('R' + r + '_artCode').value;
	}

	ShowSearchAzi('CodiceArticolo#~#\'' + CodiceArticolo + '\'#~# = ');
}

function ShowSearchAzi(Filtro) {


	var STR;
	STR = '<link rel=stylesheet href="../CTL_Library/Themes/SinteticHelp.css" type="text/css">';

	STR = STR + '<table class="SinteticHelp" width="100%" height="100%" ><tr><td class="SinteticHelp_label" width="100%" height="100%" align="center" valign="center" >';
	STR = STR + CNV('../', 'Loading ...');
	STR = STR + '</td></tr></table>';
	parent.ViewerFiltro.document.body.innerHTML = STR




	var URL;
	URL = 'ViewerFiltro.asp?STORED_SQL=yes&JSIN=no&Table=DASHBOARD_SP_DOSSIER_AZI&OWNER=&IDENTITY=IdAzi&TOOLBAR=DASHBOARD_SP_DOSSIER_AZI_TOOLBAR&DOCUMENT=ORDINE_DA_RDF&PATHTOOLBAR=../customdoc/&JSCRIPT=DASHBOARD_SP_DOSSIER&AreaAdd=no&Caption=';
	URL = URL + '&Height=260,100*,210&numRowForPag=15&Sort=aziRagioneSociale&SortOrder=asc';
	URL = URL + '&Filter=' + escape(Filtro);
	URL = URL + '&FilteredOnly=yes&ACTIVESEL=1&ONSUBMIT=WiewLoading();';

	parent.ViewerFiltro.location = URL;

	//-- inserire il titolo, e la scritta filtra
	var objDescFolder;
	objDescFolder = parent.parent.frames['intestazione'].getObj('DescFolder');
	objDescFolder.innerText = CNV('../', 'Dossier / Fornitori');


	//var STR;
	STR = '<link rel=stylesheet href="../CTL_Library/Themes/SinteticHelp.css" type="text/css">';

	STR = STR + '<table class="SinteticHelp" width="100%" height="100%" ><tr><td class="SinteticHelp_label" width="100%" height="100%" align="center" valign="center" >';
	STR = STR + CNV('../', 'E\' necessario completare i parametri di ricerca nei campi di filtro oppure premere filtra');
	STR = STR + '</td></tr></table>';
	//parent.ViewerGriglia.document.body.innerHTML = STR
	document.body.innerHTML = STR;
}




function ShowListini(param) {
	var idRow;
	var vet;
	var altro;
	var target;

	//debugger;
	vet = param.split('#');

	var w;
	var h;
	var Left;
	var Top;

	target = "Listini";
	if (vet.length >= 2) {
		target = vet[1];
	}

	if (vet.length < 3) {
		w = screen.availWidth;
		h = screen.availHeight;
		Left = 0;
		Top = 0;
	}
	else {
		var d;
		d = vet[2].split(',');
		w = d[0];
		h = d[1];
		Left = (screen.availWidth - w) / 2;
		Top = (screen.availHeight - h) / 2;

		if (vet.length > 3) {
			altro = vet[3];
		}
	}


	//-- recupera il codice della riga selezionata

	idRow = Grid_GetIdSelectedRow('GridViewer');

	while (idRow.indexOf('~~~') >= 0)
		idRow = idRow.replace('~~~', ',');

	if (idRow == '') {
		//alert( "E' necessario selezionare prima una riga" );
		DMessageBox('../CTL_Library/', 'E\' necessario selezionare prima una riga', 'Attenzione', 2, 400, 300);
	}
	else {
		ExecFunction(vet[0] + '&FilterHide=' + idRow, target, ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro);
	}

}


function VisualizzaDocumentiIdAzi(grid, r, c) {
	//-- recupero il codice della riga passata
	var cod = GetIdRow(grid, r, 'self');


	ShowSearchDoc('idAziPartecipante#~#\'' + cod + '\'#~# = ');

}





function Inoltra() {

	var idRow = Grid_GetIdSelectedRow('GridViewer');
	while (idRow.indexOf('~~~') >= 0)
		idRow = idRow.replace('~~~', ',');

	if (idRow == '') {
		DMessageBox('../CTL_Library/', 'E\' necessario selezionare prima una riga', 'Attenzione', 2, 400, 300);
	}
	else {
		ExecFunctionCenter('../GestioneArchivi/N_Inoltra.asp?ListIdMsg=' + idRow + '#InfoFiltri#350,300');
	}
}





function UPDAZI() {
	var idRow = Grid_GetIdSelectedRow('GridViewer');


	if (idRow == '') {
		DMessageBox('../CTL_Library/', 'E\' necessario selezionare prima una riga', 'Attenzione', 2, 400, 300);
		return;
	}


	if (idRow.indexOf('~~~') >= 0) {
		DMessageBox('../CTL_Library/', 'E\' necessario selezionare solo una riga', 'Attenzione', 2, 400, 300);
		return;
	}

	ExecFunctionCenter('../DASHBOARD/Viewer.asp?OWNER=idpfu&Table=DASHBOARD_VIEW_UPDAZI&IDENTITY=PARAM&DOCUMENT=,' + idRow + '&PATHTOOLBAR=../CustomDoc/&JSCRIPT=anagrafica&AreaAdd=no&Caption=Modifica anagrafica&Height=0,100*,210&numRowForPag=20&Sort=&SortOrder=&Exit=si&AreaFiltro=no&FilterHide=idazi = ' + idRow + '#UPDAZI#400,350');

}




function SendMailToAzi() {

	var List = Grid_GetIndSelectedRow('GridViewer')


	//mailto:mtscf@microsoft.com?
	//subject=Feedback&amp;
	//bcc=pippo@lll.it,....,ddd@dd.it;
	var strBcc = '';
	var strMailto = 'mailto:?subject=Oggetto Mail Aziende&bcc=';

	if (List == '') {

		DMessageBox('../CTL_Library/', 'E\' necessario selezionare prima una riga', 'Attenzione', 2, 400, 300);
		return;

	}
	var VetAzi = List.split('~~~');
	var nNumAzi = VetAzi.length;
	var email = '';
	var emailRP = '';

	for (ILoop = 0; ILoop < nNumAzi; ILoop++) {
		email = getObjValue('R' + VetAzi[ILoop] + '_aziE_Mail');

		try {
			emailRP = getObjValue('R' + VetAzi[ILoop] + '_EmailRapLeg');
		} catch (e) { emailRP = ''; }

		if (email != '') {
			if (strBcc == '')
				strBcc = email;
			else
				strBcc = strBcc + ',' + email;
		}


		if (emailRP != '') {
			if (strBcc == '')
				strBcc = emailRP;
			else
				strBcc = strBcc + ',' + emailRP;
		}
	}


	strMailto = strMailto + strBcc + ';';
	getObj('SendMailAnchor').href = strMailto;
	getObj('SendMailAnchor').click();

}


function WiewLoading() {
	parent.ViewerGriglia.document.body.innerHTML = '<table class="Loading" width="100%" height="100%" ><tr><td width="100%" height="100%" align="center" valign="center" >Loading ...</td></tr></table>';
}


/*   PARTE PER GESTIONE FILTRO MODELLI CLASSI   */

$(document).ready(function () {
	$.getScript('../customdoc/jsapp/FILTRO_ADD_INFO.js',
		function () {
			addButtonAdInfoFilterDossier();
		});
});
