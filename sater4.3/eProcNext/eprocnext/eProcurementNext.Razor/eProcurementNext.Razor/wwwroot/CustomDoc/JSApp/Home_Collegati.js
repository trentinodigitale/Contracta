

function OpenCollegati(objGrid , Row , c  )
{
  
	var Fascicolo = '';
	try	{ 	Fascicolo = getObjValue( 'R' + Row + '_Fascicolo')	}catch( e ) {};

	//alert(Fascicolo);
	var URL = '../dashboard/mainView.asp?A=A&FOLDER_GROUP=LINKED_ISCRIZIONE_ALBO&FilterHide= Fascicolo = \'' + Fascicolo + '\' ';
	
	
	parent.parent.parent.DocumentiCollegati( URL );

}
function OpenCollegati_NEW(objGrid , Row , c  )
{
  
	var Fascicolo = '';
	try	{ 	Fascicolo = getObjValue( 'R' + Row + '_Fascicolo')	}catch( e ) {};

	
	var URL = '../dashboard/mainView.asp?A=A&FOLDER_GROUP=LINKED_CONSULTAZIONE_BANDO&FilterHide= Fascicolo = \'' + Fascicolo + '\' ';
	
	
	parent.parent.parent.DocumentiCollegati( URL );

}

function ChangeViewBandi( Param , URL )
{
    if ( Param == 'scaduti' )
    {
    
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORI'  ).innerHTML = 'Bandi di iscrizione all\'albo fornitori scaduti';
        
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi di iscrizione all\'albo fornitori scaduti';
    }
    else
    {
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORI'  ).innerHTML = 'Bandi di iscrizione all\'albo fornitori';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi di iscrizione all\'albo fornitori';
    }
    parent.ExecFunction1( URL , 'self','' )

}


function ChangeViewBandiSDA( Param , URL )
{
    if ( Param == 'scaduti' )
    {
    
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_ISCRIZIONE_SDA'  ).innerHTML = 'Bandi Privati SDA scaduti';
        
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Privati SDA scaduti';
    }
    else
    {
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_ISCRIZIONE_SDA'  ).innerHTML = 'Bandi Privati SDA';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Privati SDA';
    }
    parent.ExecFunction1( URL , 'self','' )

}

function ChangeViewBandiSDAPUBB( Param , URL )
{
    if ( Param == 'scaduti' )
    {
    
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_PUBB_SDA'  ).innerHTML = 'Bandi Pubblicati SDA scaduti';
        
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Pubblicati SDA  scaduti';
    }
    else
    {
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_PUBB_SDA'  ).innerHTML = 'Bandi Pubblicati SDA';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Pubblicati SDA';
    }
    parent.ExecFunction1( URL , 'self','' )

}


function ChangeViewInviti( Param , URL )
{
    if ( Param == 'scaduti' )
    {
//        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_INVITI_FORN_SERV_PRIV'  ).innerHTML = 'Inviti Forniture e Servizi scaduti';
//        parent.parent.parent.getObj('descfolder').innerHTML = 'Inviti Forniture e Servizi scaduti';
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_INVITI_FORN_SERV_PRIV'  ).innerHTML = 'Inviti scaduti';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Inviti scaduti';
    }
    else
    {
//        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_INVITI_FORN_SERV_PRIV'  ).innerHTML = 'Inviti Forniture e Servizi';
//        parent.parent.parent.getObj('descfolder').innerHTML = 'Inviti Forniture e Servizi';
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_INVITI_FORN_SERV_PRIV'  ).innerHTML = 'Inviti';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Inviti';
    }   
    parent.ExecFunction1( URL , 'self','' )

}

function ChangeViewInviti2( Param , URL )
{
    if ( Param == 'scaduti' )
    {
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_INVITI_LAVORI'  ).innerHTML = 'Inviti Lavori scaduti';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Inviti Lavori scaduti';
    }
    else
    {
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_INVITI_LAVORI'  ).innerHTML = 'Inviti Lavori';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Inviti Lavori';
    }   
    parent.ExecFunction1( URL , 'self','' )

}

function ChangeViewBandiPriv( Param , URL )
{
    if ( Param == 'scaduti' )
    {
//        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV'  ).innerHTML = 'Bandi Forniture e Servizi a cui sto partecipando scaduti. (Solo Procedure Aperte, Ristrette ed Avvisi)';
//        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Forniture e Servizi a cui sto partecipando scaduti. (Solo Procedure Aperte, Ristrette ed Avvisi)';
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV'  ).innerHTML = 'Bandi a cui sto partecipando scaduti. (Solo Procedure Aperte, Ristrette ed Avvisi)';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi a cui sto partecipando scaduti. (Solo Procedure Aperte, Ristrette ed Avvisi)';
    }
    else
    {
//        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV'  ).innerHTML = 'Bandi Forniture e Servizi a cui sto partecipando (solo Procedure Aperte, Ristrette ed Avvisi)';
//        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Forniture e Servizi a cui sto partecipando (solo Procedure Aperte, Ristrette ed Avvisi)';
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV'  ).innerHTML = 'Bandi a cui sto partecipando (solo Procedure Aperte, Ristrette ed Avvisi)';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi a cui sto partecipando (solo Procedure Aperte, Ristrette ed Avvisi)';
    }
    parent.ExecFunction1( URL , 'self','' )

}

