window.onload = OnloadPage;

function OnloadPage()
{
	try
	{
		//Se il documento è nello statoFunzionale di 'InAttesaTed' apriamo il documento di invio dati di rettifica TED ( fintanto che il finalizza non cambia lo stato funzionale di questo documento, cioè al completamento della rettifica ted )
		var StatoFunzionale = getObjValue('StatoFunzionale');
		
		if ( StatoFunzionale == 'InAttesaTed' )
		{
			MakeDocFrom ( 'RETTIFICA_GARA_TED##RETTIFICA' );
			return;
		}
		
	}
	catch(e)
	{
	}
	
	$("#cap_label1,#cap_label2,#cap_label1,#cap_label3,#cap_label4,#cap_label5,#cap_label6,#cap_label7,#cap_label8").addClass('style_bold');
	
	/* EVIDENZIAMO TUTTI I CAMPI IN ERRORE */
	var errFields = document.getElementsByClassName('ERR_FIELD_VALID');
	
	for (var i = 0; i < errFields.length; i++) 
	{
		var fieldWithErr = errFields.item(i);
		
		var fieldClassErr = fieldWithErr.getAttribute('class').replace('ERR_FIELD_VALID', '').trim();		
		
		var vetFieldInfo = fieldClassErr.split('.');
		var fieldErrorSec = vetFieldInfo[0];
		var fieldErrorId = vetFieldInfo[1];
		TxtErr(fieldErrorId);
	}
	
}

function afterProcess(param) 
{
	var JumpCheck = getObjValue('JumpCheck');
	
	//alert(param);
	
	if ( JumpCheck == 'RETTIFICA' && param == 'SEND:-1:CHECKOBBLIG') 
	{
		//RETTIFICA_GARA_TED_CREATE_FROM_RETTIFICA
		MakeDocFrom ( 'RETTIFICA_GARA_TED##RETTIFICA' );
	}
}

function fieldSectionFocus(section, field)
{
	DocShowFolder(section);
	//TxtErr(field);
	getObj(field).focus();
}