function ricerca() {

	//controlla se sono presenti righe prima di fare la ricerca
	var numeroRighe0 = GetProperty(getObj('CRITERIGrid'), 'numrow');
	if (numeroRighe0 < 0) {
		DMessageBox('../', 'E\' necessario inserire almeno una riga prima di fare la ricerca', 'Attenzione', 1, 400, 300);
		return;
	}

	//var TipoProceduraCaratteristica = getObj('TipoProceduraCaratteristica').value;
	//if ( TipoProceduraCaratteristica == 'RDO' )
	var ListaAlbiValore = getObj('ListaAlbi').value;
	//alert(ListaAlbiValore);

	var aInfo = ListaAlbiValore.split('###');
	//alert(aInfo.length);
	if (ListaAlbiValore != '') {
		var i = 0;
		try {
			for (i = 0; getObj('R' + i + '_ListaAlbi') != undefined && i < 1000; i++) {
				if (getObj('R' + i + '_ListaAlbi').value == '') {
					DMessageBox('../', 'E\' necessario selezionare un valore nel campo \"Impresa Iscritta Al\" prima di eseguire una ricerca', 'Attenzione', 1, 400, 300);
					return;
				}

			}

		} catch (e) { }

	}



	var value = '';

	if (getObj('StatoFunzionale').value != 'InLavorazione') {
		value = 'NO';
	}

	if (value == '') {
		ExecDocProcess('RICERCA,RICERCA_OE');
	}
	else
		return false;

}

function RefreshContent() {
	RefreshDocument('');
}


function VisualizzaAzienda(grid, r, c) {
	//-- recupero il codice della riga passata

	var nIdAzienda;
	try {
		nIdAzienda = getObj('RESITIGrid_' + r + '_IdAzi')[0].value
	} catch (e) {
		nIdAzienda = getObj('RESITIGrid_' + r + '_IdAzi').value
	}


	//variabili che mi indicano in che posizione devo aprire le form dei documenti
	const_width = 780;
	const_height = 500;
	sinistra = (screen.width - const_width) / 2;
	alto = (screen.height - const_height) / 2;




	//Se versione accessibile
	if (isSingleWin()) {
		var url;
		url = encodeURIComponent('ctl_library/document/document.asp?MODE=SHOW&lo=base&JScript=SCHEDA_ANAGRAFICA&DOCUMENT=SCHEDA_ANAGRAFICA&IDDOC=' + nIdAzienda);
		ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document', '', '');
	}
	else {

		//non apro più la vecchia anagrafica se è versione accessibile
		window.open('../../customdoc/VisualizzaAzienda.asp?IdPfu=&strFlag=OK&idAzi=' + nIdAzienda + '&IDMP=&intTab=0&strNomeCampo=-1&Read_Only=YES&Provenienza=1', 'Run_Dati_AziendaLinked', 'toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width=' + const_width + ',height=' + const_height + ',left=' + sinistra + ',top=' + alto + ',screenX=' + sinistra + ',screenY=' + alto + '');

	}
}
window.onload = controlli;

