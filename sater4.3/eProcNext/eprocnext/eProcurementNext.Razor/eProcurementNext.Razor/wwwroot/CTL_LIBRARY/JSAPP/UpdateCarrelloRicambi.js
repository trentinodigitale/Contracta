
function UpdateCarrelloRicambi()
{

	
	//debugger;

	var objFormCarrello;
		
	//-- recupero il form del carrello
	objFormCarrello = getObj( 'FormCarrello' );

	//-- cambio l'action
	objFormCarrello.action= 'Carrello.ASP?UPDATECARRELLO=YES';
		
	//-- chiamo il submit
	objFormCarrello.submit();
	

}

