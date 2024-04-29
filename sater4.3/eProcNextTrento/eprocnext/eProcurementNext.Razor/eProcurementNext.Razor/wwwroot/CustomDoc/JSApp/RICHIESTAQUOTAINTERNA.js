

function trim(str)
{
	return str.replace(/^\s+|\s+$/g,"");
}


window.onload = onloadDOc ;

function onloadDOc() {
  
  
  
  //Importo Totale Allocato non editable se ci sono righe nella griglia dei lotti
   if (GetProperty(getObj('LOTTIGrid'), 'numrow') != -1 || getObj( 'JumpCheck' ).value == 'QUOTA_PER_LOTTI' ) 
   {
		NumberreadOnly( 'Importo' , true );   	
		getObj( 'JumpCheck' ).value='QUOTA_PER_LOTTI';
   }
   else
   {
	   NumberreadOnly( 'Importo' , false );
	   //NASCONDE LA GRIGLIA
	   getObj('div_LOTTIGrid').style.display='none';
	   getObj('QUOTA_LOTTI_TOOLBAR_Lotto_da_convezione').style.display='none';
	   getObj( 'JumpCheck' ).value='QUOTA_SENZA_LOTTI';
	   
   }
	   
  
  
}


function MyOpenViewer(param)
{	
	ExecDocProcess( 'SAVE_AND_GO,QUOTA_ADD_LOTTO,,NO_MSG');
}

function afterProcess( param )
{
	if ( param == 'SAVE_AND_GO' )
    {
       OpenViewer('Viewer.asp?OWNER=&Table=CONVENZIONE_CAPIENZA_LOTTI_VIEW&ModelloFiltro=&ModGriglia=CONVENZIONE_LOTTI&IDENTITY=idRow&lo=base&HIDE_COL=&DOCUMENT=QUOTA&PATHTOOLBAR=../CustomDoc/&JSCRIPT=QUOTA&AreaAdd=no&Caption=Lista lotti convezione&Height=180,100*,210&numRowForPag=20&Sort=NumeroLotto&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_PRODOTTI&ACTIVESEL=2&FilterHide=IdHeader='+ getObj('LinkedDoc').value + '&doc_to_upd='+ getObj('IDDOC').value);
    }
	
}

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
			parametri =  'LOTTI#ADDFROM#IDROW=' + idRow + '&IDDOC='+ doc_to_upd +'&RESPONSE_ESITO=YES&TABLEFROMADD=CONVENZIONE_CAPIENZA_LOTTI_VIEW&DOCUMENT=QUOTA';
		}
		else
		{
			parametri =  'LOTTI#ADDFROM#IDROW=' + idRow + '&TABLEFROMADD=CONVENZIONE_CAPIENZA_LOTTI_VIEW&RESPONSE_ESITO=YES'
		}
		
		Viewer_Dettagli_AddSel( parametri);	
	}  
}