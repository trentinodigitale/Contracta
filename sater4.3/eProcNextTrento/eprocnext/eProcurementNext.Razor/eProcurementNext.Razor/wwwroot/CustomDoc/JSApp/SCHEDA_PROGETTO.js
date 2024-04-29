//-- apre un documento Controlli partendo da una colonna di una sezione del documetno
//-- Il presupposto è una colonna nascosta che contiene l'id del documento da aprire , ed una che contiene il tipo di documento
//-- le colonne nascoste devono cominciare con il nome della sezione seguite da Grid , '_ID_DOC' e '_OPEN_DOC_NAME
function OpenControlli( objGrid , Row , c )
{

	var cod;
	var strDoc;

	//-- recupero il codice della riga passata
	//if ( getObj( 'R' + Row + '_' + objGrid + '_ID_DOC').count == 0 )
	{
		cod = getObj( 'R' + Row + '_' + objGrid + '_ID_DOC').value;
	} 
	//else {
	//	cod = getObj( 'R' + Row + '_' + objGrid + '_ID_DOC')[0].value;
	//}
	
	if (cod==''){
		DMessageBox( '../' , 'Salvare prima la scheda e ripetere l\'operazione' , 'Attenzione' , 2 , 400 , 300 );
		return;
	}

	//-- recupero il documento da aprire
	//if ( getObj( 'R' + Row + '_' + objGrid + '_OPEN_DOC_NAME').count == 0 )
	{
		strDoc = getObj( 'R' + Row + '_' + objGrid + '_OPEN_DOC_NAME').value;
	}
	// else {
	//	strDoc = getObj( 'R' + Row + '_' + objGrid + '_OPEN_DOC_NAME')[0].value;
	//}

	//ShowDocument( strDoc , cod );
	
	var UpdParent = 'no';
	//--recupera il campo nascosto che indica se aggiornare oppure no il chiamante
	try{
		var vu = getObj( 'UpdParent_' + strDoc ).value;
		UpdParent = vu;
	}catch(e){};

	var w;
	var h;
	var Left;
	var Top;
    
	//w = screen.availWidth * 0.9;
	//h = screen.availHeight  * 0.9;
	w=700;
	h=500;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
  
	
	ExecFunction(  'document.asp?UpdateParent=' + UpdParent + '&JScript=' + strDoc + '&DOCUMENT=' + strDoc + '&MODE=OPEN&IDDOC=' + cod  , strDoc + '_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );

}

function VisualizzaAzienda( grid , r , c )
{
	//-- recupero il codice della riga passata
	
	var nIdAzienda;
	try{
		nIdAzienda = getObj( 'R' + r + '_IdAzi' )[0].value
	}catch( e ) {
		nIdAzienda = getObj( 'R' + r + '_IdAzi' ).value
	}
	//variabili che mi indicano in che posizione devo aprire le form dei documenti
	const_width=780;
	const_height=500;
	sinistra=(screen.width-const_width)/2;
	alto=(screen.height-const_height)/2;
	
	//window.open('../AFLAdmin/OpenDatiAzi.asp?IdPfu=&strFlag=OK&idAzi=' + nIdAzienda + '&IDMP=&intTab=0&strNomeCampo=-1&Provenienza=1','Run_Dati_AziendaLinked','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
	window.open('../../customdoc/VisualizzaAzienda.asp?IdPfu=&strFlag=OK&idAzi=' + nIdAzienda + '&IDMP=&intTab=0&strNomeCampo=-1&Provenienza=1','Run_Dati_AziendaLinked','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
	
	//-- ricordarsi di sostituire MP e IdPfu
}
