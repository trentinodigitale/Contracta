window.onload = setdocument;

function setdocument()
{
	Hide_CLASSI();
}


function RefreshContent()
{ 	
	RefreshDocument('');      
}
//nasconde la sezione delle classi se non vengo da un BANDO_ME
function Hide_CLASSI()
{
	if ( getObjValue('JumpCheck') != 'BANDO'	)
	{
		document.getElementById("CLASSI").style.display="none";
	}

}










