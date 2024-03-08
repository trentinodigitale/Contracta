
function CreateDocOrdineForCarrelloRicambi( param )
{

	//-- per questo comando il param deve essere:
	//-- sottotipo;idmodello attributi da aggiungere; posizione sezione  prodotto, nome sezione prodotto; nome area griglia; 1 per apreire il documento 2 per inviare direttamente;
	//-- colonne del carrello deparate da, ; colonne del modello deparate da ,
	//-- 4;391;2;0;Prodotti;1;BskQT,BskCodArt,BskDescrizione;QMOArticolo,Codice Articolo,Descrizione Articolo
	
	
	//debugger;

	var objFormCarrello;
		
	//-- recupero il form del carrello
	objFormCarrello = getObj( 'FormCarrello' );

	//-- cambio l'action
	objFormCarrello.action= 'Carrello.ASP?' +  'CREATEORDER=NEW&PARAM=' + param;
		
	//-- chiamo il submit
	objFormCarrello.submit();
	

}

