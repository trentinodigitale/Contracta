
/*-----------------ReplaceExtended---------------------------------------------
DESCRIZIONE: effettua la replace di tutte le occorrenze di una stringa
input:
  strExpression= la stringa in vui fare la replace
  strFind=la stringa da cercare
  strReplace=la stringa da sostituire
		
output: la nuova stringa
*/
function ReplaceExtended(strExpression,strFind,strReplace)
{
  if( strExpression == 'null' || strExpression == undefined )
	strExpression='';
  /*while (strExpression.indexOf(strFind)>=0)
  	strExpression=strExpression.replace(strFind,strReplace);
		
  return strExpression;*/
  return replaceAll_NEW(strExpression,strFind,strReplace);
  
}

function replaceAll_NEW(str, find, replace) 
{
  return str.replace(new RegExp(escapeRegExp(find), 'g'), replace);
  
}

function escapeRegExp(string) 
{
  return string.replace(/[.*+\-?^${}()|[\]\\]/g, '\\$&'); // $& means the whole matched string
}
