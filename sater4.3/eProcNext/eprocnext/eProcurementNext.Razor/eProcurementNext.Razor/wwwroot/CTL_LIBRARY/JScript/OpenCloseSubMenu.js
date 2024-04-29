
function OpenCloseSubMenu( IdMenu )
{
	var objMenu;
	var objMenuWin;
	var OpenClose;
	
	
	//debugger;
	
	
	objMenu  = getObj( IdMenu );
	objMenuWin = getObj( 'Group_Open_' + IdMenu + '_SUB' );
	
	
	
	if( objMenu.OpenSub == 1 )
	{
		objMenu.OpenSub = 0;
		
		setVisibility(objMenuWin, 'none');
		
	}
	else
	{
		objMenu.OpenSub = 1;
		
		objMenuWin.style.left = PosLeft( objMenu ) + 10;
		objMenuWin.style.top = PosTop( objMenu ) + objMenu.offsetHeight;
		
		setVisibility(objMenuWin, '')

	}

}
