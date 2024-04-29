//--Versione=2&data=2012-12-06&Attivita=40053&Nominativo=Sabato

//-- chiamata sull'evento di onblur per controllare il valore immesso e riportarlo 
//-- nel campo nascosto in forma tecnica
function ck_VN( obj_field , strSepDecimal , nCifreDecimali ) {
	
	//debugger;
	var ObjHidden;
	var textDate;
	var sep;
	var format;
	
	format = '';
	
	//-- recupera il campo nascosto
	//ObjHidden = getObj( obj_field.id + '_H' );
	ObjHidden = getObjGrid( obj_field.id.substr( 0, obj_field.id.length -2 ) );
	obj_field.style.textAlign='right';

	//Ricavo il numero di cifre decimali dalla format
	format = GetProperty(ObjHidden, 'format');
	
	if ( format )
	{
		if ( format != '' )
		{
			if( format.indexOf(".") > -1  )
			{
				nCifreDecimali = (format.length-1) - format.indexOf(".");
			}
			else
			{
				nCifreDecimali = 0;
			}
				
		}
	}
	
	//tolgo il sep delle migliaia dal valore visuale
	var strSepFix;
	if (strSepDecimal==',')
		strSepFix='.';
	
	valueVis = obj_field.value;
	
	index=valueVis.indexOf(strSepFix, 0);
	while (index > 0)
	{	
		valueVis=valueVis.replace(strSepFix,'');
		index=valueVis.indexOf(strSepFix, index+1);
	}
	obj_field.value = valueVis;
	
	CheckValore( obj_field , ObjHidden , strSepDecimal,nCifreDecimali);
}



function CheckValore( objField , objHidden , strSepDecimal,nCifreDecimali) {

	var nomeCampoVis;
	var valueVis,valueVis1;
	var strSepFix;
	var strSign;
	var strTempValue;
	var index;
	
	strSign='';
	
	
	//stabilisco il separatore delle migliaia
	strSepFix=',';
	if (strSepDecimal==',')
		strSepFix='.';
	
	//controllo che il valore inserito è un numero float corretto
	valueVis = objField.value;
	if (valueVis!=''){
		
		valueVis=valueVis.replace(',','.');
		valueVis1=valueVis;
		if (isFinite(valueVis)){
			

			//-- prelevo il segno se presente
			if (valueVis.charAt(0)=='-' || valueVis.charAt(0)=='+'){
				strSign=valueVis.charAt(0);
				valueVis1=valueVis.substr(1,valueVis.length)
			}	
			
			objField.value = strSign + FormatNumber(valueVis1,strSepDecimal,strSepFix,nCifreDecimali);
			//setStyleById(nomeCampoVis,"textAlign","right");
			
			 
			//aggiorno il campo tecnico
			strTempValue=objField.value;
			index=strTempValue.indexOf(strSepFix, 0);
			while (index > 0)
			{	
				strTempValue=strTempValue.replace(strSepFix,'');
				index=strTempValue.indexOf(strSepFix, index+1);
			}
			strTempValue=strTempValue.replace(strSepDecimal,'.')
			objHidden.value = strTempValue;
		
		}else{
		
			objField.value = '';
			objHidden.value = '';
			
		}
	}
	else
	{
		
			objField.value = '';
			objHidden.value = '';
			
	}
}

//-- evento sul onchange, riporta nel campo nascosto il valore immesso in quello visuale
function oc_VN(elemento, strSepDecimal,nCifreDecimali) {
	
	
	
	/*
	
	var objField;


	var nomeCampoVis;
	var valueVis,valueVis1;
	var strSepFix;
	var strSign;
	var strTempValue;
	var index;
	var ObjHidden;
	
	//-- recupero il campo 
	ObjHidden = getObjGrid( elemento.id.substr( 0, elemento.id.length -2 ) );
	
	
	valueVis1 = elemento.value;
	
	//-- trasformo la virgola nel punto per portare il valore nella forma tecnica
	valueVis=valueVis1.replace(',','.');

	
	//-- controlla che il valore inserito sia un numero corretto
	if (isFinite(valueVis))
	{
		//-- controlla che il numero di decimali sia corretto

		//-- riporta il valore nel campo nascosto
		ObjHidden.value = valueVis;					
	
	}
	else
	{
		elemento.value = '';
		ObjHidden.value = '';
	}
	
	*/
	
	
	//ck_VN (elemento, strSepDecimal,nCifreDecimali);
	
	//debugger;
	var ObjHidden;
	var format;	
	
	//-- recupera il campo nascosto
	ObjHidden = getObjGrid( elemento.id.substr( 0, elemento.id.length -2 ) );


	//Ricavo il numero di cifre decimali dalla format
	format = GetProperty(ObjHidden, 'format');
	
	if ( format != '' )
	{
		if( format.indexOf(".") > -1  )
		{
			nCifreDecimali = (format.length-1) - format.indexOf(".");
		}
		else
		{
			nCifreDecimali = 0;
		}
			
	}
	
	
	
	CheckValore( elemento , ObjHidden , strSepDecimal,nCifreDecimali);	
	
}



//-- evento di on focus per i numerici
function of_VN(elemento, strSepDecimal,nCifreDecimali) {


	//debugger;
	
	var valueVis;
	var strSepFix;
	var index;
	
	
	
	elemento.style.textAlign='left';
	
	//stabilisco il separatore delle migliaia
	strSepFix=',';
	if (strSepDecimal==',')
		strSepFix='.';
	
	valueVis=elemento.value;
	
	//-- tolgo dalla stringa il separatore delle migliaia
	index=valueVis.indexOf(strSepFix, 0);
	while (index > 0)
	{	
		valueVis=valueVis.replace(strSepFix,'');
		index=valueVis.indexOf(strSepFix, index+1);
	}
	
	//-- aggiorno il campo
	elemento.value=valueVis;
	try { elemento.select(); } catch( e ){};
	//setStyleById(nomeCampoVis,"textAlign","left");
	
}


