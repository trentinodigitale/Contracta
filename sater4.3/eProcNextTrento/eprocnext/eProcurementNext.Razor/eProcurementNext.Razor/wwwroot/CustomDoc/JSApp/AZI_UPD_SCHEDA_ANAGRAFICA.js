window.onload=view_differenze;

function view_differenze()
{
  	
	var attivoOCP = getObj('OCP_Modulo_Attivo');
	
	// SE ESISTE IL CAMPO
	if ( attivoOCP )
	{
		if ( attivoOCP.value != '1' )
			getObj('OCP').style.display = 'none'; // Nascondiamo la sezione OCP
	}
	
	try{ShowEvidenza( 'Evidenzia' , '1px solid red' );}catch(e){}
	
	
		
}