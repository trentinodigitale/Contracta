//--Versione=1&data=2012-06-11&Attvita=38536&Nominativo=Francesco
function Cancella_RIGA(objGrid , Row , c)
{
if (getObj('R'+Row+'_Interno').value==1)
{
	DettagliDel( objGrid , Row , c );
}
}

function DETTAGLI_OnLoad()
{
    
    try
	{
		MostraEvidenza( 'DETTAGLI' , 'Modified' );
	}catch( e ) {};
}

window.onload=DETTAGLI_OnLoad;