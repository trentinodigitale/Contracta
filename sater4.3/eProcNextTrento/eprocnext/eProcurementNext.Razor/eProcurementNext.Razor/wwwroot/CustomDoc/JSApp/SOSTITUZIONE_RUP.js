
window.onload=onloaddoc;

function onloaddoc()
{
	
	var tipoDocChiamante = getObjValue('JumpCheck');
	
	//PER UNA SOSTITUZIONE RUP relativa ad un BANDO_SEMPLIFICATO oppure BANDO_GARA posso selezionare solo utenti che hanno il ruolo RUP_PDG
	if ( tipoDocChiamante == 'BANDO_SEMPLIFICATO' || tipoDocChiamante == 'BANDO_GARA' || tipoDocChiamante == 'BANDO_CONCORSO' )
	{
		 var filter =  'SQL_WHERE= dmv_cod in (Select DMV_COD from ELENCO_RESPONSABILI_AZI  where idpfu =  <ID_USER> and RUOLO in (\'RUP_PDG\') )'
	
	}
	//PER UNA SOSTITUZIONE RUP relativa ad un BANDO_RDO posso selezionare solo utenti che hanno il ruolo PO, RUP
	if ( tipoDocChiamante == 'BANDO_RDO' )
	{
		var filter =  'SQL_WHERE= dmv_cod in (Select DMV_COD from ELENCO_RESPONSABILI_AZI  where idpfu =  <ID_USER> and RUOLO in (\'PO\',\'RUP\') )'
	}
	
	FilterDom( 'UserRUP' , 'UserRUP' , getObjValue('UserRUP') , filter ,'', '');
	
}
