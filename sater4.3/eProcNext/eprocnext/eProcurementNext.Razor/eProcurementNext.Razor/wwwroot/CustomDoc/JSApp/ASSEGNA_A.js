function afterProcess()
{
	/* Funzione che viene chiamata dopo l'esecuzione di un processo e permette il refresh in memoria del documento chiamante
		recuperato grazie a LinkedDoc + VersioneLinkedDoc */

	var linkedDoc = getObjValue('LinkedDoc');
	var tipoDocChiamante = getObjValue('VersioneLinkedDoc');

  //ReloadDocFromDB( linkedDoc , tipoDocChiamante ) ;
   //se sto nel bandocentrico oppure versione accessibile ricarico il documento sorgente dal db in un frame nascosto
   if ( isSingleWin() || eval( 'BrowseInPage' ) == 1)
		ReloadDocFromDB( linkedDoc , tipoDocChiamante ) ;	
   else
		opener.RefreshDocument('');   	
  
}

window.onload=onloaddoc;

function onloaddoc()
{
	
	var linkedDoc = getObjValue('LinkedDoc');
	var iddoc = getObj('IDDOC').value; 
	var tipoDocChiamante = getObjValue('VersioneLinkedDoc');
	
	//solo per il documento di REVOCA BANDO filtra il dominio degli utenti con gli idpfu di riferimenti e RUP
	if ( tipoDocChiamante == 'REVOCA_BANDO' || tipoDocChiamante == 'RETTIFICA_BANDO' || tipoDocChiamante == 'PROROGA_BANDO')
	{
	  var filter =  'SQL_WHERE= idpfu in ( select idpfu  from VIEW_IDPFU_ASSEGNA_A where id = \'' + linkedDoc +  '\')';

		try
		{
			if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' || iddoc.substr(0,3) == 'new'  )
			{
				FilterDom( 'IdpfuInCharge' , 'IdpfuInCharge' , getObjValue('IdpfuInCharge') , filter ,'', '');
			}
		}catch( e ) {};
	
	}
	if ( tipoDocChiamante == 'ANALISI_FABBISOGNI' )
	{
		var filter =  'SQL_WHERE= idpfu in ( select idpfu from profiliutente where pfuidazi = ( select pfuidazi from profiliUtente where idpfu = <ID_USER> )) and  idpfu in ( select idpfu  from profiliUtenteAttrib where dztnome=\'Profilo\' and Attvalue=\'FabbGestione\')';
		try
		{
			if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' || iddoc.substr(0,3) == 'new'  )
			{
				FilterDom( 'IdpfuInCharge' , 'IdpfuInCharge' , getObjValue('IdpfuInCharge') , filter ,'', '');
			}
		}catch( e ) {};
	}
	if ( tipoDocChiamante == 'BANDO_FABBISOGNI' )
	{
		var filter =  'SQL_WHERE= idpfu in ( select idpfu from profiliutente where pfuidazi = ( select pfuidazi from profiliUtente where idpfu = <ID_USER> )) and idpfu in ( select idpfu  from profiliUtenteAttrib where dztnome=\'Profilo\' and Attvalue=\'FabbGestione\')';
		try
		{
			if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' || iddoc.substr(0,3) == 'new'  )
			{
				FilterDom( 'IdpfuInCharge' , 'IdpfuInCharge' , getObjValue('IdpfuInCharge') , filter ,'', '');
			}
		}catch( e ) {};
	}
	if ( tipoDocChiamante == 'QUESTIONARIO_FABBISOGNI' )
	{
		var filter =  'SQL_WHERE= idpfu in ( select idpfu from profiliutente where pfuidazi = ( select pfuidazi from profiliUtente where idpfu = <ID_USER> )) and idpfu in ( select idpfu  from profiliUtenteAttrib where dztnome=\'Profilo\' and Attvalue=\'FabbOperativo\')';
		try
		{
			if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' || iddoc.substr(0,3) == 'new'  )
			{
				FilterDom( 'IdpfuInCharge' , 'IdpfuInCharge' , getObjValue('IdpfuInCharge') , filter ,'', '');
			}
		}catch( e ) {};
	}
	if ( tipoDocChiamante == 'RICHIESTA_CODIFICA_PRODOTTI' || tipoDocChiamante == 'CODIFICA_PRODOTTI')
	{
		var filter =  'SQL_WHERE= idpfu in ( select idpfu from profiliutente where pfuidazi = ( select pfuidazi from profiliUtente where idpfu = <ID_USER> )) and idpfu in ( select idpfu  from profiliUtenteAttrib where dztnome=\'Profilo\' and Attvalue=\'Gest_ric_cod_p\')';
		try
		{
			if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' || iddoc.substr(0,3) == 'new'  )
			{
				FilterDom( 'IdpfuInCharge' , 'IdpfuInCharge' , getObjValue('IdpfuInCharge') , filter ,'', '');
			}
		}catch( e ) {};
	}
	if ( tipoDocChiamante == 'COMMISSIONE_PDA' )
	{
		 var filter =  'SQL_WHERE= idpfu in ( select idpfu  from VIEW_IDPFU_ASSEGNA_A_COMMISSIONE_PDA where id = \'' + linkedDoc +  '\')';
		try
		{
			if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' || iddoc.substr(0,3) == 'new'  )
			{
				FilterDom( 'IdpfuInCharge' , 'IdpfuInCharge' , getObjValue('IdpfuInCharge') , filter ,'', '');
			}
		}catch( e ) {};
	}
	
	if ( tipoDocChiamante == 'NOTIER_DDT' )
	{
		var filter =  'SQL_WHERE= idpfu in ( select idpfu from profiliutente where pfuidazi = ( select pfuidazi from profiliUtente where idpfu = <ID_USER> )) and idpfu in ( select idpfu from profiliUtenteAttrib where dztnome=\'Profilo\' and Attvalue in ( \'NoTIER-PA\',\'notier\',\'NoTIER-PA\',\'NoTI-ER_FATTURE\',\'NoTIER-responsabile-peppol\'))';

		try
		{
			if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' || iddoc.substr(0,3) == 'new'  )
			{
				FilterDom( 'IdpfuInCharge' , 'IdpfuInCharge' , getObjValue('IdpfuInCharge') , filter ,'', '');
			}
		}
		catch( e )
		{
		}
	}

	if ( tipoDocChiamante == 'BANDO_GARA' || tipoDocChiamante == 'BANDO_SEMPLIFICATO' )
	{
		 var filter =  'SQL_WHERE= idpfu in ( select idpfu  from VIEW_IDPFU_ASSEGNA_A_RIFERIMENTI_RUP_GARA where id = \'' + linkedDoc +  '\')';
		try
		{
			if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' || iddoc.substr(0,3) == 'new'  )
			{
				FilterDom( 'IdpfuInCharge' , 'IdpfuInCharge' , getObjValue('IdpfuInCharge') , filter ,'', '');
			}
		}catch( e ) {};
	}
	
	if ( tipoDocChiamante == 'CONFIG_MODELLI_LOTTI' )
	{
		var filter =  'SQL_WHERE= idpfu in ( select idpfu  from VIEW_IDPFU_ASSEGNA_A_CONFIG_MODELLI_LOTTI where id = \'' + linkedDoc +  '\')';		

		try
		{
			if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' || iddoc.substr(0,3) == 'new'  )
			{
				FilterDom( 'IdpfuInCharge' , 'IdpfuInCharge' , getObjValue('IdpfuInCharge') , filter ,'', '');
			}
		}
		catch( e )
		{
		}
	}
	//gli utenti utili sono i membri della commissione ed i riferimenti (Inviti) del bando
	if ( tipoDocChiamante == 'VERBALEGARA' )
	{
		 var filter =  'SQL_WHERE= idpfu in ( select idpfu  from VIEW_IDPFU_ASSEGNA_A_VERBALGARA where id = \'' + linkedDoc +  '\')';

		try
		{
			if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' || iddoc.substr(0,3) == 'new'  )
			{
				FilterDom( 'IdpfuInCharge' , 'IdpfuInCharge' , getObjValue('IdpfuInCharge') , filter ,'', '');
			}
		}
		catch( e )
		{
		}
	}
	//gli utenti utili sono quelli che hanno il profilo PROG_Gestione
	if ( tipoDocChiamante == 'BANDO_PROGRAMMAZIONE' )
	{
		
		var filter =  'SQL_WHERE= idpfu in ( select idpfu from profiliutente where pfuidazi = ( select pfuidazi from profiliUtente where idpfu = <ID_USER> )) and idpfu in ( select idpfu  from profiliUtenteAttrib where dztnome=\'Profilo\' and Attvalue=\'PROG_Gestione\')';
		try
		{
			if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' || iddoc.substr(0,3) == 'new'  )
			{
				FilterDom( 'IdpfuInCharge' , 'IdpfuInCharge' , getObjValue('IdpfuInCharge') , filter ,'', '');
			}
		}
		catch( e )
		{
		}
	}
	
	if ( tipoDocChiamante == 'QUESTIONARIO_PROGRAMMAZIONE' )
	{
		var filter =  'SQL_WHERE= idpfu in ( select idpfu from profiliutente where pfuidazi = ( select pfuidazi from profiliUtente where idpfu = <ID_USER> )) and idpfu in ( select idpfu  from profiliUtenteAttrib where dztnome=\'Profilo\' and Attvalue=\'PROG_Operativo\')';
		try
		{
			if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' || iddoc.substr(0,3) == 'new'  )
			{
				FilterDom( 'IdpfuInCharge' , 'IdpfuInCharge' , getObjValue('IdpfuInCharge') , filter ,'', '');
			}
		}catch( e ) {};
	}
	
	//gli utenti utili sono i riferimenti (quesiti) del bando -- commento
	if ( tipoDocChiamante == 'DETAIL_CHIARIMENTI_BANDO' )
	{
	  var filter =  'SQL_WHERE= idpfu in ( select idpfu  from VIEW_IDPFU_ASSEGNA_A_QUESITI where id = \'' + linkedDoc +  '\')';

		try
		{
			if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' || iddoc.substr(0,3) == 'new'  )
			{
				FilterDom( 'IdpfuInCharge' , 'IdpfuInCharge' , getObjValue('IdpfuInCharge') , filter ,'', '');
			}
		}catch( e ) {};
	
	}
	

}