function DrillODC( strNameGrid,nameField, nIndCell )
{
	var nIdDett;

	//-- recupero la riga selezionata
	var VetPos = GetPositionDimensionOfCell(  strNameGrid, nIndCell );


	var Cond =  Grid_vetDimElem[1][VetPos[2]];

	var filter = getObj( 'WHERE_SQL' ).value;

	
	var URL = 'Viewer.asp?JSIN=yes&ShowExit=yes&Table=DASHBOARD_VIEW_REP_Odc&OWNER=RDA_Owner&IDENTITY=RDA_Id&TOOLBAR=REP_Prosp_sintesi_TOOLBAR&DOCUMENT=REPERTORIO&PATHTOOLBAR=../customdoc/&JSCRIPT=REPORT_CONVENZIONI&AreaAdd=no&Caption=Consumi per Direzioni&Height=95,100*,210&numRowForPag=30&Sort=&SortOrder=&ACTIVESEL=1&Exit=si&FILTERCOLUMNFROMMODEL=yes&TOTAL=&FilteredOnly=no&HIDEBUTTON=yes'
	URL = URL + '&FilterHide=PegPlant=\'' + escape( Cond ) + '\'' ;

	Cond =  Grid_vetDimElem[0][VetPos[1]];


        URL = URL + ' and Anno=\'' +  Cond + '\'' ;
/*

	if ( filter != '' )
	{   
	    filter = ReplaceExtended( filter , '  like  ' , '=' );
	    filter = ReplaceExtended( filter , '\%' , '' );
	    //alert( filter );

		URL = URL + ' and ' + escape( filter );
	}
*/
	w = 1000;
	h = 600;
	Left = (screen.availWidth-w)/2;
	Top  = (screen.availHeight-h)/2;	
	ExecFunction( URL  , '' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  ).focus();
 
}



function OpenContratto( objGrid , Row , c )
{

	var Convenzione;
	var Anno;
	var PegPlant;


        try
	{
		Anno = getObj( 'R' + Row + '_Anno')[0].value;
		Convenzione = getObj( 'R' + Row + '_Convenzione')[0].value;
		PegPlant = getObj( 'R' + Row + '_PegPlant')[0].value;

	} catch(e)
	{
		return;
	}


	var URL = 'Viewer.asp?JSIN=yes&ShowExit=yes&Table=DASHBOARD_VIEW_REP_Odc_Prod&OWNER=RDA_Owner&IDENTITY=RDA_Id&TOOLBAR=REP_Prosp_sintesi_TOOLBAR&DOCUMENT=REPERTORIO&PATHTOOLBAR=../customdoc/&JSCRIPT=REPORT_CONVENZIONI&AreaAdd=no&Caption=Consumi per Contratto&Height=95,100*,210&numRowForPag=30&Sort=&SortOrder=&ACTIVESEL=1&Exit=si&FILTERCOLUMNFROMMODEL=yes&TOTAL=&FilteredOnly=no&HIDEBUTTON=yes'

	URL = URL + '&FilterHide=Convenzione=\'' + Convenzione + '\'' + ' and PegPlant=\'' + escape( PegPlant ) + '\'' + ' and Anno=\'' + Anno + '\'';


	w = 1000;
	h = 600;
	Left = (screen.availWidth-w)/2;
	Top  = (screen.availHeight-h)/2;
	ExecFunction( URL  , '' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  ).focus();

}


function DrillConv( strNameGrid,nameField, nIndCell )
{
	var nIdDett;

	//-- recupero la riga selezionata
	var VetPos = GetPositionDimensionOfCell(  strNameGrid, nIndCell );


	var Cond =  Grid_vetDimElem[1][VetPos[2]];

	var filter = getObj( 'WHERE_SQL' ).value;


	var URL = 'Viewer.asp?JSIN=yes&ShowExit=yes&Table=DASHBOARD_VIEW_REP_Convenzioni&OWNER=RDA_Owner&IDENTITY=RDA_Id&TOOLBAR=REP_Prosp_sintesi_TOOLBAR&DOCUMENT=REPERTORIO&PATHTOOLBAR=../customdoc/&JSCRIPT=REPORT_CONVENZIONI&AreaAdd=no&Caption=Consumi per Classi Merceologiche&Height=95,100*,210&numRowForPag=30&Sort=&SortOrder=&ACTIVESEL=1&Exit=si&FILTERCOLUMNFROMMODEL=yes&TOTAL=&FilteredOnly=no&HIDEBUTTON=yes'
	URL = URL + '&FilterHide=Merceologia2=\'' + escape( Cond ) + '\'' ;

	Cond =  Grid_vetDimElem[0][VetPos[1]];


        URL = URL + ' and Anno=\'' +  Cond + '\'' ;


	if ( filter != '' )
	{   
	    filter = ReplaceExtended( filter , '  like  ' , '=' );
	    filter = ReplaceExtended( filter , '\%' , '' );
	    //alert( filter );

		URL = URL + ' and ' + escape( filter );
	}

	w = 1000;
	h = 600;
	Left = (screen.availWidth-w)/2;
	Top  = (screen.availHeight-h)/2;	
	ExecFunction( URL  , '' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  ).focus();
 
}



function OpenContratto2( objGrid , Row , c )
{

	var Convenzione;
	var Anno;
	var Merceologia2;


        try
	{
		Anno = getObj( 'R' + Row + '_Anno')[0].value;
		Convenzione = getObj( 'R' + Row + '_Convenzione')[0].value;
		Merceologia2 = getObj( 'R' + Row + '_Merceologia2')[0].value;

	} catch(e)
	{
		return;
	}


	var URL = 'Viewer.asp?JSIN=yes&ShowExit=yes&Table=DASHBOARD_VIEW_REP_Convenzioni_Prod&OWNER=RDA_Owner&IDENTITY=RDA_Id&TOOLBAR=REP_Prosp_sintesi_TOOLBAR&DOCUMENT=REPERTORIO&PATHTOOLBAR=../customdoc/&JSCRIPT=REPORT_CONVENZIONI&AreaAdd=no&Caption=Consumi per Contratto&Height=95,100*,210&numRowForPag=30&Sort=&SortOrder=&ACTIVESEL=1&Exit=si&FILTERCOLUMNFROMMODEL=yes&TOTAL=&FilteredOnly=no&HIDEBUTTON=yes'

	URL = URL + '&FilterHide=Convenzione=\'' + Convenzione + '\'' + ' and Merceologia2=\'' + escape( Merceologia2 ) + '\'' + ' and Anno=\'' + Anno + '\'';


	w = 1000;
	h = 600;
	Left = (screen.availWidth-w)/2;
	Top  = (screen.availHeight-h)/2;
	ExecFunction( URL  , '' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  ).focus();

}





function ReplaceExtended(strExpression,strFind,strReplace){

  while (strExpression.indexOf(strFind)>=0)
  	strExpression=strExpression.replace(strFind,strReplace);
		
  return strExpression;
}