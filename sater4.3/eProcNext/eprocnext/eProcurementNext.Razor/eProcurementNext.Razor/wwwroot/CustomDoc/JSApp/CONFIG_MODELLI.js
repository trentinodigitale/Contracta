function getQSParam(ParamName) {
	// Memorizzo tutta la QueryString in una variabile
	QS = window.location.toString();
	// Posizione di inizio della variabile richiesta
	var indSta = QS.indexOf(ParamName);
	// Se la variabile passata non esiste o il parametro � vuoto, restituisco null
	if (indSta == -1 || ParamName == "") return null;
	// Posizione finale, determinata da una eventuale &amp; che serve per concatenare pi� variabili
	var indEnd = QS.indexOf('&', indSta);
	// Se non c'� una &amp;, il punto di fine � la fine della QueryString
	if (indEnd == -1) indEnd = QS.length;
	// Ottengo il solore valore del parametro, ripulito dalle sequenze di escape
	var valore = unescape(QS.substring(indSta + ParamName.length + 1, indEnd));
	// Restituisco il valore associato al parametro 'ParamName'
	return valore;
}

function Onload_Process() {
	//Filtro i domini di quantit� e prezzo rispetto agli attributi scelti nella griglia

	var DOCUMENT_READONLY = '0';
	try {
		if (typeof InToPrintDocument !== 'undefined') {
			DOCUMENT_READONLY = '1';
		}
		else {
			DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
		}
	}
	catch (e) {
	}
	if (DOCUMENT_READONLY == '0') {
		ActiveDrag();

	} else {
		HideColDrag();
	}

	try { filtraDominiPrz_qty(); } catch (e) { }


	var Command = getQSParam('COMMAND');
	var Process_Param = getQSParam('PROCESS_PARAM');

	ajax = GetXMLHttpRequest();

	if (Command == 'PROCESS' && (Process_Param == 'SEND:-1:CHECKOBBLIG,CONFIG_MODELLI_LOTTI' || Process_Param == 'PRE_SEND_FORMULE:-1:CHECKOBBLIG,CONFIG_MODELLI_LOTTI' || Process_Param == 'SEND,CONFIG_MODELLI_LOTTI')) {

		var nocache = new Date().getTime();

		/* 
			
			***	LA REFRESH DEL MULTILINGUISMO NON DEVE PIU' ESSERE FATTA DOPO L'INTRODUZIONE DELLA CTL_MULTILINGUISMO ***
			
			var	cod = getObj( "IDDOC" ).value;
			var Stored='SP_RECUPERO_KEY_MLG';
			var param='IDDOC='+cod+'&'+'STORED='+Stored;
	
			ajax.open("GET",   '../../ctl_library/functions/Update_Key_Multilinguismo.asp?' + param + '&nocache=' + nocache, false);
			ajax.send(null);
			
			if(ajax.readyState == 4) 
			{
				if(ajax.status == 404 || ajax.status == 500)
				{
					alert('Errore invocazione Refresh Multilinguismo.');
				}
			}
			
		*/

		ajax.open("GET", '../../ctl_library/REFRESH.ASP?COSA=MODEL&nocache=' + nocache, false);
		ajax.send(null);

		if (ajax.readyState == 4) {
			if (ajax.status == 404 || ajax.status == 500) {
				alert('Errore invocazione Refresh Modelli.');
			}
		}

		try {
			//ricarico la sezione PRODOTTI del documento chiamante. La matrice in memoria della griglia deve essere aggiornata rispetto alle modifiche effettuate
			ExecDocCommandInMem('PRODOTTI#RELOAD', getObjValue('LinkedDoc'), getObjValue('VersioneLinkedDoc'));
			//ricarico anche il chiamante
			if (isSingleWin() == false) {
				parent.opener.RefreshDocument('');

			}
		}
		catch (e) { }

	}

	getObj('Titolo').onkeyup = OnKeyUpTitolo;

	ControlloDescrizione();

	if (getObjValue('JumpCheck') != 'CODIFICA_PRODOTTI') {

		try {
			OnChangeconformita();

			//gestione dei vincoli
			HandleVincoli();
		}
		catch
		{
		}

	}

	if (getObjValue('JumpCheck') == 'AMPIEZZA_DI_GAMMA') {
		//getObj('EXTRA').style.display='none';

		//nascondo i campi DZT_NAME_QTY,DZT_NAME_PRZ,DZT_NAME_VALACC
		$("#cap_DZT_NAME_QTY").parents("table:first").css({ "display": "none" });
		$("#cap_DZT_NAME_VALACC").parents("table:first").css({ "display": "none" });
		$("#cap_DZT_NAME_PRZ").parents("table:first").css({ "display": "none" });

		ShowCol('MODELLI', 'Presenza_Obbligatoria', 'none'); //MODELLIGrid_Presenza_Obbligatoria

		if (DOCUMENT_READONLY == '0') {
			$("#cap_PresenzaAmpiezzaDiGamma").parents("table:first").css({ "display": "none" });
			//getObj('cap_PresenzaAmpiezzaDiGamma').style.display='none';
			//getObj('PresenzaAmpiezzaDiGamma').style.display='none';
			$("#cap_TipoModelloAmpiezzaDiGamma").parents("table:first").css({ "display": "none" });
			// getObj('cap_TipoModelloAmpiezzaDiGamma').style.display='none';
			// getObj('TipoModelloAmpiezzaDiGamma').style.display='none';
			$("#cap_FNZ_UPD").parents("table:first").css({ "display": "none" });
			// getObj('cap_FNZ_UPD').style.display='none';
			getObj('FNZ_UPD_link').style.display = 'none';
		}
		else {
			getObj('cap_PresenzaAmpiezzaDiGamma').style.display = 'none';
			getObj('Cell_PresenzaAmpiezzaDiGamma').offsetParent.offsetParent.style.display = 'none';
			getObj('cap_TipoModelloAmpiezzaDiGamma').style.display = 'none';
			getObj('Cell_TipoModelloAmpiezzaDiGamma').offsetParent.offsetParent.style.display = 'none';
			getObj('cap_FNZ_UPD').style.display = 'none';
			getObj('FNZ_UPD').style.display = 'none';
		}


		//nascondo le colonne dei vincoli



	}

	//NASCONDO LE AREE CHE RIGURARDANO LE CONVENZIONI	
	if (getObjValue('JumpCheck') != 'CONVENZIONI') {
		getObj('EXTRA').style.display = 'none';
		getObj('VINCOLI').style.display = 'none';
	}

	if (getObjValue('JumpCheck') == 'AMPIEZZA_DI_GAMMA') {
		getObj('EXTRA').style.display = '';
		$("#cap_DZT_NAME_QTY").parents("table:first").css({ "display": "none" });
		$("#cap_DZT_NAME_VALACC").parents("table:first").css({ "display": "none" });
		$("#cap_DZT_NAME_PRZ").parents("table:first").css({ "display": "none" });


		getObj('VINCOLI').style.display = '';
	}

	//PER I MODELLI DI CODIFICA PRODOTTI CAMBIO LA CAPTION DELLA GRIGLIA
	if (getObjValue('JumpCheck') == 'CODIFICA_PRODOTTI') {
		var tmpMlg = '';
		try {
			tmpMlg = CNV(pathRoot, 'Attributi da utilizzare');
			$('#MODELLIGrid_Caption td.Grid_TitleCell').html(tmpMlg);
		}
		catch (e) { alert(e.message); }

		var filter = 'SQL_WHERE= dmv_cod not in ( \'5\',\'6\' )';
		try {
			FilterDom('MacroAreaMerc', 'MacroAreaMerc', getObjValue('MacroAreaMerc'), filter, '', '');
		} catch (e) { };

	}

	if (getObj('LinkedDoc').value != '0' && getObj('LinkedDoc').value != '') {
		//nascondo la colonna presenza Obbligatoria per i modelli custom 
		ShowCol('MODELLI', 'Presenza_Obbligatoria', 'none');
		//funzione per rendere la riga non modificabile se presenza_obbligatoria=1 (si)
		Riga_not_edit();
	}


}

