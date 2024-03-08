
window.onload = OpenModuli;



function OpenModuli() {

	try {
		if (getObjValue('Versione') == '2') {
			document.location = '../../CustomDoc/TEMPLATE_REQUEST.ASP?IDDOC=' + getObjValue('IDDOC') + '&VER=2&JSCRIPT=MODULO_TEMPLATE_REQUEST_VER2&lo=base';
		}

	} catch (e) { }

	//	if ( getQSParam('lo') == 'print' )
	//{
	try {
		document.getElementById('USER_DOC_READONLY_TOOLBAR_DOCUMENT_PRINT').style.display = 'none';
		document.getElementById('USER_DOC_READONLY_TOOLBAR_DOCUMENT_EXCEL').style.display = 'none';
	} catch (e) { }
	//}

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
					return element.attr("alt");
				}
			}
		});
	});

	var GRP = document.getElementsByName("GRP_Related");
	var i;
	for (i = 0; i < GRP.length; i++) {
		try { OpenCloseGroup(GRP[i]); } catch (e) { };
	}

	try {
		Stato = getObj('StatoDoc').value;
		CAN_MOD = getObj('colonnatecnica').value;

		if ((getObjValue('SIGN_LOCK') == '0' || getObjValue('SIGN_LOCK') == '') && (Stato == 'Saved' || Stato == "")) {
			document.getElementById('generapdf').disabled = false;
			document.getElementById('generapdf').className = "generapdf";
		}
		else {
			document.getElementById('generapdf').disabled = true;
			document.getElementById('generapdf').className = "generapdfdisabled";
		}
		if (getObjValue('SIGN_LOCK') != '0' && (Stato == 'Saved') && CAN_MOD == 'si') {
			document.getElementById('editistanza').disabled = false;
			document.getElementById('editistanza').className = "attachpdf";
		}
		else {
			document.getElementById('editistanza').disabled = true;
			document.getElementById('editistanza').className = "attachpdfdisabled";
		}
		if (getObjValue('SIGN_ATTACH') == '' && (Stato == 'Saved') && getObjValue('SIGN_LOCK') != '0') {
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





}


function afterProcess(param) {

	if (param == 'EXEC_COMMAND') {
		setTimeout(function () {
			try { document.body.scrollTop = getObj('Note').value; } catch (e) { }
		}, 10);
	}
	if (param == 'FITTIZIO') {
		//recupero solo i dgue con versione < 2
		strFilter = 'versione < 2';
		OpenViewer('Viewer.asp?JSIN=yes&ShowExit=0&OWNER=OWNER&Table=View_Elenco_DGUE_Compilati&&ModGriglia=&IDENTITY=ID&lo=base&HIDE_COL=FNZ_OPEN,&DOCUMENT=MODULO_TEMPLATE_REQUEST&PATHTOOLBAR=../CustomDoc/&JSCRIPT=ELENCO_DGUE_COMPILATI&AreaAdd=no&Caption=Elenco DGUE Compilati&Height=200,100*,210&numRowForPag=20&Sort=Id&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=hide&TOOLBAR=TOOLBAR_VIEW_LISTA_DGUE_COMPILATI&ACTIVESEL=1&FILTERCOLUMNFROMMODEL=yes&FilterHide=' + strFilter + '&doc_to_upd=' + getObj('IDDOC').value + '&a=');
	}
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



}



function OnChangeScelta(obj) {
	try { OpenCloseGroup(getObj('GRP_' + obj.id + '_ON_TRUE')); } catch (e) { }
	try { OpenCloseGroup(getObj('GRP_' + obj.id + '_ON_FALSE')); } catch (e) { }
}


function AddItem(Item) {
	getObj('Note').value = 'ADDITEM@@@' + Item + '@@@' + document.body.scrollTop;
	//getObj( 'Note' ).value = document.body.scrollTop;
	Command('ADDITEM', Item);
}

function DelItem(Item) {
	getObj('Note').value = 'DELITEM@@@' + Item + '@@@' + document.body.scrollTop;
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


function Command(cmd, Item) {
	var statoDoc;
	statoDoc = getObj('DOCUMENT_READONLY').value;

	if (statoDoc == '1') {
		return;
	}

	var nocache = new Date().getTime();
	var c = Item.split('@@@');

	ShowWorkInProgress();

	//-- ottimizzare passando il nome del modello da ripulire
	//--SUB_AJAX( '../../ctl_library/REFRESH.ASP?COSA=MODEL&nocache=' + nocache );

	setTimeout(function () {

		SUB_AJAX('../../CustomDoc/TEMPLATE_REQUEST_COMMAND.ASP?IDDOC=' + getObjValue('IDDOC') + '&COMANDO=' + cmd + '&Modulo=' + c[0] + '&Gruppo=' + c[1] + '&Indice=' + c[2] + '&nocache=' + nocache);

		ExecDocProcess('EXEC_COMMAND,MODULO_TEMPLATE_REQUEST,,NO_MSG');

	}, 1);
}

function SetInitField() {

	var i = 0;
	for (i = 0; i < NumControlli; i++) {
		//if ( getObjValue('Not_Editable').indexOf( LstAttrib[i] + ' ,') < 0 )
		if (getObj(LstAttrib[i])) {
			TxtOK(LstAttrib[i]);
		}
	}




}
var NumControlli;
var LstAttrib;
function GeneraPDF() {




	var statoDoc;
	var nomeFile;
	nomeFile = getObj('Caption').value;
	statoDoc = getObj('DOCUMENT_READONLY').value;

	if (statoDoc == '1') {
		return;
	}




	if (controlli('') == 1) {
		DMessageBox('../', 'Compilare il DGUE in tutti i suoi campi obbligatori, successivamente effettuare nuovamente il comando genera pdf.', 'Attenzione', 1, 400, 300);
		//SaveDoc();
		return;
	}


	scroll(0, 0);

	if (nomeFile == 'Modulo - DGUE') {
		nomeFile = 'DGUE';
	}
	else {
		nomeFile = getObjValue('JumpCheck')
	}
	ToPrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=Documento_' + nomeFile + '&lo=print&NO_SECTION_PRINT=DISPLAY_FIRMA&ML_FOOTER=ML_FOOTER_PAGING_PDF&JSCRIPT_STAMPA=YES&JSCRIPT_STAMPA_NAME=MODULO_TEMPLATE_REQUEST&PROCESS=MODULO_TEMPLATE_REQUEST@@@VERIFICA_CAMPI_OBBLI');

}



function controlli(param) {
	if (getObj('DOCUMENT_READONLY').value != '1') {
		var err = 0;
		var cod = getObj("IDDOC").value;
		var campiObblig = getObjValue('Body');

		LstAttrib = JSON.parse(campiObblig);
		NumControlli = LstAttrib.length - 1;


		SetInitField();

		//-- controllo i dati della richiesta
		var i = 0;
		var err = 0;

		var bFirst = 0;
		var obj;

		//recupero il valore del campo radio della sezione E "Salta alla prossima Parte" 	
		var valObjSaltaSezioneE = '';

		if (getObj('MOD_E_1_1_FLD_G1_2_R1'))
			valObjSaltaSezioneE = getObjValue('MOD_E_1_1_FLD_G1_2_R1');

		for (i = 0; i < NumControlli; i++) {

			try {
				//if ( getObjValue('Not_Editable').indexOf( LstAttrib[i] + ' ,') < 0 )

				//effettuo i controlli se non sono elementi della sezione E oppure se il salta non è selezionato e sono elementi della sezione E
				if (
					LstAttrib[i].substring(0, 6) != 'MOD_E_'
					||
					(valObjSaltaSezioneE != 'si' && LstAttrib[i].substring(0, 6) == 'MOD_E_')
				) {
					if (getObj(LstAttrib[i])) {

						obj = getObj(LstAttrib[i]);
						if (obj.type == undefined && obj.length > 1)
							obj = obj[0];


						if (
							obj.type == 'text' || obj.type == 'hidden' ||
							obj.type == 'select-one' || obj.type == 'textarea' ||
							obj.type == 'radio'
						) {
							if (trim(getObjValue(LstAttrib[i])) == '') {
								err = 1;
								TxtErr(LstAttrib[i]);
							}
						}


						if (obj.type == 'checkbox') {
							if (obj.checked == false) {
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
				}
			} catch (e) { alert(i + ' - ' + LstAttrib[i]); }


		}
		return err;
	}
}

function GeneraPDF_E() {
	ToPrintPdf('PDF_NAME=Documento_' + getObjValue('JumpCheck') + '&lo=print&NO_SECTION_PRINT=DISPLAY_FIRMA&PROCESS=&ML_FOOTER=ML_FOOTER_PAGING_PDF&JSCRIPT_STAMPA=YES&JSCRIPT_STAMPA_NAME=MODULO_TEMPLATE_REQUEST');
}



function TogliFirma() {
	//DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
	ExecDocProcess('SIGN_ERASE,FirmaDigitale');
}


function AllegaDOCFirmato() {


	var idDoc;
	var CF = '';
	idDoc = getObjValue('IDDOC');
	CF = getObjValue('codicefiscale');

	if (CF != '' && CF != undefined) {
		ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=ctl_doc&amp;IDDOC=' + idDoc + '&amp;CF=' + CF + '&amp;OPERATION=INSERTSIGN&amp;IDENTITY=Id&amp;AREA=&amp;DOMAIN=FileExtention&amp;FORMAT=#AllegaFirma#600,400')
	}
	else {
		ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=ctl_doc&amp;IDDOC=' + idDoc + '&amp;OPERATION=INSERTSIGN&amp;IDENTITY=Id&amp;AREA=&amp;DOMAIN=FileExtention&amp;FORMAT=#AllegaFirma#600,400')
	}


}

function trim(str) {
	return str.replace(/^\s+|\s+$/g, "");
}



function MyOpenViewer(param) {
	ExecDocProcess('FITTIZIO,DOCUMENT,,NO_MSG');
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
