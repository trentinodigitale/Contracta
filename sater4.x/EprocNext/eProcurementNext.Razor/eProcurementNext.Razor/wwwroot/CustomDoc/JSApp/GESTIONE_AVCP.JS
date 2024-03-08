function Pulisci_Azzera(param)
{

	var idRow = 0;
	try { idRow = getObj( 'GridViewer_idRow_0' ).value;}catch(e){}
	
		if ( idRow == 0 )
		{
			DMessageBox( '../ctl_library/' , 'Non sono presenti gare per i campi selezionati' , 'Attenzione' , 1 , 400 , 300 ); 
			return false;		
		}
		else
		{
			if ( isSingleWin() == false)
			{
				parent.Viewer_Command.location =  'ViewerCommand.asp?IDLISTA=' + idRow +'&PROCESS_PARAM=' + param ;
			}
			else
			{
				//alert(idRow);
				getObj('Viewer_Command').src =  'ViewerCommand.asp?IDLISTA=' + idRow +'&PROCESS_PARAM=' + param ;
			}
		}


}



function Cestino (grid , r , c)
{
	var idRow;
	var param;
	
	//-- recupero il codice della riga passata
	idRow = GetIdRow( grid , r , 'self' );
	
	var Statofunzionale = '';
	
	try	{ 	Statofunzionale = getObj( 'R' + r + '_StatoFunzionale').value;	}catch( e ) {};
	
	if ( Statofunzionale == '' || Statofunzionale == undefined )
	{
		try	{ 	Statofunzionale = getObj( 'R' + r + '_StatoFunzionale')[0].value; }catch( e ) {};
	}
	

	if ( Statofunzionale == 'Pubblicato' )
	{
		param = 'DELETE,DOCUMENT_AVCP_VIEWER&CAPTION=Cancellazione Documento&TABLE=CTL_DOC&KEY=Id&FIELD=Protocollo'	 
	}
	
	if ( Statofunzionale == 'Annullato' )
	{
		param = 'RIPRISTINA,DOCUMENT_AVCP_VIEWER&CAPTION=Cancellazione Documento&TABLE=CTL_DOC&KEY=Id&FIELD=Protocollo'
	}
	
	if ( isSingleWin() == false)
	{
		parent.Viewer_Command.location =  'ViewerCommand.asp?IDLISTA=' + idRow +'&PROCESS_PARAM=' + param;
	}
	else
	{
		getObj('Viewer_Command').src =  'ViewerCommand.asp?IDLISTA=' + idRow +'&PROCESS_PARAM=' + param;
	}
	
	

}




function Controllo_Valori() 
{
	
	var Ente = getObj( 'AZI_Ente' ).value;
	var Anno = getObj( 'Anno' ).value;
	today = new Date();
	
	if (Ente ==  '' || Anno == '')
	{
		DMessageBox( '../ctl_library/' , 'Compilare Ente ed Anno' , 'Attenzione' , 1 , 400 , 300 ); 
		return false;		
	}
	/*if ( parseInt(Anno) > parseInt(today.getFullYear())-1 )
	{
		DMessageBox( '../ctl_library/' , 'L\'anno inserito non e valido' , 'Attenzione' , 1 , 400 , 300 ); 
		return false;		
	}*/
	
	
	
	return true;
	
	
}

function DMessageBox( path , Text , Title , ICO , w , h)
{


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
		
		return window.open( Url ,target,'toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes' + param );
	}
}
function RefreshContent()
{
	if ( isSingleWin() == false)
	{
		parent.ViewerFiltro.getObj('FormViewerFiltro').submit();
	}
	else
	{
		getObj('FormViewerFiltro').submit();
	}
	
}

function GetXMLHttpRequest() {
	var
		XHR = null,
		browserUtente = navigator.userAgent.toUpperCase();

	if(typeof(XMLHttpRequest) === "function" || typeof(XMLHttpRequest) === "object")
		XHR = new XMLHttpRequest();
		else if(window.ActiveXObject && browserUtente.indexOf("MSIE 4") < 0) {
			if(browserUtente.indexOf("MSIE 5") < 0)
				XHR = new ActiveXObject("Msxml2.XMLHTTP");
			else
				XHR = new ActiveXObject("Microsoft.XMLHTTP");
		}
		return XHR;
};
ajax = GetXMLHttpRequest();   

window.onload=LFN_CONDITION_VIEWER;

