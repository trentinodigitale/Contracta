function afterProcess()
{
	/* Funzione che viene chiamata dopo l'esecuzione di un processo e permette il refresh in memoria del documento chiamante
		recuperato grazie a LinkedDoc + VersioneLinkedDoc */

	var linkedDoc = getObjValue('LinkedDoc');
	var tipoDocChiamante = getObjValue('VersioneLinkedDoc');

  //ReloadDocFromDB( linkedDoc , tipoDocChiamante ) ;
   //se sto nel bandocentrico oppure versione accessibile ricarico il documento sorgente dal db in un frame nascosto
   if ( isSingleWin() || eval( 'BrowseInPage' ) == 1)
		ReloadDocFromDB( linkedDoc , tipoDocChiamante ) ;	
   else
		opener.RefreshDocument('');   	
  
}

window.onload=onloaddoc;

function onloaddoc()
{
	
	var linkedDoc = getObjValue('LinkedDoc');
	var iddoc = getObj('IDDOC').value; 
	var tipoDocChiamante = getObjValue('VersioneLinkedDoc');
	var Filtro_Nuovo_Utente = getObjValue('Filtro_Nuovo_Utente');
	var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;
	var filter = ''
	
	//alert(getExtraAttrib('val_IdpfuInCharge','value'));
	
	
	//Se il documento è editabile
	if ( DOCUMENT_READONLY == '0' )
	{
		//aggiungo al filtro il precedente utente che se non ha più il profilo non uscirebbe e non potrei cambiare solo user rup 
		filter =  'SQL_WHERE= idpfu in ( select idpfu from ProfiliUtenteAttrib where dztNome=\'Profilo\' and attValue=\'' + Filtro_Nuovo_Utente + '\') or idpfu =' + getExtraAttrib('val_IdpfuInCharge','value') ;
		//alert(filter);
		FilterDom( 'IdpfuInCharge' , 'IdpfuInCharge' ,getExtraAttrib('val_IdpfuInCharge','value') , filter ,'', '');
	}
	
	

}



