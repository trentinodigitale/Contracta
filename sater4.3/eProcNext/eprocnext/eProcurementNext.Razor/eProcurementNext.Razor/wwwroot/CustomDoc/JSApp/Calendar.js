function ExportListCal()
{
	ExecFunction( 'viewerExcel.asp?OPERATION=EXCEL&"' + GetURL( )  , '' , '' );
}

function ViewerCalendar(  )
{
	parent.ViewerGriglia.location = 'Viewer.ASP?' +  GetURL();
}

function GetURL()
{
	var cod;
	var CurFilter;
	var CurPage;
	var CurSort;
	var CurSortOrder;
	var CurTable;
	var CurQueryString;
	
	//debugger;
	
	CurQueryString = 'Viewer.asp?a=a&Table=DASHBOARD_VIEW_CAL_SEDUTE_LOTTI_LISTA&OWNER=&IDENTITY=Id&TOOLBAR=DASHBOARD_VIEW_CAL_SEDUTE_LOTTI_LISTA&DOCUMENT=SCHEDA_PROGETTO&PATHTOOLBAR=../customdoc/&JSCRIPT=Calendar&AreaAdd=no&Height=0,100*,210&numRowForPag=60&Sort=Data&SortOrder=asc&ACTIVESEL=1';

	//-- altri parametri di configurazione
	//CurQueryString = getObj( 'QueryString' ).value;
	CurQueryString = ReplaceExtended( CurQueryString , '&DATA_CALENDAR=' , '&OLD_DATA_CALENDAR=' );
	CurQueryString = ReplaceExtended( CurQueryString , '&FilterHide=' , '&OldFilterHide=' );
	CurQueryString = ReplaceExtended( CurQueryString , '&ModGriglia=' , '&OldModGriglia=' );
	//CurQueryString = ReplaceExtended( CurQueryString , '&Sort=' , '&OldSort=' );
	CurQueryString = ReplaceExtended( CurQueryString , '&CALENDAR=' , '&Sort=' );
	CurQueryString = ReplaceExtended( CurQueryString , '&Caption=' , '&OldCaption=' );
	//bebbuger;
	
	var GridViewer_CAL_CAPTION = getObj( 'GridViewer_CAL_CAPTION' )[0].innerHTML;
	var DATA_CALENDAR = getObj( 'DATA_CALENDAR' ).value;
	var ModGriglia = getObj( 'ModGriglia' ).value;
	
	
	var URL =  CurQueryString + '&FilterHide= MeseCalendar = \'' + DATA_CALENDAR + '\'&ModGriglia=DASHBOARD_VIEW_CAL_SEDUTE_LOTTIGrigliaLista&Caption=' + GridViewer_CAL_CAPTION + '&CaptionPrint=' + GridViewer_CAL_CAPTION + '&ShowExit=0&CaptionNoML=1' ;
	URL = URL + '&ROWCONDITION=RED,CAL_Giorno=1~RED,CAL_Giorno=7~';
	return URL;
	//parent.ViewerGriglia.location = URL;

}



function ReplaceExtended(strExpression,strFind,strReplace){

  while (strExpression.indexOf(strFind)>=0)
  	strExpression=strExpression.replace(strFind,strReplace);
		
  return strExpression;
}


function OpenDocumentColumnCal( objGrid , Row , c )
{
	var cod;
	var nq;

	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );

	if ( Number( cod ) < 0 )
	{
		cod = Number( cod ) * -1;
	}

	var strDoc;
	
	if ( getObj( 'R' + Row + '_OPEN_DOC_NAME').count == 0 )
	{
		strDoc = getObj( 'R' + Row + '_OPEN_DOC_NAME').value;

	} else {
		strDoc = getObj( 'R' + Row + '_OPEN_DOC_NAME')[0].value;
	}
	
	if( strDoc == 'NODOC' ) return;

	ShowDocument( strDoc , cod );
}


function RefreshContent()
{
	try
	{
		//-- provo ad aggiornare il parent
		parent.opener.RefreshContent();
	
	}catch( e ) 
	{

		try
		{
			//-- provo ad aggiornare il parent
			parent.opener.document.location = parent.opener.document.location;
		}catch( e ) {};
	}

	
	try
	{
		//-- provo ad aggiornare il calendario sintetico
		parent.ViewerCalendar.document.location = parent.ViewerCalendar.document.location;
		
	}catch( e ) {};


	try
	{
		//-- provo ad aggiornare la pagina corrente
		document.location = document.location;
		
	}catch( e ) {};

	
}