

function DrillDirezioni( strNameGrid,nameField, nIndCell )
{
	var nIdDett;

	//-- recupero la riga selezionata
	var VetPos = GetPositionDimensionOfCell(  strNameGrid, nIndCell );
	

	var Cond =  Grid_vetDimElem[0][VetPos[1]];

	var filter = getObj( 'WHERE_SQL' ).value;
	

	var URL = 'Viewer.asp?JSIN=yes&ShowExit=yes&Table=DASHBOARD_VIEW_REP_Direzioni&OWNER=&IDENTITY=ID_MSG_PDA&TOOLBAR=REP_Prosp_sintesi_TOOLBAR&DOCUMENT=REPERTORIO&PATHTOOLBAR=../customdoc/&JSCRIPT=REPORT_LAVORI&AreaAdd=no&Caption=Prospetto Direzioni&Height=95,100*,210&numRowForPag=30&Sort=&SortOrder=&ACTIVESEL=1&Exit=si&FILTERCOLUMNFROMMODEL=yes&TOTAL=Totale,1&FilteredOnly=no&HIDEBUTTON=yes'
	URL = URL + '&FilterHide=DirezioneProponente=\'' + Cond + '\'' ;
	if ( filter != '' )
	{   
	    filter = ReplaceExtended( filter , '  like  ' , '=' );
	    filter = ReplaceExtended( filter , '\%' , '' );
	    //alert( filter );
	
		URL = URL + ' and ' + escape( filter );
	}

	w = 800;
	h = 600;
	Left = (screen.availWidth-w)/2;
	Top  = (screen.availHeight-h)/2;
	ExecFunction( URL  , '' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  ).focus();
 
}


function DrillDirezioniProvv( strNameGrid,nameField, nIndCell )
{
	var nIdDett;

	//-- recupero la riga selezionata
	var VetPos = GetPositionDimensionOfCell(  strNameGrid, nIndCell );
	

	var Cond =  Grid_vetDimElem[0][VetPos[1]];

	var filter = getObj( 'WHERE_SQL' ).value;
	

	var URL = 'Viewer.asp?JSIN=yes&ShowExit=yes&Table=DASHBOARD_VIEW_REP_DirezioniProvv&OWNER=&IDENTITY=ID_MSG_PDA&TOOLBAR=REP_Prosp_sintesi_TOOLBAR&DOCUMENT=REPERTORIO&PATHTOOLBAR=../customdoc/&JSCRIPT=REPORT_LAVORI&AreaAdd=no&Caption=Prospetto Direzioni Provvisorio&Height=95,100*,210&numRowForPag=30&Sort=&SortOrder=&ACTIVESEL=1&Exit=si&FILTERCOLUMNFROMMODEL=yes&TOTAL=Totale,1&FilteredOnly=no&HIDEBUTTON=yes&ModelloFiltro=DASHBOARD_VIEW_REP_DirezioniFiltro&ModGriglia=DASHBOARD_VIEW_REP_DirezioniProvvGriglia'


	URL = URL + '&FilterHide=DirezioneProponente=\'' + Cond + '\'' ;
	if ( filter != '' )
	{   
	    filter = ReplaceExtended( filter , '  like  ' , '=' );
	    filter = ReplaceExtended( filter , '\%' , '' );
	    //alert( filter );
	
		URL = URL + ' and ' + escape( filter );
	}

	w = 800;
	h = 600;
	Left = (screen.availWidth-w)/2;
	Top  = (screen.availHeight-h)/2;
	ExecFunction( URL  , '' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  ).focus();
 
}

