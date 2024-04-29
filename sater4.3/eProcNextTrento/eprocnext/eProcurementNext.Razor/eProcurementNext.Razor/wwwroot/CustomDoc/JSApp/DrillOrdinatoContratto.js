function DrillOrdinatoContratto (  objGrid , Row , c )
{

	var cod;
	var nq;

	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );

    ExecFunctionCenter( 'Viewer.asp?JSIN=yes&ShowExit=yes&Table=DASHBOARD_VIEW_REP_Odc_Prod_ALL&OWNER=&IDENTITY=RDA_Id&TOOLBAR=REP_Prosp_sintesi_TOOLBAR&DOCUMENT=REPERTORIO&PATHTOOLBAR=../customdoc/&JSCRIPT=REPORT_CONVENZIONI&AreaAdd=no&AreaFiltro=no&Caption=Consumi%20per%20Contratto&Height=95,100*,210&numRowForPag=30&Sort=&SortOrder=&ACTIVESEL=1&Exit=si&FILTERCOLUMNFROMMODEL=yes&TOTAL=&FilteredOnly=no&HIDEBUTTON=yes&FilterHide=id_Convenzione=' + cod + '#DrillContratto#800,600' );


    //http://afsvm002/application/DASHBOARD/ViewerGriglia.asp?JSIN=yes&ShowExit=yes&Table=DASHBOARD_VIEW_REP_Odc_Prod&OWNER=RDA_Owner&IDENTITY=RDA_Id&TOOLBAR=REP_Prosp_sintesi_TOOLBAR&DOCUMENT=REPERTORIO&PATHTOOLBAR=../customdoc/&JSCRIPT=REPORT_CONVENZIONI&AreaAdd=no&Caption=Consumi%20per%20Contratto&Height=95,100*,210&numRowForPag=30&Sort=&SortOrder=&ACTIVESEL=1&Exit=si&FILTERCOLUMNFROMMODEL=yes&TOTAL=&FilteredOnly=no&HIDEBUTTON=yes&FilterHide=Convenzione='19'%20and%20PegPlant='25%20-%20%20Gestione%20e%20funzionamento%20della%20IV%5E%20Direzione%20tecnica%20edilizia%20scolastica'%20and%20Anno='2009'	
}