//autore:E.P 
//descrizione:converte un numero float dalla forma xxx.yyy nella forma visuale con
//			  un certo numero di cifre decimali
/*input:
nValue:valore in forma tecnica xxx.yyy
strSeparator:separatore dei decimali
strSeparatorFix:separatore delle migliaia
nCifreDecimali:numero di cifre decimali
*/

function FormatNumber(nValue,strSeparator,strSeparatorFix,nCifreDecimali){
	
	var strZero = '0000000000';

	//strValue=Number(nValue).toFixed(10).toString();
	strValue=nValue.toString();
	
	a=strValue.split('.');
	strFix=a[0];
	
	//se la parte fissa non viene imputata setto 0
	if (strFix == '')
		strFix = '0';	
	
	strDecimal='';
	
	if (a.length==2){
		
		strDecimal=a[1];
		if (strDecimal.length >= nCifreDecimali) {
			strDecimal=strDecimal.substr(0,nCifreDecimali)
		}
		else
		{
			//nCifreDecimali=nCifreDecimali-strDecimal.length;
			strDecimal=strDecimal + strZero.substr( 0 ,nCifreDecimali - strDecimal.length)
		}
	}
	else
	{
		strDecimal=strZero.substr( 0 ,nCifreDecimali )
	}	
	
	VisValue='';

	//applichiamo il separatore delle migliaia alla parte fissa
	strFixFinal=strFix;
	if (strSeparatorFix!=''){
		strFixNew='';
		while (strFix.length > 3){
			strFixNew= strSeparatorFix+strFix.substr(strFix.length-3,3)+strFixNew;
			strFix=strFix.substr(0,strFix.length-3);
		}
		strFixFinal=strFix+strFixNew;
	}
	
	if( nCifreDecimali == 0 )
		VisValue=strFixFinal;
	else
		VisValue=strFixFinal+strSeparator+strDecimal;
	
	return VisValue;
}

//-- la funzione aggiorna un campo numerico ed il suo corrispettivo visuale 
//-- prendendo le informazioni di formato dal campo nascosto in forma tecnica 
function SetNumericValue( objName , value )
{
	var DecimalSep;
	var GroupSep;
	var NumDec;
	var Field;
	var val;
	var ObjHidden;
	ObjHidden = getObjGrid( objName.substr( 0, objName.length -2 ) );
	NumDec=0;
	//debugger;
	try
	{
		//-- verifica se il campo è unico o un array, in tal caso lavora sul primo
		try 
		{
			val = getObjGrid( objName ).value;
			val = 0;
			Field = getObjGrid( objName );
		
		}catch ( e ) {
			val = 1;
			Field = getObjGrid( objName )[0];
		}

		Field.value = value;

		//-- recupera le informazioni di formattazione
		try
		{
			//DecimalSep = Field.DS;
			DecimalSep = GetProperty(Field,'DS');
			if( DecimalSep == ',' )
			{
				GroupSep = '.';
			}
			else
			{
				GroupSep = ',';
			}
			//NumDec = Field.ND;
			
			//Ricavo il numero di cifre decimali dalla format se esiste
			format = GetProperty(ObjHidden, 'format');
	
			if ( format != '' )
			{
				if( format.indexOf(".") > -1  )
				{
					NumDec = (format.length-1) - format.indexOf(".");
				}
				else
				{
					NumDec = 0;
				}
					
			}		
			else
			{
				NumDec = GetProperty(Field,'ND');
			}
		
		}catch( e ) {
		
			DecimalSep = ',';
			GroupSep = '.';
			NumDec = 2;
		}

		value = Number( value );
		value =  value.toFixed( NumDec );
		Field.value = value;
		
		
		if( DecimalSep == undefined ) DecimalSep = ',';
		if( GroupSep == undefined ) GroupSep = '.';
		if( NumDec == undefined ) NumDec = 2;
		
		
	   
		if ( val == 1 )	
			try{
			   
			   if (  getObj( objName + '_V' ).tagName != 'LABEL' && getObj( objName + '_V' ).tagName != 'SPAN' )
			     getObjGrid( objName + '_V' )[0].value = FormatNumber(value, DecimalSep , GroupSep , NumDec);	
			   else
				    getObjGrid( objName + '_V' )[0].innerHTML = FormatNumber(value, DecimalSep , GroupSep , NumDec);	
			}catch(e){alert(e);}	
		else
			try{
			  
				if (  getObj( objName + '_V' ).tagName != 'LABEL' && getObj( objName + '_V' ).tagName != 'SPAN' )
				  
				  getObjGrid( objName + '_V' ).value = FormatNumber(value, DecimalSep , GroupSep , NumDec);
				else
				  getObjGrid( objName + '_V' ).innerHTML = FormatNumber(value, DecimalSep , GroupSep , NumDec);
			}catch(e){alert(e);}					
	}catch( e ){};


}

function NumberreadOnly(objName,b)
{
  //considero il campo che rappresenta la forma visuale del campo numerico
  objName = objName + '_V';
  try{ getObj(objName).readOnly=b; } catch( e ){};	
  
  if ( b == true )
     getObj(objName).className =  getObj(objName).className + ' readonly';
  if ( b == false )
   getObj(objName).className = ReplaceExtended(getObj(objName).className,' readonly','')
   
}