function controlli() {
	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;


	//se il doc è readonly nasconde il ricerca
	//if ( getObj('StatoFunzionale').value != 'InLavorazione')
	if (DOCUMENT_READONLY == '1') {
		document.getElementById('bottone_ricerca').style.visibility = 'hidden';

	}

	ShowSorteggio();


	//dopo il conferma chiudo il documento
	var Command = getQSParam('COMMAND');
	var Process_Param = getQSParam('PROCESS_PARAM');

	if (Command == 'PROCESS' && Process_Param == 'SEND,RICERCA_OE') {
		if (isSingleWin() == false)
			RemoveMessageFromMem();
		else {
			//Ricarico dal db la sezione dei destinatari del documento chiamante
			var linkedDoc = getObjValue('LinkedDoc');
			var tipoDocChiamante = getObjValue('VersioneLinkedDoc');

			if (linkedDoc != '' && tipoDocChiamante != '') {
				ShowWorkInProgress(true);
				ExecDocCommandInMem('DESTINATARI_1#RELOAD', linkedDoc, tipoDocChiamante);
				ExecDocCommandInMem('DESTINATARI_2#RELOAD', linkedDoc, tipoDocChiamante);
				ShowWorkInProgress(false);

				if (getObj('StatoFunzionale').value == 'Annullato') {

					ML_text = 'Operazione non consentita per lo stato del documento collegato alla Ricerca Operatori Economici';
					var Title = 'Informazione';
					var ICO = 1;
					var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent(ML_text) + '&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
					ExecFunctionModaleWithAction(page, null, 200, 420, null, 'breadCrumbPop');
				}
				else {
					//Ritorno sull'ultimo livello delle molliche di pane
					breadCrumbPop();
				}

			}
		}
	}


	if (DOCUMENT_READONLY == '0') {
		FiltroClasseIscriz();

		FiltroListaAlbi();
	}

	var TipoProceduraCaratteristica = getObj('TipoProceduraCaratteristica').value;

	//nascondo help se non RDO e non Cottimo
	if (TipoProceduraCaratteristica != 'RDO' && TipoProceduraCaratteristica != 'Cottimo') {
		$("#cap_LblHelpRDORicercaOE").parents("table:first").css({ "display": "none" })
	}

	//per il cottimo cambio help
	if (TipoProceduraCaratteristica == 'Cottimo') {

		getObj('cap_LblHelpRDORicercaOE').innerHTML = CNV('../../', 'LblHelpCOTTIMORicercaOE');;

	}


	Alternate_ClasseIscriz_SOA();

	//if ( getObj( 'DOCUMENT_READONLY' ).value == '0' )
	if (DOCUMENT_READONLY == '0') {
		FiltroCategorieSOA();
	}


	if (DOCUMENT_READONLY == '0') {

		try {
			//se nascosto o bloccato non faccio nulla sul campo "TipoSelezioneSoggetti"

			//se UNA RDO oppure INVITO senza AVVISO tolgo "Sorteggio Pubblico"
			if (getObj('TipoProceduraCaratteristica').value == 'RDO' || (getObj('TipoBandoGara').value == '3' && getObj('InvitoDaAvviso').value == '0')) {
				rimuovivoce('TipoSelezioneSoggetti', 'sorteggiopubblico');

			}

			//se INVITO RISTRETTA lascio solo "Manuale"
			if (getObj('TipoBandoGara').value == '3' && getObj('ProceduraGara').value == '15477') {
				rimuovivoce('TipoSelezioneSoggetti', 'rotazione');
				rimuovivoce('TipoSelezioneSoggetti', 'rotazione2');
				rimuovivoce('TipoSelezioneSoggetti', 'sorteggio');
				rimuovivoce('TipoSelezioneSoggetti', 'sorteggiopubblico');

			}

			//se INVITO da AVVISO tolgo tutte le "rotazioni" 
			if (getObj('TipoBandoGara').value == '3' && getObj('InvitoDaAvviso').value == '1') {

				rimuovivoce('TipoSelezioneSoggetti', 'rotazione');
				rimuovivoce('TipoSelezioneSoggetti', 'rotazione2');

			}


			//PER LE GARE INVITI DEI LAVORI TipoappaltoGara = 2 ( lavori) la selezione "rotazione 2" deve essere presente
			var TipoAppaltoGara = ''
			var VIS_rotazione2 = 0
			try { TipoAppaltoGara = getObj('TipoAppaltoGara').value; } catch (e) { TipoAppaltoGara = ''; };

			//SE LA GARA E' LAVORI, NEGOZIATA, INVITO SENZA AVVISO e NON RDO
			//SI PUO' SCEGLIERE ROTAZIONE2
			if (TipoAppaltoGara == 2 && getObj('ProceduraGara').value == '15478' && getObj('TipoBandoGara').value == '3' && getObj('InvitoDaAvviso').value == '0' && getObj('TipoProceduraCaratteristica').value == '') {
				VIS_rotazione2 = 1;
			}

			if (VIS_rotazione2 == 0) {
				rimuovivoce('TipoSelezioneSoggetti', 'rotazione2');
			}

		}
		catch (e) { }


		/*
		//APPLICO FILTRO SOLO SE IL DOMINIO CONTIENE ELEMENTO "rotazione2"
		var nIsPresentRotazione2 = 0;
		objTipoSelezioneSoggetti = getObj('TipoSelezioneSoggetti')
		
		var nNum = objTipoSelezioneSoggetti.length ;
		for (i = 0; i < nNum; i++) {
			
			if ( objTipoSelezioneSoggetti.options[i].value == 'rotazione2' )
			{
				nIsPresentRotazione2 = 1;
				break;
			}
			
		} 
		
		//alert(nIsPresentRotazione2);
		
		
		if ( VIS_rotazione2 == 0 && nIsPresentRotazione2 == 1 )
		{
			//var filter =  'SQL_WHERE= dmv_cod not in ( \'rotazione2\' )' ;
			//try
			//{
			//	FilterDom( 'TipoSelezioneSoggetti' , 'TipoSelezioneSoggetti' , getObjValue('TipoSelezioneSoggetti') , filter ,'', 'ChangedTipoSelezioneSoggetti( this );');
			//}catch( e ) {};
			//TOLGO ROTAZIONE2
			rimuovivoce( 'TipoSelezioneSoggetti','rotazione2');
			
		}
		*/

	}


	SetLinkInviti();



}

