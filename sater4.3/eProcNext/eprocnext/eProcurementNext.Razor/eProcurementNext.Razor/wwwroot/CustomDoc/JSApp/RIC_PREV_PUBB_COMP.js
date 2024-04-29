
function OpenQuotidiani ()
{

	var w;
	var h;
	var Left;
	var Top;
	var strURL;
    
	w = screen.availWidth;
	h = screen.availHeight;
	Left=0;
	Top=0;

	w = 800;
	h = 600;
	Left = (screen.availWidth-w)/2;
	Top  = (screen.availHeight-h)/2;

	try
	{
		if( bProc == true )
		{
			return;
		}
	}catch( e ) {};
	
	strURL = '../../DASHBOARD/Viewer.asp?Table=CONTATORE_GIORNALI&IDENTITY=DMV_Cod&OWNER=&DOCUMENT=RIC_PREV_PUBB_COMP&PATHTOOLBAR=../customdoc/&jscript=RIC_PREV_PUBB_COMP&AreaAdd=no&Caption=Visualizza occorrenze quotidiani&Height=50,100*,210&numRowForPag=1000&Sort=Diffusione,Num_Preventivi&SortOrder=&Exit=si';
	strURL = strURL + '&TOOLBAR=&AreaFiltro=no&AreaInfo=yes&ACTIVESEL=1';



	ExecFunction(  strURL    , 'OpenQuotidiani' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );

	
}
