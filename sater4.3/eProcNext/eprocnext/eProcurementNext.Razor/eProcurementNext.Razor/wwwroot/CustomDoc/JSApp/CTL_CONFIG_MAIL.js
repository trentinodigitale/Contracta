window.onload = OnLoadPage;
function OnLoadPage()
{
	//se non è in lavorazione tolgo il campo pwd
	if( getObjValue( 'StatoFunzionale' ) != 'InLavorazione'  )
	{
		getObj( 'CAMPO_PWD' ).style.display='none';
		
	}
	
	OnChangeLoginMethod();
	
}

function OnChangeLoginMethod ()
{
	
	
	
	var LoginMethod = '';
	
	try { LoginMethod = getObjValue( 'LoginMethod' ); }
	catch { LoginMethod = getObjValue( 'val_LoginMethod' ); }
	
	
	if( LoginMethod == 'XOAUTH2'  )
	{
		//getObj( 'JsonToken' ).style.display='';		
		//getObj( 'ClientId' ).style.display='';
		//getObj( 'ClientSecret' ).style.display='';
		//getObj( 'TokenEndpoint' ).style.display='';		
		
		getObj( 'XOAUTH2' ).style.display='';	
		getObj( 'CTL_CONFIG_MAIL_TOOLBAR_DOCUMENT_MAILUTENTI' ).style.display='none';	
		getObj( 'CTL_CONFIG_MAIL_TOOLBAR_DOCUMENT_MAILREAD' ).style.display='none';	
		
		getObj( 'CTL_CONFIG_MAIL_TOOLBAR_DOCUMENT_Help_XOAUTH2' ).style.display='';	
		
	}
	else
	{
		//getObj( 'JsonToken' ).style.display='none';	
		//getObj( 'ClientId' ).style.display='none';
		//getObj( 'ClientSecret' ).style.display='none';
		//getObj( 'TokenEndpoint' ).style.display='none';	

		getObj( 'XOAUTH2' ).style.display='none';	
		getObj( 'CTL_CONFIG_MAIL_TOOLBAR_DOCUMENT_MAILUTENTI' ).style.display='';	
		getObj( 'CTL_CONFIG_MAIL_TOOLBAR_DOCUMENT_MAILREAD' ).style.display='';	
		
		getObj( 'CTL_CONFIG_MAIL_TOOLBAR_DOCUMENT_Help_XOAUTH2' ).style.display='none';	
		
	
	}
		
		
	
}

function MySend(param)
{
	var err = 0;
	
	var LoginMethod = '';
	
	LoginMethod = getObjValue( 'LoginMethod' );
	
	if ( getObjValue( 'Authenticate' ) == '1' )
	{
		
		if( trim(getObjValue( 'UserName' )) == '' )
		{
			err = 1;
			TxtErr( 'UserName' );
		}
		else
		{
			TxtOK( 'UserName' );
		}
		
		if( trim(getObjValue( 'Password' )) == '' && LoginMethod == 'LOGIN' )
		{
			err = 1;
			TxtErr( 'Password' );
		}
		else
		{
			TxtOK( 'Password' );
		}								
								
		
	}
	
	
	
	if( trim(getObjValue( 'Server' )) == '' )
	{
		err = 1;
		TxtErr( 'Server' );
	}
	else
	{
		TxtOK( 'Server' );
	}	
	
	if( trim(getObjValue( 'ServerRead' )) == '' )
	{
		err = 1;
		TxtErr( 'ServerRead' );
	}
	else
	{
		TxtOK( 'ServerRead' );
	}	
	
	if( trim(getObjValue( 'ServerPort' )) == '' )
	{
		err = 1;
		TxtErr( 'ServerPort' );
	}
	else
	{
		TxtOK( 'ServerPort' );
	}	
	
	if( trim(getObjValue( 'ServerPortRead' )) == '' )
	{
		err = 1;
		TxtErr( 'ServerPortRead' );
	}
	else
	{
		TxtOK( 'ServerPortRead' );
	}	
	
	if( trim(getObjValue( 'UseSSL' )) == '' )
	{
		err = 1;
		TxtErr( 'UseSSL' );
	}
	else
	{
		TxtOK( 'UseSSL' );
	}	
	
	if( trim(getObjValue( 'Authenticate' )) == '' )
	{
		err = 1;
		TxtErr( 'Authenticate' );
	}
	else
	{
		TxtOK( 'Authenticate' );
	}	
	
	if( trim(getObjValue( 'MailFrom' )) == '' )
	{
		err = 1;
		TxtErr( 'MailFrom' );
	}
	else
	{
		TxtOK( 'MailFrom' );
	}
	
	
	if( trim(getObjValue( 'Certified' )) == '' )
	{
		err = 1;
		TxtErr( 'Certified' );
	}
	else
	{
		TxtOK( 'Certified' );
	}	
	
	if (LoginMethod == 'XOAUTH2')
	{
		if( trim(getObjValue( 'JsonToken' )) == '' )
		{
			err = 1;
			TxtErr( 'JsonToken' );
		}
		else
		{
			TxtOK( 'JsonToken' );
		}	
		
		if( trim(getObjValue( 'ClientId' )) == '' )
		{
			err = 1;
			TxtErr( 'ClientId' );
		}
		else
		{
			TxtOK( 'ClientId' );
		}	
		
		if( trim(getObjValue( 'ClientSecret' )) == '' )
		{
			err = 1;
			TxtErr( 'ClientSecret' );
		}
		else
		{
			TxtOK( 'ClientSecret' );
		}	
		
		if( trim(getObjValue( 'TokenEndpoint' )) == '' )
		{
			err = 1;
			TxtErr( 'TokenEndpoint' );
		}
		else
		{
			TxtOK( 'TokenEndpoint' );
		}	
		
	}
	
	if(  err > 0 )
	{
		
		DMessageBox( '../' , 'Per proseguire e\' necessaria la compilazione di tutti i campi evidenziati' , 'Attenzione' , 1 , 400 , 300 );
		return -1;
	}	
	
	
	ExecDocProcess(param);
	
}

