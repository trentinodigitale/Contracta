/*<script language="Javascript">*/

//FUNZIONE     : [isNumeric]

//AUTORE       : [ ]

//@bfunc [Public] | [isNumeric]	| [VOID]	| [controlla che il contenuto del campo testo sia numerico]

//@bparm Input	 | [j]			| [LONG]		| [l'indice di colonna]
//@bparm Input	 | [intLoop]	| [LONG]		| [l'indice di riga]

//@comm [IL TIPO DI ELEMENTO CREATO DA BuildFieldsHidden HA DUE INDICI]

function isNumeric(j,intLoop) {
	nomeCampoChech="elementi_"+intLoop+"_"+j;
	var temp = document.prodotti.elements[nomeCampoChech].value;
	if (IsNumber(temp)==0){
		document.prodotti.elements[nomeCampoChech].value = "";
		document.prodotti.elements[nomeCampoChech].focus();
	}
}


/*-----------------IsNumber---------------------------------------------
DESCRIZIONE: verifica se una stringa indica un numero
input:
	szValue= la stringa da controllare
output: se la stringa risulta corretta la funzione ritorna 1; 0 altrimenti

*/
function IsNumber (szValue)
{
	var szDigits;
	var nIndex;

	szDigits = "0123456789";

	for (nIndex=0;nIndex < szValue.length; nIndex++)
	   { 
	      if (szDigits.indexOf(szValue.charAt(nIndex)) < 0)
	         return 0;
	   }

	return 1;
}        
//----------------------------------------------------------------------

//Questa funzione prende in input una stringa e restituisce 0 se non � un double, altrimenti 1.
//caratteri su cui effettua iul controlnto: {0123456789.,}
function IsDouble (szValue)
{
 //@comm controlla che il campo sia di tipo double e nel caso lo sia torna 1 altrimenti 0
   var szDigits;
   var nIndex;

   szDigits = "0123456789.,";

   for (nIndex=0;nIndex < szValue.length; nIndex++)
      { 
         if (szDigits.indexOf(szValue.charAt(nIndex)) < 0)
            return 0;
      }

   return 1;
}
/*</script>*/