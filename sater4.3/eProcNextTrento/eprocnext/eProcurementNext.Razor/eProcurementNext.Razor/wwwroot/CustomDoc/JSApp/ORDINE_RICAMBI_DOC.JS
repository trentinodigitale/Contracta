//-- invocata dalla griglia per rimuovere un articolo
function RicambiDelFromGrid( grid , r , c )
{
	sec = 'CUSTOMSECTION';
	ExecDocCommand( sec + '#DELETE_ROW#' + 'IDROW=' + r );
}


function TESTATA_OnLoad(){
		
	//bisogna includere uno script sul documento ordine ricambi
	//nascondo il totale se il documento è fuori listino e se nello stato nuovo oppure salvato
	if (getObj('val_Stato') != undefined){
		if  (  getObj( 'val_FuoriListino').value == 'si' && getObj('val_Stato').value != 'Variato' && getObj('val_Stato').value != 'Sended'  ) {
			
			getObj( 'Total_V').style.display='none';
			getObj( 'cap_Total').style.display='none';
			objParent=getObj( 'Total_V').parentElement;
			objParent.style.display='none';
		}
	}else{
		if  (  getObj( 'val_FuoriListino').value == 'si' ){
			getObj( 'Total_V').style.display='none';
			getObj( 'cap_Total').style.display='none';
			objParent=getObj( 'Total_V').parentElement;
			objParent.style.display='none';
		}
		
	}
		
}