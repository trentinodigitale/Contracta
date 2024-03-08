
function ExecFunction( Url  , target , param )
{
	var me;
	var posML = Url.indexOf('#ML.');

	try
	{
		
		//Se trovo una chiave di multilinguismo da sostituire
		if ( posML >= 0 )
		{
			var tmpPath = '../' ;

			if ( isSingleWin() )
			{
				tmpPath = pathRoot;
			}

			var chiaveML = '';
			var carattereML = '';
			for (var i = posML+4; i < Url.length; i++) 
			{
				carattereML = Url.charAt(i);
				
				if ( carattereML != '#' )
					chiaveML += carattereML;
				else
					break;
			}
			
			var chiaveCnv = CNV( tmpPath,chiaveML);
			
			if ( chiaveCnv.indexOf('???') == -1 )
			{
				Url = Url.replace('#ML.' + chiaveML + '#', chiaveCnv);
			}				
			
			
		}
	}
	catch(e){}
		
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
		
		if (typeof target !== "undefined") 
		{
			target = target.replace('<','').replace('>','');
		}

		if (typeof isFaseII !== 'undefined' && isFaseII) {
			if (target === 'DOMINIO_GEO') {
				closeDrawer();
				//apro il drawer
				openDrawer(`<div class="iframeRightAreaContain">
							<iframe
								class="iframeRightArea"
								src="${Url}">
							</iframe>
						</div>`, "500px", "", "", false, true, true)
				return;
			} else if (target === 'AddProduct') {
				closeDrawer();
				//apro il drawer
				openDrawer(`<div class="iframeRightAreaContain">
							<iframe
								class="iframeRightArea"
								src="${Url}">
							</iframe>
						</div>`, "500px", "", "", false, true, true)
				return;
			} else if (target === "PROCESS") {
				closeDrawer();
				//apro il drawer
				openDrawer(`<div class="iframeRightAreaContain">
							<iframe
								class="iframeRightArea"
								src="${Url}">
							</iframe>
						</div>`, "500px", "", "", false, true, true)
			}
		}

		return window.open( Url ,target,'toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes' + param );
	}
}

function ExecFunction1( Url  , target , param )
{
	if( target == 'self' )
		self.location = Url;
	else
		return window.open( Url ,target,'toolbar=yes,location=no,directories=no,status=yes,menubar=yes,resizable=yes,copyhistory=yes,scrollbars=yes' + param );

}

