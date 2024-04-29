window.onload = OnLoadPage;

function OnLoadPage() {
	//Alternate_ISCRITTI();	
	try {
		if (getObjValue('DOCUMENT_READONLY') == '0') {
			getObj('PresenzaDGUE').onchange = DGUE_Request_Active;

		}
	} catch (e) { }
	try {
		if (getObjValue('DGUEAttivo') != 'si') {
			document.getElementById('DGUE').style.display = "none";
		}
	} catch (e) { }


	//se documento editabile filtro il campo DirezioneEspletante in base all'azienda Ente
	if (getObjValue('DOCUMENT_READONLY') == '0') {
		try { filtroDirezioneEspletante(); } catch (e) { }

	}


}


function LISTA_DOCUMENTI_OnLoad() {

	/* if (getObj('IDDOC').value.substring(0,3) == 'new' )
	 {
		 LISTA_DOCUMENTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=&Table=BANDO_ALBO_LISTA_DOCUMENTI&JSCRIPT=BANDO&IDENTITY=Id&DOCUMENT=BANDO&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=0,100*,0&numRowForPag=15&Sort=data&ActiveSel=2&SortOrder=asc&Exit=no&ShowExit=0&AreaFiltroWin=close&FilterHide=IdDoc = 0 ';
	 }
	 else
	 {
		 LISTA_DOCUMENTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=&Table=BANDO_ALBO_LISTA_DOCUMENTI&JSCRIPT=BANDO&IDENTITY=Id&DOCUMENT=BANDO&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=0,100*,0&numRowForPag=15&Sort=data&ActiveSel=2&SortOrder=asc&Exit=no&ShowExit=0&AreaFiltroWin=close&FilterHide=LinkedDoc =' + getObj('IDDOC').value ;;	
	 }
	 */
}

function Cancella_Iscrizione(objGrid, Row, c) {

	/* var cod;
   	
	 //-- recupero il codice della riga passata
	   cod = GetIdRow( objGrid , Row , 'self' );
	 
	 //se lo stato è cancellato allora messaggio
	 var ValueStatoIscrizione;
	 
	 ValueStatoIscrizione = getObj( 'val_RISCRITTIGrid_' + Row + '_StatoIscrizione_extraAttrib').value;
	 \
	 if (ValueStatoIscrizione == 'value#=#Cancellato'){
	 
	   DMessageBox( '../' , 'iscrizione operatore gia cancellata' , 'Attenzione' , 1 , 400 , 300 );
   	
	   
	 }else{
	   
	   //innesco createfrom per creare documento CANCELLA_ISCRIZIONE
	   //ExecFunctionSelf(  pathRoot + 'ctl_Library/document/MakeDocFrom.asp?TYPE_TO=CANCELLA_ISCRIZIONE&IDDOC='+ cod + '&TYPEDOC=BANDO_ISCRIZ_ALBO' , '', '');
			 var strURL = 'ctl_library/document/document.asp?';
	   url = encodeURIComponent(strURL + 'JScript=CANCELLA_ISCRIZIONE&lo=base&DOCUMENT=CANCELLA_ISCRIZIONE&MODE=CREATEFROM&PARAM=BANDO_ISCRIZ_ALBO,' + cod );
		 return ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
	   
	 }*/

	//-- recupero il codice della riga passata
	cod = GetIdRow(objGrid, Row, 'self');

	//alert(cod);

	var strDoc = '';

	try { strDoc = getObj('R' + objGrid + '_' + Row + '_OPEN_DOC_NAME').value; } catch (e) { };

	if (strDoc == '' || strDoc == undefined) {
		try { strDoc = getObj('R' + objGrid + '_' + Row + '_OPEN_DOC_NAME')[0].value; } catch (e) { };
	}

	if (strDoc == '' || strDoc == undefined) {
		alert('Errore tecnico - ' + 'R' + objGrid + '_' + Row + '_OPEN_DOC_NAME - non trovato');
		return;
	}

	var TYPEDOC = '';

	try { TYPEDOC = getObj('R' + objGrid + '_' + Row + '_MAKE_DOC_NAME').value; } catch (e) { };

	if (TYPEDOC == '' || TYPEDOC == undefined) {
		try { TYPEDOC = getObj('R' + objGrid + '_' + Row + '_MAKE_DOC_NAME')[0].value; } catch (e) { };
	}

	if (TYPEDOC == '' || TYPEDOC == undefined) {
		alert('Errore tecnico - ' + 'R' + objGrid + '_' + Row + '_MAKE_DOC_NAME - non trovato');
		return;
	}

	var param = '';

	param = TYPEDOC + '##' + strDoc + '#' + cod + '#';

	MakeDocFrom(param);


}

