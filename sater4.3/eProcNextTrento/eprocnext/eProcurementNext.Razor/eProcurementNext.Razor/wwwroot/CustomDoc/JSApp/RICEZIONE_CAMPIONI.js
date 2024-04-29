//chiamata dopo il successo di un processo
function afterProcess(){
  
  var IdDocPDA = getObj('idDoc').value ;
  ExecDocCommandInMem( 'OFFERTE#RELOAD', IdDocPDA, 'PDA_MICROLOTTI');

}  