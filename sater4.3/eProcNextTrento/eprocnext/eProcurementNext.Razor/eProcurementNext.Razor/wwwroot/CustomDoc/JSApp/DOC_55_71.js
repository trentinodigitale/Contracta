<script language="javascript">

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

	if ( nHide==1 ) {
		setVisibility(getObj('DIV_ECONOMICA_allegati'),'none');
    setVisibility(getObj('DIV_TECNICA_allegati'),'none');	
		
	}

}catch(e){
}

</script>

