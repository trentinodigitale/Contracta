//-- *********************************************************************
//-- * Versione=1&data=2012-05-24&Attvita=37854&Nominativo=FedericoLeone *
//-- *********************************************************************

//-- la funzione aggiorna un campo attach ed il suo corrispettivo visuale
function SetAttachValue( objName , value , VisValue )
{
	var val;
	var Field;
	var Field_V;
	
	//-- verifica se il campo è unico o un array, in tal caso lavora sul primo
	try 
	{
		Field = getObj( objName );
		Field.value = value;
		
		//se la classe è fld_Evidence la cambio
		if (Field.className=='fld_Evidence')
			Field.className='Text';
			
	}catch ( e ) {
			
	}
	
	try 
	{
		Field_V = getObj( 'DIV_' + objName  );
		if (value=='')
			Field_V.innerHTML = ' ';
		else
			Field_V.innerHTML = VisValue;
		
		//se la classe è fld_Evidence la cambio
		if (Field_V.className=='fld_Evidence')
			Field_V.className='Text';
			
	}catch ( e ) {

	}	

}

function InfoSignCert( path, hash, attIdMsg, attOrderFile, attIdObj, noPath)
{
	// * ATT_Hash     , chiave di aggancio per i nuovi allegati
	// * attIdMsg     , chiave di aggancio per i vecchi allegati
	// * attOrderFile , chiave di aggancio per i vecchi allegati
	// * attIdObj     , chiave di aggancio per i vecchi allegati 
	// * noPath , parametro opzionale per indicare alla pagina viewCertificato che il dettaglio del certificato non deve entrare nelle molliche di pane
	
	if ( isSingleWin() )
	{

		var objForm=getObj('FORMDOCUMENT');
	
		var IDDOC = getObj( 'IDDOC' ).value;
		var TYPEDOC = getObj( 'TYPEDOC' ).value; 

		if (noPath === undefined) 
		{
			noPath = '';
		}
					
		objForm.action = path + '../functions/FIELD/viewCertificato.asp?ATT_Hash=' + hash + '&attIdMsg=' + attIdMsg + '&attOrderFile=' + attOrderFile + '&attIdObj=' + attIdObj + '&IDDOC=' + IDDOC + '&TYPEDOC=' + TYPEDOC + '&NO_PATH=' + noPath;
		objForm.target ='_self';

		objForm.submit();
		
		//ExecFunctionSelf( path + '../functions/FIELD/viewCertificato.asp?ATT_Hash=' + hash + '&attIdMsg=' + attIdMsg + '&attOrderFile=' + attOrderFile + '&attIdObj=' + attIdObj);
	}
	else
	{
		ExecFunctionCenter( path + '../functions/FIELD/viewCertificato.asp?ATT_Hash=' + hash + '&attIdMsg=' + attIdMsg + '&attOrderFile=' + attOrderFile + '&attIdObj=' + attIdObj);
	}
}



function DisplayAttach(path, param)
{
	
	
	//ExecFunction( '../Application/CTL_Library/functions/field/DisplayAttach.ASP?OPERATION=DISPLAY&FIELD=AllegatoPerOCP&PATH=%2E%2E%2F%2E%2E%2F&TECHVALUE=2020%5F06%5F11%5Frichiesta%5Fsater%2Epdf%2Apdf%2A499849%2Abb88bdd24c324818a%5F20211125155422595%2ASHA256%2AD8196A5F737D53B24E6529F02FDCBE1B92E0E6F625BF8F5C9A24801569A00519%2A2021%2D11%2D25T16%3A54%3A26&FORMAT=INTM'  , 'DisplayAttach' , ',height=400,width=600' );
	var strUrl = path + '/CTL_Library/functions/field/DisplayAttach.ASP?';
	strUrl = strUrl + 'OPERATION=DISPLAY&TECHVALUE=' + encodeURIComponent(param);
	//strUrl = strUrl + 'TECHVALUE=' + encodeURIComponent(strTechValueAttach);
	ExecFunction(  strUrl  , 'DisplayAttach' , ',height=400,width=600' );
}