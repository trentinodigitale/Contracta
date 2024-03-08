function OpenLevel( objGrid , Row , c )
{
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
	
    var loc = getObjValue( 'QueryString' );
    var loc2 = '';
    
    loc=loc.replace(/%20/g," ");
    
    var n=loc.indexOf("&FilterHide=");
    {
        
        var j=loc.indexOf("&" , n + 1);
        var x=loc.indexOf(" and " , n + 1);
        if ( x < 0 ) 
        {
            x=loc.indexOf("&" , n + 1);
        }
        
        loc2 = loc.substring( 0 , n ) + loc.substring( j , 5000 ) + '&FilterHide=' + loc.substring( n + 12 , x ) + ' and ' + cod;
    }
	
    if ( isSingleWin() )
	{
		self.location = 'Viewer.asp?' + loc2;
	}
	else
	{
		self.location = 'ViewerGriglia.asp?' + loc2;
	}
    
    



}


function MyConfirm( strParam )
{
	
	//faccio il controllo che ho selezionato almeno una riga (quello che viene fatto adesso in Dash_ExecProcess)
	var idRow;
	idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	
	if( idRow == '' )
	{
		//alert( "E' necessario selezionare prima una riga" );
		DMessageBox('../', 'E\' necessario selezionare prima una riga', 'Attenzione', 2, 400, 300);
		return;
	}
	
	//if( confirm(CNV( '../','Sei sicuro?')) )
	//	Dash_ExecProcess( 'RIPRISTINA,STRUTTURA_APPARTENENZA&CAPTION=Ripristina Nodo Nel Dominio&TABLE=az_struttura&KEY=ID&FIELD=Descrizione');		
	var ml_text = 'Sei sicuro?';
	var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ml_text ) +'&CAPTION=Informazione&ICO=1';
	
	var strFunctionConfirm = '';
	
	if (strParam == 'ripristino')
		strFunctionConfirm = 'ConfermaRipristino';
	else
		strFunctionConfirm = 'ConfermaElimina';	
	
	//chiamo la modale con la funzione da lanciare su OK
	ExecFunctionModaleConfirm( page, null , 200 , 220 , null , strFunctionConfirm );
	
}


function ConfermaRipristino()
{
	Dash_ExecProcess( 'RIPRISTINA,STRUTTURA_APPARTENENZA&CAPTION=Ripristina Nodo Nel Dominio&TABLE=az_struttura&KEY=ID&FIELD=Descrizione' );	
}


function ConfermaElimina()
{
	Dash_ExecProcess( 'DELETE,STRUTTURA_APPARTENENZA&CAPTION=Cancella Nodo dal Dominio&TABLE=az_struttura&KEY=Id&FIELD=Descrizione' );
}