function ActiveDrag() {
	ActiveGridDrag('MODELLIGrid', MoveAllRow);
	ActiveGridDrag('CALCOLIGrid', MoveAllRowCalcolo);
}

function HideColDrag() {
	ShowCol('MODELLI', 'FNZ_DRAG', 'none');
	ShowCol('CALCOLI', 'FNZ_DRAG', 'none');
}

function move(field, row, verso) {
	try {
		var f1 = getObj('RMODELLIGrid_' + row + '_' + field);
		var f2 = getObj('RMODELLIGrid_' + (row + verso) + '_' + field);
		var app;

		app = f1.value;

		f1.value = f2.value;

		f2.value = app

	}
	catch (e) {
	}

	try {
		var f1 = getObj('RMODELLIGrid_' + row + '_' + field + '_edit');
		var f2 = getObj('RMODELLIGrid_' + (row + verso) + '_' + field + '_edit');
		var app;

		app = f1.value;

		f1.value = f2.value;

		f2.value = app

	}
	catch (e) {
	}

	try {
		var f1 = getObj('RMODELLIGrid_' + row + '_' + field + '_edit_new');
		var f2 = getObj('RMODELLIGrid_' + (row + verso) + '_' + field + '_edit_new');
		var app;

		app = f1.value;

		f1.value = f2.value;

		f2.value = app

	}
	catch (e) {
	}

	try {
		var f1 = getObj('RMODELLIGrid_' + row + '_' + field + '_extraAttrib');
		var f2 = getObj('RMODELLIGrid_' + (row + verso) + '_' + field + '_extraAttrib');
		var app;

		app = f1.value;

		f1.value = f2.value;

		f2.value = app

	}
	catch (e) {
	}
}

function moveCalcoli(field, row, verso) {
	try {
		var f1 = getObj('RCALCOLIGrid_' + row + '_' + field);
		var f2 = getObj('RCALCOLIGrid_' + (row + verso) + '_' + field);
		var app;
		app = f1.value;
		f1.value = f2.value;
		f2.value = app
	} catch (e) { }

}

function MoveAllRow(r, v) {
	move('DZT_Name', r, v);
	move('Descrizione', r, v);
	move('MOD_Convenzione', r, v);
	move('MOD_StampaListino', r, v);
	move('MOD_PerfListino', r, v);
	move('MOD_Ordinativo', r, v);
	move('MOD_StampaOrdinativo', r, v);

	move('MOD_Bando', r, v);
	move('MOD_Offerta', r, v);
	move('MOD_Cauzione', r, v);
	move('MOD_PDA', r, v);
	move('MOD_PDADrillTestata', r, v);
	move('MOD_PDADrillLista', r, v);
	move('MOD_OffertaDrill', r, v);
	move('MOD_ConfDett', r, v);
	move('MOD_ConfLista', r, v);

	move('MOD_BandoSempl', r, v);
	move('MOD_OffertaTec', r, v);
	move('MOD_OffertaInd', r, v);
	move('MOD_OffertaINPUT', r, v);
	move('TOOLTIP_ORDER', r, v);

	move('TipoFile', r, v);

	move('MOD_Macro_Prodotto', r, v);
	move('MOD_Prodotto', r, v);
	move('Presenza_Obbligatoria', r, v);
	move('Numero_Decimali', r, v);
	move('NumeroDec', r, v);


	move('MOD_ListinoOrdini', r, v);
	move('MOD_PerfListinoOrdini', r, v);

	//ControlloDescrizioneafterupdown();
	ControlloDescrizioneafterupdownROW(r);
	ControlloDescrizioneafterupdownROW(r + v);

	Riga_not_edit();
}

function MoveAllRowCalcolo(r, v) {
	moveCalcoli('EsitoRiga', r, v);
	moveCalcoli('Descrizione', r, v);
	moveCalcoli('DZT_Name', r, v);
	moveCalcoli('MOD_PDA', r, v);
	moveCalcoli('PDADrillTestata', r, v);
	moveCalcoli('MOD_PDADrillLista', r, v);
	moveCalcoli('NonEditabili', r, v);
	moveCalcoli('Formula', r, v);
	moveCalcoli('Aggregazione', r, v);
}

function ClickDown(grid, r, c) {
	if (grid == 'MODELLIGrid') {
		MoveAllRow(r, 1);
		// move( 'DZT_Name' , r  , 1 );
		// move( 'Descrizione' , r  , 1 );
		// move( 'MOD_Convenzione' , r  , 1 );
		// move( 'MOD_StampaListino' , r  , 1 );
		// move( 'MOD_PerfListino' , r  , 1 );	
		// move( 'MOD_Ordinativo' , r  , 1 );
		// move( 'MOD_StampaOrdinativo' , r  , 1 );


		// move( 'MOD_Bando' , r  , 1 );
		// move( 'MOD_Offerta' , r  , 1 );
		// move( 'MOD_Cauzione' , r  , 1 );
		// move( 'MOD_PDA' , r  , 1 );
		// move( 'MOD_PDADrillTestata' , r  , 1 );
		// move( 'MOD_PDADrillLista' , r  , 1 );
		// move( 'MOD_OffertaDrill' , r  , 1 );
		// move( 'MOD_ConfDett' , r  , 1 );
		// move( 'MOD_ConfLista' , r  , 1 );

		// move( 'MOD_BandoSempl' , r  , 1 );
		// move( 'MOD_OffertaTec' , r  , 1 );
		// move( 'MOD_OffertaInd' , r  , 1 );
		// move( 'MOD_OffertaINPUT' , r  , 1 );
		// move( 'TOOLTIP_ORDER' , r  , 1 );


		// move( 'TipoFile' , r  , 1 );

		// move( 'MOD_Macro_Prodotto' , r  , 1 );
		// move( 'MOD_Prodotto' , r  , 1 );
		// move( 'Presenza_Obbligatoria' , r  , 1 );
		// move( 'Numero_Decimali' , r  , 1 );
		// move( 'NumeroDec' , r  , 1 );
		// ControlloDescrizioneafterupdown();
		// Riga_not_edit();
	} else if (grid == 'CALCOLIGrid') {
		MoveAllRowCalcolo(r, 1);
		// moveCalcoli( 'EsitoRiga' , r  , 1 );
		// moveCalcoli( 'Descrizione' , r  , 1 );
		// moveCalcoli( 'DZT_Name' , r  , 1 );
		// moveCalcoli( 'MOD_PDA' , r  , 1 );
		// moveCalcoli( 'PDADrillTestata' , r  , 1 );
		// moveCalcoli( 'MOD_PDADrillLista' , r  , 1 );
		// moveCalcoli( 'NonEditabili' , r  , 1 );
		// moveCalcoli( 'Formula' , r  , 1 );
		// moveCalcoli( 'Aggregazione' , r  , 1 );
	}
}


