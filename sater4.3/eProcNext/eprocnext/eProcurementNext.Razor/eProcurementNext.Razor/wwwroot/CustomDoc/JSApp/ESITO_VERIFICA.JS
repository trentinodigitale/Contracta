function TESTATA_OnLoad()
{
    //-- se il documento è stato confermato aggiorno il chiamante e chiudo la finestra
    var val_StatoFunzionale = getObjValue( 'val_StatoFunzionale' );
    var idRow;
    
    if ( val_StatoFunzionale  == 'Confermato' )
    {
    
        opener.ExecDocCommand( 'OFFERTE#Reload#' );

        self.close();
    }
}
    
    
function MyOpenViewerSelMotiv(){

  
  //aggiorno documento in meoria
  UpdateDocInMem( getObj( 'IDDOC' ).value, getObj( 'TYPEDOC' ).value );

  //apro il viewer per selezionare azienda
  OpenViewer('Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_GESTIONE_MOTIVAZIONI_ESITO&ModelloFiltro=&ModGriglia=SELEZIONA_MOTIVAZIONE_FROM_ESITOGriglia&Filter=&IDENTITY=&lo=base&HIDE_COL=&DOCUMENT=ESITO_VERIFICA&PATHTOOLBAR=../CustomDoc/&JSCRIPT=ESITO_VERIFICA&AreaAdd=no&Caption=Selezione Motivazione&Height=180,100*,210&numRowForPag=20&Sort=Titolo&SortOrder=asc&Exit=si&AreaFiltro=no&AreaFiltroWin=close&TOOLBAR=dashboard_view_aziende_toolbar&ACTIVESEL=1&FilterHide=Contesto = \'ESITO_VERIFICA\' and StatoFunzionale=\'Confermato\'&ONSUBMIT=&doc_to_upd='+ getObj('IDDOC').value );

}

function SelezionaMotivazione( objGrid , Row , c )
{
	var param;
	
	var myReq = GetXMLHttpRequest(); 
    var res = false;
	var DOC_TO_UPD = getQSParam('doc_to_upd');
	var TYPEDOC = 'ESITO_VERIFICA';
	var nocache = new Date().getTime();
    	
	var STR_URL =  '../ctl_library/document/Upd_Field_Document_InMem.asp?OUTPUT=NO&SECTION=TESTATA&TYPEDOC=' + TYPEDOC + '&lo=content&IDDOC=' + DOC_TO_UPD + '&MODE=SHOW&FIELD=Body&FIELD_VALUE=&nocache=' + nocache;
	
    myReq.open('POST', STR_URL, false);
	var Motivazione=getObj( 'R'+ Row + '_Body' ).value;	
	param='IDDOC=' + DOC_TO_UPD + '&Motivazione=' + encodeURIComponent(Motivazione);	
   

	myReq.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
	myReq.send(param);
	//myReq.onreadystatechange = function() {

		if (myReq.readyState == 4)
		{
			if(myReq.status == 404 || myReq.status == 500)
			{
			  alert('Errore invocazione pagina');				  
			}
			if(myReq.status == 200) 
			{
				if ( myReq.responseText == 'ERRORE_DOCUMENTO_DA_AGGIORNARE' ) 
				{
				 alert('Errore: Stato del documento da aggiornare diverso da in lavorazione');				  
				}
				//alert(myReq.responseText);

				res = true;
				
				if ( myReq.responseText == 'OK' ) 
				{
					//ritorno al documento 
					breadCrumbPop('');
				}	

			}
			else
			{
				res = false;
			}
		}

	//}
    return res;
}

