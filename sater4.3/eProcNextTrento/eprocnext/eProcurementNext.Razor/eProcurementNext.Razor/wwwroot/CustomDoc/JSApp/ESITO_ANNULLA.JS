function TESTATA_OnLoad()
{
    //-- se il documento è stato confermato aggiorno il chiamante e chiudo la finestra
    var val_StatoFunzionale = getObjValue( 'val_StatoFunzionale' );
    var idRow;
    
    if ( val_StatoFunzionale  == 'Confermato' )
    {
    
        opener.ExecDocCommand( 'OFFERTE#Reload#' );

        self.close();
    }
}
    
    
