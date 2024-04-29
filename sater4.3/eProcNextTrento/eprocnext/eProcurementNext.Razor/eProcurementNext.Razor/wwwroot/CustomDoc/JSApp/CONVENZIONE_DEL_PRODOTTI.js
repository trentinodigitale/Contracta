




function AggiungiProdotti(){
  
  var idRow;
  var doc_to_upd=getQSParam('doc_to_upd');
  
	//-- recupera il codice delle righe selezionate
	idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	
	if( idRow == '' )
	{
	  DMessageBox( '../' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );  
	}
	else
	{					
		var parametri='';
		if ( isSingleWin() )
		{
			parametri =  'PRODOTTI#ADDFROM#IDROW=' + idRow + '&IDDOC='+ doc_to_upd +'&RESPONSE_ESITO=YES&TABLEFROMADD=View_CONVENZIONE_DEL_PRODOTTI&DOCUMENT=CONVENZIONE_DEL_PRODOTTI';
		}
		else
		{
			parametri =  'PRODOTTI#ADDFROM#IDROW=' + idRow + '&TABLEFROMADD=View_CONVENZIONE_DEL_PRODOTTI&RESPONSE_ESITO=YES'
		}
		
		Viewer_Dettagli_AddSel( parametri);	
	}  
}

function MyOpenViewer(param)
{	

     

	ExecDocProcess( 'SAVE_AND_GO,CONVENZIONE_ADD_PRODOTTI,,NO_MSG');
}

function afterProcess( param )
{
	if ( param == 'SAVE_AND_GO' )
    {
		
		var strCaption = 'Lista articoli convezione' ; 
		var strLinkedDoc  = getObj('LinkedDoc').value ;
	   
		if ( getObj('JumpCheck').value == 'LISTINO_ORDINI' )
		{   
			strCaption = 'Lista articoli listino ordini' ; 
			strLinkedDoc  = getObj('idDocListinoOrdini').value ; 	
		}	
	 
       OpenViewer('Viewer.asp?OWNER=&Table=View_CONVENZIONE_DEL_PRODOTTI&ModelloFiltro=Convenzione_Modifica_ProdottiFiltro&ModGriglia=' + getObj('ModelloConvenzione').value + '&IDENTITY=ID&lo=base&HIDE_COL=FNZ_DEL,EsitoRiga,&DOCUMENT=CONVENZIONE_DEL_PRODOTTI&PATHTOOLBAR=../CustomDoc/&JSCRIPT=CONVENZIONE_DEL_PRODOTTI&AreaAdd=no&Caption=' + strCaption + '&Height=180,100*,210&numRowForPag=20&Sort=Id&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_PRODOTTI&ACTIVESEL=2&FilterHide=IdHeader='+ strLinkedDoc  + ' and StatoRiga in (\'Saved\',\'\',\'Inserito\',\'Variato\') &doc_to_upd='+ getObj('IDDOC').value);
    }
	
}

//serve solo nella versione multi finestra
function RefreshContent()
{
	if ( isSingleWin() == false )
	{
		ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');
	}
}


