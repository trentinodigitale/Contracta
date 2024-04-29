
function MyRefresh(){

	/*aggiorno i campi nel document opener
	telefono
	fax
	mail
	domanda
	risposta
	allegato*/

	var numRow;
	var IDDOC;

	IDDOC=getObj('IDDOC').value;

	//determino la riga interessata in base a iddoc
	numRow = eval('self.opener.DETTAGLIGrid_NumRow') ;

	for( i = 0; i <= numRow ; i++ ){
	  if ( self.opener.getObj( 'R' + i + '_DETTAGLIGrid_ID_DOC').value ==  IDDOC )
		break;
	}

		try{self.opener.SetTextValue( 'R' + i + '_ProtocolloGenerale' , getObj('ProtocolloGenerale').value ) ;}catch(e){}		
		try{self.opener.SetDataValue( 'R' + i + '_DataProt' , getObj('DataProt').value  , getObj('DataProt_V').value ) ;}catch(e){}		
		try{self.opener.SetDataValue( 'R' + i + '_DataProt' , getObj('DataProt').value  , getObj('DataProt_L').innerHTML ) ;}catch(e){}		
    		try{self.opener.SetDataValue( 'R' + i + '_DataInvio' , getObj('DataInvio').value, getObj('DataInvio_L').innerHTML ) ;}catch(e){}		
    		try{self.opener.SetDomValue( 'R' + i + '_Stato' , GetProperty( getObj('val_Stato'), 'value') , getObj('val_Stato').innerHTML ) ;}catch(e){}		
    
	return ;
}
function MySaveDoc()
{
	
	SaveDoc();
	//MyRefresh();
	return;
}
function MySendDoc()
{
	
	ExecDocProcess('SEND,COM_GENERICA_FORNITORE');	
	//MyRefresh();
	return;
}

window.onload=MyRefresh;