

function CheckCoerenza( objfield )
{
	
	if ( getObj('DataScadenza').value != '' && getObj('DataStipula').value != '' )
	{
		if (CheckData('DataScadenza', getObjValue('DataStipula'), 'Compilare Data Scadenza', 'Data Scadenza deve essere maggiore di Data Stipula Contratto') == -1) 
		{
			objfield.value='';
			return -1;
		}
	}
	
}

function CheckData(FieldData, Riferimento, msgVuoto, msgMinoreRif) {
    if (getObjValue(FieldData) == '') 
	{              
        try {getObj(FieldData + '_V').focus();} catch (e) {};
        DMessageBox('../', msgVuoto, 'Attenzione', 1, 400, 300);
        return -1;
    }

    if (getObjValue(FieldData) <= Riferimento) 
	{   
        try { getObj(FieldData + '_V').focus();} catch (e) {};
        DMessageBox('../', msgMinoreRif, 'Attenzione', 1, 400, 300);
        return -1;
    }

    return 0;
}
