                                          
function CreateRilancioCompetitivo( objGrid , Row , c )
{
	var cod;
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );

    
	MakeDocFrom( 'NUOVO_RILANCIO_COMPETITIVO##BANDO_AQ#' + cod + '#');
    
}
