function OpenQuestionari( objGrid , Row , c )
{
	var cod; 
	var nq;
	var idRow;
	var idMsg;
	var idAzi;

	//-- recupero il codice della riga passata
	//cod = GetIdRow( objGrid , Row , 'self' );
	//idRow = GetIdRow( objGrid , Row , 'self' );
	

	//Compongo il nome del campo di griglia rispetto alla riga sulla quale è stato fatto click
	//idRow = getObjValue('R' + Row + '_idRow');
	idMsg = getObjValue('R' + Row + '_idMsg');
	idAzi = getObjValue('R' + Row + '_IdAzi');
	
	//alert('idmsg : ' + idMsg);
	//alert('idrow : ' + idRow);
	//alert('idAzi : ' + idAzi);
	
	var w;
	var h;
	var Left;
	var Top;
    
	w = 1200; 
	h = 500; 
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h) / 2;;
  
	var strLink;
	//strDoc = 'FATTURA_INFO'; //getObj('DOCUMENT').value;

	//strLink = '../DASHBOARD/ViewerGriglia.asp?STORED_SQL=no&Table=DASHBOARD_VIEW_QUESTIONARIO_FORNITORE_VALUTATO&ModGriglia=&ModelloFiltro=&OWNER=IdPfu&IDENTITY=IdMsg&TOOLBAR=DASHBOARD_VIEW_QUESTIONARIO_FORNITORE_VALUTATO_TOOLBAR&DOCUMENT=QUESTIONARIO_FORNITORE&PATHTOOLBAR=../customdoc/&JSCRIPT=&AreaAdd=no&Caption=&Height=180,100*,210&numRowForPag=25&Sort=idmsg&SortOrder=desc&FilteredOnly=no&FILTERCOLUMNFROMMODEL=yes&ACTIVESEL=2&AreaFiltroWin=close&ONSUBMIT=&ROWCONDITION=&iSubType=2&iType=1061&s_mpcSelection=0&IDMP=1&Descrizione=Questionari%20Fornitore%20valutati&strISubTypeFiltro=&strFlag=&strGruppo=Qualificazione%20Fornitori&FilterHide=idazi=35152834 and idbando=283'
	strLink =  'DASHBOARD/Viewer.asp?lo=base&STORED_SQL=no&Table=DASHBOARD_VIEW_QUESTIONARIO_FORNITORE_VALUTATO&ModGriglia=&ModelloFiltro=&OWNER=&IDENTITY=IdMsg&TOOLBAR=DASHBOARD_VIEW_QF_VALUTATO_TOOLBAR&DOCUMENT=QUESTIONARIO_FORNITORE&PATHTOOLBAR=../customdoc/&JSCRIPT=&AreaAdd=no&Caption=&Height=180,100*,210&numRowForPag=25&Sort=idmsg&SortOrder=desc&FilteredOnly=no&FILTERCOLUMNFROMMODEL=yes&ACTIVESEL=2&AreaFiltroWin=close&ONSUBMIT=&ROWCONDITION=&iSubType=2&iType=1061&s_mpcSelection=0&IDMP=1&Descrizione=Questionari%20Fornitore%20valutati&strISubTypeFiltro=&strFlag=&strGruppo=Qualificazione%20Fornitori&TITLE_GRID=Questionari Valutati&FilterHide=' + encodeURIComponent('idAzi = ' + idAzi + ' and idbando=' + idMsg);
	strLink = encodeURIComponent(strLink);
	//ExecFunction(  strLink , '' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  ).focus();
	//ExecFunctionSelf(  strLink , '' , ''  );
	ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + strLink + '&KEY=viewer'   ,  '' , '');


}


function GetPositionRow( grid , idRow , Page )
{

 var objInd;
 var nInd; 
 var objGrid;
 var numRow;
 
 
 try
 {
  objGrid = getObjPage( grid , Page);
  //numRow = objGrid.numrow;
  
    numRow = GridViewer_NumRow;
  
  if(  numRow == undefined ) numRow = objGrid[0].numrow;
  
  for (nInd=0;nInd<=numRow;nInd++)
  {
   //-- prelevo il valore dell'identificativo
   objInd = getObjPage( grid + '_idRow_' + nInd , Page);
   
   if ( objInd.value == idRow )
   {
    return nInd;
   }
  }
  
  return -1;
 }
 catch(  e ){ return -1;  };

}


function CompletaDati()
{
	
	var parametri;
	var idRow;
	
	idRow = Grid_GetIdSelectedRow( 'GridViewer' ); 
	idRow = idRow.replace( /~~~/g, ',')
	
	if( idRow == '' )
	{
	  DMessageBox( '../ctl_library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
	  return;
	  
	 }
	z = idRow.split( ',' );
	if(  z.length > 1 ) 
    {
      DMessageBox( '../ctl_library/' , 'E\' necessario selezionare una sola riga' , 'Attenzione' , 2 , 400 , 300 );
	  return;      
    }	
	
	var Row = GetPositionRow('GridViewer',idRow,'self');
	
	//alert(Row);
	
	idRow = getObjValue('R' + Row + '_idRow');
	
	//alert(idRow);
	
	parametri = 'DATI_QUALIFICA#BANDO_QF,' + idRow +  '#1024,768';
	
	DASH_NewDocumentFrom(parametri);
	
}	

function CreaEsito()
{
	
	var parametri;
	var idRow;
	var originalIdRow;
	
	idRow = Grid_GetIdSelectedRow( 'GridViewer' ); 
	idRow = idRow.replace( /~~~/g, ',')
	
	if( idRow == '' )
	{
	  DMessageBox( '../ctl_library/' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );
	  return;
	  
	 }
	z = idRow.split( ',' );
	if(  z.length > 1 ) 
    {
      DMessageBox( '../ctl_library/' , 'E\' necessario selezionare una sola riga' , 'Attenzione' , 2 , 400 , 300 );
	  return;      
    }	
	
	var Row = GetPositionRow('GridViewer',idRow,'self');
	
	
	idRow = getObjValue('R' + Row + '_idRow');
	
	//alert(idRow);
	
	parametri = 'ESITO_QUALIFICAZIONE#BANDO_QF,' + idRow +  '#1024,768';
	
	//alert(parametri);
	
	DASH_NewDocumentFrom(parametri);
	
}	

function MyOpenDocumentColumn( objGrid , Row , c )
{

	var idMsg = getObjValue('R' + Row + '_idMsg');
	var strDoc;
	
	try	{ 	strDoc = getObjValue( 'R' + Row + '_OPEN_DOC_NAME');	}catch( e ) {};
	
	ShowDocument( strDoc , idMsg );
	
	

}

