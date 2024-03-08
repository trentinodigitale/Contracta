 window.onload = onloadpage; 
 function onloadpage()
{
	if ( getObjValue( 'StatoFunzionale' ) == 'NEW_CODIFICA_PRODOTTI' )
	{	
		ExecDocProcess( 'VERIFICA_CARICAMENTO,CODIFICA_PRODOTTI,,NO_MSG' );
	}

	if ( getObjValue( 'StatoFunzionale' ) != 'InLavorazione' || getObjValue( 'IdpfuInCharge' ) == '0' )
	{	
		ShowCol( 'PRODOTTI' , 'FNZ_OPEN' , 'none' );    
	}

}
 



function MySend(param)
{
    if( ControlliSend( param ) == -1 ) return -1;
    ExecDocProcess(param);
 
}

function ControlliSend(param)
{
    

  
	
  	if( GetProperty( getObj('PRODOTTIGrid') , 'numrow')==-1)
  	{
  		
 	    DocShowFolder( 'FLD_PRODOTTI' );	   
  		tdoc();
  		DMessageBox( '../' , 'Compilare correttamente la sezione dei prodotti' , 'Attenzione' , 1 , 400 , 300 );
  		return -1;
  	}	
  	
  	
  	if( getObjValue('TipoBando') == '' )
  	{
  		
 	    DocShowFolder( 'FLD_PRODOTTI' );	   
  		tdoc();
  		DMessageBox( '../' , 'Compilare correttamente la sezione dei prodotti' , 'Attenzione' , 1 , 400 , 300 );
  		return -1;
  	}	
    
     
		  

	
}



function DownLoadCSV()
{

    var TipoBando = getObjValue( 'TipoBando' );
    
    if ( TipoBando == '' )
    {
	  DMessageBox( '../' , 'E\' necessario selezionare prima il modello' , 'Attenzione' , 1 , 400 , 300 );
      return ;
    }
   
    ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + getObjValue('IDDOC') + '&HIDECOL=StatoRiga,ToDelete,ESITORIGA&TIPODOC=CODIFICA_PRODOTTI&MODEL=MODELLO_BASE_CODIFICA_PRODOTTI_' + TipoBando + '_MOD_Macro_Prodotto'  , '_blank' ,'');
    
}



function AddProdotto( )
{
	var strCommand = 'PRODOTTI#ADDFROM#IDROW=' + getObjValue( 'IDDOC' ) + '&TABLEFROMADD=DOCUMENT_CODIFICA_PRODOTTI_ADD_PRODOTTO' 

    ExecDocCommand( strCommand );
	
}


function MyDeleteArticolo(objGrid, Row, c) {


    if ( getObj('RPRODOTTIGrid_' + Row + '_ToDelete').value == '1' )
	{
		DMessageBox( '../' , 'Non si possono cancellare le righe provenienti dalla "Richiesta"' , 'Attenzione' , 1 , 400 , 300 );
		return ;
	}
	else	
		DettagliDel ( objGrid , Row , c );


}
function OpenViewerRicercaMetaProdotti(objGrid, Row, c)
{
	//SE LA RIGA RISULTA CODIFICATA NON CONSENTE DI APRIRE IL VIEWER DI RICERCA 
	 if ( getObj('RPRODOTTIGrid_' + Row + '_CODICE_REGIONALE').value != '' )
	{	
		DMessageBox( '../' , 'La riga risulta gia codificata.' , 'Attenzione' , 1 , 400 , 300 );
		return ;
	}
	else
	{
	//Prova a recuperare i valori per le colonne presenti nel filtro del viewer e per quelle che trova un valore le passo al filter del viewer
		var value='';
		
		try{	
				if ( getObj('RPRODOTTIGrid_' + Row + '_CODICE_REGIONALE').value != '')
				{
					value=value + 'CODICE_REGIONALE=\'' + getObj('RPRODOTTIGrid_' + Row + '_CODICE_REGIONALE').value + '\' and '
				}
			}catch(e){}
		
		try{	
				if ( getObj('RPRODOTTIGrid_' + Row + '_DESCRIZIONE_CODICE_REGIONALE').value != '')
				{
					value=value + 'DESCRIZIONE_CODICE_REGIONALE=\'' + getObj('RPRODOTTIGrid_' + Row + '_DESCRIZIONE_CODICE_REGIONALE').value + '\' and '
				}
			}catch(e){}
		
		try{	
				if ( getObj('RPRODOTTIGrid_' + Row + '_CODICE_CND').value != '')
				{
					value=value + 'CODICE_CND=\'' + getObj('RPRODOTTIGrid_' + Row + '_CODICE_CND').value + '\' and '
				}
			}catch(e){}
		
		try{	
				if ( getObj('RPRODOTTIGrid_' + Row + '_LATEX_FREE').value != '')
				{
					value=value + 'LATEX_FREE=\'' + getObj('RPRODOTTIGrid_' + Row + '_LATEX_FREE').value + '\' and '
				}
			}catch(e){}
		
		try{	
				if ( getObj('RPRODOTTIGrid_' + Row + '_Somministrazione').value != '')
				{
					value=value + 'Somministrazione=\'' + getObj('RPRODOTTIGrid_' + Row + '_Somministrazione').value + '\' and '
				}
			}catch(e){}
		
		try{	
				if ( getObj('RPRODOTTIGrid_' + Row + '_CodiceATC').value != '')
				{
					value=value + 'CodiceATC=\'' + getObj('RPRODOTTIGrid_' + Row + '_CodiceATC').value + '\' and '
				}
			}catch(e){}
		try{	
				if ( getObj('RPRODOTTIGrid_' + Row + '_MATERIALE').value != '')
				{
					value=value + 'MATERIALE=\'' + getObj('RPRODOTTIGrid_' + Row + '_MATERIALE').value + '\' and '
				}
			}catch(e){}
		
		try{	
				if ( getObj('RPRODOTTIGrid_' + Row + '_CODICE_CPV').value != '')
				{
					value=value + 'CODICE_CPV=\'' + getObj('RPRODOTTIGrid_' + Row + '_CODICE_CPV').value + '\''
				}
			}catch(e){}	
		
		//se termina con and lo rimuovo
		if ( value.substring(value.length-4, value.length) == 'and ' )
		{
			value=value.substring(0,value.length-4);
		}
		//setto il value in questa colonna, dal quale lo recupero dopo il processo di save_and_go
		getObj('colonnatecnica').value = value;	
		getObj('idRowPrincipale').value = getObj('PRODOTTIGrid_idRow_' + Row ).value;	
		ExecDocProcess( 'SAVE_AND_GO,CODIFICA_PRODOTTI,,NO_MSG');
	}
		
}

