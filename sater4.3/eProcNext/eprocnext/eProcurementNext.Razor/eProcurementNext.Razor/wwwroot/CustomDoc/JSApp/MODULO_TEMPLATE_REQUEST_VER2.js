
var gModify_DGUE = 0;


window.onload = OpenModuli;


function OpenModuli() {

	try {
		controlli('');
	} catch (e) { }

	//per tutti i campi checkbox che hanno la classe di stile SelezioneVeloce
	//invoco la funzione SelezioneVeloce
	try {
		Init_SelezioneVeloce();
	} catch (e) { }

	//-- cerco di riposizionare la pagina dopo un comando
	try {
		if (getObj('Note').value != '') {
			var v = getObj('Note').value.split('@@@');

			//document.body.scrollTop =  v[4];
			document.documentElement.scrollTop = v[4];
			getObj('Note').value = '';
		}
	} catch (e) { }


	try {
		$('#Toolbar_stampa ul').style.display = 'none';
	} catch (e) { };

	/*
	
	$('.FldDomainValue_OptionTAB input').mouseup( function ()
		{   
			return false;
		} );
	$('.FldDomainValue_OptionTAB input').click( function ()
		{   
			return false;
		} );
	$('.FldDomainValue_OptionTAB input').mousedown( function ()
		{ 
			if ( this.checked == true ) 
				this.checked = false;
			else
				this.checked = true;

			OnChangeScelta(  this );
			return true;
			
		} );
	*/

	//innesco la funzione di onchange su tutti i domini a selezione singola
	//try{
	//	Init_FldDomainValue_OnChangeScelta();
	//}catch(e){}


	//-- aggiusta il tooltip
	$(function () {
		//$( document ).tooltip
		$('[data-toggle="tooltip"]').tooltip({
			items: "img, [data-toggle], [title]",
			content: function () {
				var element = $(this);
				if (element.is("[data-geo]")) {
					var text = element.title();
					return '<div  class="TTBS" >' + unescape(text) + '</div>';
				}
				if (element.is("[title]")) {
					var text = element.attr("title");
					return '<div  class="TTBS" >' + unescape(text) + '</div>';
					//return element.attr( "title" );
				}
				if (element.is("img")) {
					var text = element.attr("alt");
					return element.attr("alt");
				}
			}
		});
	});


	//-- predispongo le parti relazionate aperte o chiuse in funzione delle scelte effettuate solamente per gli OE
	//if ( getObjValue( 'INCARICOA' ) == 'OE' )
	//{
	var GRP = document.getElementsByName("GRP_Related");
	var i;
	for (i = 0; i < GRP.length; i++) {

		try { OpenCloseGroup(GRP[i]); } catch (e) { };
	}
	//}


	//-- allineo i bottoni per la gestione del PDF
	try {
		StatoDocRiferimento = getObj('StatoDocRiferimento').value;



		if ((getObjValue('SIGN_LOCK') == '0' || getObjValue('SIGN_LOCK') == '') && StatoDocRiferimento == 'InLavorazione') {
			document.getElementById('generapdf').disabled = false;
			document.getElementById('generapdf').className = "generapdf";
		}
		else {
			document.getElementById('generapdf').disabled = true;
			document.getElementById('generapdf').className = "generapdfdisabled";
		}

		if (getObjValue('SIGN_LOCK') != '0' && StatoDocRiferimento == 'InLavorazione') {
			document.getElementById('editistanza').disabled = false;
			document.getElementById('editistanza').className = "attachpdf";
		}
		else {
			document.getElementById('editistanza').disabled = true;
			document.getElementById('editistanza').className = "attachpdfdisabled";
		}

		if ((getObjValue('SIGN_ATTACH') == '' && getObjValue('SIGN_LOCK') != '0') && StatoDocRiferimento == 'InLavorazione') {
			document.getElementById('attachpdf').disabled = false;
			document.getElementById('attachpdf').className = "editistanza";
		}
		else {
			document.getElementById('attachpdf').disabled = true;
			document.getElementById('attachpdf').className = "editistanzadisabled";
		}
	}
	catch (e) {
	}



	//su tutti i controlli di tipo TEXTAREA aggiungo evento onchange
	//perchè di base la libreria dei filed non lo gestisce 

	try {
		var VetTxtArea = $(".TextArea");
		var j;
		for (j = 0; j < VetTxtArea.length; j++) {
			//alert(VetObj[i].id);
			VetTxtArea[j].onchange = OnModificaDGUE;
		}
	}
	catch (e) {
	}



	//chiamo la funzione per cambiare su tutti i campi bottone 
	//degli attributi IDENTIFIER_LOT la funzione di onclick
	Change_OnClick_Identifier_lot();


}



