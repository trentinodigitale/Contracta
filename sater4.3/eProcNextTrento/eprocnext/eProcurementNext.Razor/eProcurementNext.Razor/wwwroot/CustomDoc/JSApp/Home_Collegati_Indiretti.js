

function OpenCollegati(objGrid , Row , c  )
{
  
	var Fascicolo = ''; 
	try	{ 	Fascicolo = getObjValue( 'R' + Row + '_Fascicolo')	}catch( e ) {};

	
	var URL = '../dashboard/mainView.asp?A=A&FOLDER_GROUP=LINKED_DOCUMENTI_INDIRETTI&FilterHide= Fascicolo = \'' + Fascicolo + '\' ';
	
	
	parent.parent.parent.DocumentiCollegati( URL );

}


function ChangeViewInvitiIndiretti ( Param , URL )
{
    if ( Param == 'scaduti' )
    {
//        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_INVITI_FORN_SERV_PRIV'  ).innerHTML = 'Inviti Forniture e Servizi scaduti';
//        parent.parent.parent.getObj('descfolder').innerHTML = 'Inviti Forniture e Servizi scaduti';
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_INVITI_FORN_SERV_PRIV_INDIRETTI'  ).innerHTML = 'Inviti scaduti a cui ho partecipato Indirettamente (Mandante o Esecutrice dei Lavori)';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Inviti scaduti a cui ho partecipato Indirettamente (Mandante o Esecutrice dei Lavori)';
    }
    else
    {
//        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_INVITI_FORN_SERV_PRIV'  ).innerHTML = 'Inviti Forniture e Servizi';
//        parent.parent.parent.getObj('descfolder').innerHTML = 'Inviti Forniture e Servizi';
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_INVITI_FORN_SERV_PRIV_INDIRETTI'  ).innerHTML = 'Inviti a cui sto partecipando Indirettamente (Mandante o Esecutrice dei Lavori)';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Inviti a cui sto partecipando Indirettamente (Mandante o Esecutrice dei Lavori)';
    }   
    parent.ExecFunction1( URL , 'self','' )

}


function ChangeViewBandiPrivIndiretti  ( Param , URL )
{
    if ( Param == 'scaduti' )
    {
//        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV'  ).innerHTML = 'Bandi Forniture e Servizi a cui sto partecipando scaduti. (Solo Procedure Aperte, Ristrette ed Avvisi)';
//        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Forniture e Servizi a cui sto partecipando scaduti. (Solo Procedure Aperte, Ristrette ed Avvisi)';
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV_INDIRETTI'  ).innerHTML = 'Bandi scaduti a cui ho partecipato Indirettamente (Mandante o Esecutrice dei Lavori)';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi scaduti a cui ho partecipato Indirettamente (Mandante o Esecutrice dei Lavori)';
    }
    else
    {
//        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV'  ).innerHTML = 'Bandi Forniture e Servizi a cui sto partecipando (solo Procedure Aperte, Ristrette ed Avvisi)';
//        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Forniture e Servizi a cui sto partecipando (solo Procedure Aperte, Ristrette ed Avvisi)';
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV_INDIRETTI'  ).innerHTML = 'Bandi a cui sto partecipando Indirettamente (Mandante o Esecutrice dei Lavori)';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi a cui sto partecipando Indirettamente (Mandante o Esecutrice dei Lavori)';
    }
    parent.ExecFunction1( URL , 'self','' )

}


function OpenOfferteCollegati(objGrid , Row , c  )
{
  
  var OpenOfferte='';
  
  try	{ 	OpenOfferte = getObjValue( 'val_R' + Row + '_OpenOfferte')	}catch( e ) {};
  
  if ( OpenOfferte == '')
    return;
   
 	var Fascicolo = '';
	try	{ 	Fascicolo = getObjValue( 'R' + Row + '_Fascicolo')	}catch( e ) {};

	var Folder= '186';
	var msgISubType='';
	try	{ 	msgISubType = getObjValue( 'R' + Row + '_msgISubType')	}catch( e ) {};
	
	//offerte del flusso licitazione privata vecchio
	if 	(msgISubType == '37' || msgISubType == '21')
	 Folder = '38';
	
	//offerte del flusso aperte vecchio
	if 	(msgISubType == '25')
	 Folder = '27';
	
	//offerte del flusso aperte vecchio
	if 	(msgISubType == '49')
	 Folder = '54';
	
	//offerte del flusso in economia vecchio
	if 	(msgISubType == '69')
	 Folder = '70';
	 
	var URL = '../dashboard/mainView.asp?A=A&FOLDER=' + Folder + '&FOLDER_GROUP=LINKED_DOCUMENTI_INDIRETTI&FilterHide= Fascicolo = \'' + Fascicolo + '\' ';
	
	//alert(URL);
	parent.parent.parent.DocumentiCollegati( URL );

}