function apri_report(obj) {

	//alert(obj);
	ShowDocumentFromAttrib('REPORT_INVITI_ROTAZIONE2,' + obj + ',800,650');

}

//-- nasconde o visualizza i campi per 
function ShowSorteggio() {
	var TipoSelezioneSoggetti = getObj('TipoSelezioneSoggetti').value;

	var ObjNum

	var ObjNumMinimo;

	var Objterritorio;

	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;

	try {
		if (DOCUMENT_READONLY == "1") {
			ObjNum = getObj('NumeroOperatoridaInvitare').parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
			ObjNumMinimo = getObj('NumeroMinimoOperatoridaInvitare_V').parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
			Objterritorio = getObj('aziProvinciaLeg3').parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;

		} else {
			ObjNum = getObj('NumeroOperatoridaInvitare').parentNode.parentNode.parentNode;
			ObjNumMinimo = getObj('NumeroMinimoOperatoridaInvitare').parentNode.parentNode.parentNode;
			Objterritorio = getObj('aziProvinciaLeg3_edit_new').parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
		}

	} catch (e) { }


	var ObjNumV = getObj('NumeroOperatoridaInvitare_V')


	if (ObjNumV != null) {
		if (TipoSelezioneSoggetti == 'rotazione' || TipoSelezioneSoggetti == 'rotazione2' || TipoSelezioneSoggetti == 'sorteggio') {
			setVisibility(ObjNum, '');
		}
		else {
			setVisibility(ObjNum, 'none');
		}
	}

	if (TipoSelezioneSoggetti == 'sorteggio' && getObj('StatoFunzionale').value == 'InLavorazione') {
		document.getElementById('bottone_sorteggio').style.visibility = '';

	}
	else {
		document.getElementById('bottone_sorteggio').style.visibility = 'hidden';
	}


	//se sorteggio territoriale nascondo il campo NumeroOperatoridaInvitare e visualizzo i campi 
	//Numero Minimo Operatori da invitare" e "Territorio Interno"  
	try {
		if (TipoSelezioneSoggetti == 'sorteggioterritoriale') {
			setVisibility(ObjNumMinimo, '');
			setVisibility(Objterritorio, '');
		}
		else {
			setVisibility(ObjNumMinimo, 'none');
			setVisibility(Objterritorio, 'none');
		}
	} catch (e) { }

}