function ClickUp(grid, r, c) {
	if (grid == 'MODELLIGrid') {
		MoveAllRow(r, -1);
		// move( 'DZT_Name' , r  , -1 );
		// move( 'Descrizione' , r  , -1 );
		// move( 'MOD_Convenzione' , r  , -1 );
		// move( 'MOD_StampaListino' , r  , -1 );
		// move( 'MOD_PerfListino' , r  , -1 );	
		// move( 'MOD_Ordinativo' , r  , -1 );
		// move( 'MOD_StampaOrdinativo' , r  , -1 );

		// move( 'MOD_Bando' , r  , -1 );
		// move( 'MOD_Offerta' , r  , -1 );
		// move( 'MOD_Cauzione' , r  , -1 );
		// move( 'MOD_PDA' , r  , -1 );
		// move( 'MOD_PDADrillTestata' , r  , -1 );
		// move( 'MOD_PDADrillLista' , r  , -1 );
		// move( 'MOD_OffertaDrill' , r  , -1 );
		// move( 'MOD_ConfDett' , r  , -1 );
		// move( 'MOD_ConfLista' , r  , -1 );

		// move( 'MOD_BandoSempl' , r  , -1 );
		// move( 'MOD_OffertaTec' , r  , -1 );
		// move( 'MOD_OffertaInd' , r  , -1 );
		// move( 'MOD_OffertaINPUT' , r  , -1 );
		// move( 'TOOLTIP_ORDER' , r  , -1 );

		// move( 'TipoFile' , r  , -1 ); 

		// move( 'MOD_Macro_Prodotto' , r  , -1 );
		// move( 'MOD_Prodotto' , r  , -1 );
		// move( 'Presenza_Obbligatoria' , r  , -1 );
		// move( 'Numero_Decimali' , r  , -1 );
		// move( 'NumeroDec' , r  , -1 );
		// ControlloDescrizioneafterupdown();
		// Riga_not_edit();
	} else if (grid == 'CALCOLIGrid') {
		MoveAllRowCalcolo(r, -1);
		// moveCalcoli( 'EsitoRiga' , r  , -1 );
		// moveCalcoli( 'Descrizione' , r  , -1 );
		// moveCalcoli( 'DZT_Name' , r  , -1 );
		// moveCalcoli( 'MOD_PDA' , r  , -1 );
		// moveCalcoli( 'PDADrillTestata' , r  , -1 );
		// moveCalcoli( 'MOD_PDADrillLista' , r  , -1 );
		// moveCalcoli( 'NonEditabili' , r  , -1 );
		// moveCalcoli( 'Formula' , r  , -1 );
		// moveCalcoli( 'Aggregazione' , r  , -1 );
	}
}

function OnChangeTipo(o) {
	if (getObjValue('TipoModello') == 'SDA') {
		ShowCol('MODELLI', 'MOD_OffertaInd', '');
		ShowCol('MODELLI', 'MOD_BandoSempl', '');
	}
	else {
		ShowCol('MODELLI', 'MOD_OffertaInd', 'none');
		ShowCol('MODELLI', 'MOD_BandoSempl', 'none');
	}

}

function OnKeyUpTitolo() {

	try {
		//recupero il titolo
		var titolo = this.value;
		var test;
		var titoloripulito = '';

		//toglie gli spazi
		titolo = titolo.split(' ').join('');

		//ciclo per togliere i caratteri non validi solo numeri e lettere e _
		for (var i = 0; i < titolo.length; i++) {
			test = titolo.charAt(i);
			if (test.match("[a-zA-Z_]+")) {
				titoloripulito = titoloripulito + test;
			}
		}
		//alert(titoloripulito);
		this.value = titoloripulito;

	} catch (e) { }

}

function OnChangeconformita() {
	var value = '';

	try {
		value = getObj('Conformita').value;
	}
	catch (e) {
	}

	//se ritorna -1 non � stato selezionato Ex-Post allora vengono nascoste le colonne Conformit� Lista e Conformita Dett
	if (value.indexOf('Ex-Post') == '-1') {
		ShowCol('MODELLI', 'MOD_ConfLista', 'none');
		ShowCol('MODELLI', 'MOD_ConfDett', 'none');
	}
	else {
		ShowCol('MODELLI', 'MOD_ConfLista', '');
		ShowCol('MODELLI', 'MOD_ConfDett', '');
	}


}

function addCriterioOfferte() {
	var valore = '###';
	var numrow = GetProperty(getObj('FORMULEGrid'), 'numrow');

	for (i = 0; i <= numrow; i++) {
		valore = valore + getObj('RFORMULEGrid_' + i + '_CriterioFormulazioneOfferte').value + '###';
	}

	getObj('CriterioFormulazioneOfferte').value = valore;
}

function FORMULE_AFTER_COMMAND() {
	addCriterioOfferte();
}




function OnChangeAttributo(obj) {
	var i = obj.id.split('_');
	var row = i[1];
	var param;
	var nocache = new Date().getTime();

	filtraDominiPrz_qty();

	param = 'ID=' + obj.value;

	ajax.open("GET", '../../customDoc/CONFIG_MODELLI_LOTTI.asp?' + param + '&nocache=' + nocache, false);
	ajax.send(null);
	if (ajax.readyState == 4) {

		if (ajax.status == 404 || ajax.status == 500) {
			alert('Errore invocazione pagina');

		}

		var ainfo = ajax.responseText.split('#@#');
		var editabile = ainfo[0];
		var NumeroDec = ainfo[1];

		if (editabile != 'EDITABLE') {
			getObj('RMODELLIGrid_' + row + '_NonEditabili').value = 'fissa';
			TextreadOnly('RMODELLIGrid_' + row + '_Descrizione', true);
			getObj('RMODELLIGrid_' + row + '_Descrizione').value = editabile;
			getObj('RMODELLIGrid_' + row + '_NumeroDec').value = NumeroDec;
			if (NumeroDec == 0) {
				getObj('RMODELLIGrid_' + row + '_Numero_Decimali').value = '';
			}

		}
		else {
			TextreadOnly('RMODELLIGrid_' + row + '_Descrizione', false);
			getObj('RMODELLIGrid_' + row + '_Descrizione').value = '';
			getObj('RMODELLIGrid_' + row + '_NonEditabili').value = '';
			getObj('RMODELLIGrid_' + row + '_NumeroDec').value = NumeroDec;
			if (NumeroDec == 0) {
				getObj('RMODELLIGrid_' + row + '_Numero_Decimali').value = '';
			}
		}
	}

	//ricarico la combo degli attributi per i vincoli
	HandleVincoli();

	//rivaluto le espressioni
	CheckEspressioneAll();

	try {
		//Se ho selezionato un attributo di tipo Domain Ext o Gerarchico visualizzo accando alla combo attributo un icona che permette all'utente di aprire il dominio
		//E consultarne in sola lettura i valori in esso contenuti

		viewHelpDominio(obj);

	}
	catch (e) {
	}

	try {
		hideNumeroDecimali(row);
	}
	catch (e) {
	}

}

function viewHelpDominio(obj) {
	var arr = obj.id.split('_');
	var row = arr[1];

	var selezione = obj.value;
	var typeAttrib = -1;

	if (obj.options[obj.selectedIndex].text.substring(0, 12) == 'Domain Ext -' || obj.options[obj.selectedIndex].text.substring(0, 8) == 'Domain -')
		typeAttrib = 8;

	if (obj.options[obj.selectedIndex].text.substring(0, 12) == 'Gerarchico -')
		typeAttrib = 5;

	if (typeAttrib == -1) {
		removeNode('help_dom_' + row);
	}
	else {
		var nomeAttributo = obj.value.replace('RMODELLIGrid_' + row + '_DZT_Name_', '');

		var span = document.createElement("span");
		var link = document.createElement("a");
		var img = document.createElement("img");

		img.setAttribute("alt", 'img_label_alt');
		img.setAttribute("class", 'Apri dettaglio');
		img.setAttribute("src", pathRoot + 'CTL_Library/images/Domain/Lente.gif');

		var urlHelp = pathRoot + 'CTL_LIBRARY/dztToDom.asp?DZT=' + encodeURIComponent(nomeAttributo);

		span.setAttribute("id", "help_dom_" + row);
		link.setAttribute("href", '#');
		link.setAttribute("onclick", 'ExecFunctionCenter(\'' + urlHelp + '#new#800,600\');return false;');

		removeNode('help_dom_' + row);

		link.appendChild(img);
		span.appendChild(link);

		getObj('val_RMODELLIGrid_' + row + '_DZT_Name').appendChild(span);

	}

}