function trim(str)
{
    return str.replace(/^\s+|\s+$/g,"");
}

function CallPagina(param)
{
	var w;
	var h;
	
	w = screen.availWidth - 1300;
	h = screen.availHeight - 800;

	//CheckFirmaEBlocco( param );	

	//debugger;
	var CommandQueryString = getObj('CommandQueryString').value;
	var IDDOC = getObj( 'IDDOC' ).value;
	var TYPEDOC = getObj( 'TYPEDOC' ).value;
	var strPrecTarget;
	
	var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;

	//Se siamo nella versione accessibile sostituisco il layout con quello print
	if ( isSingleWin() )
	{
		CommandQueryString = ReplaceExtended( CommandQueryString, '%5F', '_');

		CommandQueryString = CommandQueryString.replace( 'lo=' + layout , 'lo=print');
		CommandQueryString = CommandQueryString.replace( 'LO=' + layout , 'lo=print');
	}

	var newwin = window.open( '' , param ,'toolbar=no,location=no,directories=no,status=yes,resizable=yes,copyhistory=yes,scrollbars=yes,menubar=yes,left=600,top=500,width=' + (w-100) + ',height=' + (h-100) );

	try{ newwin.document.write( '<html><body><table class="Loading" width="100%" height="100%" ><tr><td width="100%" height="100%" align="center" valign="center" >Loading ...</td></tr></table></body></html>'); }catch(e){};
	try{ newwin.focus(); }catch(e){}
	
	//newwin.focus();
	
	var objForm=getObj('FORMDOCUMENT');
	
		
	strPrecTarget=objForm.target;
	//objForm.action='document.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=PRINT&OPERATION=PRINT&' + param ;
	//objForm.action='../../ctl_Library/TestReadMail.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=PRINT&OPERATION=PRINT&' + param ;
	objForm.action='../../ctl_Library/' + param + '.asp?' + CommandQueryString + '&MODE=SHOW&COMMAND=&OPERATION=&DOCUMENT_READONLY=' + DOCUMENT_READONLY;
	
	objForm.target = param;
	
	objForm.submit();
	
	objForm.target=strPrecTarget;
	
}


function TestSendMail()
{
	CallPagina('TestSendMail');
}

function TestReadMail()
{
	CallPagina('TestReadMail');
}


/*
function TestReadMail()
{
    //alert ( getObjValue( 'IDDOC' ) );
	
	var IdDoc = getObjValue( 'IDDOC' );
	
	try
	{
		// RICARICO I DATI DELL'UTENTE COLLEGATO /
		ajax = GetXMLHttpRequest(); 
		var nocache = new Date().getTime();

		if(ajax)
		{
			ajax.open("GET", '../../ctl_library/TestReadMail.asp?nocache=' + nocache + '&IdDoc=' + IdDoc , false);
			ajax.send(null);
			
			if(ajax.readyState == 4) 
			{
				//Se non ci sono stati errori di runtime
				if(ajax.status == 200)
				{
					var res = ajax.responseText;
					
					alert ( res );
					
					
					//if ( res!= '' ) 
					//{
						
						//Se l'esito della chiamata è stato positivo
						//if ( res.substring(0, 2) == '1#' ) 
						//{
							//opener.ReloadMain();
							//RefreshDocument( './' );
						//}
					//}
					
				}
			}
		}
	}
	catch(e)
	{
	}	
	
}

*/