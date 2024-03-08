
$( document ).ready(function() {
    OnLoadPage();
});


function OnLoadPage() 
{
	FiltraTipoVerbale();
}
function DETTAGLI_AFTER_COMMAND( param )
{
     //CloseRTE();
     var NumRow = GetProperty(getObj('DETTAGLIGrid'),'numrow');
     for ( nIndRrow=0; nIndRrow <= NumRow; nIndRrow++){	
      
        
        $('#R' + nIndRrow + '_DescrizioneEstesa').rte("", "../images/toolbar/");
      }
}

function Scegli_Verbale_PDA ( objGrid , Row , c )
{
	
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );	
	IDDOC=getQSParam('DOC_START');
	TYPEDOC=getQSParam('TYPEDOC_START');
	param='ctl_library/Document/MakeDocFrom.asp?TYPE_TO=VERBALEGARA&IDDOC=' + IDDOC +'&TYPEDOC=' + TYPEDOC + '&BUFFER=' + cod;		
	
	opener.location= '../ctl_library/path.asp?KEY=document&url=' + encodeURIComponent(param  + '&lo=base' ) ;
	self.close();
}


function FiltraTipoVerbale( obj )
{
		
	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	var strTipoSorgente = getObjValue('TipoSorgente');
	var strFilter = 'SQL_WHERE= 1 = 1 ';
	
	if (DOCUMENT_READONLY == '0')
	{
		if ( strTipoSorgente == '120' || strTipoSorgente == '2')
		{	
			//alert(strTipoSorgente);
			strFilter = 'SQL_WHERE=  DMV_Father = \'' + strTipoSorgente + '\' ';
			//FilterDom('TipoVerbale', 'TipoBandoScelta', getObjValue('RTESTATA_PRODOTTI_MODEL_TipoBandoScelta'), filter, 'TESTATA_PRODOTTI_MODEL', 'OnChangeModello( this );');
		}
		
		FilterDom( 'TipoVerbale' ,  'TipoVerbale' , getObjValue('TipoVerbale') , strFilter , '' , ''); 
		
	}
}