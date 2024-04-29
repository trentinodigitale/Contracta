
function SetEstensioneImporto()
{
		SetNumericValue( 'Total' , Number(getObj('Vaue_Originario').value) + Number(getObj('ImportoEstensione').value)  );
	
}


