//--Versione=1&data=2012-06-11&Attvita=38536&Nominativo=Francesco
function gestione_scadenza ()
{
    if (document.getElementById('Scadenza').checked==true)
	{
	    DisableObj('NumMesiVal',false);
		//DisableObj('DestinatarioAllert',false);		
		document.getElementsByName('DestinatarioAllert')[0].disabled = false;
		document.getElementsByName('DestinatarioAllert')[1].disabled = false;		
		DisableObj('NumFrePreAlert',false);
		DisableObj('FreqPrimaria',false);
		DisableObj('FreqSecondaria',false);
		DisableObj('NumMesiVal',false);
		
		
	}
	if (document.getElementById('Scadenza').checked==false)
	{
		DisableObj('NumMesiVal',true);		
		//DisableObj('DestinatarioAllert',true);		
		document.getElementsByName('DestinatarioAllert')[0].disabled = true;
		document.getElementsByName('DestinatarioAllert')[1].disabled = true;		
		DisableObj('NumFrePreAlert',true);
		DisableObj('FreqPrimaria',true);
		DisableObj('FreqSecondaria',true);
		DisableObj('NumMesiVal',true);
		
	}
	
}

window.onload=gestione_scadenza;