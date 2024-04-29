
function afterProcess( param )
{
    
    //ricarico sezione dettaglio documento padre
    ExecDocCommandInMem( 'PRODOTTI#RELOAD', getObj('ID_FROM').value, 'BANDO_ELIMINA_LOTTO');

}