function removeNode(id) {
	try {
		//Se c'era l'help lo tolgo
		var objHelp = getObj(id);
		objHelp.parentNode.removeChild(objHelp);
	}
	catch (e) {
	}
}

function ControlloDescrizioneafterupdown() {
	try {
		var numrow = GetProperty(getObj('MODELLIGrid'), 'numrow');

		for (k = 0; k <= numrow; k++) {
			var i = getObj('RMODELLIGrid_' + k + '_DZT_Name').id.split('_');
			var row = i[1];
			var param;

			param = 'ID=' + getObj('RMODELLIGrid_' + k + '_DZT_Name').value;
			var nocache = new Date().getTime();

			ajax.open("GET", '../../customDoc/CONFIG_MODELLI_LOTTI.asp?' + param + '&nocache=' + nocache, false);
			ajax.send(null);

			//console.log('../../customDoc/CONFIG_MODELLI_LOTTI.asp?' + param + '&nocache=' + nocache);

			if (ajax.readyState == 4) {

				if (ajax.status == 404 || ajax.status == 500) {
					alert('Errore invocazione pagina');
				}

				var ainfo = ajax.responseText.split('#@#');
				var editabile = ainfo[0];
				var NumeroDec = ainfo[1];

				//console.log(ajax.responseText);				
				//alert(ajax.responseText);  
				if (editabile != 'EDITABLE') {
					//getObj('RMODELLIGrid_' + row + '_Descrizione').readOnly=true;
					getObj('RMODELLIGrid_' + row + '_NonEditabili').value = 'fissa';
					TextreadOnly('RMODELLIGrid_' + row + '_Descrizione', true);
					getObj('RMODELLIGrid_' + row + '_Descrizione').value = editabile;
					getObj('RMODELLIGrid_' + row + '_NumeroDec').value = NumeroDec;
				}
				else {
					//getObj('RMODELLIGrid_' + row + '_Descrizione').value='';
					//getObj('RMODELLIGrid_' + row + '_Descrizione').readOnly=false;				
					TextreadOnly('RMODELLIGrid_' + row + '_Descrizione', false);
					getObj('RMODELLIGrid_' + row + '_NonEditabili').value = '';
					//getObj('RMODELLIGrid_' + row + '_Descrizione').value='';
					getObj('RMODELLIGrid_' + row + '_NumeroDec').value = NumeroDec;
				}
			}

			try { hideNumeroDecimali(k); } catch (e) { }


		}

	} catch (e) { };


}
function ControlloDescrizioneafterupdownROW(k) {
	try {
		var numrow = GetProperty(getObj('MODELLIGrid'), 'numrow');

		//for( k = 0 ; k <= numrow ; k++ )
		{
			var i = getObj('RMODELLIGrid_' + k + '_DZT_Name').id.split('_');
			var row = i[1];
			var param;

			param = 'ID=' + getObj('RMODELLIGrid_' + k + '_DZT_Name').value;
			var nocache = new Date().getTime();

			ajax.open("GET", '../../customDoc/CONFIG_MODELLI_LOTTI.asp?' + param + '&nocache=' + nocache, false);
			ajax.send(null);

			//console.log('../../customDoc/CONFIG_MODELLI_LOTTI.asp?' + param + '&nocache=' + nocache);

			if (ajax.readyState == 4) {

				if (ajax.status == 404 || ajax.status == 500) {
					alert('Errore invocazione pagina');
				}

				var ainfo = ajax.responseText.split('#@#');
				var editabile = ainfo[0];
				var NumeroDec = ainfo[1];

				//console.log(ajax.responseText);				
				//alert(ajax.responseText);  
				if (editabile != 'EDITABLE') {
					//getObj('RMODELLIGrid_' + row + '_Descrizione').readOnly=true;
					getObj('RMODELLIGrid_' + row + '_NonEditabili').value = 'fissa';
					TextreadOnly('RMODELLIGrid_' + row + '_Descrizione', true);
					getObj('RMODELLIGrid_' + row + '_Descrizione').value = editabile;
					getObj('RMODELLIGrid_' + row + '_NumeroDec').value = NumeroDec;
				}
				else {
					//getObj('RMODELLIGrid_' + row + '_Descrizione').value='';
					//getObj('RMODELLIGrid_' + row + '_Descrizione').readOnly=false;				
					TextreadOnly('RMODELLIGrid_' + row + '_Descrizione', false);
					getObj('RMODELLIGrid_' + row + '_NonEditabili').value = '';
					//getObj('RMODELLIGrid_' + row + '_Descrizione').value='';
					getObj('RMODELLIGrid_' + row + '_NumeroDec').value = NumeroDec;
				}
			}

			try { hideNumeroDecimali(k); } catch (e) { }
			try {
				viewHelpDominio(getObj('RMODELLIGrid_' + k + '_DZT_Name'));
			}
			catch (e) {
			}

		}

	} catch (e) { };


}
function ControlloDescrizione() {

	try {
		var jumpCheck = getObjValue('JumpCheck');
		var filter = '';
		var onChangeProp = '';
		var numrow = GetProperty(getObj('MODELLIGrid'), 'numrow');

		for (i = 0; i <= numrow; i++) {

			try {
				hideNumeroDecimali(i);
			}
			catch (e) {
			}


			try {
				viewHelpDominio(getObj('RMODELLIGrid_' + i + '_DZT_Name'));
			}
			catch (e) {
			}

			if (getObj('RMODELLIGrid_' + i + '_NonEditabili').value == 'fissa') {
				//getObj('RMODELLIGrid_' + i + '_Descrizione').readOnly=true;					
				TextreadOnly('RMODELLIGrid_' + i + '_Descrizione', true);

			}
			if (getObj('RMODELLIGrid_' + i + '_NonEditabili').value != 'fissa') {
				//getObj('RMODELLIGrid_' + i + '_Descrizione').readOnly=true;					
				TextreadOnly('RMODELLIGrid_' + i + '_Descrizione', false);
			}

		}

	} catch (e) { };


}

function MODELLI_AFTER_COMMAND() {
	var jumpCheck = getObjValue('JumpCheck');

	ControlloDescrizione();

	if (jumpCheck != 'CODIFICA_PRODOTTI') {
		//ricarico la combo degli attributi per i vincoli
		HandleVincoli();
		//rivaluto le espressioni
		CheckEspressioneAll();
	}

	try {
		Onload_Process();
	}
	catch (e) { }
}