function ChangeViewBandiPubblici( Param , URL )
{
    if ( Param == 'scaduti' )
    {
        //parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDI_FORN_SERV_PUBB'  ).innerHTML = 'Bandi Forniture e Servizi Pubblicati scaduti';
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDI_FORN_SERV_PUBB'  ).innerHTML = 'Bandi Pubblicati scaduti';
        //parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Forniture e Servizi Pubblicati scaduti';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Pubblicati scaduti';
    }
    else
    {
        //parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDI_FORN_SERV_PUBB'  ).innerHTML = 'Bandi Forniture e Servizi Pubblicati';
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDI_FORN_SERV_PUBB'  ).innerHTML = 'Bandi Pubblicati';
        //parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Forniture e Servizi Pubblicati';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Pubblicati';
    }
    parent.ExecFunction1( URL , 'self','' )

}


function ChangeViewBandiLavoriPriv( Param , URL )
{

    if ( Param == 'scaduti' )
    {
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV'  ).innerHTML = 'Bandi Forniture e Servizi a cui sto partecipando scaduti. (Solo Procedure Aperte, Ristrette ed Avvisi)';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Lavori Pubblici a cui sto partecipando scaduti.';
    }
    else
    {
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV'  ).innerHTML = 'Bandi Forniture e Servizi a cui sto partecipando (solo Procedure Aperte, Ristrette ed Avvisi)';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Lavori Pubblici a cui sto partecipando.';
    }
    parent.ExecFunction1( URL , 'self','' )

}

function ChangeViewBandiLavoriPriv2( Param , URL )
{
    if ( Param == 'scaduti' )
    {
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDILAVORIPRIVATI'  ).innerHTML = 'Bandi Lavori Pubblici a cui sto partecipando scaduti.';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Lavori Pubblici a cui sto partecipando scaduti.';
    }
    else
    {
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDILAVORIPRIVATI'  ).innerHTML = 'Bandi Lavori Pubblici a cui sto partecipando.';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Lavori Pubblici a cui sto partecipando.';
    }
    parent.ExecFunction1( URL , 'self','' )

}

function ChangeViewBandiLavoriPriv( Param , URL )
{
    
    if ( Param == 'scaduti' )
    {
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDILAVORIPUBBLICI'  ).innerHTML = 'Bandi Lavori Pubblicati scaduti.';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Lavori Pubblicati scaduti.';
    }
    else
    {
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_BANDILAVORIPUBBLICI'  ).innerHTML = 'Bandi Lavori Pubblicati.';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Bandi Lavori Pubblicati.';
    }
    parent.ExecFunction1( URL , 'self','' )

}

function ChangeView_ComFor( Param , URL )
{
    
    if ( Param == 'scaduti' )
    {
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_COMUNICAZIONI_FORNITORI'  ).innerHTML = 'Comunicazioni scadute';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Comunicazioni scadute';
    }
    else
    {
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_COMUNICAZIONI_FORNITORI'  ).innerHTML = 'Comunicazioni';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Comunicazioni';
    }
    parent.ExecFunction1( URL , 'self','' )

}

function ChangeView_Answer_ComFor( Param , URL )
{
    
    if ( Param == 'scaduti' )
    {
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_COMUNICAZIONI_RISPOSTA_FORNITORI'  ).innerHTML = 'Comunicazioni Risposta scadute';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Comunicazioni Risposta scadute';
    }
    else
    {
        parent.parent.getObj( 'TITLE_DASHBOARD_VIEW_COMUNICAZIONI_RISPOSTA_FORNITORI'  ).innerHTML = 'Comunicazioni Risposta';
        parent.parent.parent.getObj('descfolder').innerHTML = 'Comunicazioni Risposta';
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
	if 	( msgISubType == '37' || msgISubType == '21' )
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
	
	
	
   
	var URL = '../dashboard/mainView.asp?A=A&FOLDER=' + Folder + '&FOLDER_GROUP=LINKED_ISCRIZIONE_ALBO&FilterHide= Fascicolo = \'' + Fascicolo + '\' ';
	
	//alert(URL);
	parent.parent.parent.DocumentiCollegati( URL );

}

