

function MakeTotal_Section( strNameControl ){
	
	var strMsgErr;
	//debugger;
	
	try {	
		//--recupero oggetto che contiene info per il totale dell'area
		strExpression = getObj(strNameControl + '_EXPRESSION').value;

		strSECTION_DETAIL = getObj(strNameControl + '_SECTION_DETAIL').value;
		
		Grid = getObj( strSECTION_DETAIL + 'Grid');
		nNumRow=parseInt( Grid.numrow );
		
		if (nNumRow >= 0)
		{
		
			//recupero gli operandi dalla formula
			strTempExpression=strExpression
			
			strTempExpression=ReplaceExtended(strTempExpression,'(',',');
			strTempExpression=ReplaceExtended(strTempExpression,')',',');
			strTempExpression=ReplaceExtended(strTempExpression,'*',',');
			strTempExpression=ReplaceExtended(strTempExpression,'/',',');
			strTempExpression=ReplaceExtended(strTempExpression,'+',',');
			strTempExpression=ReplaceExtended(strTempExpression,'-',',');
			
			aOperandi=strTempExpression.split(',');
			nNumAttrib=aOperandi.length;
			
			
			//recupero la valuta della prima riga della griglia
			nValueTotal=0;
			strMsgErr='';
				
			
			//ciclo sulle righe della griglia
			for (nIndRrow=0;nIndRrow<=nNumRow;nIndRrow++){
					
				strExpressionRow=strExpression
				nValueTotalRow=0
				
				for (nIndAttrib=0;nIndAttrib<nNumAttrib;nIndAttrib++){
				
					if( aOperandi[nIndAttrib] != '' )
					{
						//strValueAttrib=GetValueAttrib(nTipoMemAttrib,strNameControl,nPosCol,nIndRrow)
						strValueAttrib = getObj( 'R' + nIndRrow + '_' + aOperandi[nIndAttrib] ).value;
						if (strValueAttrib!='')
							strExpressionRow=ReplaceExtended(strExpressionRow, aOperandi[nIndAttrib] ,parseFloat(strValueAttrib));
					}
				}
					
				strMsgErr = '';			
				try {
					nValueTotalRow=eval(strExpressionRow);
				} catch (e) {
					strMsgErr='errore';
						
				}
				if (strMsgErr=='')	
					nValueTotal=nValueTotal+parseFloat(nValueTotalRow);
				//else
				//	nValueTotal='';

			}
				
			
		}
		else
		{
			nValueTotal = 0;
		}
		

		try {
			SetNumericValue( getObj( strNameControl + '_F_TOT_RIGHE').value , nValueTotal );
		} catch( e ) {};

		SetTotalField( strNameControl );
		
		
	}
	catch (e){
	}
}


function SetTotalField( strNameControl )
{
		//-- inserisce i valori nella sezione
		var trasp = 0.0;
		var sco = 0.0;
		var cap = 0.0;

		//debugger;
		//-- totale scontato
		try {
		
			nValueTotal = 0.0;
			
			if( getObj( getObj( strNameControl + '_F_TOT_RIGHE').value ).value != '' )
			{
				nValueTotal = parseFloat(getObj( getObj( strNameControl + '_F_TOT_RIGHE').value ).value);
			}

			
			try {
				if( getObj( getObj( strNameControl + '_F_SCONTO').value ).value != '' )
					sco = parseFloat(getObj( getObj( strNameControl + '_F_SCONTO').value ).value);
			} catch( e ) {};
			
			SetNumericValue(  getObj( strNameControl + '_F_TOTALESCONTATO' ).value , nValueTotal  - sco );
		
		} catch( e ) {};


		//-- totale commissione
		
		try {
		
			nValueTotal = parseFloat(getObj( getObj( strNameControl + '_F_TOTALESCONTATO').value ).value);


			try {
				if( getObj( getObj( strNameControl + '_F_TRASPORTO').value ).value != '' )
					trasp = parseFloat(getObj( getObj( strNameControl + '_F_TRASPORTO').value ).value);
			} catch( e ) {};
			
			
			SetNumericValue(  getObj( strNameControl + '_F_TOT' ).value , nValueTotal  - trasp );
		
		} catch( e ) {};




		//-- residuo
		try {

			try {
				if ( getObj( getObj( strNameControl + '_F_ACCONTO').value ).value != '' )
					cap = parseFloat(getObj( getObj( strNameControl + '_F_ACCONTO').value ).value);
			} catch( e ) {};
			
			
			SetNumericValue(  getObj( strNameControl + '_F_RESTO' ).value , nValueTotal - trasp -  cap );
		} catch( e ) {};


}

/*-----------------ReplaceExtended---------------------------------------------
DESCRIZIONE: effettua la replace di tutte le occorrenze di una stringa
input:
  strExpression= la stringa in vui fare la replace
  strFind=la stringa da cercare
  strReplace=la stringa da sostituire
		
output: la nuova stringa
*/
function ReplaceExtended(strExpression,strFind,strReplace){

  while (strExpression.indexOf(strFind)>=0)
  	strExpression=strExpression.replace(strFind,strReplace);
		
  return strExpression;
}