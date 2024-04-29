function Controllo_Valori() 
{
	
	//alert('check obblig date');
	
	var DataDa = getObj( 'DataRiferimentoCompleta' ).value;
	var DataAl = getObj( 'DataRiferimentoCompletaAl' ).value;
	
	
	if (DataDa == '' || DataAl == '' )
		{
			
			DMessageBox( '../ctl_library/' , 'Compilare i campi "Data scadenza dal" e "Data scadenza al" correttamente' , 'Attenzione' , 1 , 400 , 300 ); 
			return false;
		
		}
	
	
	
	return true;
	
	
}

function DMessageBox( path , Text , Title , ICO , w , h)
{


	//var path = document.location.pathname.toUpperCase();
	/*
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
	*/


	//var w = 400;
	//var h = 250;
	var Left = (screen.availWidth-w)/2;
	var Top  = (screen.availHeight-h)/2;
	var strPosition = ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h ;
		

	ExecFunction( path + 'MessageBoxWin.asp?ML=yes&MSG=' + Text +'&CAPTION=' + Title + '&ICO=' + ICO , 'MSGBOX' , strPosition );


}

function ExecFunction( Url  , target , param )
{
	var me;
	
	if( target == 'self' ){
		
		self.document.write ('<table width="100%" height="100%">')
		self.document.write ('<tr>')
		self.document.write ('<td width="100%" height="100%" valign="middle" align="center" ><label id="_loading" name="_loading" ><font Arial size=1>Loading... </font></label>')
		self.document.write ('</td>')
		self.document.write ('</tr>')
		self.document.write ('</table>')
		
		self.location = Url;
	}
	else{
		//debugger;
		/*meWin = window.open( '' ,target,'toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes' + param );
		try {
			meWin.document.write ('')
			meWin.document.write ('<table width="100%" height="100%">')
			meWin.document.write ('<tr>')
			meWin.document.write ('<td width="100%" height="100%" valign="middle" align="center" ><label id="_loading" name="_loading" ><font Arial size=1>Loading...</font></label>')
			meWin.document.write ('</td>')
			meWin.document.write ('</tr>')
			meWin.document.write ('</table>')
		}catch(e){
		}
		
		meWin.location=Url;
		return meWin;
		*/
		return window.open( Url ,target,'toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes' + param );
	}
}


function DownloadXlsx( param ){
	
	var Url;
	
	Url = '../ctl_library/xlsx.aspx?STORED_SQL=yes&vexcel=1&TIPODOC=BANDO_GARA&ModGriglia=' ;
	Url = Url + getObj('ModGriglia').value + '&HIDECOL=&VIEW=DASHBOARD_STORED_CONSULTAZIONE_LOG&Sort=DataLog asc&hiddenViewerCurFilter=' ; 
	Url = Url + escape( getObj('CurFilter').value ) ;
	
	ExecDownloadSelf ( Url );
	
}	

