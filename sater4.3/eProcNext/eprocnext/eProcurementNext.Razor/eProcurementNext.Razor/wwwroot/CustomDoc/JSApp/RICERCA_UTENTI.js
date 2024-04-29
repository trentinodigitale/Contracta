

function Scegli_Firmatario ( objGrid , Row , c )
{
 

	var cod;
	var strcommand;

	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );

	
	parent.self.opener.getObj('IdPfu_Firmatario').value=cod;
	parent.close();
	parent.self.opener.ExecDocProcess( 'SCEGLI_FIRMATARIO,CONTRATTO_GARA');
	//SaveDoc();

 }

 
function Aggiungi_Firmatario ( objGrid )
{ 
	var idRow;	
	idRow = Grid_GetIdSelectedRow( objGrid );	
	idRow = idRow.replace( /~~~/g, ',');
	
	var strPath = '../';
	
	
	if( idRow == '' )
	{
		DMessageBox( strPath + '../ctl_library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
		//alert( "E' necessario selezionare prima una riga" );
		return;
	}
	
	z = idRow.split( ',' );
	if(  z.length > 1 ) 
		{
		  DMessageBox( strPath + '../ctl_library/' , 'E\' necessario selezionare una sola riga' , 'Attenzione' , 2 , 400 , 300 );
			return;				  
		}
				
	parent.self.opener.getObj('IdPfu_Firmatario').value=idRow;
	parent.close();
	parent.self.opener.ExecDocProcess( 'SCEGLI_FIRMATARIO,CONTRATTO_GARA');
	
}