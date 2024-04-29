
window.onload = OnLoadPage; 

function OnLoadPage()
{
	//-- nasconde la colonna con la lente
	ShowCol( 'ANALISI_DETTAGLIO_TESTATA' , 'FNZ_OPEN' , 'none' );
	ShowCol( 'ANALISI_DETTAGLIO' , 'NumeroRiga' , 'none' );

}

function afterProcess( param )
{
	if ( param == 'SALVA' )
    {
		breadCrumbPop( '');
		return false;
	}
}
		