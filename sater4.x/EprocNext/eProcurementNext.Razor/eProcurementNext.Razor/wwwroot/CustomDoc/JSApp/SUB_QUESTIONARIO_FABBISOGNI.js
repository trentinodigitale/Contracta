function DownLoadCSV()
{

    var TipoBando = getObjValue( 'TipoBando' );
    
    if ( TipoBando == '' )
    {
      alert( CNV( '../','E\' necessario selezionare prima il modello'));
      return ;
    }
   
    ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + getObjValue('IDDOC') + '&TIPODOC=SUB_QUESTIONARIO_FABBISOGNI&MODEL=MODELLO_BASE_FABBISOGNI_' + TipoBando + '_Fabb_Questionario&HIDECOL=ESITORIGA'  , '_blank' ,'');
    
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

function DownLoadCSV_Raccolta()
{

    var TipoBando = getObjValue( 'TipoBando' );
    
    if ( TipoBando == '' )
    {
      alert( CNV( '../','E\' necessario selezionare prima il modello'));
      return ;
    }
   
    ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + getObjValue('LinkedDoc') + '&TIPODOC=QUESTIONARIO_FABBISOGNI&MODEL=MODELLO_BASE_FABBISOGNI_' + TipoBando + '_Fabb_Questionario&HIDECOL=ESITORIGA'  , '_blank' ,'');
    
}