function ListaIscrittiToExcel(param) {

	var QS = param;

	var win;

	win = ExecFunction('../../dashboard/viewerExcel.asp?OPERATION=EXCEL' + '&' + QS + '&', '', '');


}

function Alternate_ISCRITTI() {
	if (getObj('JumpCheck').value == 'BANDO_ALBO_LAVORI')
		ShowCol('ISCRITTI', 'ClasseIscriz', 'none');
	else
		ShowCol('ISCRITTI', 'ClassificazioneSOA', 'none');

	if (getObj('TipoBando').value == 'BANDO_ALBO_PROFESSIONISTI') {
		ShowCol('ISCRITTI', 'ClassificazioneSOA', 'none');
		ShowCol('ISCRITTI', 'ClasseIscriz', 'none');
	}

}





function DGUE_Request_Active() {
	//--- attiva la presenza del template che se assente viene creato con un processo
	if (getObjValue('PresenzaDGUE') == 'si' && getObjValue('idTemplate') == '') {
		ExecDocProcess('ATTIVA_DGUE,BANDO,,NO_MSG');
	}

}

function DGUE_Request() {
	if (getObjValue('PresenzaDGUE') == 'si') {
		MakeDocFrom('TEMPLATE_CONTEST##BANDO');
	}
	else {
		DMessageBox('../', 'E\' necessario aver selezionato la presenza del DGUE', 'Attenzione', 1, 400, 300);
	}

}


function MyOpenViewer(param) {
	if (getObjValue('JumpCheck') == '' || getObjValue('JumpCheck') == undefined || getObjValue('JumpCheck') == 'BANDO_ALBO_FORNITORI') {
		OpenViewer('Viewer.asp?STORED_SQL=yes&OWNER=&Table=DASHBOARD_SP_DASHBOARD_VIEW_OE_ALBO&ModelloFiltro=DASHBOARD_VIEW_OE_ALBOFiltro&ModGriglia=DASHBOARD_VIEW_OE_ALBOGriglia&IDENTITY=idrow&lo=base&HIDE_COL=&DOCUMENT=PDA_COMUNICAZIONE_GENERICA&PATHTOOLBAR=../CustomDoc/&JSCRIPT=PDA_COMUNICAZIONE_GENERICA&AreaAdd=no&Caption=Ricerca Operatori Economici&Height=180,100*,210&numRowForPag=20&Sort=idrow&SortOrder=asc&Exit=si&AreaFiltro=&FilteredOnly=yes&ONSUBMIT=WiewLoading()&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_RICERCA_OPERATORI_ECONOMICI&ACTIVESEL=2&FilterHide=IdHeader=' + getObj('IDDOC').value);
	}
	if (getObjValue('JumpCheck') == 'BANDO_ALBO_PROFESSIONISTI') {
		OpenViewer('Viewer.asp?STORED_SQL=yes&OWNER=&Table=DASHBOARD_SP_DASHBOARD_VIEW_OE_ALBO&ModelloFiltro=DASHBOARD_VIEW_OE_ALBO_PROFFiltro&ModGriglia=DASHBOARD_VIEW_OE_ALBO_PROFGriglia&IDENTITY=idrow&lo=base&HIDE_COL=&DOCUMENT=PDA_COMUNICAZIONE_GENERICA&PATHTOOLBAR=../CustomDoc/&JSCRIPT=PDA_COMUNICAZIONE_GENERICA&AreaAdd=no&Caption=Ricerca Operatori Economici&Height=180,100*,210&numRowForPag=20&Sort=idrow&SortOrder=asc&Exit=si&AreaFiltro=&FilteredOnly=yes&ONSUBMIT=WiewLoading()&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_RICERCA_OPERATORI_ECONOMICI_PROF&ACTIVESEL=2&FilterHide=IdHeader=' + getObj('IDDOC').value);
	}
	if (getObjValue('JumpCheck') == 'BANDO_ALBO_LAVORI') {
		OpenViewer('Viewer.asp?STORED_SQL=yes&OWNER=&Table=DASHBOARD_SP_DASHBOARD_VIEW_OE_ALBO&ModelloFiltro=DASHBOARD_VIEW_OE_ALBO_LAVFiltro&ModGriglia=DASHBOARD_VIEW_OE_ALBO_LAVGriglia&IDENTITY=idrow&lo=base&HIDE_COL=&DOCUMENT=PDA_COMUNICAZIONE_GENERICA&PATHTOOLBAR=../CustomDoc/&JSCRIPT=PDA_COMUNICAZIONE_GENERICA&AreaAdd=no&Caption=Ricerca Operatori Economici&Height=180,100*,210&numRowForPag=20&Sort=idrow&SortOrder=asc&Exit=si&AreaFiltro=&FilteredOnly=yes&ONSUBMIT=WiewLoading()&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_RICERCA_OPERATORI_ECONOMICI_LAV&ACTIVESEL=2&FilterHide=IdHeader=' + getObj('IDDOC').value);
	}

}