function filtraDominiPrz_qty() {
	/* Filtro i domini DZT_NAME_QTY e DZT_NAME_PRZ facendo uscire soltanto gli attributi scelti nella griglia degli attributi da usare sul modello */

	var jumpCheck = getObjValue('JumpCheck');

	if (getObjValue('JumpCheck') != 'AMPIEZZA_DI_GAMMA') {

		var numrow = GetProperty(getObj('MODELLIGrid'), 'numrow');
		var listaAttributi = '';
		var filtro = '';

		for (i = 0; i <= numrow; i++) {
			if (getObj('RMODELLIGrid_' + i + '_DZT_Name').value != '') {
				listaAttributi = listaAttributi + '\'' + getObj('RMODELLIGrid_' + i + '_DZT_Name').value + '\',';
			}
		}

		listaAttributi = listaAttributi + '\'FITTIZIO_EXTRA\'';

		filtro = 'SQL_WHERE= DMV_Cod in (' + listaAttributi + ') and dzt_type=2';

		//FilterDom( objName , FieldName , valore , filter , row  , OnChange)
		FilterDom('DZT_NAME_QTY', 'DZT_NAME_QTY', getObj('DZT_NAME_QTY').value, filtro, '', 'CheckEspressioneAll()');
		FilterDom('DZT_NAME_PRZ', 'DZT_NAME_PRZ', getObj('DZT_NAME_PRZ').value, filtro, '', 'CheckEspressioneAll()');
		FilterDom('DZT_NAME_VALACC', 'DZT_NAME_VALACC', getObj('DZT_NAME_VALACC').value, filtro, '', 'CheckEspressioneAll()');
	}
}

function onChangeConvenzione(paramObj) {
	var obj = this;

	if (paramObj)
		obj = paramObj;

	var i = obj.id.split('_');
	var row = i[1];

	//Se non si � selezionato qualcosa per la convenzione tolto la selezione alla colonna stampa listino
	if (obj.value == '') {
		getObj('RMODELLIGrid_' + row + '_MOD_StampaListino').selectedIndex = '0';
	}
}

function onChangeOrdinativo(paramObj) {
	var obj = this;

	if (paramObj)
		obj = paramObj;

	var i = obj.id.split('_');
	var row = i[1];

	//Se non si � selezionato qualcosa per la convenzione tolto la selezione alla colonna stampa listino
	if (obj.value == '') {
		getObj('RMODELLIGrid_' + row + '_MOD_StampaOrdinativo').selectedIndex = '0';
	}
}


function HandleVincoli() {

	//se il documento � editabile


	if (getObjValue('StatoFunzionale') == 'InLavorazione') {

		var bExistCombo = false;
		//carico combo con gli attributi del modello e la inserisco in questo controllo label
		//LblGuri_label  
		myDiv = getObj('LblGuri_label');

		var selectList;

		selectList = getObj('AttribForvincolo');
		//alert(selectList);
		if (selectList == null) {
			selectList = document.createElement("select");
			selectList.id = "AttribForvincolo";

		} else {
			//rimuovo le option
			selectList.innerHTML = '';
			bExistCombo = true;
		}

		var option = document.createElement("option");
		option.value = '';
		//option.text = 'Seleziona Attributo per il vincolo';
		option.appendChild(document.createTextNode('Seleziona'));
		selectList.appendChild(option);

		if (!bExistCombo)
			myDiv.appendChild(selectList);

		//Create and append the options
		var numrow = GetProperty(getObj('MODELLIGrid'), 'numrow');

		//alert( getObj('RMODELLIGrid_0_DZT_Name').options[getObj('RMODELLIGrid_0_DZT_Name').selectedIndex].text);

		var DescrOption = '';

		for (k = 0; k <= numrow; k++) {
			DescrOption = getObj('RMODELLIGrid_' + k + '_DZT_Name').options[getObj('RMODELLIGrid_' + k + '_DZT_Name').selectedIndex].text;
			if (DescrOption.length > 8) {
				//alert(DescrOption.substring(0,8));
				//if ( DescrOption.substring(0,8) == 'Number -' ){

				if (DescrOption.substring(0, 8) != 'Attach -' && getObj('RMODELLIGrid_' + k + '_DZT_Name').value != '') {
					var option = document.createElement("option");

					option.value = getObj('RMODELLIGrid_' + k + '_DZT_Name').value;
					//option.text = DescrOption;
					option.appendChild(document.createTextNode(DescrOption));
					selectList.appendChild(option);
				}
			}
		}

		//aggiungo bottone per fare ADD sul vincolo
		if (!bExistCombo) {
			var btn = document.createElement("BUTTON");        // Create a <button> element
			btn.setAttribute("type", "button");
			btn.setAttribute("class", "ButtonBar_Button");

			btn.setAttribute("onClick", "AddAttribVincolo();return false;");

			var spazio = document.createTextNode(" ");       // Create a text nodes
			myDiv.appendChild(spazio);
			myDiv.appendChild(spazio);
			var t = document.createTextNode("Aggiungi");       // Create a text node
			btn.appendChild(t);
			myDiv.appendChild(btn);
		}

	} else {

		//nascondo la caption della label
		//alert(getObj( 'cap_LblGuri' ));
		setVisibility(getObj('cap_LblGuri'), 'none');

	}

}

function AddAttribVincolo() {


	//controllo che ci sia un vincolo selezionato
	var Grid = getObj('VINCOLIGrid');
	if (GetProperty(Grid, 'numrow') == '-1') {

		DMessageBox('../', 'Aggiungere un vincolo', 'Attenzione', 2, 400, 300);
		return;

	}


	//controllo che ho seleziona l'attributo
	if (getObj('AttribForvincolo').value == '') {

		DMessageBox('../', 'Selezionare un attributo da aggiungere al vincolo.', 'Attenzione', 2, 400, 300);
		return;


	}

	//recupero il vincolo selezionato
	var indRow = MyGrid_GetIndSelectedRow('VINCOLIGrid');


	var v = indRow.split('~~~');

	if (indRow == '') {
		DMessageBox('../', 'E\' necessario selezionare prima un vincolo', 'Attenzione', 2, 400, 300);
		return;
	}

	if (v.length > 1) {
		DMessageBox('../', 'E\' necessario selezionare un solo vincolo', 'Attenzione', 2, 400, 300);
		return;
	}


	//se non presente aggiungo attributo all'espressione
	var Attrib = getObj('AttribForvincolo').value;
	var ValueEspressione = getObj('R' + indRow + '_Espressione').value;

	//if  ( ValueEspressione.indexOf( ' ' + Attrib)  == -1 )
	getObj('R' + indRow + '_Espressione').value = getObj('R' + indRow + '_Espressione').value + ' ' + Attrib;


	CheckEspressione(getObj('R' + indRow + '_Espressione'));
}

