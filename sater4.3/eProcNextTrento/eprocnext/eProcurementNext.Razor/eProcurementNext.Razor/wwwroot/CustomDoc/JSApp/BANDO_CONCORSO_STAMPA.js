window.onload = OnLoadPage; 

function OnLoadPage()
{
	
	try
	{	
		if( getObjValue( 'val_ PunteggioTEC_100' ) <= '0' )
		{
			$( "#cap_PunteggioTEC_TipoRip" ).parents("table:first").hide();
		}		
    } catch(e){};   

	
	
}
