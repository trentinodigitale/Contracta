
window.onload = Init_DOC;
function Init_DOC() 
{
	//quando sono riferita ad una monolotto nasconde i campi NUmero Lotto e Descrizione Lotto
	if (getObj('Versione').value == 'MONOLOTTO') 
	{
		  $("#cap_VersioneLinkedDoc").parents("table:first").css({
					"display": "none"
				})
		  $("#cap_Note").parents("table:first").css({
					"display": "none"
				})

	}
}

