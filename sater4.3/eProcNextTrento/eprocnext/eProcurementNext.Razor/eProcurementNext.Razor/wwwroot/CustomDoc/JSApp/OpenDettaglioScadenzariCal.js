
function OpenDettaglioScadenzariCal( objGrid , Row , c )
{

	//recupero identity
	var idRow = getObjValue( objGrid + '_idRow_' + Row );

	var w;
	var h;
	var Left;
	var Top;
	var altro;

	var strFilter='';
	var strTable ='';
	var strURL='';	
	var Caption = ''
	
	w = screen.availWidth * 0.5;
	h = screen.availHeight  * 0.4;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;	
	
	
	//recupero il valore della colonna idpfu
	//se valorizzato lo aggiungo al filtro
	var idpfucollegato = getObjValue( 'R' + Row + '_IdPfu' );
	var tipodoc = getObjValue( 'R' + Row + '_TipoDoc' );	
	Caption  = 'Sintesi scadenze del giorno '  + idRow.substr(  8 , 2 )  + '-' + idRow.substr( 5 , 2 ) + '-' + idRow.substr( 0,4);
	
	if ( tipodoc == 'CONVENZIONE' )
	{
		strFilter = 'FilterHide=StatoFunzionale <> \'InLavorazione\' and Datafine=%27' + idRow  + '%27' ;
		strTable = 'DASHBOARD_VIEW_CONVENZIONI' ;
		strURL='DASHBOARD/Viewer.asp?ModelloFiltro=&OWNER=Owner&MODGriglia=&AreaFiltro=no&AreaInfo=no&TOOLBAR=DASHBOARD_VIEW_GARE_DETTAGLI_CAL_TOOLBAR&Table=' + strTable + '&JSCRIPT=&IDENTITY=ID&DOCUMENT=CONVENZIONE&PATHTOOLBAR=../customdoc/&AreaAdd=no&CaptionNoML=yes&Caption=' + Caption + '&Height=50,100*,0&numRowForPag=20&Sort=Datafine&SortOrder=asc&Exit=si&' + strFilter ;
		
	}	
	else
	{
		strFilter = 'FilterHide=StatoFunzionale <> \'InLavorazione\' and DataScadenza=%27' + idRow  + '%27' ;
		strTable = 'DASHBOARD_VIEW_CONTRATTI' ;
		strURL='DASHBOARD/Viewer.asp?ModelloFiltro=DASHBOARD_VIEW_CONTRATTO_GARAFiltro&OWNER=Owner&MODGriglia=DASHBOARD_VIEW_CONTRATTO_GARAGriglia&AreaFiltro=no&AreaInfo=no&TOOLBAR=DASHBOARD_VIEW_GARE_DETTAGLI_CAL_TOOLBAR&Table=' + strTable + '&JSCRIPT=&IDENTITY=ID&DOCUMENT=P&PATHTOOLBAR=../customdoc/&AreaAdd=no&CaptionNoML=yes&Caption=' + Caption + '&Height=50,100*,0&numRowForPag=20&Sort=DataScadenza&SortOrder=asc&Exit=si&' + strFilter ;
		
	}
	//ExecFunction(  strURL , 'ElencoImpegni'  , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
	ExecFunctionCenterPath( strURL );

}