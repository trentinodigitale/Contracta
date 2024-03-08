$( document ).ready(function() {
    OnLoadPage();
});

function OnLoadPage()
{
	
	if (getObj('RichiestaRisposta').value != 'si' )
	{
		//nascondo  data rispondere entro il		
		$("#cap_DataScadenza").parents("table:first").css({"display": "none"});
		$("#DataScadenza_L").parents("table:first").css({"display": "none"});
		
	}
	
}