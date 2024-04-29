//window.onload = OnLoadPage; 
$( document ).ready(function() {
    OnLoadPage();
});



function OnLoadPage()
{
	
	
	var DOCUMENT_READONLY = '0';
	
	try
	{
		DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	}
	catch(e)
	{
		
	}
	
	if (DOCUMENT_READONLY == '0' ) 
	{ 
			
		//filtro i riferimenti se ci sono referenti tecnici
		try{
			FilterRiferimenti();
			
		}catch(e){}
		
	}

}

function RIFERIMENTI_AFTER_COMMAND( param )
{
  FilterRiferimenti();
  
}



function FilterRiferimenti(){
	
	
	var filterUser = '';	
	var i;
	var numrighe=GetProperty( getObj('RIFERIMENTIGrid') , 'numrow');
	
	//filterUser = 'SQL_WHERE= idpfu in ( select idpfu from RiferimentiForBando where DOC_ID = \'BANDO_GARA\'  and  OWNER = <ID_USER> )';
	
	
	try
	{
		
		for( i = 0 ; i < numrighe+1 ; i++ )
		{
			

			try
			{
				//AGGIUNGO IL FILTRO QUANDO LA RIGA E' ReferenteTecnico per mostrare  gli utenti con il profilo di ReferenteTecnico di tutte le aziende
				if ( getObjValue( 'RRIFERIMENTIGrid_' + i + '_RuoloRiferimenti' ) == 'ReferenteTecnico' )
				{
					filterUser = 'SQL_WHERE= idpfu in ( select ID_FROM from USER_DOC_PROFILI_FROM_UTENTI where profilo =\'Referente_Tecnico\' )';
					FilterDom(  'RRIFERIMENTIGrid_' + i + '_IdPfu' , 'IdPfu' , getObjValue( 'val_RRIFERIMENTIGrid_' + i + '_IdPfu' ), filterUser , 'RIFERIMENTIGrid_' + i  , 'HandlePresenzaListinoOrdini(this)')
				}
				/*
				else
				{				
					filterUser = 'SQL_WHERE= idpfu in ( select idpfu from RiferimentiForBando where DOC_ID = \'BANDO_GARA\'  and  OWNER = <ID_USER> )';
				}
				*/
				
			}
			catch(e)
			{
			}

		}
		
	}catch(e){};

}