function LFN_CONDITION_VIEWER()
{
	var Ente;
	var Anno;

	//var Anno = parent.getObj('ViewerFiltro').contentDocument.getElementById('Anno').value;
	
	if ( isSingleWin() == false)
	{
		Ente = parent.ViewerFiltro.getObj('AZI_Ente').value;
		Anno = parent.ViewerFiltro.getObj('Anno').value;
	}
	else
	{
		Ente = getObjValue('AZI_Ente');
		Anno = getObjValue('Anno');
	}
	
	var param='LFN_CONDITION=YES&ENTE=' + encodeURI(Ente) + '&ANNO=' + encodeURI(Anno);
	
	if(ajax)
	{
		ajax.open("GET",   '../AVCP/AVCP_AGGIORNA_DA_PORTALE.asp?' +  param  , false);
		ajax.send(null);
		if(ajax.readyState == 4) 
		{
			if(ajax.status == 200)
			{
				
				//alert(ajax.responseText);
				if( ajax.responseText == 'Pubblicazione_XML_Disabled' )
				{
				try	{
						setClassName( getObj('DASHBOARD_VIEW_GESTIONE_AVCP_TOOLBAR_PUB_XML') , 'Toolbar_buttonDisabled');
						getObj('DASHBOARD_VIEW_GESTIONE_AVCP_TOOLBAR_PUB_XML').onclick='';
					} catch( e ) {};
				}	
			
				if( ajax.responseText == 'Warning' || ajax.responseText == 'Download_XML_Da_Pubblicare_Disabled' )
				{
					try	{
							setClassName( getObj('DASHBOARD_VIEW_GESTIONE_AVCP_TOOLBAR_PUB_XML') , 'Toolbar_buttonDisabled');
							getObj('DASHBOARD_VIEW_GESTIONE_AVCP_TOOLBAR_PUB_XML').onclick='';
							setClassName( getObj('DASHBOARD_VIEW_GESTIONE_AVCP_TOOLBAR_DOWN_XML') , 'Toolbar_buttonDisabled');
							getObj('DASHBOARD_VIEW_GESTIONE_AVCP_TOOLBAR_DOWN_XML').onclick='';
						} catch( e ) {};
				}
			}
		}
	 }


}

function Update ()
{
	//WiewLoading();
	
	var Ente;
	var Anno;

	if ( isSingleWin() == false)
	{
		Ente = parent.ViewerFiltro.getObj('AZI_Ente').value;
		Anno = parent.ViewerFiltro.getObj('Anno').value;
	}
	else
	{
		Ente = getObjValue('AZI_Ente');
		Anno = getObjValue('Anno');
	}
	
	Anno = ReplaceExtended(Anno,'%','') ;	
	
	var param='ENTE=' + encodeURI(Ente) + '&ANNO=' + encodeURI(Anno);
	
	//ExecFunctionCenter('../AVCP/import_from_db.asp?' + param + '#Import#480,360');
	//ExecFunctionCenter('../AVCP/AVCP_LOAD.asp?' + param + '#ImportAVCP#800,600');

	
	
	//if ( isSingleWin() )
	//{
	//	var url;
		
		//url = encodeURIComponent( 'AVCP/AVCP_LOAD.asp?' + param + '&lo=base' );
	//	url = encodeURIComponent( 'AVCP/AVCP_LOAD.asp?' + param f );
	//	NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	//}
	//else
	
	//{
	//	ExecFunctionCenter('../AVCP/AVCP_LOAD.asp?' + param + '#ImportAVCP#400,300');
	//}  
	
	var nocache = new Date().getTime();
	if(ajax)
	{
		ajax.open("GET",   '../AVCP/AVCP_LOAD.asp?' +  param  + '&nocache=' + nocache , false);
		ajax.send(null);
		if(ajax.readyState == 4) 
		{
			if(ajax.status == 200)
			{
				//RefreshContent();				
				//return true;	
				var v = ajax.responseText.split( '@@@' );
				DMessageBox( '../ctl_library/' , v[0] , v[1] ,v[2]  , 400 , 300 ); 
			}
		}
		else
			DMessageBox( '../ctl_library/' , 'Errore durante l\'aggiornamento dei dati.' , 'Attenzione' , 1 , 400 , 300 ); 
			RefreshContent();
			return false;		
	}
	
	
	/*
	if(ajax)
	{
		ajax.open("GET",   '../AVCP/AVCP_AGGIORNA_DA_PORTALE.asp?' +  param  , false);
		ajax.send(null);
		if(ajax.readyState == 4) 
		{
			if(ajax.status == 200)
			{
				RefreshContent();				
				return true;	
			}
		}
		else
			DMessageBox( '../ctl_library/' , 'Errore durante l\'aggiornamento dei dati.' , 'Attenzione' , 1 , 400 , 300 ); 
			RefreshContent();
			return false;		
	}
	*/
	 

}





function AVCP_CSV( param )
{

	if ( isSingleWin() == false)
	{
		objForm = parent.ViewerFiltro.FormViewerFiltro;
	}
	else
	{
		objForm = getObj('FormViewerFiltro');
	}

	
	var oldAction = objForm.action;
	var oldtarget = objForm.target;
	
	objForm.action='../AVCP/AVCP_CSV.asp?TitoloFile=' +  param;
	objForm.target='_blank';
	
	objForm.submit();
	
	objForm.action=oldAction; 
	objForm.target=oldtarget;

}


