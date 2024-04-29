

function trim(str)
{
	return str.replace(/^\s+|\s+$/g,"");
}


window.onload = onloadDOc ;

function onloadDOc() {
  
   
	//Importo Totale Allocato non editable se ci sono righe nella griglia dei lotti
	if (GetProperty(getObj('LOTTIGrid'), 'numrow') != -1 || getObj( 'JumpCheck' ).value == 'QUOTA_PER_LOTTI' ) 
	{
		NumberreadOnly( 'ImportoRichiesto' , true );   	
		getObj( 'JumpCheck' ).value='QUOTA_PER_LOTTI';
	}
	else
	{
	   NumberreadOnly( 'ImportoRichiesto' , false );
	   //NASCONDE LA GRIGLIA
	   getObj('div_LOTTIGrid').style.display='none';
	   getObj('QUOTA_LOTTI_TOOLBAR_Lotto_da_convezione').style.display='none';
	   getObj( 'JumpCheck' ).value='QUOTA_SENZA_LOTTI';
	   
	}
   
   
	//se doc editabile e il campo StrutturaAziendale Visibile
	//setto il filtro a seconda dell'ente selezionato
	var DOCUMENT_READONLY = '0';
	try
	{
		DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	}
	catch(e){}

	if (DOCUMENT_READONLY == '0')
	{
		filtroPlant( 0 );	
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
       OpenViewer('Viewer.asp?OWNER=&Table=CONVENZIONE_CAPIENZA_LOTTI_VIEW&ModelloFiltro=&ModGriglia=CONVENZIONE_LOTTI&IDENTITY=idRow&lo=base&HIDE_COL=&DOCUMENT=RICHIESTAQUOTA&PATHTOOLBAR=../CustomDoc/&JSCRIPT=RICHIESTAQUOTA&AreaAdd=no&Caption=Lista lotti convezione&Height=180,100*,210&numRowForPag=20&Sort=NumeroLotto&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=TOOLBAR_VIEW_LISTA_PRODOTTI&ACTIVESEL=2&FilterHide=IdHeader='+ getObj('LinkedDoc').value + '&doc_to_upd='+ getObj('IDDOC').value);
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
			parametri =  'LOTTI#ADDFROM#IDROW=' + idRow + '&IDDOC='+ doc_to_upd +'&RESPONSE_ESITO=YES&TABLEFROMADD=CONVENZIONE_QUOTA_LOTTI_FROMADD&DOCUMENT=RICHIESTAQUOTA';
		}
		else
		{
			parametri =  'LOTTI#ADDFROM#IDROW=' + idRow + '&TABLEFROMADD=CONVENZIONE_QUOTA_LOTTI_FROMADD&RESPONSE_ESITO=YES'
		}
		
		Viewer_Dettagli_AddSel( parametri);	
	}  
}




//applico il filtro al dominio della struttura di appartenenza
//per caricare solo i  rami relativi all'azienda collegata
function filtroPlant( nSvuota )
{

	var filter = '';

	try
	{ 
		var objBtn_Struttura = getObj('StrutturaAziendale_button');
		if (objBtn_Struttura != null)
		{	
			if ( getObj('Azienda').value != '' )
			{ 	
				filter = 'idaz in ( ' + getObj('Azienda').value + ' )' ;
				getObj('StrutturaAziendale_extraAttrib').value= 'strformat#=#M#@#filter#=#SQL_WHERE= ' + filter + '#@#multivalue#=#1';
			}	
			
			//svuoto il campo
			if ( nSvuota == 1)
			{	
				getObj( 'StrutturaAziendale').value = '';
				getObj( 'StrutturaAziendale_edit_new').value = '0 Selezionati';
			}
			
		}
	}
	catch(e){};
		
}