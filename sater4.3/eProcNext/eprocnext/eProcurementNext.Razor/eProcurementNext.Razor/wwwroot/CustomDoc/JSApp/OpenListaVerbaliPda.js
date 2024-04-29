function OpenListaVerbaliPda( objGrid , Row , c )
{
	var cod;
	var nq;
  var strURL;
  var IdMsgSource;
  var NumVerbali;
  var IdTipoVerbale;
  var c;
  
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
  
  //alert(cod);
  
  //-- recupero numero verbali fatti del tipo corrente
  NumVerbali = 0 ;
  
  NumVerbali = getObjValue ('R' + Row + '_NumeroVerbali' )
  
  
  
  if ( NumVerbali > 0 ){
    
    
    //recupero desc del tipo verbale da usare come caption per la lista che vado ad aprire
    strCaption = getObjValue ('R' + Row + '_Titolo' );
    
    //recupero idmsg della PDA
	  IdMsgSource = getObj('DOCUMENT').value;
    
    FilterHide = 'FilterHide= StatoDoc<>\'Annullato\' and LinkedDoc=' + IdMsgSource ;
    FilterHide = FilterHide + ' and IdTipoVerbale=' + cod ; 
    strURL = '../DASHBOARD/Viewer.asp?PATHTOOLBAR=../customdoc/&JScript=ListaVerbaliPda&Exit=si&Table=DASHBOARD_VIEW_VERBALI&OWNER=&IDENTITY=ID&TOOLBAR=DASHBOARD_VIEW_VERBALI_TOOLBAR&DOCUMENT=VERBALEGARA&AreaAdd=no&CaptionNoML=no&Caption=' + strCaption + '&Height=0,100*,210&numRowForPag=25&Sort=data&SortOrder=desc&ACTIVESEL=2&FILTERCOLUMNFROMMODEL=yes&AreaFiltroWin=1&AreaFiltro=no&' + FilterHide;
    
    ExecFunctionCenter( strURL + '#ListaVerbaliPDA#800,600' );
    	
    return; 
  }
  
  DMessageBox( '../CTL_Library/' , 'non ci sono verbali di questa tipologia' , 'Attenzione' , 2 , 400 , 300 ); 
  
  
  
}