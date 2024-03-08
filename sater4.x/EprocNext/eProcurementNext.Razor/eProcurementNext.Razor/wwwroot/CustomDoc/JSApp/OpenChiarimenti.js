

function OpenChiarimenti( objGrid , Row , c )
{
	var altro;
	var cod;
	var nq;
	var w;
	var h;
	var Left;
	var Top;

	idRow=prendiElementoDaId('GridViewer_idRow_' + Row).value;
	
	documento = 'CHIARIMENTI_PORTALE';
	docfrom = 'BANDI';
  
	w = screen.availWidth * 0.9;
	h = screen.availHeight  * 0.9;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
	
	ExecFunction(  '../CTL_Library/Document/document.asp?JScript=' + documento + '&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow , documento + '_DOC_createfrom' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );	
}




function OpenDettaglio( objGrid , Row , c )
{
	var altro;
	var cod;
	var nq;
	
    
	var strDoc='';
	try { strDoc = getObj('DOCUMENT').value; } catch( e ) {};
	cod=prendiElementoDaId('GridViewer_idRow_' + Row).value;
	
	var w;
	var h;
	var Left;
	var Top;
    
	w = screen.availWidth * 0.72;
	h = screen.availHeight  * 0.72;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
	
  
	ExecFunction(  '../Aflcommon/FolderGeneric/PrintDoc.asp?FileTemplate=Portale1&lIdMsgPar=' + cod + '&Name=' + strDoc + '&lIdmpPar=1&StrCommandPar=OPENDOC&ProvenienzaPortale=1' , 'PRINTDETTAGLIO' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );	
	
}

function OpenRisultatoDiGara1( objGrid , Row , c )
{
	var cod;
	var nq;
	var protbando;
	var altro='';
	var tmpVirtualDir;
	
	tmpVirtualDir = '/Application';

	if ( isSingleWin() )
		tmpVirtualDir = urlPortale;
	
	
	cod = prendiElementoDaId('R'+ Row + '_idDocR').value;	
	
	
	protbando = prendiElementoDaId('R'+ Row + '_ProtocolloBando').value;		
	
	var w;
	var h;
	var Left;
	var Top;
    
	w = screen.availWidth * 0.72;
	h = screen.availHeight  * 0.72;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
  
	
	if (cod != '0')	
		ExecFunction( tmpVirtualDir + '/report/RisultatoDiGara_Int.asp?PROTOCOLLOBANDO='+ escape(protbando) +'&CONTESTO=BANDITRADIZIONALI&BACKOFFICE=yes&TYPEDOC=RISULTATODIGARA&MODE=OPEN&IDDOC=' + cod  , 'RISULTATODIGARA' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );	

}