var Semaforo = 0;

function CRITERI_AFTER_COMMAND(cmd) {
	FiltroClasseIscriz();

	FiltroListaAlbi();

	Alternate_ClasseIscriz_SOA();

	FiltroCategorieSOA();

	addButtonAdInfoFilterRicercaOE();

	if (cmd == 'DELETE_ROW') {
		//-- cancella il risultato precedente se c'era almeno una riga
		var NumRighe = getObjValue('NumRighe');
		if (NumRighe > 0) {
			//ExecDocCommand( 'ESITI#DELETE_ALL' );
			ExecDocProcess('DELETE_ALL,RICERCA_OE');
		}
	}

}

function SP_Refresh_SP_CRITERI() {

}

function FiltroClasseIscriz() {

	var temponclick = '';
	var TipoProceduraCaratteristica = getObj('TipoProceduraCaratteristica').value;
	if (TipoProceduraCaratteristica == 'RDO') {
		var ClasseIscriz = getObj('ClasseIscriz').value;
		var i = 0;
		try {
			for (i = 0; getObj('R' + i + '_ClasseIscriz') != undefined && i < 1000; i++) {
				if (getObj('R' + i + '_ClasseIscriz').value == '') {
					Semaforo = 1;
					getObj('R' + i + '_ClasseIscriz').value = ClasseIscriz;
				}
				SetProperty(getObj('R' + i + '_ClasseIscriz'), 'filter', 'SQL_WHERE= \'' + ClasseIscriz + '0###\' like \'%###\' + dmv_cod  + \'###%\' ');
				//imposto la format solo ad A per classiIscriz
				//obj=getObj('R' + i + '_ClasseIscriz').parentElement;	
				obj = getObj('R' + i + '_ClasseIscriz_button');
				temponclick = obj.getAttribute('onclick');
				temponclick = temponclick.replace(/Format=JA/g, 'Format=A');
				obj.setAttribute('onclick', temponclick);

			}

		} catch (e) { alert(e.message) }

	}

	//-- aggiorno la griglia dei criteri a video
	if (Semaforo == 1) {
		Semaforo = 0;
		var strCommand = 'CRITERI#PAGINAZIONE#nPag=1';
		ExecDocCommand(strCommand);
	}
}

function FiltroListaAlbi() {

	var ListaAlbiValori = getObj('ListaAlbi').value;
	var tempValue = '';


	if (ListaAlbiValori != '') {

		var aInfo = ListaAlbiValori.split('###');
		if (aInfo.length == 3) {
			tempValue = ReplaceExtended(ListaAlbiValori, '###', '');
			//alert(tempValue);
		}

	}

	if (ListaAlbiValori != '') {

		var i = 0;
		try {
			for (i = 0; getObj('R' + i + '_ListaAlbi') != undefined && i < 1000; i++) {
				if (getObj('R' + i + '_ListaAlbi').value == '') {

					if (tempValue != '') {
						getObj('R' + i + '_ListaAlbi').value = tempValue;
						Semaforo = 1;

					}
				}

				OldFilter = GetProperty(getObj('R' + i + '_ListaAlbi'), 'filter');
				NewFilter = OldFilter + ' and \'' + ListaAlbiValori + '\' like \'%###\' + cast(dmv_cod as varchar(50)) + \'###%\' ';
				//alert( NewFilter ) ;
				SetProperty(getObj('R' + i + '_ListaAlbi'), 'filter', NewFilter);

			}

		} catch (e) { }

	}

	//-- aggiorno la griglia dei criteri a video
	if (Semaforo == 1) {
		Semaforo = 0;
		var strCommand = 'CRITERI#PAGINAZIONE#nPag=1';
		ExecDocCommand(strCommand);
	}
}

function OnChangeClasseIscriz(obj) {
	FiltroClasseIscriz();
}


