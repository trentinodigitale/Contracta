function SEZ_NORM_ANTIMAFIA_OnLoad()
{
	try
	{
		var v = getObj( 'ValoreContratto' ).value;
		
		if ( v == '' )
		{
		  
			SetNumericValue( 'ValoreContratto' , parseFloat( getObj( 'ValoreContrattoOfferta' ).value ) );
	
		}
	}catch( e ){};

}
