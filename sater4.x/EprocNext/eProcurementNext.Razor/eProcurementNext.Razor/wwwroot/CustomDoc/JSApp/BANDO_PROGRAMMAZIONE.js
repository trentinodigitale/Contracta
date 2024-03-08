var flag=0;
var OldValueTipoBando = '';

window.onload = OnLoadPage; 

function DESTINATARI_AFTER_COMMAND( command )
{
	if ( command == 'PAGINAZIONE' )  
	{
		rimuovilente();
	}
}

function OnLoadPage()
{

	//cambia la tooltip della matita per Aprire il dettaglio del modello	
	var tmpMlg = '';
	
	try{
		tmpMlg = CNV( pathRoot ,'Modifica Modello Gara');
		getObj('RTESTATA_PRODOTTI_MODEL_FNZ_UPD_link').firstChild.alt= tmpMlg;
		getObj('RTESTATA_PRODOTTI_MODEL_FNZ_UPD_link').firstChild.title=tmpMlg;
	}catch( e ) {};	

    FiltraModelli();
	rimuovilente();


}
function rimuovilente()
{
  // rimuove la funzione di onclick quando non esiste il questionario
  var onclick = '';
  var numeroRighe0 = GetProperty( getObj('DESTINATARIGrid') , 'numrow');
	if(  Number( numeroRighe0 ) > 0 )
	{
		for( i = 0 ; i <= numeroRighe0 ; i++ )
		{
		 try{
				if( getObjValue('R' + i + '_DESTINATARIGrid_ID_DOC') == '' )
				{
					//obj=getObj('R' + i + '_FNZ_OPEN' ).parentElement;
					getObj( 'DESTINATARIGrid_r' + i + '_c13' ).innerHTML = '';
					//onclick='';			
					//obj.innerHTML = onclick;
				}
			}
		  catch(e){};
		}
	}
}


function OnChangeAmbito()
{
	var iddoc = getObj('IDDOC').value;	
	
	var Ambito = getObjValue('RTESTATA_PRODOTTI_MODEL_Ambito');
	            
	if (getObjValue( 'TipoBando' ) != '' )
	{
		alert( CNV( '../','Il cambio dell\'ambito comporta un azzeramento del modello dei prodotti'));

        ExecDocProcess( 'SVUOTA_SOLO_MODELLO_PRODOTTI,BANDO_GARA');

	}
	else
	{
        FiltraModelli();
	}
}


function FiltraModelli()
{
    try
    {
        if( getObjValue(   'StatoFunzionale' ) == 'InLavorazione' )
        {

            //var Ambito = getObjValue( 'RTESTATA_PRODOTTI_MODEL_Ambito' ); 
         
            
            var filter =  'SQL_WHERE= DMV_Cod in ( select codice  from View_Modelli_PROGRAMMAZIONE )';

            FilterDom( 'RTESTATA_PRODOTTI_MODEL_TipoBandoSceltaProgrammazione' , 'TipoBandoSceltaProgrammazione' , getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBandoSceltaProgrammazione') , filter , 'TESTATA_PRODOTTI_MODEL'  , 'OnChangeModello( this );');
        }
    }catch( e ) {};

}



function RefreshContent()
{
	
	if( getObjValue(   'StatoFunzionale' ) != 'InLavorazione' )
    {
		RefreshDocument('');
	}
	else
	{
		
		ExecDocCommand( 'DESTINATARI_1#RELOAD' );
		
	}
}



//-- associo il nuovo modello al documento 
function OnChangeModello( o )
{
  
    //-- aggiorna il modello da usare per la sezione prodotti

	ExecDocProcess( 'SELECT_MODELLO_BANDO,BANDO_PROGRAMMAZIONE');
} 




function MySend(param)
{
    if( ControlliSend( param ) == -1 ) return -1;
    ExecDocProcess(param);
 
}

function ControlliSend(param)
{
    	

  	if( GetProperty( getObj('RIFERIMENTIGrid') , 'numrow')==-1)
  	{
  		
      DocShowFolder( 'FLD_RIFERIMENTI' );	   
      tdoc();
      DMessageBox( '../' , 'Compilare correttamente la sezione dei Riferimenti' , 'Attenzione' , 1 , 400 , 300 );
      return -1;
  		
  	}	
  	
  	
		  

	
}

function CheckData( FieldData , Riferimento , msgVuoto , msgMinoreRif )
{
    if( getObjValue( FieldData ) == '' )
    {
 	    DocShowFolder( 'FLD_COPERTINA' );	   
  		tdoc();
        try{ getObj( FieldData + '_V' ).focus(); }catch( e ) {};
        DMessageBox( '../' , msgVuoto , 'Attenzione' , 1 , 400 , 300 );
        return -1;       
	}

    if( getObjValue( FieldData ) <= Riferimento )
    {
 	    DocShowFolder( 'FLD_COPERTINA' );	   
  		tdoc();
        try{ getObj( FieldData + '_V' ).focus(); }catch( e ){};
        DMessageBox( '../' , msgMinoreRif , 'Attenzione' , 1 , 400 , 300 );
        return -1;       
    }
    
    return 0;
}


function DownLoadCSV_ANALISI()
{

    var TipoBando = getObjValue( 'TipoBando' );
    
    if ( TipoBando == '' )
    {
      alert( CNV( '../','E\' necessario selezionare prima il modello'));
      return ;
    }
   
   
    ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + getObjValue('IDDOC') + '&VIEW=DOCUMENT_PROGRAMMAZIONE_DETTAGLI&HIDECOL=&TIPODOC=BANDO_PROGRAMMAZIONE&MODEL=MODELLO_BASE_PROGRAMMAZIONE_' + TipoBando + '_Prog_Analisi&HIDECOL=ESITORIGA'  , '_blank' ,'');
    
}

function UploadsCSV_ANALISI( obj )
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
        ImportExcel( 'CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,BANDO_PROGRAMMAZIONE&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#400,300' );
}




function PrintAndSend(param)
{

	
	
    if( ControlliSend( param ) == -1 ) return -1;

	ShowWorkInProgress(true);
	
	ToPrint(param);
}




function AddProdotto( )
{
	var strCommand = 'PRODOTTI#ADDFROM#IDROW=' + getObjValue( 'IDDOC' ) + '&TABLEFROMADD=DOCUMENT_ADD_PRODOTTO' 

    ExecDocCommand( strCommand );
	
}

function UpdateModelloBando()
{

    var TipoBando = getObjValue( 'TipoBando' );
	var cod=getObjValue( 'id_modello' );
    var docReadonly = getObjValue( 'DOCUMENT_READONLY' );
	
    if ( TipoBando == '' || cod == '' )
    {
      DMessageBox( '../' , 'E\' necessario selezionare prima il modello' , 'Attenzione' , 1 , 400 , 300 );
	  return;
    }	
	
	//Se il documento non è readonly l'apertura del documento CONFIG_MODELLI_FABBISOGNI la posticipiamo al reload del documento, nell'after process
	if ( docReadonly == '1' )
		ShowDocumentPath( 'CONFIG_MODELLI_FABBISOGNI' , cod ,'../');
	else
		ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');

}

function afterProcess( param )
{
	if ( param == 'FITTIZIO' )
    {
		var cod=getObjValue( 'id_modello' );
		ShowDocumentPath( 'CONFIG_MODELLI_FABBISOGNI' , cod ,'../');
	}
}


