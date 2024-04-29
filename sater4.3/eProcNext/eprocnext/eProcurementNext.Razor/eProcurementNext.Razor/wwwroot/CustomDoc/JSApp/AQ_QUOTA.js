

function Seleziona_Ente ( objGrid , Row , c )
{
 

	var cod;
	var strcommand;

	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );

	parent.self.opener.getObj('Value_tec__Azi').value=cod;
	parent.self.opener.getObj('Azienda').value=cod;
	parent.close();
	parent.self.opener.ExecDocProcess( 'SEL_ENTE,AQ_QUOTA');
	//SaveDoc();

 }


function InvioQuota ( param )
{


  if( trim(getObjValue( 'Titolo' )) == '' )
  {
  //alert( CNV( '../', 'Per proseguire e\' necessariao inserire il titolo.' ));
  DMessageBox( '../' , 'Per proseguire e\' necessariao inserire il titolo.' , 'Attenzione' , 1 , 400 , 300 );
  getObj('Titolo').focus();
  return;
  }
   var v = Number( getObjValue( 'Importo') );
   
   if ( v==0)
   {
   
    //alert( CNV( '../', 'Per proseguire e\' necessariao avvalorare il campo Importo allocato.' ));
    DMessageBox( '../' , 'Per proseguire e\' necessariao avvalorare il campo Importo allocato.' , 'Attenzione' , 1 , 400 , 300 );
	getObj('Importo_V').focus();
	
	return;
   
   }


    /*
   if ( v > Number( getObjValue( 'Importo_Residuo_Quote') ) )
   {
    
    //alert( CNV( '../', 'L\' importo allocato non puo\' essere superiore all\' importo residuo quote.' ));
    DMessageBox( '../' , 'L\' importo allocato non puo\' essere superiore all\' importo residuo quote.' , 'Attenzione' , 1 , 400 , 300 );
	getObj('Importo_V').focus();
	
	return;
   
   }
   */
   
   if( trim(getObjValue( 'Value_tec__Azi' )) == '' )
  {
    //alert( CNV( '../', 'Per proseguire e\' necessario selezionare l\'ente.' ));
    DMessageBox( '../' , 'Per proseguire e\' necessario selezionare l\'ente.' , 'Attenzione' , 1 , 400 , 300 );
  
  return;
  }

  ExecDocProcess( 'PUBBLICA:-1:CHECKOBBLIG,AQ_QUOTA');
}


function trim(str)
{
	return str.replace(/^\s+|\s+$/g,"");
}


window.onload = InitToolbar ;

function InitToolbar() {
  
  try{
	var temp =  GetProperty( getObj( 'val_StatoDoc' ), 'value' ) ;
	if ( temp == 'Sent' || temp == 'Invalidate' )
	  getObj('AQ_QUOTA_TOOLBAR_DOCUMENT_ADD').style.display='none';
  }catch(e){
  }
  
}

function MyDetail_AddFrom(param)
{
	var temp =  GetProperty( getObj( 'val_StatoDoc' ), 'value' ) ;
	
	if ( temp == 'Sent' || temp == 'Sended' || temp == 'Invalidate' )
	{
		DMessageBox( '../' , 'La selezione dell\'ente e\' consentita solo per le nuove quote' , 'Attenzione' , 1 , 400 , 300 );
	}
	else
	{
		Detail_AddFrom(param);
	}
}