function myaddRow() {
	var cod;
	var nq;
	var strCommand;
	var testo;
	//-- recupero il codice della riga passata
	cod = -1;




	//-- compone il comando per aggiungere la riga
	strCommand = 'CRITERI#ADDFROM#' + 'IDROW=' + cod + '&TABLEFROMADD=CRITERI_RICERCA_OE_FROM_TOOLBAR';

	//alert( strCommand );

	ExecDocCommand(strCommand);

	try {
		//var sec = parent.opener.getObj( 'SECTION_DETTAGLI_NAME' ).value;
		parent.opener.ShowLoading('CRITERI');
	} catch (e) { };



}


function ChangedField(obj) {
	//-- cancella il risultato precedente se c'era almeno una riga
	var NumRighe = getObjValue('NumRighe');

	if (NumRighe > 0) {
		//ExecDocCommand( 'ESITI#DELETE_ALL' );
		ExecDocProcess('DELETE_ALL,RICERCA_OE');

	}

}

function ChangedTipoSelezioneSoggetti(obj) {

	ShowSorteggio();

	ChangedField(obj);
}

function afterProcess(param) {
	if (param == 'DELETE_ALL') {
		DMessageBox('../', 'Gli esiti della ricerca sono stati svuotati in seguito ad un cambiamento dei "Criteri di ricerca". Rieseguire la "Ricerca"', 'Attenzione', 1, 400, 300);
		return;
	}
	if (param == 'LOAD_OE') {
		DMessageBox('../', 'Operazione effettuata con successo', 'Informazione', 1, 400, 300);
		return;
	}
}


function Alternate_ClasseIscriz_SOA() {

	var TipoProceduraCaratteristica = getObj('TipoProceduraCaratteristica').value;

	//se RDO nascondo categoriaSOA
	if (TipoProceduraCaratteristica == 'RDO') {
		ShowCol('CRITERI', 'GerarchicoSOA', 'none');
	}

	//se COTTIMO mnascondo classeiscriz
	if (TipoProceduraCaratteristica == 'Cottimo') {
		ShowCol('CRITERI', 'ClasseIscriz', 'none');
	}

}

function FiltroCategorieSOA() {
	var TipoProceduraCaratteristica = getObj('TipoProceduraCaratteristica').value;

	if (TipoProceduraCaratteristica != 'RDO') {
		var CategoriaSOA = getObj('CategoriaSOA').value;
		var CategoriaSOA_PREV = getObj('CategoriaSOA_CHANGE_TECNICA').value;

		//SE NON SONO ALLA PRIMA APERTURA
		//CI SONO STATI CAMBIAMENTI
		//ALLORA SVUOTO I CAMPI VALORIZZATI
		if (CategoriaSOA_PREV != '' && CategoriaSOA != CategoriaSOA_PREV) {
			var i = 0;
			try {
				for (i = 0; getObj('R' + i + '_GerarchicoSOA') != undefined && i < 1000; i++) {

					if (getObj('R' + i + '_GerarchicoSOA').value != '') {

						getObj('R' + i + '_GerarchicoSOA').value = '';
						getObj('R' + i + '_GerarchicoSOA_edit_new').value = '';

					}
				}

			} catch (e) { }

			DMessageBox('../', 'Elenco Categorie SOA aggiornato con i nuovi valori scelti per le Categorie Prevalenti sulla procedura', 'Informazione', 1, 400, 300);
			ChangedField('');

		}
		//alert(CategoriaSOA);

		if (CategoriaSOA != '###' && CategoriaSOA != '') {
			var i = 0;
			try {
				for (i = 0; getObj('R' + i + '_GerarchicoSOA') != undefined && i < 1000; i++) {

					if (getObj('R' + i + '_GerarchicoSOA').value == '') {
						Semaforo = 1;
						getObj('R' + i + '_GerarchicoSOA').value = CategoriaSOA;
					}
					SetProperty(getObj('R' + i + '_GerarchicoSOA'), 'filter', 'SQL_WHERE= \'' + CategoriaSOA + '0###\' like \'%###\' + dmv_cod  + \'###%\' ');

				}

			} catch (e) { }
		}

		getObj('CategoriaSOA_CHANGE_TECNICA').value = CategoriaSOA;

	}

	//-- aggiorno la griglia dei criteri a video
	if (Semaforo == 1) {
		Semaforo = 0;
		var strCommand = 'CRITERI#PAGINAZIONE#nPag=1';
		ExecDocCommand(strCommand);
	}
}

