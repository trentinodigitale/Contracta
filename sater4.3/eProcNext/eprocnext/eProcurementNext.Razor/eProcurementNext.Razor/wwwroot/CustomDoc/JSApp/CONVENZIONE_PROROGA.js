window.onload = setdocument;

function setdocument()
{
	//nascondo i campi relativi alla scadenza ordinativi se la convenzione è duratafissata	
	if( getObjValue('VersioneLinkedDoc') == 'duratafissata' )	
	{		
		//risale fino alla table e la mette nascosta
		try{ getObj('NuovaDataFineOrdinativo').parentNode.parentNode.parentNode.parentNode.style.display = "none"; }catch(e){};
		try{ getObj('cap_NuovaDataFineOrdinativo').parentNode.parentNode.parentNode.parentNode.style.display = "none"; }catch(e){};
		try{ getObj('DataFineOrdinativo').parentNode.parentNode.parentNode.parentNode.style.display = "none"; }catch(e){};		
		try{ getObj('cap_DataFineOrdinativo').parentNode.parentNode.parentNode.parentNode.style.display = "none"; }catch(e){};		
		try{ getObj('TipoScadenzaOrdinativo').parentNode.parentNode.parentNode.parentNode.style.display = "none"; }catch(e){};		
		try{ getObj('cap_TipoScadenzaOrdinativo').parentNode.parentNode.parentNode.parentNode.style.display = "none"; }catch(e){};		
		
	}
	else
	{	
		try{setClassName( getObj('cap_NuovaDataFineOrdinativo').parentNode , 'VerticalModel_ObbligCaption');}catch(e){};
	}
	
}


