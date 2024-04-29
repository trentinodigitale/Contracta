function afterProcess(param)
{
	
	if ( param == ('ANNULLA') || param == ('CONFERMA') )
	{
		
		
		if( getObj( "StatoFunzionale" ).value == 'Annullato' || getObj( "StatoFunzionale" ).value == 'Confermato' )
		{
			//per dare messaggio quando invio anche offerta
			if ( getObj( "JumpCheck" ).value == 'OFFERTA_SEND' )
			{
				var Title = 'Informazione';
				var ML_text = 'Invio offerta eseguito correttamente';
				var ICO = 1;
				var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
				
				ExecFunctionModaleWithAction( page, null , 200 , 420 , null , 'breadCrumbPop' );
			}
			else
			{
				breadCrumbPop();
			}
		}
	}
}

window.onload = onloadpage;

function onloadpage()
{
	if ( getObj('EsitoRiga').value == '' )
	{
		 $("#cap_EsitoRiga").parents("table:first").css({"display": "none"})
	}
	
	if ( GetProperty(getObj('DETTAGLIGrid'), 'numrow') < 0 ) 
	{
		document.getElementById('div_DETTAGLIGrid').style.display = "none";
		
	}
	
}