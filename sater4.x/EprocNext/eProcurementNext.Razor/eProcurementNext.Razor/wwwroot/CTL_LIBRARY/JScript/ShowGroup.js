
function ShowGroup( IdGruppo  , OpenClose )
{
	var objOpen;
	var objClose;
	var PropPosition;
	
	try {
		objOpen  = getObj( 'Group_Open_' + IdGruppo );
		objClose = getObj( 'Group_Close_' + IdGruppo );
		
		
		if( OpenClose == 1 )
		{
			setVisibility(objOpen, 'none')
			setVisibility(objClose, '')
			
		}
		else
		{
			
			try {
				CloseAllGroup();
			}catch(e){
			}
			
			PropPosition=GetProperty(objOpen, 'position');
			if( PropPosition == 'absolute')
			{
				objOpen.style.left = PosLeft( objClose );
			}

			setVisibility(objOpen, '');
			if( PropPosition != 'absolute'){
				setVisibility(objClose, 'none')
				
			}
			
			
		}
	}catch(e){
		alert(e)
	}
	
	
	
}


function OpenCloseGroup( ID , H )
{

	var objOpen  = getObj( 'Group_' + ID );

	//objOpen.style.overflow = 'hidden';
	if( objOpen.style.display == 'none' )
	{
		//objOpen.style.height = 0;
		//SetProperty( objOpen , 'height' , 0 );
		setVisibility( objOpen , '' );
	
		//AnimOpenGroup( ID , 0 , H )
	}
	else
	{
		setVisibility( objOpen , 'none' );
		//AnimCloseGroup( ID , H , 0 )
	
	}
}

function AnimOpenGroup( ID , S_H , E_H )
{
	try
	{

		var objOpen  = getObj( 'Group_' + ID );
/*
		S_H = S_H + 5;
		if( S_H < E_H )
		{
			//SetProperty( objOpen , 'height' ,  S_H );
			objOpen.style.height = S_H;
		    setTimeout('AnimOpenGroup( \'' +  ID  + '\', ' + S_H + ', ' + E_H + ' )' , 100);
		}
		else
*/
		{
			//SetProperty( objOpen , 'height' ,  E_H );
			
			//objOpen.style.height = E_H;
			//objOpen.offsetParent.style.height = E_H;
			objOpen.offsetParent.style.display = '';
			objOpen.style.display = '' 
			
		}	
	}
	catch( e ) {};
}

function AnimCloseGroup( ID , S_H , E_H )
{
	try
	{

		var objOpen  = getObj( 'Group_' + ID );
/*
		S_H = S_H - 5;
		if( S_H > E_H )
		{
			//SetProperty( objOpen , 'height' ,  S_H );
			objOpen.style.height = S_H;
		    setTimeout('AnimCloseGroup( \'' +  ID  + '\', ' + S_H + ', ' + E_H + ' )' , 100);
		}
		else
*/
		{
			//SetProperty( objOpen , 'height' ,  E_H );
			//objOpen.style.height = E_H;
			
			//setVisibility( objOpen , 'none' );
			//objOpen.offsetParent.style.height = 0;//E_H;
			objOpen.offsetParent.style.display  = 'none';
			objOpen.style.display == 'none' 
		}	
	}
	catch( e ) {};
}


