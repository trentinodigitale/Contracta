
function FIRMA_OnLoad()
{
   
	var Stato ='';
	Stato = getObjValue('StatoFunzionale');
	
	
	 try
	 {
		if ( Stato=='Inviato' && getObjValue('IdpfuInCharge') != '0' )
			{
				document.getElementById('attachpdfcontratto').disabled = false; 
				document.getElementById('attachpdfcontratto').className ="attachpdf";
				document.getElementById('attachpdfclausola').disabled = false; 
				document.getElementById('attachpdfclausola').className ="attachpdf";			
			}
		else
		   {
			   document.getElementById('attachpdfcontratto').disabled = true; 
			   document.getElementById('attachpdfcontratto').className ="attachpdfdisabled";
			   document.getElementById('attachpdfclausola').disabled = true; 
			   document.getElementById('attachpdfclausola').className ="attachpdfdisabled";
		   } 
	  }catch( e ) {}
}

window.onload = FIRMA_OnLoad;


function AllegaContrattoFirmato()
{
	var idDoc;
	idDoc = getObjValue('IDDOC');
	
	ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=CTL_DOC_SIGN&IDDOC=' + idDoc + '&OPERATION=INSERTSIGN&IDENTITY=IdHeader&AREA=F3&DOMAIN=FileExtention&FORMAT=#AllegaFirma#600,400');
    
}
function AllegaClausolaFirmato()
{
	var idDoc;
	idDoc = getObjValue('IDDOC');
	
	ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=CTL_DOC_SIGN&IDDOC=' + idDoc + '&OPERATION=INSERTSIGN&IDENTITY=IdHeader&AREA=F4&DOMAIN=FileExtention&FORMAT=#AllegaFirma#600,400');
    
}

function RefreshContent()
{
	
}