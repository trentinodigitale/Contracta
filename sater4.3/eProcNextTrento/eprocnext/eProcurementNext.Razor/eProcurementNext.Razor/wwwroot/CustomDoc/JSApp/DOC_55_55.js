<script language="javascript">

//visualizzo la busta di documentazione
DrawLabel('1'); 
try { 
  FUNC_OPEN('55','55','1',getObj('lIdPfu').value,getObj('lIdMsgPar').value,'PRODUCTS','DOCUMENTAZIONE','AFLGenericDocument.clsTabProducts','3','226','DIV_DOCUMENTAZIONE','Open_DOCUMENTAZIONE');
} 
catch(e){} 
FUNC_DOCUMENTAZIONE(); 

//nascondo area allegati della sezione tecnica e della sezione economica in caso di nuovo documento
try{
	nHide=0;

	try{
		strdata=getObj('ReceivedDataMsg')[0].value;
	}catch(e){
		strdata=getObj('ReceivedDataMsg').value;
	}

	
	if ( strdata > '2009-10-30T00:00:00')
		nHide=1;

	if (getObj('Stato').value == '0' || getObj('Stato').value == '1' || nHide==1){
		setVisibility(getObj('DIV_TECNICA_allegati'),'none');	
		setVisibility(getObj('DIV_ECONOMICA_allegati'),'none');
	}

}catch(e){
}

</script>