function afterProcess( param )
{
	if ( param == 'SAVE_AND_GO' )
    {
       OpenViewer('Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_ELENCO_CODIFICHE_META_PRODOTTI&ModelloFiltro=DASHBOARD_VIEW_ELENCO_CODIFICHE_PRODOTTIFiltro&ModGriglia=ELENCO_CODIFICHE_META_PRODOTTI_' + getObjValue('val_MacroAreaMerc') + '_MOD_Griglia&Filter='+ getObjValue('colonnatecnica') + '&IDENTITY=ID&lo=base&HIDE_COL=&DOCUMENT=DOCUMENT_CODIFICA_PRODOTTO_' + getObjValue('val_MacroAreaMerc') +'&PATHTOOLBAR=../CustomDoc/&JSCRIPT=CODIFICA_PRODOTTI&AreaAdd=no&Caption=Ricerca Meta Prodotti&Height=180,100*,210&numRowForPag=20&Sort=Id&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_RICERCA_META_PRODOTTI&ACTIVESEL=1&FilterHide= MacroAreaMerc=' + getObjValue('val_MacroAreaMerc') + '&row_to_upd=' + getObj('idRowPrincipale').value +'&doc_to_upd='+ getObj('IDDOC').value);
    }
	
}
function selezionaMetaprodotto(objGrid, Row, c)
{
	try 
	{
		//documento da aggiornate
		var DOC_TO_UPD=getQSParam('doc_to_upd');
		//id riga sul documento codifica da aggiornate
		var ROW_TO_UPD=getQSParam('row_to_upd');
		//-- recupera il codice della riga scelta
		var idRow = getObj('GridViewer_idRow_' + Row ).value;
		
		var nocache = new Date().getTime();
		var param;
		
		param='doc_to_upd=' + DOC_TO_UPD + '&row_to_upd=' + ROW_TO_UPD + '&row_copy=' + idRow
		
		ajax = GetXMLHttpRequest();		
		
			ajax.open("GET",   '../customDoc/selezionaMetaprodotto.asp?' + param + '&nocache=' + nocache , false);
			ajax.send(null);
				
			if(ajax.readyState == 4) 
			{
				if(ajax.status == 404 || ajax.status == 500)
				{
				  alert('Errore invocazione pagina');				  
				}
				
				if ( ajax.responseText == 'OK' ) 
				{
					//ritorno al documento di codifica prodotti se tutto ok
					ReloadDocFromDB( DOC_TO_UPD , 'CODIFICA_PRODOTTI' )
					breadCrumbPop( '');
				}
				
				if ( ajax.responseText == 'ERRORE_DOCUMENTO_DA_AGGIORNARE' ) 
				{
				 alert('Errore: Stato del documento da aggiornare diverso da in lavorazione');				  
				}
			 
			 }
			 
	}catch( e ) { };	
	
}


