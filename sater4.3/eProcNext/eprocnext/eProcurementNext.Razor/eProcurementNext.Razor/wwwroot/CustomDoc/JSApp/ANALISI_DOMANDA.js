window.onload = OnLoadPage; 
function OnLoadPage()
{

	ShowRows( 'ORIGINEGrid' );
	//ShowRows( 'MULTI_NUMEROGrid' );
	ShowRows( 'MULTI_DOMINIOGrid' );


}

function ShowRows( Grid )
{
	var r,c;
	
	for( r = 1 ; getObj( Grid + '_r' + r + '_c0'  ) != undefined ; r++ )
	{
		if(  getObjValue( 'R' + Grid + '_' + r + '_Descrizione') != '' )
		{
			for( c = 0 ; getObj( Grid + '_r' + r + '_c' + c  ) != undefined ; c++ )
			{
				 getObj( Grid + '_r' + r + '_c' + c  ).style.borderTop = "thick solid #555"; 
			}
		}
	}
	

}




