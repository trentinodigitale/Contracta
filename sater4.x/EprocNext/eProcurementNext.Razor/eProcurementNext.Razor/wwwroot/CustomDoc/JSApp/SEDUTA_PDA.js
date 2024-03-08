window.onload = init;

function init()
{
	rimuovilente();
	
	var DOCUMENT_READONLY = '0';
	DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	if (DOCUMENT_READONLY == 0)
	{
		//inizializzo jumpocheck con guid verbale selezionato
		for ( i = 0 ; i <= VERBALEGrid_NumRow ; i++ )
		{
			
			if ( getObj( 'RVERBALEGrid_' + i + '_SelRow' ).checked == true )
				 
				getObj( 'JumpCheck' ).value = getObjValue( 'RVERBALEGrid_' + i + '_guid' ); 
				break;
		}
		
	}
	
	
		
}

function Crea_Verbale_Seduta()
{
    var IDSEDUTA = getObjValue( 'guid' );

    var IDTEMPLATE = getObj( 'JumpCheck' ).value;
    
    //recupero info PDA 
 		var IDDOC = getObj( 'LinkedDoc' ).value; //getObj( 'IDDOC' ).value;
		var TYPEDOC = 'PDA_MICROLOTTI'; //getObj( 'TYPEDOC' ).value;
    
    ExecFunctionSelf( '../../customdoc/Crea_Verbale_Seduta.asp?IDDOC='+ IDDOC + '&TYPEDOC='+ TYPEDOC + '&IDSEDUTA=' + escape( IDSEDUTA ) + '&IDTEMPLATE=' + escape( IDTEMPLATE ) + '#VerbaleSeduta' )

}

function SelezioneSingola( obj )
{

	r=obj.id.split('_')[1];
    
	for ( i = 0 ; i <= VERBALEGrid_NumRow ; i++ )
    {
        getObj( 'RVERBALEGrid_' + i + '_SelRow' ).checked = false;
    }
	
    getObj( 'RVERBALEGrid_' + r + '_SelRow' ).checked = true;
    getObj( 'JumpCheck' ).value = getObjValue( 'RVERBALEGrid_' + r + '_guid' ); 
	return false;
}

function RefreshContent()
{
    RefreshDocument('');

    //--opener.ExecDocCommand( 'SEDUTE#RELOAD' );
	//--opener.ShowLoading( 'SEDUTE' );

    
}

function My_OpenDocument( objGrid , Row , c )
{
	var cod;
	var nq;

	var strDoc = '';
	
	try	{ 	strDoc = getObj( 'R' + objGrid + '_' + Row + '_OPEN_DOC_NAME').value;	}catch( e ) {};
	
	if ( strDoc == '' || strDoc == undefined )
	{	
		try	{ 	strDoc = getObj( 'R' + Row + '_OPEN_DOC_NAME').value;	}catch( e ) {};
	}
	
	if ( strDoc == '' || strDoc == undefined )
	{
		try	{ 	strDoc = getObj( 'R' + Row + '_OPEN_DOC_NAME')[0].value; }catch( e ) {};
	}
	
	if ( strDoc == 'VERBALEGARA'  ) 
	{
		//-- recupero ID DEL VERBALE DA APRIRE
		try	{ 	cod = getObj( 'R' + objGrid + '_' + Row + '_idRow').value;	}catch( e ) {};
	
		if ( cod == '' || cod == undefined )
		{	
			try	{ 	cod = getObj( 'R' + Row + '_idRow').value;	}catch( e ) {};
		}
		
		if ( cod == '' || cod == undefined )
		{
			try	{ 	cod = getObj( 'R' + Row + '_idRow')[0].value; }catch( e ) {};
		}
	
		ShowDocument( strDoc , cod );
	}	
	
}


function ELENCO_VERBALI_AFTER_COMMAND() 
{
    rimuovilente();  

}


function rimuovilente()
{
  // rimuove la funzione di onclick quando non esiste il questionario
  var onclick = '';
  var numeroRighe0 = GetProperty( getObj('ELENCO_VERBALIGrid') , 'numrow');
	if(  Number( numeroRighe0 ) >= 0 )
	{
		for( i = 0 ; i <= numeroRighe0 ; i++ )
		{
		 try{     
		 
				if (getObjValue('RELENCO_VERBALIGrid_' + i + '_idRow') == '') 
				{					
					getObj( 'RELENCO_VERBALIGrid_' + i + '_FNZ_OPEN' ).innerHTML = '';
					getObj( 'ELENCO_VERBALIGrid_' + i + '_FNZ_OPEN' ).style.cursor= 'default';					
				}
			}
		  catch(e){};
		}
	}
}