function OnChangeSOA(obj) {
	FiltroCategorieSOA();
}


function fnzSorteggio() {

	if (getObj('StatoFunzionale').value == 'InLavorazione') {
		ExecDocProcess('SORTEGGIO,RICERCA_OE');
	}

}



function DownLoadXLSX() {
	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	if (DOCUMENT_READONLY == "1") {
		DMessageBox('../', 'Documento in sola lettura', 'Attenzione', 1, 400, 300);
		return;
	}

	var numeroRighe0 = GetProperty(getObj('ESITIGrid'), 'numrow');
	if (numeroRighe0 < 0) {
		DMessageBox('../', 'E\' necessario che siano presenti Operatori prima di fare l\'operazione', 'Attenzione', 1, 400, 300);
		return;
	}


	ExecFunction('../../CTL_Library/accessBarrier.asp?goto=..%2FReport%2FRICERCA_OE_INFO_AGGIUNTIVE.aspx&IDDOC=' + getObjValue('IDDOC'), '_blank', '');

}


function UpLoadXLSX() {

	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	if (DOCUMENT_READONLY == "1")
		DMessageBox('../', 'Documento in sola lettura', 'Attenzione', 1, 400, 300);
	else
		ImportExcel('CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_OE,RICERCA_OE&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#400,300');


}



function VisualizzaIstanzaProf(grid, r, c) {
	var iddoc;
	try {
		iddoc = getObj('RESITIGrid_' + r + '_ID_ALBO_PROF')[0].value
	}
	catch (e) {
		iddoc = getObj('RESITIGrid_' + r + '_ID_ALBO_PROF').value
	}
	if (iddoc > 0) {
		ShowDocument('ISTANZA_AlboProf_3_RICERCA_OE', iddoc);
	}
	else {
		return -1;
	}


}


function ESITI_AFTER_COMMAND(cmd) {

	SetLinkInviti();
}


function SetLinkInviti() {
	//QUANDO si sceglie la rotazione 2 mettere sulla colonna numero inviti del risultato una classe di stile per i link e l'evento di onclick per aprire il report
	if (getObj('TipoSelezioneSoggetti').value == 'rotazione2') {

		var nNumRowEsiti = ESITIGrid_NumRow;

		var i = 0;
		try {
			for (i = 0; i <= nNumRowEsiti; i++) {

				//var nId;				
				//nId = getObjValue( 'ESITIGrid_idRow_' + i ) ;				
				if (getObj('RESITIGrid_' + i + '_NumeroInviti') != undefined) {
					document.getElementById('RESITIGrid_' + i + '_NumeroInviti_V').className = "GridCol_Link";
					getObj('RESITIGrid_' + i + '_NumeroInviti_V').setAttribute("onclick", "apri_report('ESITIGrid_idRow_" + i + "')");
				}
			}
		} catch (e) { alert(e.message) }
	}
}

//elimina una opzione da una lista SELECT
function rimuovivoce(ListName, value_selezionato) {

	num_option = getObj(ListName).options.length;

	for (a = 0; a < num_option; a++) {

		if (getObj(ListName).options[a].value == value_selezionato) {
			getObj(ListName).options[a] = null;
			break;
		}
	}

}

/*   PARTE PER GESTIONE FILTRO MODELLI CLASSI   */

$(document).ready(function () {
	$.getScript('../../customdoc/jsapp/FILTRO_ADD_INFO.js',
		function () {
			addButtonAdInfoFilterRicercaOE();
		});
});
