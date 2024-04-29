function AddControllo()
{

	if( getObj( 'isAti' ).value  == '1' )
	{
		Detail_AddFrom( '../../DASHBOARD/Viewer.asp?Table=Document_SchedaPrecontratto_DURC_ADDFROM&IDENTITY=indrow&DOCUMENT=DURC.ADDFROM.Document_SchedaPrecontratto_DURC_ADDFROM&PATHTOOLBAR=../CTL_Library/jscript/document/&AreaAdd=no&Caption=Inserisci controllo DURC&Height=0,100*,210&numRowForPag=20&Sort=&SortOrder=&Exit=si&AreaFiltro=no#AddProduct#IDDOC#400,400');	
	}
	else
	{
	


		//-- compone il comando per aggiungere la riga
		strCommand =  'DURC#ADDFROM#' + 'IDROW=' + getObj( 'aziTs' ).value + '&TABLEFROMADD=Document_SchedaPrecontratto_DURC_ADDFROM' ;
	
	
		ExecDocCommand( strCommand );

		try{ 
			var sec = 'DURC';
			ShowLoading( sec ); 
		}catch( e ){};

	
	}
}


function OpenRepertorio()
{
    
    PrintCnv( '../../customdoc/OpenRepertorio.asp?' );

}