window.onload = OnLoadPage;

function OnLoadPage() 
{
	var numrighe=GetProperty( getObj('GridViewer') , 'numrow');
	
	for( i = 0 ; i <= numrighe ; i++ )
	{
		if ( getObjValue('R'+i+'_Descrizione') == 'Fermo Sistema' )
		{
			document.getElementById('R'+i+'_Descrizione_V').className ="GridCol_LinkCal_fermo_sistema";				
			
		}	
	}
	
}
function OpenDettaglioConcorsiCal( objGrid , Row , c )
{


	//recupero identity
	var idRow = getObjValue( objGrid + '_idRow_' + Row );

	var w;
	var h;
	var Left;
	var Top;
	var altro;

	w = screen.availWidth * 0.5;
	h = screen.availHeight  * 0.4;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;

	//recupero il valore della colonna idpfu
	//se valorizzato lo aggiungo al filtro
	var idpfucollegato = getObjValue( 'R' + Row + '_IdPfu' );

	var strFilter = 'FilterHide=linkeddoc=%27' + idRow  + '%27' ;
	var strTable = 'DASHBOARD_VIEW_CONCORSI_DETTAGLI_CAL' ;
	var strModelloGriglia = 'DASHBOARD_VIEW_CONCORSI_DETTAGLI_CALGriglia';
	try{ var hiddenViewerCurFilter = getObj('hiddenViewerCurFilter').value; } catch(e){};


	if ( idpfucollegato != '' )
	{
		strTable = 'DASHBOARD_VIEW_CONCORSI_ENTE_DETTAGLI_CAL&HIDE_COL=FNZ_OPEN' ;
		strFilter = strFilter + encodeURIComponent(' and idpfu=' + idpfucollegato) ;
	}
	else if ( hiddenViewerCurFilter.indexOf('AZI_Ente') >= 0 )	
	{
		strTable = 'DASHBOARD_VIEW_CONCORSI_ENTE_DETTAGLI_CAL_CONF_SISTEMA';
	}

	try
	{
		if ( getObjValue( 'AZI_Ente') != ''  )
		{
			//strFilter = strFilter + ' and AZI_Ente = ' + getObjValue( 'AZI_Ente')  ;
			strFilter = strFilter + encodeURIComponent( ' and AZI_Ente in ( select items from dbo.split(\'' + getObjValue( 'AZI_Ente') + '\',\'###\') )');
		}
	}catch(e){};

	var Caption = ''
	Caption  = 'Sintesi scadenze del giorno '  + idRow.substr(  8 , 2 )  + '-' + idRow.substr( 5 , 2 ) + '-' + idRow.substr( 0,4);

	//apro la lista  delle motivazioni
	//var strURL='../DASHBOARD/Viewer.asp?MODELLO=DASHBOARD_VIEW_GARE_DETTAGLI_CALInfo&MODGriglia=' + strModelloGriglia + '&AreaFiltro=no&AreaInfo=yes&TOOLBAR=&Table=' + strTable + '&JSCRIPT=&IDENTITY=ID&DOCUMENT=PIPPO&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=Elenco Impegni&Height=50,100*,0&numRowForPag=20&Sort=CAL_ora&SortOrder=asc&Exit=si&' + strFilter ;
	var strURL='DASHBOARD/Viewer.asp?ModelloFiltro=DASHBOARD_VIEW_CONCORSI_DETTAGLI_CALInfo&MODGriglia=' + strModelloGriglia + '&AreaFiltro=no&AreaInfo=no&TOOLBAR=DASHBOARD_VIEW_GARE_DETTAGLI_CAL_TOOLBAR&Table=' + strTable + '&JSCRIPT=&IDENTITY=ID&DOCUMENT=P&PATHTOOLBAR=../customdoc/&AreaAdd=no&CaptionNoML=yes&Caption=' + Caption + '&Height=50,100*,0&numRowForPag=20&Sort=DataRiferimentoCompleta&SortOrder=asc&Exit=si&' + strFilter ;

	//ExecFunction(  strURL , 'ElencoImpegni'  , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
	ExecFunctionCenterPath( strURL );

}