//SOLO PER IL ME
function CONTROLLO_CLASSE_ALTRI_BANDI(obj) {
	if (getObjValue('JumpCheck') == '' || getObjValue('JumpCheck') == undefined) {

		var classi_sel = getObjValue('ClasseIscriz');

		ajax = GetXMLHttpRequest();

		var nocache = new Date().getTime();

		if (ajax) {
			ajax.open("GET", '../../customdoc/CONTROLLO_CLASSE_ALTRI_BANDI.asp?IDDOC=' + getObj('IDDOC').value + '&classi_sel=' + encodeURIComponent(classi_sel) + '&nocache=' + nocache, false);

			ajax.send(null);

			if (ajax.readyState == 4) {
				//alert(ajax.status);
				if (ajax.status == 200) {
					if (ajax.responseText != '') {
						DMessageBox('../', 'Attenzione, alcune delle classi selezionate sono gia presenti per bandi pubblicati', 'Attenzione', 1, 400, 300);
						getObj('NoteScheda_V').innerHTML = ajax.responseText;
					}
					else {
						getObj('NoteScheda_V').innerHTML = '';
					}
				}
			}
		}

	}
}


function Confirm_MakeDocFrom(param) {
	//SE IL FLAG INDICA CHE DEVO FARE UNA NUOVA ESTRAZIONE E SONO IL RUP CHIEDO CONFERMA PRIMA DI FARLO

	var numrighe = GetProperty(getObj('COMMISSIONEGrid'), 'numrow');
	for (i = 0; i <= numrighe; i++) {
		if (getObjValue('R' + i + '_RuoloCommissione') == '15550') {
			responsabile_procedimento = getObjValue('R' + i + '_IdPfu');
		}
	}


	if (getObjValue('FLAG_NUOVA_ESTRAZIONE_OE') == '1' && idpfuUtenteCollegato == responsabile_procedimento) {
		ML_text = 'Si desidera eseguire una nuova estrazione?';
		Title = 'Informazione';
		ICO = 1;
		page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

		ExecFunctionModaleConfirm(page, Title, 200, 420, null, 'MakeDocFrom@@@@' + param, '');
	}
	else {
		MakeDocFrom(param);
	}
}



//applico il filtro al dominio della struttura di appartenenza
//per caricare solo i  rami relativi all'azienda collegata
function filtroDirezioneEspletante() {

	var filter = '';

	try {

		filter = 'idaz in ( ' + getObj('Azienda').value + ' )';
		getObj('DirezioneEspletante_extraAttrib').value = 'strformat#=##@#filter#=#SQL_WHERE= ' + filter + '#@#multivalue#=#0';


	}
	catch (e) { };

}


function DOCUMENTAZIONE_RICHIESTA_AFTER_COMMAND(param) {
	//per lazio la descrizione e di tipo RTE quindi 
	//dopo un comando devo rilanciare la direttiva per attivare i richtext
	try {
		$('.RTE').rte("", "../images/toolbar/");


	}
	catch (e) {
	}

}



