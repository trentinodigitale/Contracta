function DownLoadCSV( param )
{

    var Tipomod = getObjValue( 'Modello' );
	var iddoc = getObj('IDDOC').value;
	var filtroEffettuato;
	var URL;
	
	  
    
	URL = '../../Report/CSV_LOTTI.asp?IDDOC=' + iddoc + '&GENERAFOGLIODOMINI=yes&TIPODOC=CATALOGO_MEA&HIDECOL=TipoDoc,StatoRiga,ESITORIGA&MODEL=' + Tipomod;

	if ( param != '' )
	{
		URL = URL.replace( param , '' );
		
	}
	
	ExecFunction( URL , '_blank' ,'');
}

function OnClickProdotti( obj )
{
     var Tipomod = getObjValue( 'Modello' );
    
    
    var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;
    
    if ( DOCUMENT_READONLY == "1"  )
        DMessageBox( '../' , 'Documento in sola lettura' , 'Attenzione' , 1 , 400 , 300 );
    else
        ImportExcel( 'CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,CATALOGO_MEA&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#600,450');
}
