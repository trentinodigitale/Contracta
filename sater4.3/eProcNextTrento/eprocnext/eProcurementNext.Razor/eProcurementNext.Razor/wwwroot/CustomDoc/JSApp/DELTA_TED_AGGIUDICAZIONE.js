

function MySend(param) 
{
    //alert(param);
	//if ( ControlliSend() == -1 )
	//	return;
	//SEND:-1:CHECKOBBLIG,DELTA_TED_AGGIUDICAZIONE
   	//alert('controlli ok');
    ExecDocProcess(param);
	
}



function ControlliSend()
{
	
	var err = 0;
	
	var NR_Agg = GetProperty( getObj('GARA_SEZ_5.1Grid') , 'numrow');
	
	for( i = 0 ; i <= NR_Agg ; i++ )
	{
		TxtOK( 'RGARA_SEZ_5.1Grid_' + i + '_TED_AWARDED_IS_SME' );
		
		if ( getObj('RGARA_SEZ_5.1Grid_' + i + '_TED_AWARDED_IS_SME').value == '' )
		{
			if ( err == 0 )
				getObj('RGARA_SEZ_5.1Grid_' + i + '_TED_AWARDED_IS_SME').focus();
			err = 1 ;
			TxtErr( 'RGARA_SEZ_5.1Grid_' + i + '_TED_AWARDED_IS_SME' );
		}
	}
	
	if(  err > 0 )
	{
		
		DMessageBox( '../' , 'Per proseguire e\' necessaria la compilazione di tutti i campi evidenziati' , 'Attenzione' , 1 , 400 , 300 );
		return -1;
	}
	
	return 0;
}

