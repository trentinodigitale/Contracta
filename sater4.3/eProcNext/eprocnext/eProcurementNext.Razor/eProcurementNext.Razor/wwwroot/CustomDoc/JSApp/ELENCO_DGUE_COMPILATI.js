function Copia_DGUE(grid, r, c) {
	var id_from_copy = getObj('R' + r + '_ELENCO_DGUEGrid_ID_DOC').value;
	var doc_to_upd = getQSParam('doc_to_upd');
	//CHIAMO IL PROCESSO SENZA MOSTRARE IL MESSAGGIO, VISTO CHE DOPO LA COPIA FACCIO RITORNARE L'UTENTE AL DOCUMENTO DGUE
	//PASSANDO NEL BUFFER id del documento DA AGGIORNARE
	//ShowWorkInProgress();

	setTimeout(
		function () {
			Dash_ExecProcessID('COPIA,MODULO_TEMPLATE_REQUEST_COPY&TABLE=CTL_DOC&key=id&field=titolo&SHOW_MSG_INFO=no&BUFFER=' + doc_to_upd, id_from_copy)
		}, 1);

}


function RefreshContent() {

	var Versione = getQSParam('Versione');
	var nocache = new Date().getTime();


	//-- tolgo dalla memoria il modello utilizzato dal DGUE di destinazione
	//-- aggiunto paraemtro Versione per capire quando si tratta del nuovo DGUE	
	SUB_AJAX('../CustomDoc/TEMPLATE_REQUEST_COMMAND.ASP?Versione=' + Versione + '&IDDOC=' + getQSParam('doc_to_upd') + '&COMANDO=REMOVE_MEM_TEMPLATE&Modulo=&Gruppo=&Indice=0&nocache=' + nocache);


	//-- ricarico il documento
	if (Versione != '2')
		ReloadDocFromDB(getQSParam('doc_to_upd'), 'MODULO_TEMPLATE_REQUEST');


	if (isSingleWin() == true) {

		breadCrumbPop();

	}
	else {
		parent.opener.RefreshContent();
	}
}