function VisualizzaAzienda( grid , r , c )
{
	//-- recupero il codice della riga passata
	/*
	var nIdAzienda;
	try{
		nIdAzienda = getObj( 'R' + r + '_IdAzi' )[0].value
	}catch( e ) {
		nIdAzienda = getObj( 'R' + r + '_IdAzi' ).value
	}
	*/
	nIdAzienda=GetIdRow( grid , r , '' );
	//variabili che mi indicano in che posizione devo aprire le form dei documenti
	const_width=780;
	const_height=500;
	sinistra=(screen.width-const_width)/2;
	alto=(screen.height-const_height)/2;
	
	//window.open('../AFLAdmin/OpenDatiAzi.asp?IdPfu=&strFlag=OK&idAzi=' + nIdAzienda + '&IDMP=&intTab=0&strNomeCampo=-1&Provenienza=1','Run_Dati_AziendaLinked','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
	window.open('../customdoc/VisualizzaAzienda.asp?IdPfu=&strFlag=OK&idAzi=' + nIdAzienda + '&IDMP=&intTab=0&strNomeCampo=-1&Provenienza=1','Run_Dati_AziendaLinked','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
	
	//-- ricordarsi di sostituire MP e IdPfu
}