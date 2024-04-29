function MakeDocFromExtended( objGrid , Row , c )
{
	var cod;
	var nq;

	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
  
	//-- invoca la creazioen del documento, il codice arriverà nel buffer
	MakeDocFrom( 'CATALOGO_MEA##MODELLO#-1###' + cod);
	
}