$( document ).ready(function() {
    OnLoadPage();
	
	
});


function OnLoadPage() 
{
	
	if ( getObjValue( 'StatoFunzionale' ) != 'Completo'  && getObjValue( 'StatoFunzionale' ) != 'Invio_con_errori' && getObjValue( 'StatoFunzionale' ) != 'Annullato' )
	{
		
		setTimeout(function(){ RefreshDocument(''); }, 10000);
	
	}
}