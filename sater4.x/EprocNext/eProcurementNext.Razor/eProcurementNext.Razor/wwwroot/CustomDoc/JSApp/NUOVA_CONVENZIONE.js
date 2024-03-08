function MySaveDoc()
{
	//var strStatoFunzionale = getObj( 'StatoFunzionale' ).value;
	
	var strScelta_Convenzione = getObjValue( 'Scelta_Convenzione' );
	//alert(strScelta_Convenzione);
	
	if (strScelta_Convenzione == ''  )
	{
		DMessageBox( '../' , 'Valorizzare il campo Scelta Convenzione' , 'Attenzione' , 1 , 400 , 300 );
		return -1;
	}
	
	
	
	var strTipo_Modello_Convenzione_Scelta = getObjValue( 'Tipo_Modello_Convenzione_Scelta' );
	
	if (strScelta_Convenzione == '-1' && strTipo_Modello_Convenzione_Scelta == '' )
	{
		DMessageBox( '../' , 'Valorizzare il campo Modello Convenzione completa' , 'Attenzione' , 1 , 400 , 300 );
		return -1;
	}
	
	
	
	var strStatoFunzionale = getObjValue( 'StatoFunzionale' );
  
  
	//if ( strStatoFunzionale == 'InLavorazione' || strStatoFunzionale == '')
	//{
	   
    //		getObj( 'Deleted').value = 0;
		
	//}
	
    //SaveDoc();
    ExecDocProcess( 'SAVE,NUOVA_CONVENZIONE' );
  
  
}



window.onload = Init_Info;


function Init_Info()
{
	
  
  
  //se vengo dal processo ed è andato tutto bene apro il documento
  //Nuova Convenzione
  //Convenzione in lavorazione in cui aggiungere
  //Convenzione Integrazione
  
  //strJumpCheck vale OK per nuova convenzione e quando vado in aggiunta
  //			 per le integrazioni vale INTEGRAZIONE (per il pregresso era così)
  var strJumpCheck = getObj( 'JumpCheck' ).value;
  //alert(strJumpCheck);
  
  if( strJumpCheck == 'OK' || strJumpCheck == 'INTEGRAZIONE' )
  {
	
	var strIdDocDaAprire
	strIdDocDaAprire = getObjValue('IDDOC');
	
	//se ho scelto di andare in aggiunta su una convenzione in lavorazione
	//allora devo aprire la convenzione che è indicata nella combo Scelta_Convenzione
	var strScelta_Convenzione = getObj( 'Scelta_Convenzione').value;
	
	if (strScelta_Convenzione != '-1' && strJumpCheck != 'INTEGRAZIONE' )
	{
		strIdDocDaAprire = strScelta_Convenzione;
	
		//alert(strScelta_Convenzione);
	
		//ricarico in memoria la convenzione dal db in modo che se era stata aperta 
		//viene aggiornata
		ReloadDocFromDB(strIdDocDaAprire, 'CONVENZIONE');
	}
	
	ShowDocumentPath( 'CONVENZIONE' , strIdDocDaAprire , '../');
	
	//chiudo il wizard
	window.close();
	
  }   
	
  try
  {
	DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
  }
  catch(e)
  {
		
  }
  var strValueSelected='';
  //Filtra la combo Scelta Convenzione
  var strConvenzioni_Lavorazione  = getObj( 'IdConvenzione_Lavorazione').value;
  var strConvenzioni_Pubblicate  = getObj( 'IdConvenzione_Pubblicate').value;
  
  var strConvFiltro = '';
  var strAmbito = '';
  
  if ( strConvenzioni_Lavorazione != '' )
	strConvFiltro = strConvenzioni_Lavorazione ;

  if ( strConvenzioni_Pubblicate != '' )
	if ( strConvFiltro != '')
		strConvFiltro = strConvFiltro + ',' + strConvenzioni_Pubblicate ;
	else
		strConvFiltro = strConvenzioni_Pubblicate;
	
  
  //aggiungo elemento Nuova Convenzione
  if ( strConvFiltro == '' )
	  strConvFiltro ='-1';
  else
	  strConvFiltro = strConvFiltro + ',-1';
  //alert(strConvFiltro);
  strFilter = 'SQL_WHERE= dmv_cod in ( ' + strConvFiltro + ')';
  
  //se presente solo la voce Nuova Concenzione nascono l'attributo
  if (DOCUMENT_READONLY == '0') 	
  {  
	  if ( strConvFiltro  == '-1')
	  {
		//setto nuova convenzione come selezionato
		strValueSelected = '-1';
	  }
	  
	  FilterDom('Scelta_Convenzione', 'Scelta_Convenzione', strValueSelected , strFilter, '', 'OnChangeScelta_Convenzione( this );');
	  
	  //carico la combo dei modelli per ambito
	  if ( strConvFiltro  == '-1')
	  {		
		strAmbito = getObj( 'Ambito').value;
		
		strFilter =  'SQL_WHERE= JumpCheck in (\'CONVENZIONI\' ) and C1.Value =\'' + strAmbito +  '\'  ';
		FilterDom( 'Tipo_Modello_Convenzione_Scelta' , 'Tipo_Modello_Convenzione_Scelta' , getObjValue('Tipo_Modello_Convenzione_Scelta') , strFilter , ''  , '');
		
	  }
	  
  }
  
  //nascondo la combo Scelta Convenzione  se ho solo l'opzione "Nuova Convenzione"
  if ( strConvFiltro  == '-1')
  {
	setVisibility(getObj('cap_Scelta_Convenzione'), 'none');
	setVisibility(getObj('Scelta_Convenzione'), 'none');
	
	
	
  }
  
}


function OnChangeScelta_Convenzione( objScelta )
{
  //se seleziono una convenzione da integrare o andare in aggiunta nascondo la combo per la scelta del modello della convenzione
  var strScelta_Convenzione = getObj( 'Scelta_Convenzione').value;
  //alert(strScelta_Convenzione);
  if (strScelta_Convenzione == '-1')
  {	  
	//se ho scelto nuova convenzione visulizzo combo per la selezione del modello
	setVisibility(getObj('cap_Tipo_Modello_Convenzione_Scelta'), '');
	setVisibility(getObj('Tipo_Modello_Convenzione_Scelta'), '');
	
	//effettuo il filtro per ambito
	strAmbito = getObj( 'Ambito').value;
		
	strFilter =  'SQL_WHERE= JumpCheck in (\'CONVENZIONI\' ) and C1.Value =\'' + strAmbito +  '\'  ';
	FilterDom( 'Tipo_Modello_Convenzione_Scelta' , 'Tipo_Modello_Convenzione_Scelta' , getObjValue('Tipo_Modello_Convenzione_Scelta') , strFilter , ''  , '');
	
  }	  
  else
  {	  
	//se ho scelto una convenzione da integrare o in aggiunta nascondo la combo per la selezione del modello
	
	setVisibility(getObj('cap_Tipo_Modello_Convenzione_Scelta'), 'none');
	setVisibility(getObj('Tipo_Modello_Convenzione_Scelta'), 'none');
	
  }	  
}



