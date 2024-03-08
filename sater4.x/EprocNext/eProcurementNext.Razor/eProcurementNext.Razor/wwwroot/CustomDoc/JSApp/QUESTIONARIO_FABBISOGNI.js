window.onload = rimuovilente; 
function DownLoadCSV()
{

    var TipoBando = getObjValue( 'TipoBando' );
    
    if ( TipoBando == '' )
    {
      alert( CNV( '../','E\' necessario selezionare prima il modello'));
      return ;
    }
   
    ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + getObjValue('IDDOC') + '&TIPODOC=QUESTIONARIO_FABBISOGNI&MODEL=MODELLO_BASE_FABBISOGNI_' + TipoBando + '_Fabb_Questionario&HIDECOL=ESITORIGA'  , '_blank' ,'');
    
}
function OnClickProdotti( obj )
{
    var TipoBando = getObjValue( 'TipoBando' );
    
    if ( TipoBando == '' )
    {
      //alert( CNV( '../','E\' necessario selezionare prima il modello'));
      DMessageBox( '../' , 'E\' necessario selezionare prima il modello' , 'Attenzione' , 1 , 400 , 300 );
      return ;
    }
    
   
    var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;
    if ( DOCUMENT_READONLY == "1" )
        DMessageBox( '../' , 'Documento in sola lettura' , 'Attenzione' , 1 , 400 , 300 );
    else
        ImportExcel( 'CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,BANDO_FABBISOGNI&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#600,450' );
}


function FIRMA_OnLoad() 
{
    
	try {
			FieldToSign();
		} catch (e) {};

}
function FieldToSign() {

    var Stato = '';
    Stato = getObjValue('StatoFunzionale');
	
	

    if ( getObjValue('RichiestaFirma') == 'si' )
	{
		if ((getObjValue('SIGN_LOCK') == '0' || getObjValue('SIGN_LOCK') == '') && (Stato == 'InLavorazione' || Stato == 'Sub-Questionari Completati' || Stato == "")) {
			document.getElementById('generapdf').disabled = false;
			document.getElementById('generapdf').className = "generapdf";
		} else {
			document.getElementById('generapdf').disabled = true;
			document.getElementById('generapdf').className = "generapdfdisabled";
		}


		if ((getObjValue('SIGN_LOCK') != '0' && getObjValue('SIGN_LOCK') != '') && (Stato == 'InLavorazione' || Stato == 'Sub-Questionari Completati')) {
			document.getElementById('editistanza').disabled = false;
			document.getElementById('editistanza').className = "attachpdf";
		} else {
			document.getElementById('editistanza').disabled = true;
			document.getElementById('editistanza').className = "attachpdfdisabled";
		}

		if (getObjValue('SIGN_ATTACH') == '' && (Stato == 'InLavorazione' || Stato == 'Sub-Questionari Completati') && (getObjValue('SIGN_LOCK') != '0' && getObjValue('SIGN_LOCK') != '')) {
			document.getElementById('attachpdf').disabled = false;
			document.getElementById('attachpdf').className = "editistanza";
		} else {
			document.getElementById('attachpdf').disabled = true;
			document.getElementById('attachpdf').className = "editistanzadisabled";
		}
	}
}
function controlloEsitoRiga()
{
		var numerorigheprdotti = GetProperty( getObj('PRODOTTIGrid') , 'numrow');
		if ( numerorigheprdotti == -1 )
		{
			DMessageBox( '../' , 'Prima di Generare il Pdf Compilare la sezione dei prodotti.' , 'Attenzione' , 1 , 400 , 300 );
			//DocShowFolder( 'FLD_PRODOTTI' );	   
			return - 1;
		}
		
		
		if ( trim(getObj('EsitoRiga').value) != '' )
		
		{ 
			
			DMessageBox( '../' , 'Prima di Generare il Pdf Compilare correttamente la sezione dei prodotti.' , 'Attenzione' , 1 , 400 , 300 );
			//DocShowFolder( 'FLD_PRODOTTI' );	   
			return - 1;
			
		}
		
}


function GeneraPDF() {
   
	ExecDocProcess( 'CONTROLLO_PRODOTTI_PRE_PDF,BANDO_FABBISOGNI,,NO_MSG');
}


function afterProcess( param )
{
	if ( param == 'CONTROLLO_PRODOTTI_PRE_PDF' && getObjValue('RichiestaFirma') == 'si'   )
    {
		var EsitoRiga=controlloEsitoRiga();
		if (EsitoRiga == -1)
			return;
		scroll(0, 0);
		
		if ( trim(getObj('Titolo').value) == '' )
		{
			DMessageBox( '../' , 'Prima di Generare il Pdf Compilare il campo Titolo' , 'Attenzione' , 1 , 400 , 300 );
			return;
		}		
		

		PrintPdfSign('URL=/report/QUESTIONARIO_FABBISOGNI.ASP?SIGN=YES');
	}
	

}


function TogliFirma() {
    DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );	
    ExecDocProcess('SIGN_ERASE,FirmaDigitale');
}
function trim(str){
    return str.replace(/^\s+|\s+$/g,"");
}

function rimuovilente()
{
  // rimuove la funzione di onclick quando non esiste il questionario
  var onclick = '';
  var numeroRighe0 = GetProperty( getObj('SUB_QUESTIONARIGrid') , 'numrow');
	if(  Number( numeroRighe0 ) >= 0 )
	{
		for( i = 0 ; i <= numeroRighe0 ; i++ )
		{
		 try{
				if( getObjValue('R' + i + '_SUB_QUESTIONARIGrid_ID_DOC') == '' )
				{
					obj=getObj('R' + i + '_FNZ_OPEN' ).parentElement;
					onclick='';			
					obj.innerHTML = onclick;
				}
			}
		  catch(e){};
		}
	}
}

function SUB_QUESTIONARI_AFTER_COMMAND ()
{
	rimuovilente();
}


function DownLoadCSV_Raccolta()
{

    var TipoBando = getObjValue( 'TipoBando' );
    
    if ( TipoBando == '' )
    {
      alert( CNV( '../','E\' necessario selezionare prima il modello'));
      return ;
    }
   
    ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + getObjValue('LinkedDoc') + '&TIPODOC=BANDO_FABBISOGNI&MODEL=MODELLO_BASE_FABBISOGNI_' + TipoBando + '_Fabb_Questionario&HIDECOL=ESITORIGA'  , '_blank' ,'');
    
}