function CheckEspressione(obj) {

	var StrValueFormula = obj.value;

	var strId = obj.id;
	//alert(strId);
	var ainfo = strId.split('_');
	var row = ainfo[0].substring(1, ainfo[0].length);
	//alert(row);

	//controllo che ci sia nella formula almeno uno degli attributi QT,PRZ,VALACC
	Attrib_QT = getObj('DZT_NAME_QTY').value;
	Attrib_PRZ = getObj('DZT_NAME_PRZ').value;
	Attrib_VALACC = getObj('DZT_NAME_VALACC').value;

	if (StrValueFormula.indexOf(Attrib_QT) == -1 && StrValueFormula.indexOf(Attrib_PRZ) == -1 && StrValueFormula.indexOf(Attrib_VALACC) == -1) {

		DMessageBox('../', 'nella espressione ci deve essere almeno 1 tra quantita , prezzo, valore accessorio', 'Attenzione', 2, 400, 300);
		getObj('R' + row + '_EsitoRiga_V').innerHTML = CNV('../', 'Espressione non corretta.');
		getObj('R' + row + '_EsitoRiga').value = CNV('../', 'Espressione non corretta.');
		return false;

	}

	//controllo che nella formula ci sia almeno <,=,>
	if (StrValueFormula.indexOf('<') == -1 && StrValueFormula.indexOf('>') == -1 && StrValueFormula.indexOf('=') == -1) {

		DMessageBox('../', 'nella espressione ci deve essere almeno 1 tra <,>,=', 'Attenzione', 2, 400, 300);
		getObj('R' + row + '_EsitoRiga_V').innerHTML = CNV('../', 'Espressione non corretta.');
		getObj('R' + row + '_EsitoRiga').value = CNV('../', 'Espressione non corretta.');
		return false;

	}

	//provo a sostituire tutti gli attributi

	//alert(nNumAttrib);
	//alert (ObjAttribFormula.options[1].value);


	//rimpiazzo gli operatori e le parentesi per assicurarci gli spazi davanti gli attributi

	StrValueFormula = StrValueFormula.replace(/[(]/g, ' ( ');

	StrValueFormula = StrValueFormula.replace(/[)]/g, ' ) ');
	StrValueFormula = StrValueFormula.replace(/[+]/g, ' + ');
	StrValueFormula = StrValueFormula.replace(/[-]/g, ' - ');
	StrValueFormula = StrValueFormula.replace(/[*]/g, ' * ');
	StrValueFormula = StrValueFormula.replace(/[/]/g, ' / ');

	//StrValueFormula=StrValueFormula.replace(/<=/g, ' <= ');
	//StrValueFormula=StrValueFormula.replace(/>=/g, ' >= ');


	//if ( StrValueFormula.indexOf( '>=' )==-1 &&  StrValueFormula.indexOf( '<=' )==-1  ){
	//   StrValueFormula=StrValueFormula.replace(/[=]/g, ' == ');
	//   StrValueFormula=StrValueFormula.replace(/[<]/g, ' < ');
	//   StrValueFormula=StrValueFormula.replace(/[>]/g, ' > ');

	//}	






	StrValueFormula = ' ' + StrValueFormula + ' ';

	//alert(StrValueFormula);

	//rimpiazzo tutti gli attributi applicabili
	var ObjAttribFormula = getObj('AttribForvincolo')
	nNumAttrib = ObjAttribFormula.length;
	for (i = 1; i < nNumAttrib; i++) {
		if (isSingleWin()) {
			var testoSelezionato = ObjAttribFormula[i].text;

			if (testoSelezionato != '') {
				if (testoSelezionato.substring(0, 8) == 'Number -') {
					StrValueFormula = ReplaceExtended(StrValueFormula, ' ' + ObjAttribFormula.options[i].value + ' ', ' 1 ');
				}
				else {
					StrValueFormula = ReplaceExtended(StrValueFormula, ' ' + ObjAttribFormula.options[i].value + ' ', ' \'1\' ');
				}
			}
			//StrValueFormula=ReplaceExtended( StrValueFormula , ' ' + ObjAttribFormula.options[i].value + ' ' , ' 1 ');
		}
		else {
			while (StrValueFormula.indexOf(' ' + ObjAttribFormula.options[i].value + ' ') >= 0) {
				//StrValueFormula=StrValueFormula.replace(' ' + ObjAttribFormula.options[i].value + ' ' , ' 1 ');
				if (testoSelezionato.substring(0, 8) == 'Number -') {
					StrValueFormula = ReplaceExtended(StrValueFormula, ' ' + ObjAttribFormula.options[i].value + ' ', ' 1 ');
				}
				else {
					StrValueFormula = ReplaceExtended(StrValueFormula, ' ' + ObjAttribFormula.options[i].value + ' ', ' \'1\' ');
				}

			}
		}

	}


	//StrValueFormula=ReplaceExtended( StrValueFormula , ' = ' ,' == ');
	//alert(StrValueFormula);

	//valuto la formula per vedere se � corretta

	//prima di fare eval rimpiazzo gli operatori logici or e and
	StrValueFormula = StrValueFormula.toLowerCase();
	//StrValueFormula=StrValueFormula.replace(/or/gi, ' || ');
	//StrValueFormula=StrValueFormula.replace(/and/gi, ' && ');
	StrValueFormula = ReplaceExtended(StrValueFormula, ' and ', ' && ');
	StrValueFormula = ReplaceExtended(StrValueFormula, ' or ', ' || ');
	StrValueFormula = ReplaceExtended(StrValueFormula, ' <> ', ' != ');
	StrValueFormula = ReplaceExtended(StrValueFormula, ' = ', ' == ');



	//alert(StrValueFormula);

	try {
		StrValue = eval(StrValueFormula);
		getObj('R' + row + '_EsitoRiga_V').innerHTML = CNV('../', 'Espressione corretta.');
		getObj('R' + row + '_EsitoRiga').value = CNV('../', 'Espressione corretta.');
	} catch (e) {
		getObj('R' + row + '_EsitoRiga_V').innerHTML = CNV('../', 'Espressione non corretta.');
		getObj('R' + row + '_EsitoRiga').value = CNV('../', 'Espressione non corretta.');
	}

}



//-- ritorna gli indici delle righe selezionate in una stringa concatenandoli
//-- separati da ~~~
function MyGrid_GetIndSelectedRow(id) {
	var i;
	var result = '';
	//var NumRow = eval( id + '_EndRow;' );
	var NumRow = GetProperty(getObj(id), 'numrow')
	var nStartRow = eval(id + '_StartRow;');
	var strNomeCampo;
	//alert( getObj ( id + '_SEL_0').checked );

	for (i = nStartRow; i <= NumRow; i++) {
		try {
			if (isSingleWin()) {
				strNomeCampo = id + '_SEL_' + (i - nStartRow)
				if (!getObj(strNomeCampo))
					strNomeCampo = id + '_SEL_' + (i - nStartRow) + ' ';

				if (getObj(strNomeCampo).checked) {
					if (result != '') result = result + '~~~';
					result = result + i;
				}
			}
			else {
				if (eval(id + '_SelectedRow[ ' + (i - nStartRow) + '];') == 1) {
					if (result != '') result = result + '~~~';
					result = result + i;
				}
			}

		} catch (e) {
		}
	}

	return result;

}


function CheckEspressioneAll() {
	//alert('effettuo check di tutti i vincoli');

	var i;


	var NumRow = GetProperty(getObj('VINCOLIGrid'), 'numrow')
	var nStartRow = eval('VINCOLIGrid_StartRow');

	for (i = nStartRow; i <= NumRow; i++) {
		CheckEspressione(getObj('R' + i + '_Espressione'));
	}



}

window.onload = Onload_Process;

