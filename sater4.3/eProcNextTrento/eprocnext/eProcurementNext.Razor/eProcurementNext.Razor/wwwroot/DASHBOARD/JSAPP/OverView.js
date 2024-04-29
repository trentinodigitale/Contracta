function OverView(  objGrid , Row , c )
{

	//-- recupera dalla griglia 
	try {
	
		var param = getObj( 'R' + Row + '_param' )[0].value;
	
		var v = param.split( '~' );
	
		eval( 'top.TreeFolder.TestaGruppi.GroupRow_' + v[c-2] + '.parentElement.onclick();');
	}catch( e ){};
	

}