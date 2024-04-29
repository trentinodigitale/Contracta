function SelectEsecutrice ( objGrid , Row , c )
{
	var cod;
	var nq;

	//-- recupero il codice della riga passata
	//cod = GetIdRow( objGrid , Row , 'self' );
	
	var w;
	var h;
	var Left;
	var Top;
    
	w = screen.availWidth;
	h = screen.availHeight;
	Left=0;
	Top=0;

	w = 400;
	h = 600;
	Left = (screen.availWidth-w)/2;
	Top  = (screen.availHeight-h)/2;
		
	//debugger;

	//val_R0_Consorzio
  
	var val_R0_Consorzio;
	try{
		val_R0_Consorzio= getObj('R' + Row + '_idAziPartecipanteHide').value;

	}catch( e ) {
		try{
			val_R0_Consorzio= getObj('R' + Row + '_idAziPartecipanteHide')[0].value;
		}catch(e1 ){
			val_R0_idAziPartecipanteHide='';
		};
	}



	

	var strURL = '../../DASHBOARD/Viewer.asp?ModGriglia=AZI_CONSORZIO_SEL_ESECUTRICI2&AreaFiltro=no&Table=Document_Aziende_Esecutrici_view2&IDENTITY=idAziPartecipante&DOCUMENT=' + Row + '&PATHTOOLBAR=../customdoc/&jscript=SELECT_ESECUTRICE&AreaAdd=no&Caption=Selezione Esecutrice&Height=150,100*,210&numRowForPag=20&Sort=&SortOrder=&Exit=si';


	ExecFunctionCenter(  strURL  + '&FilterHide=idAziRTI = ' + val_R0_Consorzio  + '#SELESECUTRICE#400,600' ); // , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );



}

//-- riporta sul documento di gestione la selezione effettuata
function AddEsecutrice( objGrid , Row , c )
{

	var cod;
	var nq;
	var strCommand;
	var testo;

	//debugger;
	//-- recupero il codice della riga passata
	
	//getObj('R' + Row + '_FNZ_ADD')[0].style.border = "solid 1px black"
  
	var strDoc;
	strDoc = getObj('DOCUMENT').value;
	
	
	//-- invoca sulla pagina chiamante l'aggiunta della riga
	
//	parent.opener.ExecDocCommand( strCommand );



	var STR;
	try{
		STR= getObj('R' + Row + '_aziRagioneSociale')[0].value;


	}catch( e ) {
		try{
			STR= getObj('R' + Row + '_aziRagioneSociale').value;
		}catch(e1 ){
			STR='';
		};
	}
	parent.opener.SetTextValue(  'R' + strDoc + '_aziRagioneSociale' , STR );
	parent.opener.SetTextValue(  'R' + strDoc + '_Bil' , GetIdRow( objGrid , Row , 'self' ));
	
	parent.close();

}


function VisualizzaAzienda( grid , r , c )
{
	//-- recupero il codice della riga passata
	
	var nIdAzienda;
	try{
		nIdAzienda = getObj( 'R' + r + '_idAziPartecipanteHide' )[0].value
	}catch( e ) {
		nIdAzienda = getObj( 'R' + r + '_idAziPartecipanteHide' ).value
	}
	//variabili che mi indicano in che posizione devo aprire le form dei documenti
	/*
	const_width=780;
	const_height=500;
	sinistra=(screen.width-const_width)/2;
	alto=(screen.height-const_height)/2;
	*/
	//window.open('../customdoc/VisualizzaAzienda.asp?IdPfu=&strFlag=OK&idAzi=' + nIdAzienda + '&IDMP=&intTab=0&strNomeCampo=-1&Provenienza=1','Run_Dati_AziendaLinked','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
	ExecFunctionCenter( '../customdoc/VisualizzaAzienda.asp?IdPfu=&strFlag=OK&idAzi=' + nIdAzienda + '&IDMP=&intTab=0&strNomeCampo=-1&Provenienza=1#Run_Dati_AziendaLinked#780,500' );
	//-- ricordarsi di sostituire MP e IdPfu
}

