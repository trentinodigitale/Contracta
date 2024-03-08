window.onload = onLoadFunc;

//var FlagAfterProces = 0;

function onLoadFunc()
{

	var StatoFunzionale = getObjValue( 'StatoFunzionale' );
	
	if ( StatoFunzionale == 'InviataRichiesta' )
	{
		ExecDocProcess( 'CONSULTA_GARA_AUTO,SIMOG,,NO_MSG');
		return;
	}


}

function afterProcess( param )
{
	//alert(param);
	//FlagAfterProces = 1;

}

