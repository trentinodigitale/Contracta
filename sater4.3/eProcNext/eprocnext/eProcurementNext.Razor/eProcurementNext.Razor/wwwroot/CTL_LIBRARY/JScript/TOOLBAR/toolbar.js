

function MenuOn( IdToolbar  , idMenu , path )
{
	//debugger;
	var objMenuWin;
	var objMenu;
	objMenu  = getObj( idMenu );

	//-- conserva il percorso appena aperto
	eval( IdToolbar + '_OnMenu = "' +  path + '"' ) ;

	//eval( IdToolbar + '_TraceMenu = ' + IdToolbar + '_TraceMenu + " -- On : ' +  idMenu + ';"' ) ;
	//S1.value = eval( IdToolbar + '_TraceMenu');
	
	objMenuWin = getObj( 'Group_Open_' + idMenu + '_SUB' );
	
	objMenuWin.style.position = 'absolute';
	
	//alert(path);
	if ( path.indexOf( '\\') < 0 )
	{
		objMenuWin.style.left = new String(PosLeft( objMenu ) + 10) + 'px';
		//objMenuWin.style.top = objMenu.offsetTop + objMenu.offsetHeight -5 ;
		
		objMenuWin.style.top = new String(PosTop( objMenu ) + objMenu.offsetHeight -10) + 'px';
	}
	else
	{
		objMenuWin.style.left = PosLeft( objMenu ) + 10;
		//objMenuWin.style.top =  objMenu.offsetTop + 10;//objMenu.offsetHeight -5 ;
		objMenuWin.style.top = PosTop( objMenu ) + objMenu.offsetHeight -10 ;
		
	}
	
	setVisibility(objMenuWin, '');

}

function SubMenuOn( IdToolbar  , idMenu , path )
{
/*
	var objMenuWin;
	var objMenu;
	objMenu  = getObj( idMenu );


	//-- conserva il percorso appena aperto
	eval( IdToolbar + '_OnSubMenu = "' +  path + '"' ) ;
	
	//eval( IdToolbar + '_TraceMenu = ' + IdToolbar + '_TraceMenu + " -- OnSub : ' +  idMenu + '"' ) ;
	//S1.value = eval( IdToolbar + '_TraceMenu');
	
	objMenuWin = getObj( 'Group_Open_' + idMenu + '_SUB' );

	//objMenuWin.style.left = PosLeft( objMenu ) + 10;
	//objMenuWin.style.top = PosTop( objMenu ) + objMenu.offsetHeight;
	setVisibility(objMenuWin, '');
*/
}

function MenuOut( IdToolbar  , idMenu , path )
{
	//debugger;

	var objMenuWin;
	//alert('mouseout');
	//-- conserva il percorso appena chiuso
	//eval( IdToolbar + '_OnMenu = ""' ) ;
	
	//eval( IdToolbar + '_TraceMenu = ' + IdToolbar + '_TraceMenu + " -- Out : ' +  idMenu + '"' ) ;
	//S1.value = eval( IdToolbar + '_TraceMenu');
	
	//-- se anche il sotto menu è vuoto lo chiudo 
	
	//if( eval( IdToolbar + '_OnSubMenu' ) == '' )
	{
		objMenuWin = getObj( 'Group_Open_' + idMenu + '_SUB' );
		setVisibility(objMenuWin, 'none');
		//CloseAllSub( IdToolbar );
	}
	/*
	else
	{
		S1.value = '[' + eval( IdToolbar + '_OnSubMenu') + ']';
	}
	*/
	//CloseAllSub( IdToolbar );
	

}

function SubMenuOut( IdToolbar  , idMenu , path )
{
/*
	var objMenuWin;

	//-- svuoto il percorso
	eval( IdToolbar + '_OnSubMenu = \"\"' ) ;
	

	//eval( IdToolbar + '_TraceMenu = ' + IdToolbar + '_TraceMenu + " -- OutSub : ' +  idMenu + '"' ) ;
	//S1.value = eval( IdToolbar + '_TraceMenu');
	
	//-- se anche il sotto menu è vuoto lo chiudo 
	//if( eval( IdToolbar + '_OnMenu' ) == '' )
	
	{
	//	objMenuWin = getObj( 'Group_Open_' + idMenu + '_SUB' );
	//	setVisibility(objMenuWin, 'none');
	}
	
*/
}

