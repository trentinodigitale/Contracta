function MyOpenDocumentColumn ( grid , r , c )
{
	
	var TipoDoc = '';
	
	try	{ 	TipoDoc = getObj( 'R' + r + '_TipoDoc').value;	}catch( e ) {};
	
	if ( TipoDoc == '' || TipoDoc == undefined )
	{
		try	{ 	TipoDoc = getObj( 'R' + r + '_TipoDoc')[0].value; }catch( e ) {};
	}	
	
	if ( TipoDoc == 'AVCP_ACTION' )
	{
		getObj( 'R2_FNZ_OPEN').style.cursor="default";
		return true;
	}
	else
		OpenDocumentColumn ( grid , r , c );
	
}
window.onload=controllo_lente;

function controllo_lente()
{
var TipoDoc = '';
var numRow = GetProperty( getObj('GridViewer') , 'numrow');
	for( i=0; i <= numRow ; i++ )
	{
		try	{ 	TipoDoc = getObj( 'R' + i + '_TipoDoc').value;	}catch( e ) {};
	
		if ( TipoDoc == '' || TipoDoc == undefined )
		{
			try	{ 	TipoDoc = getObj( 'R' + i + '_TipoDoc')[0].value; }catch( e ) {};
		}
		if ( TipoDoc == 'AVCP_ACTION' )
		{	
			getObj( 'R' + i + '_FNZ_OPEN').style.cursor="default";
		}
	}

}

