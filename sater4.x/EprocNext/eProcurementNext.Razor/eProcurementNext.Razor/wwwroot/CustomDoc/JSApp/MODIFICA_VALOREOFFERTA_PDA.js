function TESTATA_OnLoad()
{
    //-- se il documento è stato confermato aggiorno il chiamante e chiudo la finestra
    var val_StatoFunzionale = getObjValue( 'val_StatoFunzionale' );
    var idRow;
    var strValueProcess ; 
    
    strValueProcess = getQSParam ('PROCESS_PARAM');
    
    if ( val_StatoFunzionale  == 'Confermato' && strValueProcess == 'CONFERMA,MODIFICA_VALOREOFFERTA_PDA' )
    {
      //chiamo pagina per aggiornare griglia in sessione
      self.location='../../AFLCommon/FolderGeneric/Command/Evaluate/Modifica_ValoreOfferta_Pda.asp?OPERATION=UPDATE&IDDOC=' + getObj('IDDOC').value 
        
    }
}