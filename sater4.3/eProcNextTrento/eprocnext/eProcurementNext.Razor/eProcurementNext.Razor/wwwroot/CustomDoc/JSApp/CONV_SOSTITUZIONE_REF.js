window.onload = filtraReferente; 

function filtraReferente()
{
	var azi_dest = getObjValue('Mandataria');
	
	var filter =  'SQL_WHERE= idpfu in ( select idpfu  from profiliUtente where pfuidazi = \'' + azi_dest +  '\'  )';

	try
	{
		if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' )
		{
			FilterDom( 'ReferenteFornitore' , 'ReferenteFornitore' , getObjValue('ReferenteFornitoreHide') , filter ,'', 'OnchangeReferenteFornitore();');
			
		}
	}
	catch( e ) 
	{
	}

	
}

function OnchangeReferenteFornitore()
{
	UpdateFieldVisual(getObj('ReferenteFornitore'),'DATI_NUOVO_REFERENTE_FORNITORE','DATI_NUOVO_REFERENTE_FORNITORE','no','=','parent','');
}