function Riga_not_edit() {

	try {
		if (getObj('LinkedDoc').value != '0' && getObj('LinkedDoc').value != '') {

			var numrow = GetProperty(getObj('MODELLIGrid'), 'numrow');

			for (k = 0; k <= numrow; k++) {
				//se richiesta la non editable la riga allora imposto il campo non editabili
				if (getObj('RMODELLIGrid_' + k + '_Presenza_Obbligatoria').value == '1') {
					try { SelectreadOnly('RMODELLIGrid_' + k + '_DZT_Name', true); } catch (e) { }
					try { TextreadOnly('RMODELLIGrid_' + k + '_Descrizione', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Convenzione', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_StampaListino', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PerfListino', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Ordinativo', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_StampaOrdinativo', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Bando', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Offerta', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Cauzione', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PDA', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PDADrillTestata', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PDADrillLista', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_OffertaDrill', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_ConfDett', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_ConfLista', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_BandoSempl', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_OffertaTec', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_OffertaInd', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_OffertaINPUT', true); } catch (e) { }
					try { TextreadOnly('RMODELLIGrid_' + k + '_TOOLTIP_ORDER', true); } catch (e) { }
					try { HierarchyreadOnly('RMODELLIGrid_' + k + '_TipoFile', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Macro_Prodotto', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Prodotto', true); } catch (e) { }

					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_ListinoOrdini', true); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PerfListinoOrdini', true); } catch (e) { }

					//try{SelectreadOnly( 'RMODELLIGrid_' + k + '_Numero_Decimali' , true );}catch(e){}
					//rimuovo il cestino se non modificabile

					try { getObj('MODELLIGrid_r' + k + '_c1').innerHTML = ReplaceExtended(getObj('MODELLIGrid_r' + k + '_c1').innerHTML, 'DettagliDel(', 'DettagliDel_OLD('); } catch (e) { }

				}
				else {
					try { SelectreadOnly('RMODELLIGrid_' + k + '_DZT_Name', false); } catch (e) { }
					if (getObj('RMODELLIGrid_' + k + '_NonEditabili').value == 'fissa') {
						TextreadOnly('RMODELLIGrid_' + k + '_Descrizione', true);
					}
					else {
						try { TextreadOnly('RMODELLIGrid_' + k + '_Descrizione', false); } catch (e) { }
					}
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Convenzione', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_StampaListino', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PerfListino', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Ordinativo', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_StampaOrdinativo', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Bando', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Offerta', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Cauzione', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PDA', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PDADrillTestata', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PDADrillLista', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_OffertaDrill', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_ConfDett', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_ConfLista', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_BandoSempl', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_OffertaTec', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_OffertaInd', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_OffertaINPUT', false); } catch (e) { }
					try { TextreadOnly('RMODELLIGrid_' + k + '_TOOLTIP_ORDER', false); } catch (e) { }
					try { HierarchyreadOnly('RMODELLIGrid_' + k + '_TipoFile', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Macro_Prodotto', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_Prodotto', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_Numero_Decimali', false); } catch (e) { }
					try { getObj('MODELLIGrid_r' + k + '_c1').innerHTML = ReplaceExtended(getObj('MODELLIGrid_r' + k + '_c1').innerHTML, 'DettagliDel_OLD(', 'DettagliDel('); } catch (e) { }

					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_ListinoOrdini', false); } catch (e) { }
					try { SelectreadOnly('RMODELLIGrid_' + k + '_MOD_PerfListinoOrdini', false); } catch (e) { }

				}

			}
		}
	} catch (e) { }
}
function HierarchyreadOnly(objname, b) {
	var onclick;
	var obj;

	objname = objname + '_button';
	try {
		if (b == true) {
			obj = getObj(objname);
			onclick = obj.getAttribute('onclick');
			if (onclick.indexOf('&readonly=1') < 0 && onclick.indexOf('&readonly=0') < 0) {
				onclick = onclick.replace('&Value=', '&Value=&readonly=1');
				try { obj.setAttribute('onclick', onclick); } catch (e) { }
			}
			if (onclick.indexOf('&readonly=1') < 0 && onclick.indexOf('&readonly=0') > 0) {
				onclick = onclick.replace('&readonly=0', '&readonly=1');
				try { obj.setAttribute('onclick', onclick); } catch (e) { }
			}

		}
		else {
			obj = getObj(objname);
			onclick = obj.getAttribute('onclick');
			if (onclick.indexOf('&readonly=1') > 0) {
				onclick = onclick.replace('&readonly=1', '&readonly=0');
				try { obj.setAttribute('onclick', onclick); } catch (e) { }
			}
		}
	} catch (e) { }
}



function DettagliDel_OLD(grid, r, c) {
	DMessageBox('../', 'Operazione non consentita', 'Attenzione', 1, 400, 300);
	return;
}

function hideNumeroDecimali(riga) {
	var num = Number(getObj('RMODELLIGrid_' + riga + '_NumeroDec').value);
	var NumeroDecimali = getObj('RMODELLIGrid_' + riga + '_Numero_Decimali');

	if (num == 0) {
		NumeroDecimali.style.display = 'none';
	}
	else {
		NumeroDecimali.style.display = '';

	}


}

function openWizardFormula(G, R, C) {
	var docReadonly = getObjValue('DOCUMENT_READONLY');

	if (docReadonly != '1') {
		if (G == 'VINCOLIGrid') {
			openWinModale('ctl_library/functions/FIELD/wizardFormula.asp?CONTESTO=VINCOLI&riga=' + R);
		}
		else {
			openWinModale('ctl_library/functions/FIELD/wizardFormula.asp?riga=' + R);
		}

	}
}


function openWinModale(page, height, width) {

	var pathRadice;

	if (isSingleWin())
		pathRadice = pathRoot;
	else
		pathRadice = '../../';

	if (height == undefined) {
		height = 650;
	}

	if (width == undefined) {
		width = 800;
	}

	if (page.indexOf("VINCOLI") > 0) {
		try {
			$(function () {
				$("#finestra_modale").load(pathRadice + page).dialog({
					resizable: true,
					height: height,
					width: width,
					modal: true,
					buttons: {
						"OK": function () {
							var rowCalcolo = getObj('riga_wizard_formula').value;

							/* Travaso i dati dalla modale al documento */
							getObj('RVINCOLIGrid_' + rowCalcolo + '_Espressione').value = getObj('Formula').value;
							getObj('RVINCOLIGrid_' + rowCalcolo + '_Descrizione').value = getObj('Descrizione').value;

							$(this).dialog("close");
						}
						, "Verifica Vincoli": function () {
							verificaVincolo(getObj('Formula').value);
						}
						, "Annulla": function () {
							$(this).dialog("close");
						}
					}
				});
			});
		}
		catch (e) {

		}

	}
	else {

		try {
			$(function () {
				$("#finestra_modale").load(pathRadice + page).dialog({
					resizable: true,
					height: height,
					width: width,
					modal: true,
					buttons: {
						"OK": function () {
							var rowCalcolo = getObj('riga_wizard_formula').value;

							/* Travaso i dati dalla modale al documento */
							getObj('RCALCOLIGrid_' + rowCalcolo + '_Formula').value = getObj('Formula').value;
							getObj('RCALCOLIGrid_' + rowCalcolo + '_Descrizione').value = getObj('Descrizione').value;
							getObj('RCALCOLIGrid_' + rowCalcolo + '_DZT_Name').value = getObj('DZT_Name').value;

							$(this).dialog("close");
						}
						, "Verifica formula": function () {
							verificaFormula(getObj('Formula').value);
						}
						, "Annulla": function () {
							$(this).dialog("close");
						}
					}
				});
			});
		}
		catch (e) {

		}
	}
}


function CheckFormula(G, R, C) {
	var docReadonly = getObjValue('DOCUMENT_READONLY');

	if (docReadonly != '1') {
		var strFormula = getObj('RCALCOLIGrid_' + R + '_Formula').value;
		var esito = verificaFormula(strFormula, 'no');

		//getObj('RCALCOLIGrid_' + R + '_EsitoRiga_V').innerHTML = esito;
		var OldEsito = getObj('RCALCOLIGrid_' + R + '_EsitoRiga').value;

		//se vengo da onload concateno il vecchio esito al nuovo
		if (C == 'NO' && esito != OldEsito)
			esito = OldEsito + esito;

		SetTextValue('RCALCOLIGrid_' + R + '_EsitoRiga', esito);


		if (esito == '' && C != 'NO') {
			alert('La formula e\' valida');
		}

	}
}

function ROUND(v, d) {
	return 1.0
}

