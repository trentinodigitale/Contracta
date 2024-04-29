
function ShowGroup( IdGruppo  , OpenClose )
{
	var objOpen;
	var objClose;
	
	objOpen  = getObj( 'Group_Open_' + IdGruppo );
	objClose = getObj( 'Group_Close_' + IdGruppo );
	
	if( OpenClose == 1 )
	{
		setVisibility(objOpen, 'none')
		setVisibility(objClose, '')
	}
	else
	{
		setVisibility(objOpen, '')
		setVisibility(objClose, 'none')
	}

}
