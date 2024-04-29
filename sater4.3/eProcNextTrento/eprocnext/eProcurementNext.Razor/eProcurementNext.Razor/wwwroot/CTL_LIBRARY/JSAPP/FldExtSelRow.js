
function FldExtSelRow( grid , r , c )
{
	try { 
		
		var name = getObj( 'DOCUMENT' ).value; 


		var txt = getObj( 'R' + r + '_DMV_DescML' ).value; 
		var cod = getObj( 'R' + r + '_DMV_Cod' ).value;
		
		if ( txt == undefined || cod == undefined )
		{
			txt = getObj( 'R' + r + '_DMV_DescML' )[0].value; 
			cod = getObj( 'R' + r + '_DMV_Cod' )[0].value;
		}
		
		//se esiste sul parent il campo name_appoggio recupero dal suo valore il nome del campo da aggiornare 
		var nomeCampo_Appoggio = name.toLowerCase() + '_appoggio';
		
		var btrovato = false ;
		
		if ( ! parent.opener.getObj(name) )
		{
			
			if ( parent.opener.getObj(nomeCampo_Appoggio) ) 
			{
				btrovato = true ;
				name = 	parent.opener.getObj(nomeCampo_Appoggio).value;
			}
		}
		else
		{	
			btrovato = true ;
		}
		
			
		if ( btrovato )	
			parent.opener.FldExtSetValue( name ,   txt , cod );
		else
			alert( 'errore nel recupero e selezione dell\'elemento' );
		
		parent.close();
		
	}catch(e){
		alert( 'errore nel recupero e selezione dell\'elemento' );
	};
}
