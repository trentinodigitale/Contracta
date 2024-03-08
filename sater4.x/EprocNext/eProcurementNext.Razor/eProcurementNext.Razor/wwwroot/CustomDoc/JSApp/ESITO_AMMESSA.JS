/*
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

*/

//chiamata dopo il successo di un processo
function afterProcess(){
  
  /*	non serve più chiamare la RELOAD. la sezione OFFERTE non c'è più sul tipodoc PDA_MICROLOTTI ed è stata spostata
			su un documento-sezione readonly che quindi prenderà sempre i dati dal db
  var IdDocPDA = getObj('idPdA').value ;
  ExecDocCommandInMem( 'OFFERTE#RELOAD', IdDocPDA, 'PDA_MICROLOTTI');
	*/
}     
    

 