var LstAttrib = [
	'UserRUP',
	'AREA_MERCEOLOGICA',
	'Target_Iniziativa',
	'DPCM',
	'CATEGORIE_MERC',
	'DescTipoProceduraIniziativa',
	'Strumento_Di_Acquisto',
	'Trimestre_Di_Indizione',
	'Anno_Previsto_Di_Indizione',
	'Trimestre_Di_Indizione_PrimaAgg',
	'Anno_Previsto_Agg',
	'Trimestre_Previsto_Prima_Attivazione'
];

var NumControlli = LstAttrib.length;

function controlli(param) {
	debugger
	if (getObj('DOCUMENT_READONLY').value != '1') {
		var err = 0;
		var cod = getObj("IDDOC").value;

		var strRet = CNV('../', 'ok');

		SetInitField();

		//-- controllo i dati della richiesta
		var i = 0;
		var err = 0;

		for (i = 0; i < NumControlli; i++) {

			try {
				if (getObjValue('NotEditable').indexOf(LstAttrib[i] + ' ') < 0) {


					if (getObj(LstAttrib[i]).type == 'text' || getObj(LstAttrib[i]).type == 'hidden'
						|| getObj(LstAttrib[i]).type == 'select-one' || getObj(LstAttrib[i]).type == 'textarea'

					) {
						if (trim(getObjValue(LstAttrib[i])) == '') {
							err = 1;
							TxtErr(LstAttrib[i]);
						}
					}

					if (getObj(LstAttrib[i]).type == 'checkbox') {
						if (getObj(LstAttrib[i]).checked == false) {
							err = 1;
							TxtErr(LstAttrib[i]);
						}
					}

				}
			} catch (e) {
				alert(i + ' - ' + LstAttrib[i]);
			}

		}



		if (err > 0) {

			DMessageBox('../', 'Per proseguire e\' necessaria la compilazione di tutti i campi evidenziati', 'Attenzione', 1, 400, 300);
			return -1;
		}

		else {
			ExecDocProcess('APPROVE,PROGRAMMAZIONE_INIZIATIVA')
		}
	}
}

function SetInitField() {

	var i = 0;
	for (i = 0; i < NumControlli; i++) {

		TxtOK(LstAttrib[i]);
	}

}

function trim(str) {
	return str.replace(/^\s+|\s+$/g, "");
}