function OpenDocGen( cod  )
{

	var strDoc;



	var w;
	var h;
	var Left;
	var Top;
    
	w = 800; //screen.availWidth * 0.9;
	h = 600; //screen.availHeight  * 0.9;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
  
	
	//ExecFunction(  'document.asp?UpdateParent=' + UpdParent + '&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod  , strDoc + '_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
	ExecFunction(  '../Aflcommon/FolderGeneric/OpenDoc.asp?lIdMsgPar=' + cod+ '&Name=' + strDoc + '&lIdmpPar=1&StrCommandPar=OPENDOC' , 'OPEN_GENERIC_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  ).focus();

}

function OpenPDA( objGrid , Row , c )
{

	var cod;
	var strDoc;

	//-- recupero il codice della riga passata
	try
	{
		cod = getObj( 'R' + Row + '_ID_MSG_PDA')[0].value;
	} catch(e)
	{
		return;
	}
	if ( cod == '' || cod  == '0' )
	{
		DMessageBox( '../CTL_Library/' , 'Il relativo documento non e\' stato creato' , 'Attenzione' , 2 , 400 , 300 );
		return;
	
	}
	
	OpenDocGen( cod );
}

function OpenSchedaPrecontrattuale( objGrid , Row , c )
{

	var cod;
	var strDoc = 'SCHEDA_PRECONTRATTO';

	//-- recupero il codice della riga passata
	try
	{
		cod = getObj( 'R' + Row + '_idDocSchedaPrecontratto')[0].value;
	} catch(e)
	{
		return;
	}

	ShowDocument( strDoc , cod );

}



function OpenRepertorio( objGrid , Row , c )
{

	var cod;
	var strDoc = 'REPERTORIO';

	//-- recupero il codice della riga passata
	try
	{
		cod = getObj( 'R' + Row + '_IdRepertorio')[0].value;
	} catch(e)
	{
		return;
	}

	ShowDocument( strDoc , cod );

}


function ReplaceExtended(strExpression,strFind,strReplace)
{

  while (strExpression.indexOf(strFind)>=0)
  	strExpression=strExpression.replace(strFind,strReplace);
		
  return strExpression;
}



function OpenCONTROLLI_GARA( objGrid , Row , c )
{

	var cod;
	var strDoc = 'CONTROLLI_GARA';

	//-- recupero il codice della riga passata
	try
	{
		cod = getObj( 'R' + Row + '_idDocControlli')[0].value;
	} catch(e)
	{
		return;
	}

	ShowDocument( strDoc , cod );

}



function DrillSeduteDiGara( strNameGrid,nameField, nIndCell )
{
	var nIdDett;

	//-- recupero la riga selezionata
	var VetPos = GetPositionDimensionOfCell(  strNameGrid, nIndCell );
	

	var Cond =  Grid_vetDimElem[0][VetPos[1]];
	
	//alert( Cond ); 

	var filter = getObj( 'WHERE_SQL' ).value;
	

	var URL = 'Viewer.asp?AreaFiltro=no&JSIN=yes&ShowExit=yes&Table=DASHBOARD_VIEW_REP_Prosp_Attivita&ModGriglia=DASHBOARD_VIEW_REP_Prosp_AttivitaDrillGriglia&ModelloFiltro=DASHBOARD_VIEW_REP_Prosp_AttivitaDrillGriglia&OWNER=&IDENTITY=ID_MSG_PDA&TOOLBAR=REP_Prosp_sintesi_TOOLBAR&DOCUMENT=REPERTORIO&PATHTOOLBAR=../customdoc/&JSCRIPT=REPORT_LAVORI&AreaAdd=no&Caption=Dettaglio sedute di gara&Height=95,100*,210&numRowForPag=30&Sort=ProtocolloBando&SortOrder=asc&ACTIVESEL=1&Exit=si&FILTERCOLUMNFROMMODEL=yes&TOTAL=Totale,1&FilteredOnly=no&HIDEBUTTON=yes'
	URL = URL + '&FilterHide=Anno=\'' + Cond + '\' and ID_MSG_PDA <> 0 ';
	if ( filter != '' )
	{   
	    filter = ReplaceExtended( filter , '  like  ' , '=' );
	    filter = ReplaceExtended( filter , '\%' , '' );
	    //alert( filter );
	
		URL = URL + ' and ' + escape( filter );
	}

	w = 800;
	h = 600;
	Left = (screen.availWidth-w)/2;
	Top  = (screen.availHeight-h)/2;
	ExecFunction( URL  , '' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  ).focus();
 
}