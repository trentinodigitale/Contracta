function RefreshContent()
{
    parent.parent.RefreshDocument('');      
	RefreshDocument('');      
}

//-- invocato dalla toolbar per prendere un articolo ad un'altra tabella attraverso una pagina di selezione
function Detail_AddFrom( param )
{

	//-- i parametri sono separati da # e sono in quest'ordine
	//-- 1° - URL da invocare
	//-- 2° - target dell'output
	//-- 3° - Attributi filtro 
	//-- 4° - dimensioni della finestra
	//-- 5° - parametri aggiuntivi da passare alla nuova finestra per una corretta visualizzazione

	var idRow;
	var vet;
	var altro;
	var i;
	
	//debugger;
	
	vet = param.split( '#' );


	//-- recupera le dimensioni della finestra di output
	var w;
	var h;
	var Left;
	var Top;
    
    if( vet.length < 4  )
    {
		w = screen.availWidth;
		h = screen.availHeight;
		Left=0;
		Top=0;
	}
	else    
	{
		var d;
		d = vet[3].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		
		if( vet.length > 3 )
		{
			altro = vet[4];
		}
	}
	
	//-- prende i campi che compongono il filtro , nel caso manchino blocca l'inserimento
	var strFilter= '';
	var strAttrib;
	var bOR = false;
	try
	{
		d = JSTrim(vet[2]).split( ',' );
		if ( d.length > 0 )
		{
			for( i = 0 ; i < d.length ; i++ )
			{

				strAttrib = d[i];
				bOR = false;
				if( strAttrib.substr(0,3) == 'or-' ) 
				{
					bOR = true;
					strAttrib = strAttrib.substring(3 , strAttrib.length );
				}
					
				if ( ( JSTrim( getObj( strAttrib ).value ) == '' ) && ( bOR == false ) )
				//if (  JSTrim( getObj( strAttrib ).value ) == '' ) 
				{
					//MyAlert( getObj( 'MSG_OBBLIG_FOR_ADD' ).value );
					DMessageBox( '../' , 'E\' necessario selezionare ' + strAttrib  , 'Attenzione' , 2 , 400 , 300 );

					return;
				}
				else
				{
					if( bOR == true ) 
					{
						strFilter = strFilter + ' ( ' + strAttrib + ' = \'\' or '
					
						strFilter = strFilter + ' ' + strAttrib + ' = \'' + getObj( strAttrib ).value +  '\' ) ';
					}
					else
					{
						strFilter = strFilter + ' ' + strAttrib + ' = \'' + getObj( strAttrib ).value +  '\'';
					}
					if(  i < d.length -1 )
					{
						strFilter = strFilter + ' and ' ;
					}
				
				}
			
			}
		}
	} catch( e ){};	
	
  
	
	ExecFunction(  vet[0] + '&FilterHide=' + escape( strFilter )  , vet[1] , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
	


}





function FldExtSelRow  ( objGrid , Row , c )
 {
 
 
 var cod;
 var text;
 var cf;
 
	//-- recupero il codice della riga passata
	cod  = GetIdRow( objGrid , Row , 'self' );
	text = getObjGrid('R' + Row + '_aziRagioneSociale').value
	cf = getObjGrid('R' + Row + '_codicefiscale').value
	
	
	//lo setto sul documento
	parent.self.opener.getObj('RagioneSociale').value=text;	
	parent.self.opener.getObj('codicefiscale').value=cf;
	parent.self.opener.getObj('Azienda').value=cod;
	
	
	//parent.opener.SaveDoc();
	parent.close();
    parent.self.opener.MyCheckCF();
	
 }
 
 function MyCheckCF()
 {
	if ( getObj('Estero').checked == false )
	{
		CheckCF( getObj('codicefiscale') );
	}
 }
