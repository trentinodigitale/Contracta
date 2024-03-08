
function DownLoadCSV()
{

    var TipoBando = getObjValue( 'TipoBando' );
    
    if ( TipoBando == '' )
    {
      alert( CNV( '../','E\' necessario selezionare prima il modello'));
      return ;
    }
   
    ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + getObjValue('IDDOC') + '&VIEW=ANALISI_FABBISOGNI_DOWNLOAD_CSV_VIEW&HIDECOL=Aggiudicata&TIPODOC=ANALISI_FABBISOGNI&MODEL=MODELLO_BASE_FABBISOGNI_' + TipoBando + '_Fabb_AnalisiDettaglio'  , '_blank' ,'');
    
}


function UpLoadCSV()
{
 
    var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;
    if ( DOCUMENT_READONLY == "1" )
        DMessageBox( '../' , 'Documento in sola lettura' , 'Attenzione' , 1 , 400 , 300 );
    else
        ImportExcel( 'CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,ANALISI_FABBISOGNI&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#400,300' );

	
}

function MYOpenDocumentColumn( objGrid , Row , c )
{
	
	IDDOC = GetIdRow( objGrid , Row , 'self' );	
	//RICARICA IL DOCUMENTO DAL DB
	ReloadDocFromDB( IDDOC , 'ANALISI_FABBISOGNO_DETTAGLIO' );
	
	OpenDocumentColumn( objGrid , Row , c );
	

}

function DownLoadXLSX()
{
	var TipoBando = getObjValue( 'TipoBando' );

    if ( TipoBando == '' )
    {
      alert( CNV( '../','E\' necessario selezionare prima il modello'));
      return ;
    }
    ExecFunction('../../Report/fab_q.aspx?IDDOC=' + getObjValue('IDDOC'), '_blank' ,'');
}