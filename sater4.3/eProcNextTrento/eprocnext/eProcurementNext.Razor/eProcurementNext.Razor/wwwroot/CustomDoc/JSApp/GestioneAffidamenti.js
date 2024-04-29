function GestioneAffidamenti(strParam){

	var  strquerystring ;
	var w = 700;
	var h = 500; 
	var Left= (screen.availWidth - w) / 2;
	var Top= (screen.availHeight - h ) / 2; 

	var strUrlViewer;
	var Filtro;
	var nPosSep;
	var strTemp;

	strquerystring=getObj('QueryString').value;

	aInfo=	strquerystring.split('&');
	
	for (i=0; i < aInfo.length ; i++){
		strTemp=aInfo[i];
		nPosSep=strTemp.indexOf('IDAZI');
		if (nPosSep >= 0) {
			Filtro=aInfo[i];
			break;
		}
	}
	

	strUrlViewer = 'Viewer.asp?InitAdd=1&Table=DASHBOARD_VIEW_AZI_AFFIDAMENTI_MANUALI&OWNER=&IDENTITY=Id&TOOLBAR=&DOCUMENT=AZI&PATHTOOLBAR=../customdoc/&JScript=&AreaAdd=yes&Caption=GestioneAffidamenti&Height=,100*,150&numRowForPag=25&Sort=receiveddatamsg&SortOrder=desc&ACTIVESEL=1&Exit=si&FilterHide=' + Filtro ;
	
		
	window.open( strUrlViewer , 'AFFIDAMENTIMANUALI' , 'toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes,height=' + h + ',width=' + w + ',left=' + Left + ',top=' + Top);
	
	
}