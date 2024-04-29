


function LISTA_DOCUMENTI_OnLoad()
{
	    
    if (getObj('IDDOC').value.substring(0,3) == 'new' )
	{
		LISTA_DOCUMENTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=&Table=BANDO_ALBO_LISTA_DOCUMENTI&JSCRIPT=BANDO&IDENTITY=Id&DOCUMENT=BANDO&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=0,100*,0&numRowForPag=15&Sort=data&ActiveSel=2&SortOrder=asc&Exit=no&ShowExit=0&FilterHide=IdDoc = 0 ';
	}
	else
	{
		LISTA_DOCUMENTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=&Table=BANDO_ALBO_LISTA_DOCUMENTI&JSCRIPT=BANDO&IDENTITY=Id&DOCUMENT=BANDO&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=0,100*,0&numRowForPag=15&Sort=data&ActiveSel=2&SortOrder=asc&Exit=no&ShowExit=0&FilterHide=LinkedDoc =' + getObj('IDDOC').value ;;	
	}
}

