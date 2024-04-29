
function AddAttiFromViewer()
{
	//-- recupera il tipo
	var v = getObj('DOCUMENT').value.split(',',10);
	
    
	
	//-- recupera i peg/prog selezionati
	var sel = '';
	
	var i;
	var result = '';
	var NumRow = eval( 'GridViewer_EndRow;' );
	var app = '';
	var valRow = 0;

	var strDoc;
	strDoc = getObj('DOCUMENT').value;
	v = strDoc.split('.');
		
	
	for ( i = 0 ; i <= NumRow ; i++ )
	{
		try {
			if( eval( 'GridViewer_SelectedRow[ ' + ( i  ) + '];' ) == 1 )
			{
				
				app = GetIdRow( 'GridViewer' , i , '' );
				if ( app != '' )
				{
					if ( result != '' ) result = result +  '~~~';
					
					result = result + app;
					
					
				}
			}
		}catch(e){
		}
	}

	if (result==''){
		alert('selezionare almeno un atto di gara');
		return false;
	}

	//alert(result);

	
	//-- compone il comando per aggiungere la riga
	
	
	//alert( strCommand );
	
	//-- invoca sulla pagina chiamante l'aggiunta della riga
	
	//parent.opener.ExecDocCommand( strCommand );	
	strCommand = v[0] + '#' + v[1] + '#' + 'IDROW=' + result + '&TABLEFROMADD=' + v[2];					
	parent.opener.ExecDocCommand( strCommand );	

	
	parent.close();

}