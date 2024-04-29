function GetPositionCol(grid, idCol, Page) {

	var objInd;
	var nInd;
	var obj;
	var numRow;


	try {
		obj = getObjPage(grid + '_' + idCol, Page);

		return obj.cellIndex;
	}
	catch (e) { return -1; };

}


function RichiestaRisposta() {
	if (getObjValue('RichiestaRisposta') == 'no' || getObjValue('RichiestaRisposta') == "") {


		getObj('DataScadenza_V').value = "";
		getObj('DataScadenza_HH_V').value = "";
		getObj('DataScadenza_MM_V').value = "";
		getObj('Richiesta_del_Prec').value = "";
		getObj('DataScadenza_button').disabled = true;
		getObj('Richiesta_del_Prec').disabled = true;
		getObj('DataScadenza_V').disabled = true;
		getObj('DataScadenza_HH_V').disabled = true;
		getObj('DataScadenza_MM_V').disabled = true;
	}

	if (getObjValue('RichiestaRisposta') == 'si') {
		getObj('Richiesta_del_Prec').disabled = false;
		getObj('DataScadenza_button').disabled = false;
		getObj('DataScadenza_V').disabled = false;
		getObj('DataScadenza_HH_V').disabled = false;
		getObj('DataScadenza_MM_V').disabled = false;
	}
}
function onchange() {

	var indCell = 0;

	try {
		if (getObjValue('RichiestaRisposta') == 'no') {
			getObj('Richiesta_del_Prec').disabled = true;
			getObj('DataScadenza_button').disabled = true;
			getObj('DataScadenza_V').disabled = true;
			getObj('DataScadenza_HH_V').disabled = true;
			getObj('DataScadenza_MM_V').disabled = true;
		}
		getObj('RichiestaRisposta').onchange = RichiestaRisposta;
	} catch (e) { }

	try {
		var i = 0;
		var numeroRighe0 = -1;
		numeroRighe0 = GetProperty(getObj('FORNITORIGrid'), 'numrow');


		indCell = GetPositionCol('FORNITORIGrid', 'OpenDettaglio', '');
		//alert(indCell);
		if (Number(numeroRighe0) >= 0) {
			for (i = 0; i <= numeroRighe0; i++) {
				try {
					if (getObj('R' + i + '_FORNITORIGrid_ID_DOC').value == '0' || getObj('R' + i + '_FORNITORIGrid_ID_DOC').value == '') {
						getObj('FORNITORIGrid_r' + i + '_c' + (indCell)).innerHTML = '&nbsp;';
						//getObj( 'FORNITORIGrid_r' + i + '_c' + ( 6) ).className='';
						getObj('FORNITORIGrid_r' + i + '_c' + (indCell)).onclick = '';


						//getObj( 'FORNITORIGrid_r' + i + '_c' + (10) ).innerHTML = '&nbsp;';
						//getObj( 'FORNITORIGrid_r' + i + '_c' + (10) ).onclick='';
					}
				} catch (e) { }

			}
		}

	} catch (e) { }


	try {
		var i = 0;
		numeroRighe0 = -1;
		numeroRighe0 = GetProperty(getObj('PLANTGrid'), 'numrow');
		//alert(Number( numeroRighe0 ));

		indCell = GetPositionCol('PLANTGrid', 'OpenDettaglio', '');
		if (Number(numeroRighe0) >= 0) {
			for (i = 0; i <= numeroRighe0; i++) {
				try {
					if (getObj('R' + i + '_PLANTGrid_ID_DOC').value == '0' || getObj('R' + i + '_PLANTGrid_ID_DOC').value == '') {
						getObj('PLANTGrid_r' + i + '_c' + (3)).innerHTML = '&nbsp;';
						//getObj( 'PLANTGrid_r' + i + '_c' + (  indCell ) ).className='';
						getObj('PLANTGrid_r' + i + '_c' + (3)).onclick = '';
					}
				} catch (e) { }
			}
		}
	} catch (e) { }

	try {
		var i = 0;
		numeroRighe0 = -1;
		numeroRighe0 = GetProperty(getObj('ENTIGrid'), 'numrow');
		//alert(Number( numeroRighe0 ));
		indCell = GetPositionCol('ENTIGrid', 'OpenDettaglio', '');
		if (Number(numeroRighe0) >= 0) {
			for (i = 0; i <= numeroRighe0; i++) {

				try {
					if (getObj('R' + i + '_ENTIGrid_ID_DOC').value == '0' || getObj('R' + i + '_ENTIGrid_ID_DOC').value == '') {

						getObj('ENTIGrid_r' + i + '_c' + (indCell)).innerHTML = '&nbsp;';
						//getObj( 'FORNITORIGrid_r' + i + '_c' + ( 6) ).className='';
						getObj('ENTIGrid_r' + i + '_c' + (indCell)).onclick = '';




						//getObj( 'ENTIGrid_r' + i + '_c' + (10) ).innerHTML = '&nbsp;';
						//getObj( 'ENTIGrid_r' + i + '_c' + (10) ).onclick='';

					}
				} catch (e) { }
			}
		}

	} catch (e) { }

	//se protocollo non attivo nascondo il campo "Richiesta Protocollo"
	if (getObj('ProtocolloAttivo').value == 'no') {

		$("#cap_RichiestaProtocollo").parents("table:first").css({ "display": "none" });

		if (getObj('DOCUMENT_READONLY').value != '1') {
			getObj('RichiestaProtocollo').value = 'no';

		}
	}


	if (getObj('DOCUMENT_READONLY').value != '1') {
		//recupero aziprofili azienda collegta 
		var aziProfili = getObjValue('aziProfili');
		var filter = 'SQL_WHERE= codice  in ( select Codice from Profili_Funzionalita where \'' + aziProfili + '\' like \'%\' + aziProfilo + \'%\'  ) ';
		try {
			SetProperty(getObj('ProfiloUtentiCom'), 'filter', filter);
		} catch (e) { }
	}


	try {
		if (getObjValue('MPLOG') != 'PA') {
			//DocDisplayFolder(  'PROTOCOLLO'   ,'none' );
			getObj('PROTOCOLLO').style.display = 'none';
		}

	} catch (e) { }


}


