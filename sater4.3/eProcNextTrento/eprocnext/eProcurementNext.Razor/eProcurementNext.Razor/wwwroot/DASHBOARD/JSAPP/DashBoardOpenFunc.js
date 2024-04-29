
function DashBoardOpenFunc( param )
{

	ExecFunction(  param  , 'DASHBOARDAreaFunz' , '' );

}

function OpenViewer ( param )
{
	ExecFunctionCenter( param );
}

function DashBoardOpenFuncMain( param )
{
	var Cap=''
	var vet = param.split( '&' );
	var dato
	var i=0;
	for( i = 0 ; i < vet.length	; i++ )
	{
		dat = vet[i].split( '=' );
		//alert( dat[1] );
		if( dat[0].toString().toUpperCase() == 'CAPTION' )
		{
			getObjParent('FUNZ_TITLE').innerHTML = CNV( '../' , dat[1].toString() );
		}
	}		
	
	param = param.replace( '&Caption=' , '&OldCaption=' );
	
	ExecFunction(  param  , 'DASHBOARDAreaFunz' , '' );

}

