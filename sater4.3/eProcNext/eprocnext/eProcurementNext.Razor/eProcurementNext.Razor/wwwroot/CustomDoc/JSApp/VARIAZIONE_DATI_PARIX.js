window.onload=view_differenze;

function view_differenze()
{
 
 	//tolgo i campi del rapleg per non dare evidenza sugli stessi delle eventuali modifiche
	var strCampiEvidenza = getObj('Note').value ;
	strCampiEvidenza = '  ' + strCampiEvidenza + '  ' ;
	strCampiEvidenza = strCampiEvidenza.replace ( '  EmailRapLeg  ', '  ');
	strCampiEvidenza = strCampiEvidenza.replace ( '  NomeRapLeg  ', '  ');
	strCampiEvidenza = strCampiEvidenza.replace ( '  CognomeRapLeg  ', '  ');
	strCampiEvidenza = strCampiEvidenza.replace ( '  TelefonoRapLeg  ', '  ');
	strCampiEvidenza = strCampiEvidenza.replace ( '  CellulareRapLeg  ', '  ');
	strCampiEvidenza = strCampiEvidenza.replace ( '  CFRapLeg  ', '  ');
	strCampiEvidenza = strCampiEvidenza.replace ( '  pfuRuoloAziendale  ', '  ');
	strCampiEvidenza = strCampiEvidenza.substring(2,strCampiEvidenza.length-2);
	//alert( '-' + strCampiEvidenza + '-');
	getObj('Note').value = 	strCampiEvidenza ;
	try{ShowEvidenza( 'Note' , '1px solid red' );}catch(e){}
		
}