function ExecFunctionCenter( param )
{
	vet = param.split( '#' );

	var w;
	var h;
	var Left;
	var Top;
	var altro;

	if( vet.length < 3  )
    {
		w = screen.availWidth-200;
		h = screen.availHeight-200;
		Left=0;
		Top=0;
	}
	else    
	{
		var d;
		d = vet[2].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		
		if( vet.length > 3 )
		{
			altro = vet[3];
		}
	}

	var newwin = window.open(  '' ,vet[1],'toolbar=no,location=no,directories=no,status=no,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes,left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
	
	try{ newwin.document.write( '<html><body><table class="Loading" width="100%" height="100%" ><tr><td width="100%" height="100%" align="center" valign="center" >Loading ...</td></tr></table></body></html>'); }catch(e){};
	try{ newwin.focus(); }catch(e){}
	
    if ( vet[0] != '' )	
        newwin.location = vet[0];

	return newwin;
}

function ExecFunctionCenterDoc( param )
{

	param = param.replace( '<ID_DOC>' , getObj( 'IDDOC' ).value );
	vet = param.split( '#' );

	var w;
	var h;
	var Left;
	var Top;
	var altro;

	if( vet.length < 3  )
    	{
		w = screen.availWidth;
		h = screen.availHeight;
		Left=0;
		Top=0;
	}
	else    
	{
		var d;
		d = vet[2].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		
		if( vet.length > 3 )
		{
			altro = vet[3];
		}
	}
	
	
	return window.open(  vet[0] ,vet[1],'toolbar=no,location=no,directories=no,status=no,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes,left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );

}

function MAIL_SYSTEM ( param )
{
	
	var IdDoc;
	var TypeDoc;
	var lIdMsgPar;
    var	iType;
	var iSubType;
    var strFilterHide;
    var TipoDocGen;
    var FilterDoc = '';
    
  
    var v = param.split( '#' )
    TipoDocGen = v[0];
    
    if ( v.length > 1 )
    {
        FilterDoc = v[1] + ',' + getObj( 'TYPEDOC' ).value;
	    TypeDoc = FilterDoc.replace(/,/g, '\',\'');
        
    }
    else
	{
	  try { 
			TypeDoc=getObj( 'TYPEDOC' ).value;
		  }
			catch(e){}
	}
  
	if (TipoDocGen == '1') //--Documento generico
	{
		lIdMsgPar=getObj( 'lIdMsgPar' ).value;
		iType=getObj( 'iType' ).value;
		iSubType=getObj( 'iSubType' ).value;
        strFilterHide = 'IdDoc=' + lIdMsgPar + ' and ( TypeDoc=\'' + iType + ';' + iSubType + '\' or TypeDoc=\'TAB_MESSAGGI\')';
        
		if( isSingleWin() == true )
		{
			OpenViewer('Viewer.asp?lo=base&OWNER=&Table=DASHBOARD_VIEW_LISTA_MAIL&IDENTITY=ID&DOCUMENT=LISTA_MAIL&PATHTOOLBAR=../CustomDoc/&JSCRIPT=LISTA_MAIL&AreaAdd=no&Caption=Lista Mail&Height=180,100*,210&numRowForPag=20&Sort=MailData&SortOrder=desc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&ACTIVESEL=2&FilterHide=' + strFilterHide);
		}
		else
		{
			ExecFunctionCenter('../../DASHBOARD/Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_LISTA_MAIL&IDENTITY=ID&DOCUMENT=LISTA_MAIL&PATHTOOLBAR=../CustomDoc/&JSCRIPT=LISTA_MAIL&AreaAdd=no&Caption=Lista Mail&Height=180,100*,210&numRowForPag=20&Sort=MailData&SortOrder=desc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&ACTIVESEL=2&FilterHide=' + strFilterHide + '#INFO_MAIL#900,800');	}
		}
	 
	else
	if( TipoDocGen == '2' ) //-- mail dei documenti figlie trasamite linkedDoc
	{
		IdDoc= getObj( 'IDDOC' ).value;
		
		
		if( isSingleWin() == true )
		{
			OpenViewer('Viewer.asp?lo=base&OWNER=&MODGriglia=DASHBOARD_VIEW_LISTA_MAILGriglia&MODELLOFiltro=DASHBOARD_VIEW_LISTA_MAILFiltro&table=DASHBOARD_VIEW_LISTA_MAIL_COLLEGATE&IDENTITY=ID&DOCUMENT=LISTA_MAIL&PATHTOOLBAR=../CustomDoc/&JSCRIPT=LISTA_MAIL&AreaAdd=no&Caption=Lista Mail&Height=180,100*,210&numRowForPag=20&Sort=MailData&SortOrder=desc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&ACTIVESEL=2&FilterHide=IdDoc=' + IdDoc +' and FilterDoc in (\''+ TypeDoc +'\' )');
		}
		else
		{
			ExecFunctionCenter('../../DASHBOARD/Viewer.asp?OWNER=&MODGriglia=DASHBOARD_VIEW_LISTA_MAILGriglia&MODELLOFiltro=DASHBOARD_VIEW_LISTA_MAILFiltro&table=DASHBOARD_VIEW_LISTA_MAIL_COLLEGATE&IDENTITY=ID&DOCUMENT=LISTA_MAIL&PATHTOOLBAR=../CustomDoc/&JSCRIPT=LISTA_MAIL&AreaAdd=no&Caption=Lista Mail&Height=180,100*,210&numRowForPag=20&Sort=MailData&SortOrder=desc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&ACTIVESEL=2&FilterHide=IdDoc=' + IdDoc +' and FilterDoc in (\''+ TypeDoc +'\' )#INFO_MAIL#900,800');
		}
	}
	
	else
	if( TipoDocGen == '3' ) //condizione per mostrare mail di rettifica, proroga e revoca bando
	{	
	
		IdDoc= getObj( 'IDDOC' ).value;
		
		if( isSingleWin() == true )
		{
			

			OpenViewer('Viewer.asp?lo=base&OWNER=&MODGriglia=DASHBOARD_VIEW_LISTA_MAILGriglia&MODELLOFiltro=DASHBOARD_VIEW_LISTA_MAILFiltro&table=DASHBOARD_VIEW_BANDO_IST&IDENTITY=ID&DOCUMENT=LISTA_MAIL&PATHTOOLBAR=../CustomDoc/&JSCRIPT=LISTA_MAIL&AreaAdd=no&Caption=Lista Mail&Height=180,100*,210&numRowForPag=20&Sort=MailData&SortOrder=desc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&ACTIVESEL=2&FilterHide=IdDoc=' + IdDoc +' and FilterDoc in (\''+ TypeDoc +'\' )');
		}
		else
		{
			ExecFunctionCenter('../../DASHBOARD/Viewer.asp?OWNER=&MODGriglia=DASHBOARD_VIEW_LISTA_MAILGriglia&MODELLOFiltro=DASHBOARD_VIEW_LISTA_MAILFiltro&table=DASHBOARD_VIEW_BANDO_IST&IDENTITY=ID&DOCUMENT=LISTA_MAIL&PATHTOOLBAR=../CustomDoc/&JSCRIPT=LISTA_MAIL&AreaAdd=no&Caption=Lista Mail&Height=180,100*,210&numRowForPag=20&Sort=MailData&SortOrder=desc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&ACTIVESEL=2&FilterHide=IdDoc=' + IdDoc +' and FilterDoc in (\''+ TypeDoc +'\' )#INFO_MAIL#900,800');
		}
	}
	else
	{	
		IdDoc= getObj( 'IDDOC' ).value;
		
		//--ExecFunctionCenter('../../DASHBOARD/Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_LISTA_MAIL&IDENTITY=ID&DOCUMENT=LISTA_MAIL&PATHTOOLBAR=../CustomDoc/&JSCRIPT=LISTA_MAIL&AreaAdd=no&Caption=Lista Mail&Height=180,100*,210&numRowForPag=20&Sort=MailData&SortOrder=desc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&ACTIVESEL=2&FilterHide=IdDoc=' + IdDoc +' and TypeDoc in (\''+ TypeDoc +'\' )#INFO_MAIL#900,800');
		
		if( isSingleWin() == true )
		{
			OpenViewer('Viewer.asp?lo=base&OWNER=&Table=DASHBOARD_VIEW_LISTA_MAIL&IDENTITY=ID&DOCUMENT=LISTA_MAIL&PATHTOOLBAR=../CustomDoc/&JSCRIPT=LISTA_MAIL&AreaAdd=no&Caption=Lista Mail&Height=180,100*,210&numRowForPag=20&Sort=MailData&SortOrder=desc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&ACTIVESEL=2&FilterHide=IdDoc=' + IdDoc +' and FilterDoc in (\''+ TypeDoc +'\' )');
		}
		else
		{
			ExecFunctionCenter('../../DASHBOARD/Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_LISTA_MAIL&IDENTITY=ID&DOCUMENT=LISTA_MAIL&PATHTOOLBAR=../CustomDoc/&JSCRIPT=LISTA_MAIL&AreaAdd=no&Caption=Lista Mail&Height=180,100*,210&numRowForPag=20&Sort=MailData&SortOrder=desc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&ACTIVESEL=2&FilterHide=IdDoc=' + IdDoc +' and FilterDoc in (\''+ TypeDoc +'\' )#INFO_MAIL#900,800');
		}
		
	}
	
}




function MAIL_SYSTEM_Viewer ( IdDoc, TypeDoc , MailGuid )
{
	if ( MailGuid == '' )
	{
		if( isSingleWin() == true )
		{
			OpenViewer('Viewer.asp?lo=base&OWNER=&Table=DASHBOARD_VIEW_LISTA_MAIL_REJECTED&IDENTITY=ID&ModGriglia=DASHBOARD_VIEW_LISTA_MAIL_REJECTEDGriglia&ModFiltro=DASHBOARD_VIEW_LISTA_MAILFiltro&DOCUMENT=LISTA_MAIL&PATHTOOLBAR=../CustomDoc/&JSCRIPT=LISTA_MAIL&AreaAdd=no&Caption=Lista Mail&Height=180,100*,210&numRowForPag=20&Sort=MailData&SortOrder=desc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL_REJECTED&ACTIVESEL=1&FilterHide=IdDoc=' + IdDoc +' and FilterDoc in (\''+ TypeDoc +'\' )');
		}
		else
		{
			ExecFunctionCenter('../../DASHBOARD/Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_LISTA_MAIL_REJECTED&IDENTITY=ID&ModGriglia=DASHBOARD_VIEW_LISTA_MAIL_REJECTEDGriglia&ModFiltro=DASHBOARD_VIEW_LISTA_MAILFiltro&DOCUMENT=LISTA_MAIL&PATHTOOLBAR=../CustomDoc/&JSCRIPT=LISTA_MAIL&AreaAdd=no&Caption=Lista Mail&Height=180,100*,210&numRowForPag=20&Sort=MailData&SortOrder=desc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL_REJECTED&ACTIVESEL=1&FilterHide=IdDoc=' + IdDoc +' and FilterDoc in (\''+ TypeDoc +'\' )#INFO_MAIL#900,800');
		}
	}
	else
	{
		if( isSingleWin() == true )
		{
			//OpenViewer('Viewer.asp?lo=base&OWNER=&Table=DASHBOARD_VIEW_LISTA_MAIL_REJECTED&IDENTITY=ID&ModGriglia=DASHBOARD_VIEW_LISTA_MAIL_REJECTEDGriglia&ModFiltro=DASHBOARD_VIEW_LISTA_MAILFiltro&DOCUMENT=LISTA_MAIL&PATHTOOLBAR=../CustomDoc/&JSCRIPT=LISTA_MAIL&AreaAdd=no&Caption=Lista Mail&Height=180,100*,210&numRowForPag=20&Sort=MailData&SortOrder=desc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL_REJECTED&ACTIVESEL=1&FilterHide=IdDoc=' + IdDoc +' and FilterDoc in (\''+ TypeDoc +'\' )');
			OpenViewer('Viewer.asp?lo=base&OWNER=&ModGriglia=DASHBOARD_VIEW_MAIL_GUIDGriglia&ModFiltro=DASHBOARD_VIEW_MAIL_GUIDFiltro&Table=DASHBOARD_VIEW_MAIL_GUID_REJECTED&DOCUMENT=LISTA_MAIL&IDENTITY=ID&PATHTOOLBAR=../CustomDoc/&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL_REJECTED&AreaAdd=no&AreaFiltro=&AreaFiltroWin=1&DOCUMENT=&Caption=Conversazione&Height=180,100*,210&numRowForPag=20&ACTIVESEL=1&Sort=MailData&SortOrder=desc&Exit=si&FilterHide=MailGuid=\'' + MailGuid + '\'&FilteredOnly=no');
	   
		}
		else
		{
			//ExecFunctionCenter('../../DASHBOARD/Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_LISTA_MAIL_REJECTED&IDENTITY=ID&ModGriglia=DASHBOARD_VIEW_LISTA_MAIL_REJECTEDGriglia&ModFiltro=DASHBOARD_VIEW_LISTA_MAILFiltro&DOCUMENT=LISTA_MAIL&PATHTOOLBAR=../CustomDoc/&JSCRIPT=LISTA_MAIL&AreaAdd=no&Caption=Lista Mail&Height=180,100*,210&numRowForPag=20&Sort=MailData&SortOrder=desc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL_REJECTED&ACTIVESEL=1&FilterHide=IdDoc=' + IdDoc +' and FilterDoc in (\''+ TypeDoc +'\' )#INFO_MAIL#900,800');
			ExecFunctionCenter('../../DASHBOARD/Viewer.asp?OWNER=&ModGriglia=DASHBOARD_VIEW_MAIL_GUIDGriglia&ModFiltro=DASHBOARD_VIEW_MAIL_GUIDFiltro&Table=DASHBOARD_VIEW_MAIL_GUID_REJECTED&DOCUMENT=LISTA_MAIL&IDENTITY=ID&PATHTOOLBAR=../CustomDoc/&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL_REJECTED&AreaAdd=no&AreaFiltro=&AreaFiltroWin=1&DOCUMENT=&Caption=Conversazione&Height=180,100*,210&numRowForPag=20&ACTIVESEL=1&Sort=MailData&SortOrder=desc&Exit=si&FilterHide=MailGuid=\'' + MailGuid + '\'&FilteredOnly=no#INFO_MAIL#900,800');
		}
	}

}