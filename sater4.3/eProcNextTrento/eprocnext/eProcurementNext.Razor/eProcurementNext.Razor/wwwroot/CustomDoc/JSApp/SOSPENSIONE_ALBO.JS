function OPEN_SCHEDA_ANAGRAFICA ()
{

	var nIdAzienda;
	nIdAzienda= document.getElementById('Azienda').value;
	
	var const_width;
	const_width=780;
	
	var const_height;
	const_height=500;
	
	var sinistra;
	sinistra=(screen.width-const_width)/2;
	
	var alto;
	alto=(screen.height-const_height)/2;
	
	window.open('../../customdoc/VisualizzaAzienda.asp?IdPfu=&strFlag=OK&idAzi=' + nIdAzienda + '&IDMP=&intTab=0&strNomeCampo=-1&Provenienza=1','Run_Dati_AziendaLinked','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
	
}