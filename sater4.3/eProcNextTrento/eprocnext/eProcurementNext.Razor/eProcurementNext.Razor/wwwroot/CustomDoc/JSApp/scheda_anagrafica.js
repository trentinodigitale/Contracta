window.onload = Onload_Page;

function Onload_Page()
{
	
	try{
        var i = 0;		
			for( i=0; i < CLASSEISCRIZGrid_EndRow+1 ; i++ )
			{
				if( getObj( 'RCLASSEISCRIZGrid_' + i + '_FNZ_OPEN' ).innerHTML.indexOf('NO_Lente.gif') >= 0 )
				{
					
					getObj( 'RCLASSEISCRIZGrid_' + i + '_FNZ_OPEN' ).innerHTML = '';
				}
			}		
	}catch(e){}

}


function MyMakeDocFrom( objGrid , Row , c ){

 
  //-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
  
   //alert(cod);
  
	var strDoc = '';
	
	try	{ 	strDoc = getObj( 'R'+ objGrid + '_' + Row + '_OPEN_DOC_NAME').value;	}catch( e ) {};
	
	if ( strDoc == '' || strDoc == undefined )
	{
		try	{ 	strDoc = getObj( 'R' + objGrid + '_' + Row + '_OPEN_DOC_NAME')[0].value; }catch( e ) {};
	}
	
	if ( strDoc == '' || strDoc == undefined ) 
	{
		alert( 'Errore tecnico - ' +  'R' + objGrid + '_' + Row + '_OPEN_DOC_NAME - non trovato' );
		return;
	}
	
	var TYPEDOC = '';
	
	try	{ 	TYPEDOC = getObj( 'R' + objGrid + '_'  + Row + '_MAKE_DOC_NAME').value;	}catch( e ) {};
	
	if ( TYPEDOC == '' || TYPEDOC == undefined )
	{
		try	{ 	TYPEDOC = getObj( 'R' + objGrid + '_' + Row + '_MAKE_DOC_NAME')[0].value; }catch( e ) {};
	}
	
	if ( TYPEDOC == '' || TYPEDOC == undefined ) 
	{
		alert( 'Errore tecnico - ' +  'R' + objGrid + '_' + Row + '_MAKE_DOC_NAME - non trovato' );
		return;
	}

	var param='';
      
    param =  TYPEDOC + '##' +  strDoc + '#' + cod + '#' ;
	
    MakeDocFrom ( param ) ;
    
    
  }
  

//--Versione=1&data=2012-06-11&Attvita=38536&Nominativo=Francesco
function Open_Cronologia (objGrid , Row , c)
{


ExecFunctionCenter( '../../DASHBOARD/Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_DOCUMENTAZIONE_AZIENDA_STORICO&IDENTITY=&DOCUMENT=,' + Row + '&PATHTOOLBAR=../CustomDoc/&JSCRIPT=AZI_DOCUMENTAZIONE&AreaAdd=no&Caption=Cronologia Documento&Height=0,100*,210&numRowForPag=20&Sort=DataEmissione&SortOrder=Desc&Exit=si&AreaFiltro=no&FilterHide=IdChainDocStory=' + getObj('R'+Row+'_idChainDocStory').value+'##800,600' );
	
}

