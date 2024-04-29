 window.onload = HideCol_Apri; 
 function HideCol_Apri()
{
	ShowCol( 'PRODOTTI' , 'FNZ_OPEN' , 'none' );    
}
 function PRODOTTI_AFTER_COMMAND()
{
    HideCol_Apri();
}

function PRODOTTI_OnLoad()
{
    HideCol_Apri();
}


function OnChangeAmbito()
{
	            
	if (getObjValue( 'TipoBando' ) != '' )
	{
		alert( CNV( '../','Il cambio dell\'ambito comporta un azzeramento del modello dei prodotti'));

        ExecDocProcess( 'ADD_MODELLO_PRODOTTI,RICHIESTA_CODIFICA_PRODOTTI');

	}
	else
	{
        ExecDocProcess( 'ADD_MODELLO_PRODOTTI,RICHIESTA_CODIFICA_PRODOTTI');
	}
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
        ImportExcel( 'CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,RICHIESTA_CODIFICA_PRODOTTI&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#400,300' );
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
   
    ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + getObjValue('IDDOC') + '&HIDECOL=StatoRiga,ToDelete&TIPODOC=RICHIESTA_CODIFICA_PRODOTTI&MODEL=MODELLO_BASE_CODIFICA_PRODOTTI_' + TipoBando + '_MOD_Macro_Prodotto&HIDECOL=ESITORIGA'  , '_blank' ,'');
    
}



function AddProdotto( )
{

	var strCommand = 'PRODOTTI#ADDFROM#IDROW=' + getObjValue( 'IDDOC' ) + '&TABLEFROMADD=DOCUMENT_ADD_PRODOTTO' 

    ExecDocCommand( strCommand );
	
}


function MyDeleteArticolo(objGrid, Row, c) {

    //setto statoriga a deleted sulla riga

    //getObj('R' + Row + '_StatoRiga').value = 'deleted';

    DettagliDel ( objGrid , Row , c );


}

