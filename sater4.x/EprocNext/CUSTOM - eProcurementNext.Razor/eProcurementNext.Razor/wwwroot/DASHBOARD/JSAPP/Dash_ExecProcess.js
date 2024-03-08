
function Dash_ExecProcess( param , ID_Griglia, singleRow)
{
	var idRow;
	var vet;
	var altro;
	
	//debugger;
  
	
	//-- recupera il codice della riga selezionata
	//idRow = GetIdSelectedRow( 'GridViewer' , 'RadioSel' , 'this' );
	//idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	
	if( ID_Griglia  == undefined )
		ID_Griglia = '';
	
	if( singleRow  == undefined )
		singleRow = '';
	

	if (ID_Griglia == '' )
		idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	else
		idRow = Grid_GetIdSelectedRow( ID_Griglia + 'Grid' );	
	
	if( idRow == '' )
	{
		alert( "E' necessario selezionare prima una riga" );
	}
	else
	{
		
		if ( singleRow == '1' )
		{
			try
			{
				z = idRow.split( '~~~' );
				if(  z.length > 1 ) 
				{
					DMessageBox( '../ctl_library/' , 'E\' necessario selezionare una sola riga' , 'Attenzione' , 2 , 400 , 300 );
					return;				  
				}
			}
			catch(e){}
		
		}
			
		//-- per ogni riga selezionata recupero il tipo documento associato
		if (ID_Griglia == '' )
		{
			parent.Viewer_Command.location =  'ViewerCommand.asp?IDLISTA=' + idRow +'&PROCESS_PARAM=' + param ;
		}
		else
		{
			parent.ExcelDocument.location =  '../../dashboard/ViewerCommand.asp?IDLISTA=' + idRow +'&PROCESS_PARAM=' + param ;
		}

	}

}


function Dash_ExecProcessRow( objGrid , Row , c )
{
	var idRow;
	var vet;
	var altro;
	
	//debugger;

	var objInd;
	var nInd; 
	var obj;
	var numRow;
	var name;
	var ColName;
	
	var param;
	ColName =  'PROC_PARAM';
	
  
	//-- recupero il codice della riga passata
	idRow = GetIdRow( objGrid , Row , 'self' );
	try
	{
		if ( getObj( 'R' + Row + '_' + ColName ).count == 0 )
		{
			param = getObj( 'R' + Row + '_' + ColName ).value;

		} else {
			param = getObj( 'R' + Row + '_' + ColName )[0].value;
		}
	}catch(e) {
		alert( 'Manca il parametro per il processo');
	};
	
	
	var Vet = param.split('~PROC_PARAM~')
	
	parent.Viewer_Command.location =  'ViewerCommand.asp?IDLISTA=' + idRow +'&PROCESS_PARAM=' + Vet[c] ;

}



function Dash_ExecProcessID( param , idRow)
{
	try
	{
		parent.Viewer_Command.location =  'ViewerCommand.asp?IDLISTA=' + idRow +'&PROCESS_PARAM=' + param ;
	}
	catch(e)
	{
		//Se sto eseguendo la funzione da un documento invece che dal viewer
		parent.ExcelDocument.location =  '../../dashboard/ViewerCommand.asp?IDLISTA=' + idRow +'&PROCESS_PARAM=' + param ;
	}
	
}


function Dash_ExecProcessDoc( param , ID_Griglia)
{
	var idRow;
	var vet;
	var altro;
	
	//debugger;
	
	if( ID_Griglia  == undefined )
		ID_Griglia = '';
	
	//-- recupera il codice della riga selezionata
	//idRow = GetIdSelectedRow( 'GridViewer' , 'RadioSel' , 'this' );
	//idRow = Grid_GetIdSelectedRow( ID_Griglia + 'GridViewer' );
	if (ID_Griglia == '' )
		idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	else
		idRow = Grid_GetIdSelectedRow( ID_Griglia + 'Grid' );
	
	if( idRow == '' )
	{
		alert( "E' necessario selezionare prima una riga" );
	}
	else
	{
		var ListDoc
		//-- per ogni riga selezionata recupero il tipo documento associato
		if (ID_Griglia == '' )
		{
			ListDoc = Grid_GetDOCSelectedRow( 'GridViewer' );
			parent.Viewer_Command.location =  'ViewerCommand.asp?IDLISTA=' + idRow +'&PROCESS_PARAM=' + param + '&DOCLISTA=' + ListDoc;
		}
		else
		{
			ListDoc = Grid_GetDOCSelectedRow( ID_Griglia + 'Grid' );
			parent.ExcelDocument.location =  '../../dashboard/ViewerCommand.asp?IDLISTA=' + idRow +'&PROCESS_PARAM=' + param + '&DOCLISTA=' + ListDoc;
		}
		
	}

}


//-- ritorna i Tipi delle righe selezionate in una stringa concatenandoli
//-- separati da ~~~
function Grid_GetDOCSelectedRow( id )
{
	var i;
	var result = '';
	var NumRow = eval( id + '_EndRow;' );
	var nStartRow=eval( id + '_StartRow;' );
	var app = '';
	var strDoc = '';
	
	for ( i = nStartRow ; i <= NumRow ; i++ )
	{
		try {
			if( eval( id + '_SelectedRow[ ' + ( i - nStartRow ) + '];' ) == 1 )
			{

				strDoc = '';
					
				try	{ 	strDoc = getObj( 'R' + i + '_OPEN_DOC_NAME').value;	}catch( e ) {};
					
				if ( strDoc == '' || strDoc == undefined )
				{
 				try	{ 	strDoc = getObj( 'R' + i + '_OPEN_DOC_NAME')[0].value; }catch( e ) {};
				}
        
        if ( strDoc == '' || strDoc == undefined )
          strDoc = 'DOCUMENTO_GENERICO';
        
				if ( strDoc != '' )
				{
					if ( result != '' ) result = result +  '~~~';
					result = result + strDoc;
				}
			}
		}catch(e){
		}
	}
	
	return result;

}