function Change_OnClick_Identifier_lot() {

	var Make_Filter_Identifier_lot = false;

	//E' stato chiesto di disattivare il filtro sul lotto: un lotto scelto non poteva essere più usato sulle altre iterazioni
	if (!Make_Filter_Identifier_lot)
		return;


	try {
		//var VetIDENTIFIER_LOT = getObj('IDENTIFIER_LOT');
		var Vet_IDENTIFIER_LOT = $(".Identificativo_lotto");

		//alert(Vet_IDENTIFIER_LOT.length);

		//$( ".button" );
		var z;
		for (z = 0; z < Vet_IDENTIFIER_LOT.length; z++) {

			//recupero nome del bottone
			Name_Btn_IdLotto = Vet_IDENTIFIER_LOT[z].value + '_button';


			objBtn = getObj(Name_Btn_IdLotto);

			if (objBtn) {
				//devo aggiungere su onclick una funzione che aggiorna il filtro del campo per evitare
				//che sulla selezione escano i lotti già indicati in altre ripetizioni



				var Old_OnClick = objBtn.onclick;
				//alert(Old_OnClick);

				//il vecchio onclick lo metto in una proprieta del bottone
				//SetProperty( objBtn ,'old_onclick',Old_OnClick);

				objBtn.onclick =
					function () {

						UpgradeFiltro_IDENTIFIER_LOT(this);
						//Old_OnClick();

						//openExtDomPopup( 'MOD_C_1_9_FLD_K1(1)_R1','./LoadExtendedAttrib.asp?MultiValue=1&titoloFinestra=%3F%3F%3FEVIDENCE%5FIDENTIFIER%3F%3F%3F&TypeAttrib=8&IdDomain=IDENTIFIER%5FLOT&Attrib=MOD%5FC%5F1%5F9%5FFLD%5FK1%281%29%5FR1&Format=MLD&Editable=True&Suffix=&Filter=SQL%5FWHERE%3D%28idgara%3D431746%20and%20tipodoc%3D%27BANDO%5FGARA%27%29', 'dialog-iframe-IDENTIFIER_LOT');

						//Name_Attrib = this.id.replace('_button','');

						//alert(Name_Attrib);


						//openExtDomPopup( this.id.replace('_button','') ,'./LoadExtendedAttrib.asp?MultiValue=1&titoloFinestra=%3F%3F%3FEVIDENCE%5FIDENTIFIER%3F%3F%3F&TypeAttrib=8&IdDomain=IDENTIFIER%5FLOT&Attrib=' + this.id.replace('_button','') + '&Format=MLD&Editable=True&Suffix=&Filter', 'dialog-iframe-IDENTIFIER_LOT');
					};


				/*
				$(objBtn).click(function() {
					
					UpgradeFiltro_IDENTIFIER_LOT(this);
					
					Old_OnClick;
					
				});
				*/


			}


		}
	}
	catch (e) {
	}

}


