
function MySeleziona(param)
{
	
	if ( param == 'SELALLL' )
	{
		for ( i = 0 ; i <= LISTA_LOTTIGrid_NumRow ; i++ )
		{
			getObj( 'RLISTA_LOTTIGrid_' + i + '_SelRow' ).checked = true;
		}  
	}
	if ( param == 'DESEL' )
	{
		for ( i = 0 ; i <= LISTA_LOTTIGrid_NumRow ; i++ )
		{
			getObj( 'RLISTA_LOTTIGrid_' + i + '_SelRow' ).checked = false;
		}  
	}
	
	if ( param == 'INVSEL' )
	{
		for ( i = 0 ; i <= LISTA_LOTTIGrid_NumRow ; i++ )
		{
			if ( getObj( 'RLISTA_LOTTIGrid_' + i + '_SelRow' ).checked )
			{
				getObj( 'RLISTA_LOTTIGrid_' + i + '_SelRow' ).checked = false;
			}
			else
			{
				getObj( 'RLISTA_LOTTIGrid_' + i + '_SelRow' ).checked = true;
			}

		}  
	}
	
	
	
}



//innesca esecuzione del processo di invio sulla lista dei DELTA_TED_AGGIUDICAZIONE selezionati
function My_Dash_ExecProcessDoc( param )
{
	
	
	var w;
	var h;
	var Left;
	var Top;
	
	w = 800;
	h = 600;	
	Left = (screen.availWidth-w)/2;
	Top  = (screen.availHeight-h)/2;	
	ID_Griglia = 'LISTA_LOTTIGrid';
	
	var i;
	var result = '';
	var NumRow = eval( ID_Griglia + '_EndRow;' );
	var nStartRow=eval( ID_Griglia + '_StartRow;' );
	var strDoc = '';
	
	
	var columnName = 'SelRow';
	var objSel;
	
    for( i = nStartRow ; i <= NumRow ; i++ )
    {
		
		objSel = getObj( 'R' + ID_Griglia + '_' + i + '_' + columnName );
		if ( objSel.checked )
		{
			strDoc = getObj( ID_Griglia + '_idRow_' + i ).value; 
				
			if ( result != '' ) 
				result = result +  '~~~';

			result = result + strDoc;
		
		}	
    }
	
	
	//alert(result);
	
	if (result == '')
	{
		alert(  CNV( '../../' ,  'E\' necessario selezionare prima una riga' ));
		return;
	}	
			
	
	parent.ExcelDocument.location =  '../../dashboard/ViewerCommand.asp?IDLISTA=' + result +'&PROCESS_PARAM=' + param ;
	
	
}