function verificaFormula(strFormula, output) {
	var esitoFormula = '';
	var imgEsito = '<img src="../images/Domain/State_ERR.gif"/>';
	var continueCheck = true;

	try {

		if (strFormula != '') {
			var numrow = GetProperty(getObj('MODELLIGrid'), 'numrow');

			for (k = 0; k <= numrow; k++) {

				var campo = getObj('RMODELLIGrid_' + k + '_DZT_Name');

				var indexSel = campo.selectedIndex;
				var lista = campo.options;
				var valueCampo = campo.value;
				var testoSelezionato = lista[indexSel].text;

				if (testoSelezionato.substring(0, 8) == 'Number -') {
					var descSelezionato = getObj('RMODELLIGrid_' + k + '_Descrizione').value;

					try {
						//alert(descSelezionato);
						//strFormula = strFormula.replace('[' + descSelezionato + ']', '1');	
						strFormula = ReplaceExtended(strFormula, '[' + descSelezionato + ']', ' 1 ');
					}
					catch (e) { }

				}

			}

			try {
				/* Se nella formula sono ancora presenti delle parentesi quadre vuol dire che sono stati utilizzati attributi non numerici */
				if (strFormula.indexOf('[') >= 0 || strFormula.indexOf(']') >= 0) {
					if (output != 'no') {
						alert('La formula non e\' sintatticamente corretta');
					}
					else {
						esitoFormula = esitoFormula + imgEsito + 'La formula contiene attributi non numerici' + '<br/>';
					}

					continueCheck = false;

				}

			}
			catch (e) {
			}

			try {
				var t = document.getElementById('DZT_Name');
				var selectedText = t.options[t.selectedIndex].text;
				if (getObjValue('Formula').indexOf(selectedText) >= 0) {
					alert('In una formula non deve comparire l\'attributo utilizzato come risultato calcolato');
					esitoFormula = esitoFormula + imgEsito + 'In una formula non deve comparire l\'attributo utilizzato come risultato calcolato' + '<br/>';
					continueCheck = false;

				}
			}
			catch (e) {
			}


			if (continueCheck) {

				try {
					//alert('prima di eval' + strFormula);
					var a = eval(strFormula);

					if (output != 'no') {
						alert('La formula e\' sintatticamente corretta');
					}

				}
				catch (e) {

					if (output != 'no') {
						alert('La formula non e\' formalmente valida');
					}
					else {
						esitoFormula = esitoFormula + imgEsito + 'La formula non e\' sintatticamente corretta' + '<br/>';
					}
				}

			}

		}
		else {
			if (output != 'no') {
				alert('La formula non \' sintatticamente corretta');
			}
			else {
				esitoFormula = esitoFormula + imgEsito + 'La formula non e\' sintatticamente corretta' + '<br/>';
			}
		}

	}
	catch (e) {
	}


	return esitoFormula;

}



function hideAllCols() {
	ShowCol('MODELLI', 'DZT_Name', 'none');
	ShowCol('MODELLI', 'MOD_Convenzione', 'none');
	ShowCol('MODELLI', 'MOD_StampaListino', 'none');
	ShowCol('MODELLI', 'MOD_PerfListino', 'none');
	ShowCol('MODELLI', 'MOD_ListinoOrdini', 'none');
	ShowCol('MODELLI', 'MOD_PerfListinoOrdini', 'none');
	ShowCol('MODELLI', 'MOD_Ordinativo', 'none');
	ShowCol('MODELLI', 'MOD_StampaOrdinativo', 'none');



}



function ShowAllCols() {
	ShowCol('MODELLI', 'DZT_Name', '');
	ShowCol('MODELLI', 'MOD_Convenzione', '');
	ShowCol('MODELLI', 'MOD_StampaListino', '');
	ShowCol('MODELLI', 'MOD_PerfListino', '');
	ShowCol('MODELLI', 'MOD_ListinoOrdini', '');
	ShowCol('MODELLI', 'MOD_PerfListinoOrdini', '');
	ShowCol('MODELLI', 'MOD_Ordinativo', '');
	ShowCol('MODELLI', 'MOD_StampaOrdinativo', '');



}


function OnChangeAmbito() {

}




function CheckVincolo(G, R, C) {
	var docReadonly = getObjValue('DOCUMENT_READONLY');

	if (docReadonly != '1') {
		var strVincolo = getObj('R' + R + '_Espressione').value;
		var esito = verificaVincolo(strVincolo, 'no');

		var OldEsito = getObj('R' + R + '_EsitoRiga').value;

		//se vengo da onload concateno il vecchio esito al nuovo
		if (C == 'NO' && esito != OldEsito)
			esito = OldEsito + esito;

		SetTextValue('R' + R + '_EsitoRiga', esito);

		if (esito == '' && C != 'NO') {
			alert('Il Vincolo e\' valido');
		}



	}
}




function verificaVincolo(strVincolo, output) {
	var esitoVincolo = '';
	var imgEsito = '<img src="../images/Domain/State_ERR.gif"/>';
	var continueCheck = true;
	try {

		if (strVincolo != '') {
			var numrow = GetProperty(getObj('MODELLIGrid'), 'numrow');

			for (k = 0; k <= numrow; k++) {

				var campo = getObj('RMODELLIGrid_' + k + '_DZT_Name');

				var indexSel = campo.selectedIndex;
				var lista = campo.options;
				var valueCampo = campo.value;
				var testoSelezionato = lista[indexSel].text;

				if (testoSelezionato.substring(0, 8) != 'Attach -') //if (testoSelezionato.substring(0, 8) == 'Number -')
				{
					var descSelezionato = getObj('RMODELLIGrid_' + k + '_Descrizione').value;

					try {
						if (testoSelezionato.substring(0, 8) == 'Number -') {
							strVincolo = ReplaceExtended(strVincolo, '[' + descSelezionato + ']', '1');
						} else {
							strVincolo = ReplaceExtended(strVincolo, '[' + descSelezionato + ']', '\'1\'');
						}
					}
					catch (e) { }

				}

			}

			try {
				/* Se nella formula sono ancora presenti delle parentesi quadre vuol dire che sono stati utilizzati attributi non numerici */
				if (strVincolo.indexOf('[') >= 0 || strVincolo.indexOf(']') >= 0) {
					if (output != 'no') {
						alert('Il Vincolo contiene attributi non numerici', 'Attenzione');

					}
					else {
						esitoVincolo = esitoVincolo + imgEsito + 'Il Vincolo contiene attributi non numerici' + '<br/>';
					}

					continueCheck = false;

				}

			}
			catch (e) {
			}


			if (continueCheck) {
				//controllo che nella formula ci sia almeno <,=,>
				if (strVincolo.indexOf('<') == -1 && strVincolo.indexOf('>') == -1 && strVincolo.indexOf('=') == -1) {
					if (output != 'no') {
						alert('Nell\'espressione ci deve essere almeno 1 tra <,>,=', 'Attenzione');
					}
					else {
						esitoVincolo = esitoVincolo + imgEsito + 'Nell\'espressione ci deve essere almeno 1 tra <,>,=' + '<br/>';
					}

					continueCheck = false;

				}
			}


			if (continueCheck) {

				try {
					//alert(strVincolo);
					strVincolo = strVincolo.toLowerCase();
					strVincolo = ReplaceExtended(strVincolo, '==', '=');
					strVincolo = ReplaceExtended(strVincolo, '=', '==');
					strVincolo = ReplaceExtended(strVincolo, '<>', '!=');
					strVincolo = ReplaceExtended(strVincolo, 'and', '&&');
					strVincolo = ReplaceExtended(strVincolo, 'or', '||');

					var a = eval(strVincolo);

					if (output != 'no') {
						alert('Espressione corretta.', 'Attenzione');
					}

				}
				catch (e) {
					if (output != 'no') {
						alert('Espressione non corretta.', 'Attenzione');
					}
					else {
						esitoVincolo = esitoVincolo + imgEsito + 'Espressione non corretta' + '<br/>';
					}
				}

			}

		}
		else {
			if (output != 'no') {
				alert('Espressione non corretta.');
			}
			else {
				esitoVincolo = esitoVincolo + imgEsito + 'Espressione non corretta' + '<br/>';
			}
		}

	}
	catch (e) {
	}


	return esitoVincolo;


}

function ismultiplo(a, b) {
	return 1
}

function isempty(a) {
	return 1
}

