window.onload = InitDoc;


function OpenViewerTipologia( objGrid , Row , c )
{
//OpenViewer('Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_ELENCO_CODIFICHE_META_PRODOTTI&ModelloFiltro=DASHBOARD_VIEW_ELENCO_CODIFICHE_PRODOTTIFiltro&ModGriglia=ELENCO_CODIFICHE_META_PRODOTTI_' + getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito') + '_MOD_Griglia&Filter= MacroAreaMerc=\'' + getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito') + '\'&IDENTITY=ID&lo=base&HIDE_COL=&DOCUMENT=DOCUMENT_CODIFICA_PRODOTTO_' + getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito') +'&PATHTOOLBAR=../CustomDoc/&JSCRIPT=BANDO_GARA&AreaAdd=no&Caption=Ricerca Meta Prodotti&Height=180,100*,210&numRowForPag=20&Sort=Id&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_RICERCA_METAPRODOTTI&ACTIVESEL=2&FilterHide=&ONSUBMIT=return cercaperambito()&doc_to_upd='+ getObj('IDDOC').value);

	var cod;
	var nq;

	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
	
	//alert(cod);
	var strFilterHide = 'tipologiaerrore like \'' + encodeURIComponent(cod) + '\' ';
	DashBoardOpenFuncMain('dashboard/Viewer.asp?MODGriglia=&ModelloFiltro=&Table=Ctl_Event_Log_Report&OWNER=&IDENTITY=id&TOOLBAR=Ctl_Event_Log_Report_Dettaglio_TOOLBAR&DOCUMENT=DOCUMENT_INTEGRATION_REQUEST&PATHTOOLBAR=../customdoc/&AreaAdd=no&Height=150,100*,210&numRowForPag=15&Sort=id&SortOrder=desc&ACTIVESEL=1&HIDE_COL=&AreaFiltroWin=&FiltroWin=1&Filter=&TOOLBAR_PAGINAZIONE_=&TypeScroll=1&FILTER_BUTTON=right&FilterCaption=no&FILTERCOLUMNFROMMODEL=yes&JSCRIPT=protgen&CAPTION=Monitoraggio Sistema | Monitor Eventi Tipologia "' + ReplaceExtended(cod,'###','') + '"&ShowExit=0&CaptionNoML=no&FilterHide=' + strFilterHide );
	
}


function InitDoc(obj) 
{
	HideCestinodoc();
}



function HideCestinodoc() {
	
	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
    
	if (DOCUMENT_READONLY == '1')
		return;
	
    try {
       
	   var i = 0;

			
            for (i = 0; i < DETTAGLIGrid_EndRow + 1; i++) 
			{
				//alert( getObj('R' + i + '_Titolo_Tipologia').value );
							  
                if ( getObj('R' + i + '_Titolo_Tipologia').value == 'Altro') 
				{
					TextreadOnly( 'R' + i + '_Titolo_Tipologia', true);
					TextreadOnly( 'R' + i + '_Descrizione_Tipologia', true);
					TextreadOnly( 'R' + i + '_ParoleChiavi_Tipologia', true);
					
                    getObj('DETTAGLIGrid_r' + i + '_c0').innerHTML = '&nbsp;';
					return;
					
                }
            }
       
    } catch (e) {}

}

function DETTAGLI_AFTER_COMMAND(command) 
{
		HideCestinodoc();
}