function UpgradeFiltro_IDENTIFIER_LOT(obj_button_IdentFier) {
	var NameButton = obj_button_IdentFier.id;


	//recupero nome attributo 
	var NameAttrib = NameButton.replace('_button', '');

	//alert(NameAttrib);

	//MOD_C_1_9_FLD_K1(1)_R1
	//recupero ultime parentesi ()
	var nPosOpen = NameAttrib.lastIndexOf("(");
	var nPosClose = NameAttrib.lastIndexOf(")");


	//alert(nPosOpen + '-' + nPosClose);

	//devo recuperare il prefissso MOD_C_1_9_FLD_K1
	var Prefisso_IdentLotto = NameAttrib.substring(0, nPosOpen);

	//devo recuperare iterazione corrente 1mo
	var Iterazione_IdentLotto = NameAttrib.substring(nPosOpen + 1, nPosClose);

	//devo recuperare il suffisso _R1
	var Suffisso_IdentLotto = NameAttrib.substring(nPosClose + 1);

	//alert('prefisso=' + Prefisso_IdentLotto +'---Iterazione=' + Iterazione_IdentLotto + '---suffisso=' + Suffisso_IdentLotto);

	//in ciclo mi devo cercare tutti i campi del tipo
	//MOD_C_1_9_FLD_K1(X)_R1  dove X diverso da me e conservare tutti i valori di questi campi


	var i = 1;
	var NameIdentLottoAltro = Prefisso_IdentLotto + '(' + i + ')' + Suffisso_IdentLotto;
	objIdentLottoAltro = getObj(NameIdentLottoAltro);

	var StrCodiciAltri = '';

	while (objIdentLottoAltro != undefined) {

		//se non sono io recupero i valoriselezionati
		if (i != Iterazione_IdentLotto) {
			//alert( objIdentLottoAltro.value );
			StrCodiciAltri = StrCodiciAltri + objIdentLottoAltro.value;
		}

		i = i + 1;
		NameIdentLottoAltro = Prefisso_IdentLotto + '(' + i + ')' + Suffisso_IdentLotto;
		objIdentLottoAltro = getObj(NameIdentLottoAltro);

	}

	//alert(StrCodiciAltri);
	//Con questi valori vado ad aggiornare il filtro del campo corrente 
	var Obj_Identifier_Lotto = getObjGrid('IDENTIFIER_LOT');
	var FilterOrigin = GetProperty(Obj_Identifier_Lotto, 'filter');
	var NewFilter = FilterOrigin;

	if (StrCodiciAltri != '') {
		//sostituisco i ### con ','
		StrCodiciAltri = StrCodiciAltri.replace(/###/g, '\',\'');

		//tolgo i primi 2 e gli ultimi 2 caratteri
		StrCodiciAltri = StrCodiciAltri.substring(2, StrCodiciAltri.length - 2);

		//aggiorno il filtro 		
		NewFilter = NewFilter + ' and dmv_cod not in (' + StrCodiciAltri + ')';

	}

	//alert (NewFilter);

	SetProperty(getObj(NameAttrib), 'filter', NewFilter);

	//chiamo il vecchio onclick che ho messo in una property Old_OnClick del bottone
	//Old_Onclick = GetProperty(obj_button_IdentFier,'old_onclick');
	//eval(Old_Onclick);

	openExtDomPopup(NameAttrib, './LoadExtendedAttrib.asp?MultiValue=1&titoloFinestra=%3F%3F%3FEVIDENCE%5FIDENTIFIER%3F%3F%3F&TypeAttrib=8&IdDomain=IDENTIFIER%5FLOT&Attrib=' + encodeURIComponent(NameAttrib) + '&Format=MLD&Editable=True&Suffix=&Filter=', 'dialog-iframe-IDENTIFIER_LOT');
}

function afterProcess(param) {
	/*
		if (param == 'EXEC_COMMAND') 
		{
			setTimeout(function(){ 
					try{ document.body.scrollTop =  getObj( 'Note' ).value; }catch(e){}
			}, 10 );
		}
	
		if ( param == 'FITTIZIO' )
		{
		   strFilter = 'versione >= 2';
		   OpenViewer('Viewer.asp?JSIN=yes&ShowExit=0&OWNER=OWNER&Table=View_Elenco_DGUE_Compilati&&ModGriglia=&IDENTITY=ID&lo=base&HIDE_COL=FNZ_OPEN,&DOCUMENT=MODULO_TEMPLATE_REQUEST&PATHTOOLBAR=../CustomDoc/&JSCRIPT=ELENCO_DGUE_COMPILATI&AreaAdd=no&Caption=Elenco DGUE Compilati&Height=200,100*,210&numRowForPag=20&Sort=Id&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=hide&TOOLBAR=TOOLBAR_VIEW_LISTA_DGUE_COMPILATI&ACTIVESEL=1&FILTERCOLUMNFROMMODEL=yes&FilterHide=' + strFilter + '&doc_to_upd='+ getObj('IDDOC').value + '&a=');
		}
	*/

}


function OpenCloseGroup(obj) {
	var id = obj.id;

	//-- leggere la caratteristica per decidere se visualizzare o nascondere
	var l = id.length;

	var idRadio = id  //--.substring(4 );; //--GRP_

	if (idRadio.indexOf('_ON_TRUE') > -1)
		idRadio = id.substring(4, l - 8);; //--GRP_

	if (idRadio.indexOf('_ON_FALSE') > -1)
		idRadio = id.substring(4, l - 9);; //--GRP_


	var idValore = 'H_' + id;

	//-- per prima cosa si nasconde il gruppo
	//se si commenta la riga successiva tutte le sezioni saranno esplose
	obj.style.display = 'none';

	//var selectedOption = $("input:radio[id='idRadio']:checked").val()

	//-- si riattiva se il radio è selezionato quello giusto
	if (
		(getObjValue(idValore) == 'GROUP_FULFILLED.ON_TRUE' && getObjValue(idRadio) == 'si')
		||
		(getObjValue(idValore) == 'GROUP_FULFILLED.ON_FALSE' && getObjValue(idRadio) == 'no')
	) {
		obj.style.display = '';
	}


	var next = obj.nextElementSibling;

	if (next.id == obj.id) {
		OpenCloseGroup(next);
	}

}



function OnChangeScelta(obj) {
	try { OpenCloseGroup(getObj('GRP_' + obj.id + '_ON_TRUE')); } catch (e) { }
	try { OpenCloseGroup(getObj('GRP_' + obj.id + '_ON_FALSE')); } catch (e) { }

	//faccio la chiamta per segnare che ho fatto una modifica 
	OnModificaDGUE(obj);

}


function AddItem(Item, IdModulo) {
	getObj('Note').value = 'ADDITEM@@@' + Item + '@@@' + document.documentElement.scrollTop;
	//getObj( 'Note' ).value = document.body.scrollTop;
	Command('ADDITEM', Item, IdModulo);
}

function DelItem(Item) {
	getObj('Note').value = 'DELITEM@@@' + Item + '@@@' + document.documentElement.scrollTop;
	var v = Item.split('@@@');


	var objName = "MOD_" + v[0] + "_FLD_N" + v[2] + v[1];
	var objNameCUR = "MOD_" + v[0] + "_FLD_CUR_N" + v[2] + v[1];
	var objNameTo;
	var objNameFrom;

	var arr = [];
	$("input,select").each(function () {

		try {
			if (this.id.indexOf(objName) > -1 && this.id.indexOf('extraAttrib') == -1) {
				arr.push(this.id.substring(objName.length));
			}
			/*
			if( this.id.includes(  objNameCUR ) )
			{
			arr.push( this.id.substring( ) );
			}
			*/
		} catch (e) { };
	});

	//-- per ogni attributo presente nel gruppo iterabile si spostano i campi
	try {
		var r = Number(v[2]);
		while (r < 1000) //-- 1000 è per evitare un loop infinito
		{
			objNameTo = "MOD_" + v[0] + "_FLD_N" + r + v[1];
			objNameCurTo = "MOD_" + v[0] + "_FLD_CUR_N" + r + v[1];
			r++;
			objNameFrom = "MOD_" + v[0] + "_FLD_N" + r + v[1];
			objNameCurFrom = "MOD_" + v[0] + "_FLD_CUR_N" + r + v[1];

			//-- muove tutti gli attributi presenti nel gruppo
			for (i = 0; i < arr.length; i++) {
				if (getObj(objNameTo + arr[i]).type == 'select') {
					getObj(objNameTo + arr[i]).selectedIndex = getObj(objNameFrom + arr[i]).selectedIndex;
				}
				else {
					getObj(objNameTo + arr[i]).value = getObj(objNameFrom + arr[i]).value;

					//-- prova a spostare anche un eventuale currency
					try { getObj(objNameCurTo + arr[i]).selectedIndex = getObj(objNameCurFrom + arr[i]).selectedIndex; } catch (e) { }
				}
			}
		}
	}
	catch (e) { }



	//getObj( 'Note' ).value = document.body.scrollTop;
	Command('DELITEM', Item);
}

function DelItemVer2(Item, IdModulo) {
	getObj('Note').value = 'DELITEM@@@' + Item + '@@@' + document.documentElement.scrollTop;
	Command('DELITEM', Item, IdModulo);
}


function Command(cmd, Item, IdModulo) {
	var statoDoc;
	statoDoc = getObj('DOCUMENT_READONLY').value;

	if (statoDoc == '1') {
		return;
	}

	var nocache = new Date().getTime();
	var c = Item.split('@@@');

	ShowWorkInProgress();



	ExecDocCommand('#' + cmd + '.' + Item + '#', IdModulo);

	//-- ottimizzare passando il nome del modello da ripulire
	//--SUB_AJAX( '../../ctl_library/REFRESH.ASP?COSA=MODEL&nocache=' + nocache );
	/*
	setTimeout(function()
		{ 

			SUB_AJAX( '../../CustomDoc/TEMPLATE_REQUEST_COMMAND.ASP?IDDOC=' + getObjValue('IDDOC') + '&COMANDO=' + cmd + '&Modulo=' + c[0] + '&Gruppo=' + c[1] + '&Indice=' + c[2] + '&nocache=' + nocache );
			
			ExecDocProcess( 'EXEC_COMMAND,MODULO_TEMPLATE_REQUEST,,NO_MSG');

			}, 1 );
	*/
}
function SaveDoc() {
	ShowWorkInProgress();

	ExecDocCommand('#SAVE#');
}

function ExecDocCommand(parametri, IdModulo) {
	//	debugger;
	var section;
	var command;
	var param;
	var vet;


	vet = parametri.split('#');
	section = vet[0];
	command = vet[1];
	param = vet[2];

	var CommandQueryString = getObj('CommandQueryString').value;



	var IDDOC = getObj('IDDOC').value;
	var TYPEDOC = getObj('TYPEDOC').value;

	var objForm = getObj('FORMDOCUMENT');
	var strUrl = ''

	//tolgo il parametro CRITERION
	if (IdModulo != undefined) {
		CommandQueryString = CommandQueryString.replace('&CRITERION=', '&_CRITERION=');
		CommandQueryString = CommandQueryString.replace('&lo=', '&_lo=');
		CommandQueryString = CommandQueryString + '&CRITERION=' + IdModulo + '&lo=no';
	}

	strUrl = 'TEMPLATE_REQUEST.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=' + command + param;

	objForm.action = strUrl;

	objForm.target = '';

	//passo il modulo e layout=no
	//target frame nascosto oppure chiamata ajax
	if (IdModulo != undefined)
		objForm.target = 'DGUE_Command';

	try { CloseRTE() } catch (e) { };
	objForm.submit();


}

function SetInitField() {

	var i = 0;

	for (i = 0; i < NumControlli; i++) {
		//if ( getObjValue('Not_Editable').indexOf( LstAttrib[i] + ' ,') < 0 )
		if (getObj(LstAttrib[i])) {
			try {
				TxtOK(LstAttrib[i]);
			} catch (e) {
				//alert( i + '---' + LstAttrib[i]);
			}
		}
	}




}
var NumControlli;
var LstAttrib;
function GeneraPDFOLD() {




	var statoDoc;
	statoDoc = getObj('DOCUMENT_READONLY').value;

	if (statoDoc == '1') {
		return;
	}



	/*  
	   if( controlli('') == 1) 
	   {
		   DMessageBox( '../' , 'Compilare il DGUE in tutti i suoi campi obbligatori, successivamente effettuare nuovamente il comando genera pdf.' , 'Attenzione' , 1 , 400 , 300 );
		   //SaveDoc();
		   return;
	   }
   */

	scroll(0, 0);
	//alert( 'URL=/customdoc/TEMPLATE_REQUEST.ASP?' + getObjValue( 'PrintQueryString' ) );

	PrintPdfSign('URL=/customdoc/TEMPLATE_REQUEST.ASP?' + getObjValue('PrintQueryString') + '&SIGN=YES&PROCESS=');

	//PrintPdfSign('URL=/report/prn_' + getObj('TYPEDOC').value + '.ASP?SIGN=YES&PROCESS=ISTANZA@@@VERIFICHE_PRE_PDF');	

	//ToPrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=Documento_' + getObjValue( 'JumpCheck' ) + '&lo=print&NO_SECTION_PRINT=DISPLAY_FIRMA&ML_FOOTER=ML_FOOTER_PAGING_PDF&JSCRIPT_STAMPA=YES&JSCRIPT_STAMPA_NAME=MODULO_TEMPLATE_REQUEST&PROCESS=MODULO_TEMPLATE_REQUEST@@@VERIFICA_CAMPI_OBBLI');

}

function GeneraPDF() {


	var value2 = controlli('');
	var nomeFile;

	//var EsitoRiga=controlloEsitoRiga();

	//if (value2 == 1)
	//	return;

	if (controlli('') == 1) {
		DMessageBox('../', 'Compilare il DGUE in tutti i suoi campi obbligatori, successivamente effettuare nuovamente il comando genera pdf.', 'Attenzione', 1, 400, 300);
		//SaveDoc();
		return;
	}

	//Stato = getObjValue('StatoDoc');
	//chiedere conferma a sabato
	//Stato = getObjValue('StatoDocRiferimento'); 

	//if( Stato == '' ) 
	//se ho fatto una modifca richiedo un salvataggio
	if (gModify_DGUE == 1) {
		alert('Per effettuare il \"Genera PDF\" si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di \"Genera PDF\"');
		//	DMessageBox( '../' , 'Per procedere si richiede prima un salvataggio, successivamente effettuare nuovamente il comando genera pdf.' , 'Attenzione' , 1 , 400 , 300 );
		SaveDoc('');
		return;
	}

	/*
	if ( EsitoRiga == -1 )
	{
		return;
	}
	*/

	scroll(0, 0);

	nomeFile = getObj('Caption').value;

	if (nomeFile == 'Modulo - DGUE') {
		nomeFile = 'DGUE';
	}
	else {
		nomeFile = getObjValue('JumpCheck')
	}


	PrintPdfSign('URL=/customdoc/TEMPLATE_REQUEST.ASP?' + getObjValue('PrintQueryString') + '&SIGN=YES&PROCESS=&PDF_NAME=Documento_' + nomeFile + '&lo=print&JSCRIPT_STAMPA=YES&JSCRIPT_STAMPA_NAME=MODULO_TEMPLATE_REQUEST_VER2');

	//Print('TEMPLATE_REQUEST.ASP?' + getObjValue( 'PrintQueryString' ) + '&SIGN=YES&PROCESS=&PDF_NAME=Documento_' + nomeFile + '&lo=print&JSCRIPT_STAMPA=YES&JSCRIPT_STAMPA_NAME=MODULO_TEMPLATE_REQUEST_VER2&');	

}

function ShowPDF() {


	/*
	
		var statoDoc;
		statoDoc = getObj('DOCUMENT_READONLY').value;
	
		if( statoDoc == '1' ) 
		{
			return;
		}
	
		
	
		if( controlli('') == 1) 
		{
			DMessageBox( '../' , 'Compilare il DGUE in tutti i suoi campi obbligatori, successivamente effettuare nuovamente il comando genera pdf.' , 'Attenzione' , 1 , 400 , 300 );
			//SaveDoc();
			return;
		}
	*/

	scroll(0, 0);

	//PrintPdf( '/customdoc/TEMPLATE_REQUEST.ASP?' + getObjValue( 'PrintQueryString' ) + '&PDF_NAME=ESPD_REQUEST&lo=print&ML_FOOTER=ML_FOOTER_PAGING_PDF' );
	//alert( 'URL=/customdoc/TEMPLATE_REQUEST.ASP?' + getObjValue( 'PrintQueryString' ) );

	//PrintPdf( '/customdoc/TEMPLATE_REQUEST.ASP?' + getObjValue( 'PrintQueryString' ) + '&PDF_NAME=ESPD_REQUEST&lo=print&ML_FOOTER=ML_FOOTER_PAGING_PDF' );

	nomeFile = getObj('Caption').value;

	if (nomeFile == 'Modulo - DGUE') {
		nomeFile = 'DGUE';
	}
	else {
		nomeFile = getObjValue('JumpCheck')
	}

	Print('TEMPLATE_REQUEST.ASP?' + getObjValue('PrintQueryString') + '&SIGN=YES&PROCESS=&PDF_NAME=Documento_' + nomeFile + '&lo=print&JSCRIPT_STAMPA=YES&JSCRIPT_STAMPA_NAME=MODULO_TEMPLATE_REQUEST_VER2&');

}



function controlli(param) {
	if (getObj('DOCUMENT_READONLY').value != '1') {
		var err = 0;
		var cod = getObj("IDDOC").value;
		var campiObblig = getObjValue('ElencoFieldObblig');

		campiObblig = campiObblig.replace(/~~~/g, '\"')
		LstAttrib = JSON.parse(campiObblig);
		NumControlli = LstAttrib.length;


		SetInitField();

		//-- controllo i dati della richiesta
		var i = 0;
		var err = 0;

		var bFirst = 0;
		var obj;
		var bVis;

		for (i = 0; i < NumControlli; i++) {

			try {
				//if ( getObjValue('Not_Editable').indexOf( LstAttrib[i] + ' ,') < 0 )
				if (getObj(LstAttrib[i])) {
					bVis = true;

					obj = getObj(LstAttrib[i]);
					if (obj.type == undefined && obj.length > 1)
						obj = obj[0];


					if (
						obj.type == 'text' || obj.type == 'hidden' ||
						obj.type == 'select-one' || obj.type == 'textarea' ||
						obj.type == 'radio'
					) {
						if (trim(getObjValue(LstAttrib[i])) == '') {

							//prima di settare la classe per obbligatorio vado a controllare se 
							//l'attributo appartiene ad un gruppo relazionato
							//se il campo GROUP_Related<attributo> esiste mi prendo il valore  e se l'oggetto relativo
							//è visibile allora lo evidenzio altrimenti se è nascosto no
							objRelated = getObj('Group_Related_' + LstAttrib[i]);

							//siccome possono essere annidati vado a ritroso e mi fermo quando non ne ho trovati più
							//di annidamenti (il campo del relazionato è vuoto oppure non esiste prorpio)
							//oppure appena trovo un relazionato non visibile

							while (objRelated != null) {

								ValueRelated = objRelated.value;

								if (ValueRelated != '') {

									ObjGroup_Related = getObj(ValueRelated);

									//se trovo un gruppo nella catena nascosto esco e non  devo fare nulla 
									if (ObjGroup_Related != undefined) {
										if (ObjGroup_Related.style.display == "none") {
											bVis = false;
											break;
										}
									}

									objRelated = getObj('Group_Related_' + ValueRelated);
								}
								else {
									break;
								}
							}

							//se il campo è visibile allora setto la classe per evidenziarlo com eobbligatorio
							if (bVis) {
								err = 1;
								TxtErr(LstAttrib[i]);
							}

						}
					}


					if (obj.type == 'checkbox') {
						if (obj.checked == false) {
							err = 1;
							TxtErr(LstAttrib[i]);
						}
					}

					//gestione delle select multiple
					if (obj.type == 'select-multiple') {
						//if( trim(getObjValue( LstAttrib[i] )) == '' )
						//se non ci sono option allora lo evidenzio	
						if (document.getElementById(LstAttrib[i]).options.length == 0) {
							err = 1;
							TxtErr(LstAttrib[i]);
						}
					}


					if (bFirst == 0 && err == 1) {
						try {
							obj.focus();
							bFirst = 1;
						} catch (e) { }
					}

				}
			} catch (e) { /*alert( i + ' - ' +  LstAttrib[i] );*/ }


		}
		return err;
	}
}

function GeneraPDF_E() {
	ToPrintPdf('PDF_NAME=Documento_' + getObjValue('JumpCheck') + '&lo=print&NO_SECTION_PRINT=DISPLAY_FIRMA&PROCESS=&ML_FOOTER=ML_FOOTER_PAGING_PDF&JSCRIPT_STAMPA=YES&JSCRIPT_STAMPA_NAME=MODULO_TEMPLATE_REQUEST');
}



function TogliFirma() {
	//ExecDocProcess( 'SIGN_ERASE,FirmaDigitale');

	ShowWorkInProgress();

	ExecDocCommand('#SIGN_ERASE#');

}


function AllegaDOCFirmato() {


	var idDoc;
	var CF = '';
	idDoc = getObjValue('IDDOC');
	CF = getObjValue('codicefiscale');

	if (CF != '' && CF != undefined) {
		ExecFunctionCenterDoc('../CTL_Library/functions/field/uploadattachsigned.asp?TABLE=ctl_doc&amp;IDDOC=' + idDoc + '&amp;CF=' + CF + '&amp;OPERATION=INSERTSIGN&amp;IDENTITY=Id&amp;AREA=&amp;DOMAIN=FileExtention&amp;FORMAT=#AllegaFirma#600,400')
	}
	else {
		ExecFunctionCenterDoc('../CTL_Library/functions/field/uploadattachsigned.asp?TABLE=ctl_doc&amp;IDDOC=' + idDoc + '&amp;OPERATION=INSERTSIGN&amp;IDENTITY=Id&amp;AREA=&amp;DOMAIN=FileExtention&amp;FORMAT=#AllegaFirma#600,400')
	}


}

function trim(str) {
	return str.replace(/^\s+|\s+$/g, "");
}



function MyOpenViewer(param) {
	//ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');
	strFilter = 'versione >= 2';
	OpenViewer('Viewer.asp?JSIN=yes&ShowExit=0&OWNER=OWNER&Table=View_Elenco_DGUE_Compilati&&ModGriglia=&IDENTITY=ID&lo=base&HIDE_COL=FNZ_OPEN,&DOCUMENT=MODULO_TEMPLATE_REQUEST&PATHTOOLBAR=../CustomDoc/&JSCRIPT=ELENCO_DGUE_COMPILATI&AreaAdd=no&Caption=Elenco DGUE Compilati&Height=200,100*,210&numRowForPag=20&Sort=DataInvio&SortOrder=desc&Exit=si&AreaFiltro=&AreaFiltroWin=hide&TOOLBAR=TOOLBAR_VIEW_LISTA_DGUE_COMPILATI&ACTIVESEL=1&FILTERCOLUMNFROMMODEL=yes&FilterHide=' + strFilter + '&doc_to_upd=' + getObj('IDDOC').value + '&Versione=2&a=');

}






function OpenCloseGroup2(ID, H) {

	var objOpen = getObj('Group_' + ID);

	var cls = objOpen.getAttribute('class');

	if (objOpen.style.display == 'none' || cls.indexOf('display_none') > -1) {
		setVisibility(objOpen, '');
	}
	else {
		setVisibility(objOpen, 'none');
	}
}


//---- IDENTIFIER OPERATOR

function AddIdentifier(ObjName) {

	AddItemIdentifier(ObjName + '_ALL_DOMAIN', ObjName + '_SELECTED_ITEM');

	document.getElementById(ObjName).value = GetSelectedItemIdentifier(ObjName);

	OnModificaDGUE(ObjName)

}

function DelIdentifier(ObjName) {

	RemoveItemIdentifier(ObjName + '_SELECTED_ITEM');

	document.getElementById(ObjName).value = GetSelectedItemIdentifier(ObjName);

	OnModificaDGUE(ObjName)

}


function AddItemIdentifier(source, dest) {

	Sel_Dest = document.getElementById(dest);
	Sel_Source = document.getElementById(source);

	num_option_dest = document.getElementById(dest).options.length;
	num_option_source = document.getElementById(source).options.length;

	//indice_selezionato = document.getElementById(source).selectedIndex;
	var indice_selezionato = 0;
	while (indice_selezionato < num_option_source) {

		//if(indice_selezionato>=0){
		if (Sel_Source.options[indice_selezionato].selected) {
			value_selezionato = document.getElementById(source).options[indice_selezionato].value;
			testo_selezionato = document.getElementById(source).options[indice_selezionato].innerHTML;
			duplicato = 0;
			for (a = 0; a < num_option_dest; a++) {
				if (document.getElementById(dest).options[a].value == value_selezionato) {
					duplicato = 1;
				}
			}
			if (duplicato == 0) {
				document.getElementById(dest).options[num_option_dest] = new Option(testo_selezionato, escape(value_selezionato), false, false);
				num_option_dest++;
				//document.getElementById(dest).options[num_option_dest].innerHTML = testo_selezionato;
			}
		}
		indice_selezionato++;
	}
}


function RemoveItemIdentifier(dest) {

	Sel_Dest = document.getElementById(dest);

	num_option_dest = Sel_Dest.options.length;

	var indice_selezionato = 0;
	while (indice_selezionato < num_option_dest) {

		//if(indice_selezionato>=0){
		if (Sel_Dest.options[indice_selezionato].selected) {
			try {
				Sel_Dest.remove(indice_selezionato, null);
			}
			catch (error) {
				Sel_Dest.remove(indice_selezionato);
			}
			num_option_dest--;
		}
		else
			indice_selezionato++;
	}
}



function GetSelectedItemIdentifier(ObjName) {
	var ret = '';
	Sel_Dest = document.getElementById(ObjName + '_SELECTED_ITEM');

	num_option_dest = Sel_Dest.options.length;

	for (var indice_selezionato = 0; indice_selezionato < num_option_dest; indice_selezionato++) {
		ret = ret + '###' + Sel_Dest.options[indice_selezionato].value;
	}

	if (ret.length > 0)
		ret += '###';

	return ret;
}



function ImportESPD_Response(parametri) {
	ExecFunctionCenter('../Ctl_library/functions/FIELD/UploadAttach.asp?PAGE=../../../ESPD/importResponse.aspx&IDDOC=' + getObjValue('IDDOC') + '&IDPFU=' + idpfuUtenteCollegato + '&' + parametri + '##400,400');
}



function RefreshDocument(path) {

	var CommandQueryString = getObj('CommandQueryString').value;

	if (path.toLowerCase().indexOf('document') > 0)
		//URL = '../Customdoc/TEMPLATE_REQUEST.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=RELOAD' ;
		//URL = '../../Customdoc/TEMPLATE_REQUEST.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=RELOAD';
		//URL = '/Application/Customdoc/TEMPLATE_REQUEST.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=RELOAD';

		//utilizzo la variabile globale di layout.inc che contiene il nome dell'applicazione con lo slash davanti ad es. "/Application"
		URL = urlPortale + '/Customdoc/TEMPLATE_REQUEST.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=RELOAD';

	else
		URL = path + 'Customdoc/TEMPLATE_REQUEST.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=RELOAD';


	try {
		self.location = URL;
	} catch (e) { }
}

//effettua la selezione veloce dei campi indicati nel campo 
//NameField + '_CampiInteressati'
//se arriva true devo mettere tutti i radio indicati a no e li inibisco altrimenti tolgo la selezione ai radio e li lascio liberi
function SelezioneVeloce(NameField, ResetOnFalse) {
	//alert(NameField);
	var i;
	var val_SV = getObj(NameField).checked;
	var NameAttrib = '';
	//alert(val_SV) ;

	//recupero i campi da influenzare
	var NameField_CI = NameField + '_CampiInteressati';

	var val_SV_CI = getObj(NameField_CI).value;

	var strSuffixSelVeloce = '';

	var nLenSelVeloce

	var nMakeSelVeloce_SI = 0;

	//per fare un test ho inserito 2 radio di esempio
	//val_SV_CI='MOD_F_0_1_FLD_K2_R1,MOD_F_0_1_FLD_K3_R1';

	if (val_SV_CI != '') {
		//la lista dei campi da influenzare contiene i campi separati dalla virgola
		var vet = val_SV_CI.split(',');
		//alert(vet.length);

		for (i = 0; i < vet.length; i++) {

			//applico trim sul nome campo indicato in caso di spazi in  coda oppure all'inizio
			NameAttrib = trim(vet[i]);

			//se gli ultimi 2 caratteri sono '-S' allora devo settare il radiobutton a SI e non a NO
			nLenSelVeloce = NameAttrib.length;
			strSuffixSelVeloce = NameAttrib.substring(nLenSelVeloce - 2, nLenSelVeloce);

			//alert(strSuffixSelVeloce);

			nMakeSelVeloce_SI = 0;

			if (strSuffixSelVeloce == '-S') {
				nMakeSelVeloce_SI = 1;
				NameAttrib = NameAttrib.substring(0, nLenSelVeloce - 2);
			}


			//alert(NameAttrib);

			if (val_SV) {

				if (nMakeSelVeloce_SI == 0)
					document.getElementsByName(NameAttrib)[0].checked = false;
				else
					document.getElementsByName(NameAttrib)[0].checked = true;

				//invovo eventuale onchange sul campo per nascondere/visualizzare area associata
				//solo se invocata esplicitamente e non sul caricamento del documento
				if (ResetOnFalse == 1) {
					try { document.getElementsByName(NameAttrib)[0].onchange(); } catch (e) { }
				}



				if (nMakeSelVeloce_SI == 0) {
					document.getElementsByName(NameAttrib)[0].disabled = true;
					document.getElementsByName(NameAttrib)[1].checked = true;
				}
				else {
					document.getElementsByName(NameAttrib)[1].disabled = true;
					document.getElementsByName(NameAttrib)[1].checked = false;
				}

				//invovo eventuale onchange sul campo per nascondere/visualizzare area associata
				//solo se invocata esplicitamente e non sul caricamento del documento
				if (ResetOnFalse == 1) {
					try { document.getElementsByName(NameAttrib)[1].onchange(); } catch (e) { }
				}
			}

			else {
				document.getElementsByName(NameAttrib)[0].disabled = false;
				document.getElementsByName(NameAttrib)[1].disabled = false;

				if (ResetOnFalse == 1) {
					document.getElementsByName(NameAttrib)[0].checked = false;
					document.getElementsByName(NameAttrib)[1].checked = false;
				}



			}


		}

	}


}


//per tutti i campi checkbox che hanno la classe di stile SelezioneVeloce
//invoco la funzione SelezioneVeloce
function Init_SelezioneVeloce(obj) {
	if (getObj('DOCUMENT_READONLY').value != '1') {
		var VetObj = $(".SelezioneVeloce");
		var i;
		//alert( VetObj.length );
		for (i = 0; i < VetObj.length; i++) {
			//alert(VetObj[i].id);
			SelezioneVeloce(VetObj[i].id, 0);
		}
	}
}


function Init_FldDomainValue_OnChangeScelta(obj) {
	//if (getObj('DOCUMENT_READONLY').value != '1' )
	//{
	var VetObj = $(".FldDomainValue");
	var i;
	//alert( VetObj.length );
	for (i = 0; i < VetObj.length; i++) {
		//alert(VetObj[i].id);
		if (VetObj[i].onchange != null)
			OnChangeScelta(VetObj[i]);

	}
	//}


}


function OnModificaDGUE(obj) {
	gModify_DGUE = 1;
}




function getObjValue(strId) {

	var obj = getObj(strId);
	var val;
	//var l = obj.length;
	var type;
	try { type = obj[0].type; }
	catch (e) {
		//console.log(e);
		type = obj.type;
	}

	try {
		if (getObj(strId).type == 'select-one') {
			if (getObj(strId).selectedIndex == -1)
				return '';
			else
				return getObj(strId).options[getObj(strId).selectedIndex].value;
		}

	} catch (e) { }

	try {
		if (getObj(strId).type == 'textarea') {
			return getObj(strId).value;
		}

	} catch (e) { }

	try {
		//if( getObj(strId).type == 'radio' )
		if (type == 'radio') {

			//var o_radio_group = getObj(strId);
			var o_radio_group = document.getElementsByName(strId);
			for (var a = 0; a < o_radio_group.length; a++) {
				if (o_radio_group[a].checked) {
					return o_radio_group[a].value;
				}
			}
			return '';
		}
	} catch (e) { }


	// Gestiti i campi Checkbox: ritorna true o false
	try {
		if (type === 'checkbox') {
			return getObj(strId).checked;
		}
	} catch (e) { }

	try {
		val = getObj(strId).value;	//	val = GetProperty( getObj( strId ) , 'value');
	} catch (e) {
		val = undefined;
	}

	//if ( val == '' || val == undefined ) 
	if (val == undefined) {
		try {
			//val = getObj( strId )[0].value;
			val = GetProperty(getObj(strId)[0], 'value');

		} catch (e) {

			val = GetProperty(getObj(strId), 'value');
		}

	}

	return val;
}


function getObj(strId) {

	if (document.all != null) {
		return document.all(strId);
	}
	else {
		return document.getElementById(strId);
	}
}
