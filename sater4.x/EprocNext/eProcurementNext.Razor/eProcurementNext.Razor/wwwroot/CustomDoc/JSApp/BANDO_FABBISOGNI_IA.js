


function DownLoadCSV()
{

    var TipoBando = getObjValue( 'TipoBando' );
    
    if ( TipoBando == '' )
    {
      alert( CNV( '../','E\' necessario selezionare prima il modello'));
      return ;
    }
   
    ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + getObjValue('VersioneLinkedDoc') + '&TIPODOC=BANDO_FABBISOGNI&MODEL=MODELLO_BASE_FABBISOGNI_' + TipoBando + '_Fabb_Richiesta&HIDECOL=ESITORIGA'  , '_blank' ,'');
    
}




function UpdateModelloBando()
{

    var TipoBando = getObjValue( 'TipoBando' );
	var cod=getObjValue( 'id_modello' );
    
    if ( TipoBando == '' || cod == '' )
    {
      DMessageBox( '../' , 'E\' necessario selezionare prima il modello' , 'Attenzione' , 1 , 400 , 300 );
	  return;
    }	
	ShowDocumentPath( 'CONFIG_MODELLI_FABBISOGNI' , cod ,'../');  
    
}




