
function showreport() {


	var DataDA = getObj('DataDA').value;
	var DataA = getObj('DataA').value;


	if (DataDA == '' || DataA == '') {

		DMessageBox('../ctl_library/', 'Compilare i campi "Data Inizio Periodo di Riferimento?" e "Data Fine Periodo di Riferimento"', 'Attenzione', 1, 400, 300);
		return false;

	}



	return true;

}

function download_xslx() {

	objForm = getObj('FormViewerFiltro');

	//objForm = FormViewerFiltro;

	var oldAction = objForm.action;
	var oldtarget = objForm.target;

	//objForm.action= '../CTL_Library/xlsx.aspx?TitoloFile=MasterPlan&LEGEND=DASHBOARD_SP_MASTER_PLANfiltro&HIDECOL=identity&IDDOC=-1&TIPODOC=&MODEL=&STORED_SQL=yes&Table=DASHBOARD_SP_MASTER_PLAN' ;
	objForm.action = '../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=MasterPlan&owner=Idpfu&LEGEND=DASHBOARD_SP_MASTER_PLANfiltro&HIDECOL=identity&IDDOC=-1&TIPODOC=&MODEL=&STORED_SQL=yes&Table=DASHBOARD_SP_MASTER_PLAN';

	objForm.target = 'XSLX';

	objForm.submit();

	objForm.action = oldAction;
	objForm.target = oldtarget;


	/*    
		var win;
		win = ExecFunction(  '../CTL_Library/xlsx.aspx?LEGEND=DASHBOARD_SP_MASTER_PLANfiltro&HIDECOL=identity&IDDOC=-1&TIPODOC=&MODEL=&STORED_SQL=yes&Table=DASHBOARD_SP_MASTER_PLAN&DEBUG=yes&FILTER=' + encodeURIComponent( getObjValue ( 'hiddenViewerCurFilter' ))  , 'xslx' ,'' );
		win.focus();
	*/

}
