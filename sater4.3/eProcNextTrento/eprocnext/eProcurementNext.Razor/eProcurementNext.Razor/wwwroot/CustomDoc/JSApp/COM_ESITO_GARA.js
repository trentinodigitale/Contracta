function RefreshContent()
{
    RefreshDocument('');

   
    
}


function My_MAIL_SYSTEM( param ){
	

	
	var IdDoc;
	var TypeDoc;
	var lIdMsgPar;
    	var	iType;
	var iSubType;
        var strFilterHide;
  
	IdDoc= getObj( 'IDDOC' ).value;
	TypeDoc=getObj( 'TYPEDOC' ).value;
		
		
	ExecFunctionCenter('../../DASHBOARD/Viewer.asp?OWNER=&ModGriglia=DASHBOARD_VIEW_LISTA_MAILGriglia&ModelloFiltro=DASHBOARD_VIEW_LISTA_MAILFiltro&Table=DASHBOARD_VIEW_COME_ESITO_GARA_LISTA_MAIL&IDENTITY=ID&DOCUMENT=LISTA_MAIL&PATHTOOLBAR=../CustomDoc/&JSCRIPT=LISTA_MAIL&AreaAdd=no&Caption=Lista Mail&Height=180,100*,210&numRowForPag=20&Sort=MailData&SortOrder=desc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&ACTIVESEL=2&FilterHide=IdDoc=' + IdDoc +' and TypeDoc=\''+ TypeDoc +'\'#INFO_MAIL#900,800');
	
}