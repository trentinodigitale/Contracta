function MessageBox( Text , Title , ICO , w , h)
{


	var path = document.location.pathname.toUpperCase();
	
	var vp = path.split('/');
	
	var i = 0;
	
	alert( vp.length );
	for( i = 0 ; i < vp.length ; i++ )
	{
		if( vp[i] == 'CTL_LIBRARY' )
		{
			path = '/' + vp[ i - 1 ] + '/' + vp[i] + '/';
		
			break;
		}
	
	}
	alert( path );


	//var w = 400;
	//var h = 250;
	var Left = (screen.availWidth-w)/2;
	var Top  = (screen.availHeight-h)/2;
	var strPosition = ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h ;
		

	ExecFunction( path + 'MessageBoxWin.asp?ML=yes&MSG=' + Text +'&CAPTION=' + Title + '&ICO=' + ICO , 'MSGBOX' , strPosition );


}