function CloseAllSub( IdToolbar )
{
	var num = eval(IdToolbar + '_subMenuNum' );
	var i;
	var objMenuWin;
	//debugger;
	
	for(  i = 1 ; i <= num ; i++ )
	{
		objMenuWin = getObj( 'Group_Open_' + eval(IdToolbar + '_subMenu[' + i + ']' )  );
		setVisibility(objMenuWin, 'none');
		objMenuWin.OpenSub = 0;
		//alert('OpenSub = 0 da CloseAllSub');
	
	}
	//nessun menu aperto;
	eval( IdToolbar + '_OnMenu = ""' ) ;
}

function CloseOtherSub( IdToolbar, IdElemento )
{
	/* Chiude tutti i submenu tranne quello dell'elemento corrente */

	var num = eval(IdToolbar + '_subMenuNum' );
	var i;
	var objMenuWin;
	var idDiv;

	for(  i = 1 ; i <= num ; i++ )
	{
		idDiv = 'Group_Open_' + eval(IdToolbar + '_subMenu[' + i + ']');
		objMenuWin = getObj( idDiv );

		//Se non sto ciclando sul sottomenu corrente
		if ( checkIfExist(idDiv,IdElemento) == false )
		{
			setVisibility(objMenuWin, 'none');
			objMenuWin.OpenSub = 0;
		}
	}

	//nessun menu aperto;
	eval( IdToolbar + '_OnMenu = ""' ) ;
}

function checkIfExist(containerID, childID) 
{
    var elm = {};
    var elms = document.getElementById(containerID).getElementsByTagName("*");
    for (var i = 0; i < elms.length; i++) 
    {
        if (elms[i].id === childID) 
        {
            return true;
        }
    }
    return false;
}

function OpenCloseSubMenuToolbar( IdToolbar, IdMenu )
{
/*
	var objMenu;
	var objMenuWin;
	var OpenClose;
	
	
	//debugger;
	
	
	objMenu  = getObj( IdMenu );
	objMenuWin = getObj( 'Group_Open_' + IdMenu + '_SUB' );
	
	//alert(objMenuWin.OpenSub);
	
	if( objMenuWin.OpenSub == 1 )
	{
		objMenuWin.OpenSub = 0;
		//alert('Opensub=0 da OpenClose');
		
		setVisibility(objMenuWin, 'none');
		//eval( IdToolbar + '_OnMenu = ""' ) ;
	}
	else
	{
		//alert('Opensub=1 da OpenClose');		
		objMenuWin.style.left = PosLeft( objMenu ) + 10;
		objMenuWin.style.top = PosTop( objMenu ) + objMenu.offsetHeight;
		
		CloseAllSub( IdToolbar );
		setVisibility(objMenuWin, '');
		objMenuWin.OpenSub = 1;

	}
*/
}

function MenuMove( IdToolbar  , idMenu , path )
{
/*	//debugger;
	
	var objMenuWin;
	var objMenu;
	objMenu  = getObj( idMenu );
	//alert(path);
	//alert(eval( IdToolbar + '_OnMenu' ));
	if( eval( IdToolbar + '_OnMenu' ) != path  )
	{
		CloseAllSub( IdToolbar );
	
		//-- conserva il percorso appena aperto
		eval( IdToolbar + '_OnMenu = "' +  path + '"' ) ;

		//eval( IdToolbar + '_TraceMenu = ' + IdToolbar + '_TraceMenu + " -- On : ' +  idMenu + ';"' ) ;
		//S1.value = eval( IdToolbar + '_TraceMenu');
	
		objMenuWin = getObj( 'Group_Open_' + idMenu + '_SUB' );
		objMenuWin.style.left = PosLeft( objMenu ) + 10;
		objMenuWin.style.top = PosTop( objMenu ) + objMenu.offsetHeight;
		setVisibility(objMenuWin, '');
		objMenuWin.OpenSub = 1;
		//alert('Opensub=1 da MenuMove');

	}
*/
}