window.onload = onchange;

function FORNITORI_AFTER_COMMAND(p) {
	onchange();


}

function PLANT_AFTER_COMMAND(p) {
	onchange();
}

function ENTI_AFTER_COMMAND(p) {

	onchange();
}

function TESTATA_OnLoad() {

}

function MyExcelDestinatari(param) {

	ExecDocProcess('FITTIZIO,DOCUMENT,,NO_MSG');

}

function MyExcelDestinatari_OK(param) {

	var win;

	param = param + '&IDENTITY=idcom&FILTER=IdCom=' + getObj('IDDOC').value;

	win = ExecFunction('../../dashboard/viewerExcel_x.asp?OPERATION=EXCEL' + '&' + param, '', '');
}


function afterProcess(param) {

	if (param == 'FITTIZIO') {

		var numeroRigheENTI = -1
		try { numeroRigheENTI = GetProperty(getObj('ENTIGrid'), 'numrow'); } catch (e) { };

		var numeroRigheOE = -1
		try { numeroRigheOE = GetProperty(getObj('FORNITORIGrid'), 'numrow'); } catch (e) { };

		if (numeroRigheENTI < 0 && numeroRigheOE < 0) {
			DMessageBox('../', 'Prima di avviare l\'esportazione selezionare i destinatari', 'Attenzione', 1, 400, 300);
			return;
		}
		if (numeroRigheENTI >= 0) {
			MyExcelDestinatari_OK('Caption=Esporta Enti&Table=Document_Com_DPE_Enti_VIEW&ModGriglia=COM_DPE_ENTI');
			return;
		}
		if (numeroRigheOE >= 0) {
			MyExcelDestinatari_OK('Caption=Esporta Fornitori&Table=Document_Com_DPE_Fornitori_VIEW&ModGriglia=COM_DPE_FORNITORI');
			return;
		}


		//MyExcelDestinatari_OK(param_exp_xls);
	}
}

function MyExecDocProcess(param) {
	if (getObjValue('RichiestaRisposta') == 'si') {
		if (getObjValue('Richiesta_del_Prec') == '') {
			getObj('Richiesta_del_Prec').focus();
			DMessageBox('../', 'Selezionare il campo "Invalida Risposte Precedenti"', 'Attenzione', 1, 400, 300);
			return;
		}
	}
	ExecDocProcess(param);
}