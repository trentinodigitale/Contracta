//--Versione=1&data=2012-06-11&Attvita=38536&Nominativo=Francesco
function Open_Cronologia (objGrid , Row , c)
{


ExecFunctionCenter( '../DASHBOARD/Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_DOCUMENTAZIONE_AZIENDA_STORICO&IDENTITY=&DOCUMENT=,' + Row + '&PATHTOOLBAR=../CustomDoc/&JSCRIPT=AZI_DOCUMENTAZIONE&AreaAdd=no&Caption=Cronologia Documento&Height=0,100*,210&numRowForPag=20&Sort=DataEmissione&SortOrder=Desc&Exit=si&AreaFiltro=no&FilterHide=IdChainDocStory=' + getObj('R'+Row+'_idChainDocStory').value+'##800,600' );
	
}

