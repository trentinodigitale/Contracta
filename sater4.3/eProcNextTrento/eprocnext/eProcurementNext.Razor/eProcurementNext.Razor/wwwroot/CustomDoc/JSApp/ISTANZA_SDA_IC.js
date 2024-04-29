
var LstAttrib = [
'NomeRapLeg',
'CognomeRapLeg',
'LocalitaRapLeg',
'ProvinciaRapLeg',
'StatoRapLeg',
'DataRapLeg',
'CFRapLeg',
'TelefonoRapLeg',
'CellulareRapLeg',
'ResidenzaRapLeg',
'ProvResidenzaRapLeg',
'StatoResidenzaRapLeg',
'IndResidenzaRapLeg',
'CapResidenzaRapLeg',
'RagSoc',
//'NaGi',
'INDIRIZZOLEG',
'LOCALITALEG',
'CAPLEG',
'PROVINCIALEG',
'STATOLOCALITALEG',
'NUMTEL',
//'NUMFAX',
'codicefiscale',
'PIVA',
'CittaEntrate',
'SettoriCCNL'//,
//'Numerodipendenti',
//'tribunale_di',
//'autorizzazione_n',
//'Data'
//'CheckProcedureAffidamento'
];

var LstAttribEsteri = [
'NomeRapLeg',
'CognomeRapLeg',
'LocalitaRapLeg',
'ProvinciaRapLeg',
'StatoRapLeg',
'DataRapLeg',
'CFRapLeg',
'TelefonoRapLeg',
'CellulareRapLeg',
'ResidenzaRapLeg',
'ProvResidenzaRapLeg',
'StatoResidenzaRapLeg',
'IndResidenzaRapLeg',
'CapResidenzaRapLeg',
'RagSoc',
//'NaGi',
'INDIRIZZOLEG',
'LOCALITALEG',
'CAPLEG',
'PROVINCIALEG',
'STATOLOCALITALEG',
'NUMTEL',
//'NUMFAX',
'codicefiscale',
'PIVA',
'CittaEntrate'
//,'SettoriCCNL',
//'Numerodipendenti',
//'tribunale_di',
//'autorizzazione_n',
//'Data'
//'CheckProcedureAffidamento'
];

var NumControlli = LstAttrib.length;
var NumControlliEsteri = LstAttribEsteri.length;

function trim(str){
    return str.replace(/^\s+|\s+$/g,"");
}

function InvioIstanza( param )
{
	

	if ( getObjValue('RichiestaFirma') == 'no')
	{
		if ( getObjValue('JumpCheck') != 'Conferma' )
		{
			var value=controlli(param);
		}
		if (value == -1)
			return;
		
		if ( verifyCap( 'ResidenzaRapLeg2', getObj('CapResidenzaRapLeg') ) && verifyCap( 'LOCALITALEG2', getObj('CAPLEG') ) )
		{
			ExecDocProcess( 'PRE_SEND,ISTANZA_SDA_FARMACI');
		}

	}
	if (getObjValue('Attach') == "" && getObjValue('RichiestaFirma') != 'no' )
	{
		DMessageBox( '../' , 'Prima di Inviare il documento allegare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
		return;
	}
	if (getObjValue('Attach') != "" )
	{
		if ( verifyCap( 'ResidenzaRapLeg2', getObj('CapResidenzaRapLeg') ) && verifyCap( 'LOCALITALEG2', getObj('CAPLEG') ) )
		{
			ExecDocProcess( 'PRE_SEND,ISTANZA_SDA_FARMACI');
		}		
	}
	
}

function GeneraPDF ()
{
	var value2=controlli('');
	var EsitoRiga=controlloEsitoRiga();
	if (value2 == -1)
	return;
    Stato = getObjValue('StatoDoc');
    
    if( Stato == '' ) 
    {
        alert( 'Per effettuare il \"Genera PDF\" si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di \"Genera PDF\"');
	//	DMessageBox( '../' , 'Per procedere si richiede prima un salvataggio, successivamente effettuare nuovamente il comando genera pdf.' , 'Attenzione' , 1 , 400 , 300 );
        MySaveDoc();
        return;
	}
	if ( EsitoRiga == -1 )
	{
		return;
	}
    scroll(0,0);    
	PrintPdfSign('URL=/report/prn_' + getObj('TYPEDOC').value + '.ASP?SIGN=YES&PROCESS=ISTANZA@@@VERIFICHE_PRE_PDF');
	

	
}

function controlloEsitoRiga()
{
	if ( getObjValue( 'RichiediProdotti' ) == '1' )
	{
		var numerorigheprdotti = GetProperty( getObj('PRODOTTIGrid') , 'numrow');

		if ( numerorigheprdotti == -1 )
		{
			DMessageBox( '../' , 'Prima di Generare il Pdf Compilare la sezione dei prodotti.' , 'Attenzione' , 1 , 400 , 300 );
			DocShowFolder( 'FLD_PRODOTTI' );	   
			return - 1;
		}
		
		
		if ( trim(getObj('EsitoRiga').value) != '' )
		//for( i = 0 ; i <= numerorigheprdotti ; i++ )
		{
		   
			//if( getObjValue('R' + i + '_EsitoRiga') != '<img src="../images/Domain/State_OK.gif">' )
			//{
			DMessageBox( '../' , 'Prima di Generare il Pdf Compilare correttamente la sezione dei prodotti.' , 'Attenzione' , 1 , 400 , 300 );
			DocShowFolder( 'FLD_PRODOTTI' );	   
			return - 1;
			//}
		}
	}	
}
function TogliFirma () 
{
	//DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
	ExecDocProcess( 'SIGN_ERASE,FirmaDigitale');
	
	
}

function SetInitField()
{
    
	var i = 0;
	var codiceStato = '';
	
	try
	{
		codiceStato = getObjValue('STATOLOCALITALEG2');
	}
	catch(e)
	{
	}
	
	//Se lo stato è avvalorato ed è diverso da italia
	if ( codiceStato != '' && codiceStato != 'M-1-11-ITA' )
	{
		for( i = 0 ; i < NumControlliEsteri ; i++ )
		{
			if ( getObjValue('Not_Editable').indexOf( LstAttribEsteri[i] + ' ,') < 0 )
			{
				TxtOK( LstAttribEsteri[i] );
			}
		}
	}
	else
	{
	
		for( i = 0 ; i < NumControlli ; i++ )
		{
			if ( getObjValue('Not_Editable').indexOf( LstAttrib[i] + ' ,') < 0 )
			{
				TxtOK( LstAttrib[i] );
			}
		}
	
	}
    
} 


function OnChangeBelongCCIAA (obj)
{
    try{
		if( getObjValue( 'BelongCCIAA' ) == 'NO'   )
		{
			document.getElementById('BelongCCIAADIV').style.display = "none";	    
		}
		if( getObjValue( 'BelongCCIAA' ) == 'SI' )
		{
			document.getElementById('BelongCCIAADIV').style.display = "";	    
		}
	}catch( e ) 
	{
		if( getObjValue( 'val_BelongCCIAA' ) == 'NO'   )
		{
			document.getElementById('BelongCCIAADIV').style.display = "none";	    
		}
		if( getObjValue( 'val_BelongCCIAA' ) == 'SI' )
		{
			document.getElementById('BelongCCIAADIV').style.display = "";	    
		}
	}
	
	
	
}
function CheckRadio10secondo(obj)
{
	
	if( GetProperty( getObj('CESSATIGrid') , 'numrow')==-1)
	ExecDocCommand( 'CESSATI#AddNew#');
}

function IsNumeric2(sText)
{
	var ValidChars = '0123456789.';
	var IsNumber=true;
	var Char;
	
	for (i = 0; i < sText.length && IsNumber == true; i++) 
	{ 
		Char = sText.charAt(i);
		if (ValidChars.indexOf(Char) == -1) 
		{
			IsNumber = false;
		}
	}
	return IsNumber;
	
}


function roundTo(X , decimalpositions)
{
    var i = X * Math.pow(10,decimalpositions);
    i = Math.round(i);
    return i / Math.pow(10,decimalpositions);
}

function ControllaCF(cf)
{
    var validi, i, s, set1, set2, setpari, setdisp;
    if( cf == '' )  return '';
    cf = cf.toUpperCase();
    if( cf.length != 16 )
	return "La lunghezza del codice fiscale non e'\n"
	+"corretta: il codice fiscale dovrebbe essere lungo\n"
	+"esattamente 16 caratteri.";
    validi = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    for( i = 0; i < 16; i++ ){
        if( validi.indexOf( cf.charAt(i) ) == -1 )
		return "Il codice fiscale contiene un carattere non valido \'" +
		cf.charAt(i) +
		"\'.\nI caratteri validi sono le lettere e le cifre.";
	}
    set1 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    set2 = "ABCDEFGHIJABCDEFGHIJKLMNOPQRSTUVWXYZ";
    setpari = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    setdisp = "BAKPLCQDREVOSFTGUHMINJWZYX";
    s = 0;
    for( i = 1; i <= 13; i += 2 )
	s += setpari.indexOf( set2.charAt( set1.indexOf( cf.charAt(i) )));
    for( i = 0; i <= 14; i += 2 )
	s += setdisp.indexOf( set2.charAt( set1.indexOf( cf.charAt(i) )));
    if( s%26 != cf.charCodeAt(15)-'A'.charCodeAt(0) )
	return "Il codice fiscale non e\' corretto:\n"+
	"il codice di controllo non corrisponde.";
    return "";
}

function ControllaPIVA(pi)
{
    if( pi == '' )  return '';
    if( pi.length != 11 )
	return "La lunghezza della partita IVA non e\'\n" +
	"corretta: la partita IVA dovrebbe essere lunga\n" +
	"esattamente 11 caratteri.";
    validi = "0123456789";
    for( i = 0; i < 11; i++ ){
        if( validi.indexOf( pi.charAt(i) ) == -1 )
		return "La partita IVA contiene un carattere non valido \'" +
		pi.charAt(i) + "'.\nI caratteri validi sono le cifre.";
	}
    s = 0;
    for( i = 0; i <= 9; i += 2 )
	s += pi.charCodeAt(i) - '0'.charCodeAt(0);
    for( i = 1; i <= 9; i += 2 ){
        c = 2*( pi.charCodeAt(i) - '0'.charCodeAt(0) );
        if( c > 9 )  c = c - 9;
        s += c;
	}
    if( ( 10 - s%10 )%10 != pi.charCodeAt(10) - '0'.charCodeAt(0) )
	return "La partita IVA non e\' valida:\n" +
	"il codice di controllo non corrisponde.";
    return '';
}


function LocalPrintPdf( param )
{
    
    Stato = getObjValue('StatoDoc');
	//alert(getObj('TYPEDOC').value);
    param = '/report/prn_' + getObj('TYPEDOC').value + '.ASP?'
    if( Stato == '' ) 
    {
        alert( 'Per effettuare la stampa si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di stampa');
	//	DMessageBox( '../' , 'Per effettuare la stampa si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di stampa.' , 'Attenzione' , 1 , 400 , 300 );
        
		
        MySaveDoc();
        return;
	}

    
    PrintPdf( param );
	
}

function HideProdotti()
{

	try
	{
		if ( getObjValue( 'RichiediProdotti' ) == '0' || getObjValue( 'RichiediProdotti' ) == '2' )
		{
			//document.getElementById('PRODOTTI').style.display = "none";
			DocDisplayFolder( 'PRODOTTI' , 'none' );
		}
	}
	catch(e)
	{
	}

}
//funzione per inserire nella sezione documentazione i tipi allegati consentiti scelti in creazione del BANDO
function FormatAllegato()
{
	var numDocu = GetProperty( getObj('DOCUMENTAZIONEGrid') , 'numrow');
	var tipofile;
	var richiestaFirma;
	var onclick;
	var obj;
	
	for( i = 0 ; i <= numDocu ; i++ )
	{
		try
		{
			tipofile=getObj('RDOCUMENTAZIONEGrid_' + i + '_TipoFile').value;
			
			try
			{
				richiestaFirma=getObj('RDOCUMENTAZIONEGrid_' + i + '_RichiediFirma').value;
			}
			catch(e)
			{
				richiestaFirma='';
			}
			
			tipofile=ReplaceExtended(tipofile,'###',',');
			tipofile='INTVEXT:'+tipofile.substring(1,tipofile.length);
			tipofile=tipofile.substring(0, tipofile.length-1)+'-';
			tipofile='FORMAT='+tipofile;

			if ( richiestaFirma == '1' )
			{
				tipofile = tipofile + 'B'; //format per forzare la verifica di firma bloccante in caso di mancata firma o file corrotto
			}

			obj=getObj('RDOCUMENTAZIONEGrid_' + i + '_Allegato_V_BTN' ).parentElement;
			onclick=obj.innerHTML;
			onclick=onclick.replace(/FORMAT=INTV/g,tipofile);
			onclick=onclick.replace(/FORMAT=INT/g,tipofile);
			obj.innerHTML = onclick;
			
			//se per qualche motivo tolta INTV nasconde img della pennina
			
			try
			{
				if ( onclick.indexOf('FORMAT=INTV') < 0 )
				{
					$('#RDOCUMENTAZIONEGrid_' + i + '_Allegato_V_N').siblings('.IMG_SIGNINFO').hide();					
				}
			}
			catch(e)
			{		
			}
			
		}
		catch(e){}
	}
	
}
function DISPLAY_FIRMA_OnLoad()
{
    try
	{
		//uso questo metodo al posto di afterprocess in quanto non disponibile parti del documento, così faccio l'operazione a documento catricato
		if ( getQSParam('PROCESS_PARAM') == 'FITTIZIO,ISTANZA_SDA_2,,NO_MSG' )
		{
			if ( getObj('Categorie_Merceologiche').value != '' )
			{
				var cod=getObj( "IDDOC" ).value;	  
			
				strCommand = 'GRIGLIA_CATEGORIE#ADDFROM#' + 'IDROW=' + cod + '&MULTI_RECORD=YES&TABLEFROMADD=View_GRIGLIA_CATEGORIE_FROMADD_CATEGORIE_MERCEOLOGICHE';	
				ExecDocCommand( strCommand );
			}
			getObj('Categorie_Merceologiche_edit_new').focus();

		}
	}
	catch(e){}
	Gestione_Categorie();
	HideCestinodoc();
	HideProdotti();
	FormatAllegato();
	
	
	Stato ='';
	Stato = getObjValue('StatoDoc');
	IdpfuInCharge = getObjValue('IdpfuInCharge');
	/*if ( Stato != 'Saved' && Stato != '' )
		{
		document.getElementById('DIV_FIRMA').style.display = "none";	
	}*/
	
	if (  getObjValue('PresenzaDGUE') != 'si')
	{
	  document.getElementById('DIV_DGUE').style.display = "none";	
	}
	
	if ( getObjValue('RichiestaFirma') == 'no')
	{
		document.getElementById('DIV_FIRMA').style.display = "none";	
	}
	
	if ((getObjValue('SIGN_LOCK') =='0' || getObjValue('SIGN_LOCK') =='')   && (Stato=='Saved' || Stato=="") && IdpfuInCharge == idpfuUtenteCollegato )
    {
		document.getElementById('generapdf').disabled = false; 
		document.getElementById('generapdf').className ="generapdf";
	}
	else
	{
		document.getElementById('generapdf').disabled = true; 
		document.getElementById('generapdf').className ="generapdfdisabled";
	}
	
	
	if ( getObjValue('SIGN_LOCK') != '0'   && (Stato=='Saved') && IdpfuInCharge == idpfuUtenteCollegato )
    {
		document.getElementById('editistanza').disabled = false; 
		document.getElementById('editistanza').className ="attachpdf";
	}
	else
	{
		document.getElementById('editistanza').disabled = true; 
		document.getElementById('editistanza').className ="attachpdfdisabled";
	} 
	if (getObjValue('SIGN_ATTACH') ==''  &&  (Stato=='Saved') && getObjValue('SIGN_LOCK') != '0'  && IdpfuInCharge == idpfuUtenteCollegato )
    {
		document.getElementById('attachpdf').disabled = false; 
		document.getElementById('attachpdf').className ="editistanza";
	}
	else
	{
		document.getElementById('attachpdf').disabled = true; 
		document.getElementById('attachpdf').className ="editistanzadisabled";
	}
	if (  IdpfuInCharge != idpfuUtenteCollegato )
	{
		getObj('apriGEO' + '_link').setAttribute("onclick", "return false;" );
		getObj('apriGEO').className = "";
		getObj('apriGEO' + '_link').style.cursor="default";
		
		getObj('apriGEO2' + '_link').setAttribute("onclick", "return false;" );
		getObj('apriGEO2').className = "";
		getObj('apriGEO2' + '_link').style.cursor="default";
		
		getObj('apriGEO3' + '_link').setAttribute("onclick", "return false;" );
		getObj('apriGEO3').className = "";
		getObj('apriGEO3' + '_link').style.cursor="default";
	}
	
	if ( getObjValue('PresenzaDGUE') == 'si' )
	{
	  
		document.getElementById('CompilaDGUE').disabled = false; 
		document.getElementById('CompilaDGUE').className ="CompilaDGUE";
		
	}
	
	initAziEnte();
	Messaggio_Readonly();
    
	
}
window.onload = DISPLAY_FIRMA_OnLoad;

function Messaggio_Readonly()
{
	if( getObj( "StatoFunzionale" ).value == 'InLavorazione' && getObj( "BANDO_SCADUTO" ).value == 'si' )
	{
		DMessageBox( '../' , 'I termini di presentazione dell\'istanza sono scaduti' , 'Attenzione' , 1 , 400 , 300 );
	}
}

function controlli (param)
{
if (getObj('DOCUMENT_READONLY').value != '1' )
{	
	var err = 0;
    var	cod = getObj( "IDDOC" ).value;


    if( getObj( "DOCUMENT_READONLY" ).value == '1' )
        return 0;
	
	
	//DOCUMENT_READONLY
	
    var strRet = CNV( '../' , 'ok' );
	
	
	
	SetInitField();
	
	var strPIVA_Obbligatoria = getObjValue('PIVA_Obbligatoria');
	//alert(strPIVA_Obbligatoria);
	//-- effettuare tutti i controlli
	
	
    //-- controllo i dati della richiesta
    var i = 0;
    var err = 0;
	var codiceStato = '';
	
	try
	{
		codiceStato = getObjValue('STATOLOCALITALEG2');
	}
	catch(e)
	{
	}
	
	//Se lo stato è avvalorato ed è diverso da italia
	if ( codiceStato != '' && codiceStato != 'M-1-11-ITA' )
	{
		
		for( i = 0 ; i < NumControlliEsteri ; i++ )
		{
			
			//se l'azienda non aveva la PIVA allora è facoltativo altrimenti obbligatorio
			if  ( LstAttribEsteri[i] !=  'PIVA' || (  LstAttribEsteri[i] ==  'PIVA' && strPIVA_Obbligatoria =='si' ) )
			{
				
				try
				{
					if ( getObjValue('Not_Editable').indexOf( LstAttribEsteri[i] + ' ,') < 0 )
					{			
					
						if ( getObj(LstAttribEsteri[i]).type == 'text' || getObj(LstAttribEsteri[i]).type == 'hidden' 
						||  getObj(LstAttribEsteri[i]).type == 'select-one' ||  getObj(LstAttribEsteri[i]).type == 'textarea')
						{
							if( trim(getObjValue( LstAttribEsteri[i] )) == '' )
							{
								err = 1;
								TxtErr( LstAttribEsteri[i] );
							}
						}
						
						if ( getObj(LstAttribEsteri[i]).type == 'checkbox' )
						{
							if( getObj( LstAttribEsteri[i] ).checked == false )
							{
								err = 1;
								TxtErr( LstAttribEsteri[i] );
							}
						}
					}
					
				}
				catch(e)
				{
					alert( i + ' - ' +  LstAttribEsteri[i] );
				}
			}
		}
	}
	else
	{
	
		for( i = 0 ; i < NumControlli ; i++ )
		{
			//se l'azienda non aveva la PIVA allora è facoltativo altrimenti obbligatorio
			if  ( LstAttrib[i] !=  'PIVA' || (  LstAttrib[i] ==  'PIVA' && strPIVA_Obbligatoria =='si' ) )
			{
				
				try{
					if ( getObjValue('Not_Editable').indexOf( LstAttrib[i] + ' ,') < 0 )
					{			
					
						if ( getObj(LstAttrib[i]).type == 'text' || getObj(LstAttrib[i]).type == 'hidden' 
						||  getObj(LstAttrib[i]).type == 'select-one' ||  getObj(LstAttrib[i]).type == 'textarea')
						{
							if( trim(getObjValue( LstAttrib[i] )) == '' )
							{
								err = 1;
								TxtErr( LstAttrib[i] );
							}
						}
						
						if ( getObj(LstAttrib[i]).type == 'checkbox' )
						{
							if( getObj( LstAttrib[i] ).checked == false )
							{
								err = 1;
								TxtErr( LstAttrib[i] );
							}
						}
					}
					
				}catch(e)
				{
					alert( i + ' - ' +  LstAttrib[i] );
				}
			}
		}
		
	}
	
	//if( getObjValue( 'BelongCCIAA' ) == 'SI' )
	//{     		
		if( trim(getObjValue( 'SedeCCIAA' )) == '' ){err = 1;TxtErr( 'SedeCCIAA' );}
		//if( trim(getObjValue( 'ANNOCOSTITUZIONE' )) == '' ){err = 1;TxtErr( 'ANNOCOSTITUZIONE' );}
		if( trim(getObjValue( 'IscrCCIAA' )) == '' ){err = 1;TxtErr( 'IscrCCIAA' );}
		
	//}

	/*if( getObj( 'CheckProcedureAffidamento' ).checked == true )
    {
		if( trim(getObjValue( 'autorizzazione_n' )) == '' ){err = 1;TxtErr( 'autorizzazione_n' );}else{TxtOK('autorizzazione_n')}
		if( trim(getObjValue( 'Data' )) == '' ){err = 1;TxtErr( 'Data' );}else{TxtOK('Data')}
		if( trim(getObjValue( 'tribunale_di' )) == '' ){err = 1;TxtErr( 'tribunale_di' );}else{TxtOK('tribunale_di')}
	
	}*/
	
	/*if( getObj( 'CheckReati2' ).checked == true )
    {
		if( trim(getObjValue( 'SentenzaReati' )) == '' ){err = 1;TxtErr( 'SentenzaReati' );}	
	}
	*/
	if( GetProperty(getObj('val_RuoloRapLeg'),'value').indexOf('PROCURATORE SPECIALE') > -1 )
    {
		 if( trim(getObjValue( 'Procura' )) == '' ){err = 1;TxtErr( 'Procura' );}else{TxtOK('Procura')}
		 if( trim(getObjValue( 'DelProcura' )) == '' ){err = 1;TxtErr( 'DelProcura' );}else{TxtOK('DelProcura')}
		 if( trim(getObjValue( 'NumProcura' )) == '' ){err = 1;TxtErr( 'NumProcura' );}else{TxtOK('NumProcura')}
		 if( trim(getObjValue( 'NumRaccolta' )) == '' ){err = 1;TxtErr( 'NumRaccolta' );}else{TxtOK('NumRaccolta')}
	}
	
	/*var numeroRighe0 = GetProperty( getObj('SOGGETTIGrid') , 'numrow');
	
	
	 if(  Number( numeroRighe0 ) < 0 )
		{
		numeroRighe0=0;
		ExecDocCommand( 'SOGGETTI#AddNew#');      
		
		}
	
	for( i = 0 ; i <= numeroRighe0 ; i++ )
	{
		try
		{
      	    if( getObjValue( 'RSOGGETTIGrid_' + i + '_NomeDirTec' ) == '' )
            {
				err = 1;
				TxtErr( 'RSOGGETTIGrid_' + i + '_NomeDirTec' );
			}
			else
			{
				
				TxtOK( 'RSOGGETTIGrid_' + i + '_NomeDirTec' );
			}
			
      	    if( getObjValue( 'RSOGGETTIGrid_' + i + '_CognomeDirTec' ) == '' )
            {
				err = 1;
				TxtErr( 'RSOGGETTIGrid_' + i + '_CognomeDirTec' );
			}
			else
			{
				
				TxtOK( 'RSOGGETTIGrid_' + i + '_CognomeDirTec' );
			}
			
			
			
      	    if( getObjValue( 'RSOGGETTIGrid_' + i + '_LocalitaDirTec' ) == '' )
            {
				err = 1;
				TxtErr( 'RSOGGETTIGrid_' + i + '_LocalitaDirTec' );
			}
			else
			{
				
				TxtOK( 'RSOGGETTIGrid_' + i + '_LocalitaDirTec' );
			}
			
			
			
      	    if( getObjValue( 'RSOGGETTIGrid_' + i + '_DataDirTec' ) == '' )
            {
				err = 1;
				TxtErr( 'RSOGGETTIGrid_' + i + '_DataDirTec' );
			}
			else
			{
				
				TxtOK( 'RSOGGETTIGrid_' + i + '_DataDirTec' );
			}
			
			
			
      	    if( getObjValue( 'RSOGGETTIGrid_' + i + '_CFDirTec' ) == '' )
            {
				err = 1;
				TxtErr( 'RSOGGETTIGrid_' + i + '_CFDirTec' );
			}
			else
			{
				
				TxtOK( 'RSOGGETTIGrid_' + i + '_CFDirTec' );
			}
			
			
			
      	    if( getObjValue( 'RSOGGETTIGrid_' + i + '_RuoloDirTec' ) == '' )
            {
				err = 1;
				TxtErr( 'RSOGGETTIGrid_' + i + '_RuoloDirTec' );
			}
			else
			{
				
				TxtOK( 'RSOGGETTIGrid_' + i + '_RuoloDirTec' );
			}
			
			
		    if( getObjValue( 'RSOGGETTIGrid_' + i + '_ResidenzaDirTec' ) == '' )
            {
				err = 1;
				TxtErr( 'RSOGGETTIGrid_' + i + '_ResidenzaDirTec' );
			}
			else
			{
				
				TxtOK( 'RSOGGETTIGrid_' + i + '_ResidenzaDirTec' );
			}
			
			
			
		}catch(e)	  {	  }
	}
	*/
	
	
	//controllo la prensenza di allegati nella sezione della documentazione
	var numeroRigheDOC = GetProperty( getObj('DOCUMENTAZIONEGrid') , 'numrow');
	
	for( i = 0 ; i <= numeroRigheDOC ; i++ )
	{
		if(getObj('RDOCUMENTAZIONEGrid_' + i + '_Obbligatorio').value == '1')
		{
			try
			{
				
				if( getObjValue( 'RDOCUMENTAZIONEGrid_' + i + '_Allegato' ) == '' )
				{
					err = 1;
					TxtErr( 'RDOCUMENTAZIONEGrid_' + i + '_Allegato' );
				}
				else
				{
					
					TxtOK( 'RDOCUMENTAZIONEGrid_' + i + '_Allegato' );
				}
				
				
			}catch(e)	  {	  }
		}
	}
	
	
	
	
	
	
	
	/*if( getObj( 'Checkcessati2' ).checked == true )
    {
		
		var numeroRighe = GetProperty( getObj('CESSATIGrid') , 'numrow');
		
		
		if(  Number( numeroRighe ) < 0 )
		{
			//movePageTo(  findPos(getObj('CESSATIGrid'))  );
			DMessageBox( '../' , 'Avvalorare almeno una riga  nella sezione di dettaglio CESSATI' , 'Attenzione' , 1 , 400 , 300 ); 
			
			return -1 ;
		}
		for( i = 0 ; i <= numeroRighe ; i++ )
		{
			try
			{
				if( getObjValue( 'RCESSATIGrid_' + i + '_NomeSogCessato' ) == '' )
				{
					err = 1;
					TxtErr( 'RCESSATIGrid_' + i + '_NomeSogCessato' );
				}
				else
				{
					
					TxtOK( 'RCESSATIGrid_' + i + '_NomeSogCessato' );
				}
				
				if( getObjValue( 'RCESSATIGrid_' + i + '_CognomeSogCessato' ) == '' )
				{
					err = 1;
					TxtErr( 'RCESSATIGrid_' + i + '_CognomeSogCessato' );
				}
				else
				{
					
					TxtOK( 'RCESSATIGrid_' + i + '_CognomeSogCessato' );
				}
				
				
				
				if( getObjValue( 'RCESSATIGrid_' + i + '_LocalitaSogCessato' ) == '' )
				{
					err = 1;
					TxtErr( 'RCESSATIGrid_' + i + '_LocalitaSogCessato' );
				}
				else
				{
					
					TxtOK( 'RCESSATIGrid_' + i + '_LocalitaSogCessato' );
				}
				
				
				
				if( getObjValue( 'RCESSATIGrid_' + i + '_DataSogCessato' ) == '' )
				{
					err = 1;
					TxtErr( 'RCESSATIGrid_' + i + '_DataSogCessato' );
				}
				else
				{
					
					TxtOK( 'RCESSATIGrid_' + i + '_DataSogCessato' );
				}
				
				
				
				if( getObjValue( 'RCESSATIGrid_' + i + '_CFSogCessato' ) == '' )
				{
					err = 1;
					TxtErr( 'RCESSATIGrid_' + i + '_CFSogCessato' );
				}
				else
				{
					
					TxtOK( 'RCESSATIGrid_' + i + '_CFSogCessato' );
				}
				
				
				
				if( getObjValue( 'RCESSATIGrid_' + i + '_RuoloSogCessato' ) == '' )
				{
					err = 1;
					TxtErr( 'RCESSATIGrid_' + i + '_RuoloSogCessato' );
				}
				else
				{
					
					TxtOK( 'RCESSATIGrid_' + i + '_RuoloSogCessato' );
				}
				
				
				if( getObjValue( 'RCESSATIGrid_' + i + '_ResidenzaSogCessato' ) == '' )
				{
					err = 1;
					TxtErr( 'RCESSATIGrid_' + i + '_ResidenzaSogCessato' );
				}
				else
				{
					
					TxtOK( 'RCESSATIGrid_' + i + '_ResidenzaSogCessato' );
				}
				
				
				
			}catch(e)	  {	  }
		}
	}
	*/
	
	
	var NRPOSIZIONI_INPSGrid = GetProperty( getObj('POSIZIONI_INPSGrid') , 'numrow');
	
	
    if(  Number( NRPOSIZIONI_INPSGrid ) >= 0 )
    {
		
		for( i = 0 ; i <= NRPOSIZIONI_INPSGrid ; i++ )
		{
			try
			{
				if( getObjValue( 'RPOSIZIONI_INPSGrid_' + i + '_NumINPS' ) == '' )
				{
					err = 1;
					TxtErr( 'RPOSIZIONI_INPSGrid_' + i + '_NumINPS' );
				}
				else
				{
					
					TxtOK( 'RPOSIZIONI_INPSGrid_' + i + '_NumINPS' );
				}
				
				if( getObjValue( 'RPOSIZIONI_INPSGrid_' + i + '_SedeINPS' ) == '' )
				{
					err = 1;
					TxtErr( 'RPOSIZIONI_INPSGrid_' + i + '_SedeINPS' );
				}
				else
				{
					
					TxtOK( 'RPOSIZIONI_INPSGrid_' + i + '_SedeINPS' );
				}
				
				if( getObjValue( 'RPOSIZIONI_INPSGrid_' + i + '_IndirizzoINPS' ) == '' )
				{
					err = 1;
					TxtErr( 'RPOSIZIONI_INPSGrid_' + i + '_IndirizzoINPS' );
				}
				else
				{
					
					TxtOK( 'RPOSIZIONI_INPSGrid_' + i + '_IndirizzoINPS' );
				}
				
				
				
				
				
			}catch(e)	  {	  }
		}
	}
	
	
	
	
	var NRPOSIZIONI_INAILGrid = GetProperty( getObj('POSIZIONI_INAILGrid') , 'numrow');
	
	
    if(  Number( NRPOSIZIONI_INAILGrid ) >= 0 )
    {
		
		for( i = 0 ; i <= NRPOSIZIONI_INAILGrid ; i++ )
		{
			try
			{
				if( getObjValue( 'RPOSIZIONI_INAILGrid_' + i + '_NumINAIL' ) == '' )
				{
					err = 1;
					TxtErr( 'RPOSIZIONI_INAILGrid_' + i + '_NumINAIL' );
				}
				else
				{
					
					TxtOK( 'RPOSIZIONI_INAILGrid_' + i + '_NumINAIL' );
				}
				
				if( getObjValue( 'RPOSIZIONI_INAILGrid_' + i + '_SedeINAIL' ) == '' )
				{
					err = 1;
					TxtErr( 'RPOSIZIONI_INAILGrid_' + i + '_SedeINAIL' );
				}
				else
				{
					
					TxtOK( 'RPOSIZIONI_INAILGrid_' + i + '_SedeINAIL' );
				}
				
				
				
			}catch(e)	  {	  }
		}
	}
	
	var NRPOSIZIONI_CASSAEDILEGrid = GetProperty( getObj('POSIZIONI_CASSAEDILEGrid') , 'numrow');
	
	
    if(  Number( NRPOSIZIONI_CASSAEDILEGrid ) >= 0 )
    {
		
		for( i = 0 ; i <= NRPOSIZIONI_CASSAEDILEGrid ; i++ )
		{
			try
			{
				if( getObjValue( 'RPOSIZIONI_CASSAEDILEGrid_' + i + '_NumEdile' ) == '' )
				{
					err = 1;
					TxtErr( 'RPOSIZIONI_CASSAEDILEGrid_' + i + '_NumEdile' );
				}
				else
				{
					
					TxtOK( 'RPOSIZIONI_CASSAEDILEGrid_' + i + '_NumEdile' );
				}
				
				if( getObjValue( 'RPOSIZIONI_CASSAEDILEGrid_' + i + '_SedeEdile' ) == '' )
				{
					err = 1;
					TxtErr( 'RPOSIZIONI_CASSAEDILEGrid_' + i + '_SedeEdile' );
				}
				else
				{
					
					TxtOK( 'RPOSIZIONI_CASSAEDILEGrid_' + i + '_SedeEdile' );
				}
				
				
				
			
			}catch(e)	  {	  }
		}
	}
	
/*	if ( getObj( 'CheckReati1' ).checked == false &&  getObj( 'CheckReati2' ).checked == false )
	{
		err = 1;
		TxtErr( 'CheckReati1' );
		TxtErr( 'CheckReati2' );
	}
	else
	{
		TxtOK( 'CheckReati1' );
		TxtOK( 'CheckReati2' );
	}   
	
	
	/*if ( getObj( 'Checkdivieto1' ).checked == false &&  getObj( 'Checkdivieto2' ).checked == false )
	{
		err = 1;
		TxtErr( 'Checkdivieto1' );
		TxtErr( 'Checkdivieto2' );
	}
	else
	{
		TxtOK( 'Checkdivieto1' );
		TxtOK( 'Checkdivieto2' );
	}   */
	
	/*if ( getObj( 'Checkobbligo1' ).checked == false &&  getObj( 'Checkobbligo2' ).checked == false )
	{
		err = 1;
		TxtErr( 'Checkobbligo1' );
		TxtErr( 'Checkobbligo2' );
	}
	else
	{
		TxtOK( 'Checkobbligo1' );
		TxtOK( 'Checkobbligo2' );
	}   
	if ( getObj( 'Checkletteran1' ).checked == false &&  getObj( 'Checkletteran2' ).checked == false &&  getObj( 'Checkletteran3' ).checked == false )
	{
		err = 1;
		TxtErr( 'Checkletteran1' );
		TxtErr( 'Checkletteran2' );
		TxtErr( 'Checkletteran3' );
	}
	else
	{
		TxtOK( 'Checkletteran1' );
		TxtOK( 'Checkletteran2' );
		TxtOK( 'Checkletteran3' );
		
	}   
	
	if ( getObj( 'Checkcessati1' ).checked == false &&  getObj( 'Checkcessati2' ).checked == false )
	{
		err = 1;
		TxtErr( 'Checkcessati1' );
		TxtErr( 'Checkcessati2' );
	}
	else
	{
		TxtOK( 'Checkcessati1' );
		TxtOK( 'Checkcessati2' );
	}   
	
   if ( getObj( 'CheckVittime1' ).checked == false &&  getObj( 'CheckVittime2' ).checked == false )
   {
	  err = 1;
	  TxtErr( 'CheckVittime1' );
	  TxtErr( 'CheckVittime2' );
	}
	else
	{
			  TxtOK( 'CheckVittime1' );
			  TxtOK( 'CheckVittime2' );
	} 
	if ( getObj( 'CheckIntestazione1' ).checked == false &&  getObj( 'CheckIntestazione2' ).checked == false )
	    {
		 err = 1;
		  TxtErr( 'CheckIntestazione1' );
		  TxtErr( 'CheckIntestazione2' );
		}
		else
	    {
      			  TxtOK( 'CheckIntestazione1' );
      			  TxtOK( 'CheckIntestazione2' );
      	} 
	
	if ( getObj( 'CheckObblighi1' ).checked == false &&  getObj( 'CheckObblighi2' ).checked == false )
	   {
		  err = 1;
		  TxtErr( 'CheckObblighi1' );
		  TxtErr( 'CheckObblighi2' );
		}
		else
	    {
      			  TxtOK( 'CheckObblighi1' );
      			  TxtOK( 'CheckObblighi2' );
      	} 	
	//RIMOSSO VISTO CHE NELLA VERSIONE ATTUALE QUESTI CHECK NON SONO PRESENTI PIù
	/*	if ( getObj( 'CheckCasellario1' ).checked == false &&  getObj( 'CheckCasellario2' ).checked == false )
	   {
		  err = 1;
		  TxtErr( 'CheckCasellario1' );
		  TxtErr( 'CheckCasellario2' );
		}
		else
	    {
      			  TxtOK( 'CheckCasellario1' );
      			  TxtOK( 'CheckCasellario2' );
      	} 	
	*/
	try
	{
		if ( getObjValue( 'elenco_categorie_sda' ) != '' || ( getObjValue( 'Elenco_Categorie_Merceologiche' ) != ''  && getObjValue( 'Livello_Categorie_Merceologiche' ) != ''  && Get_CTL_PARAMETRI('SDA','EMPTY_IS_ALL','DefaultValue','true','-1') == 'true'  ) )		
		{
			if( trim(getObjValue('Categorie_Merceologiche' )) == '' )
			{
				err = 1;
				TxtErr( 'Categorie_Merceologiche' );
			}
			else
			{
				TxtOK('Categorie_Merceologiche' );
			}
		
		}
	}catch(e)	  {	  }
	
	if ( getObjValue('PresenzaDGUE') == 'si' && getObjValue('Allegato') == "" && err==0 )
		{
			DMessageBox( '../' , 'Per proseguire e\' necessaria la compilazione del Documento DGUE' , 'Attenzione' , 1 , 400 , 300 );
			return -1;
		}

	
    if(  err > 0 )
	{
		
		DMessageBox( '../' , 'Per proseguire e\' necessaria la compilazione di tutti i campi evidenziati' , 'Attenzione' , 1 , 400 , 300 );
        return -1;
	}
	
	if ( getObjValue( 'RichiediProdotti' ) == '1' )
	{
		var numerorigheprdotti = GetProperty( getObj('PRODOTTIGrid') , 'numrow');
		if ( numerorigheprdotti == -1 )
		{
			DMessageBox( '../' , 'Prima di Inviare il documento Compilare la sezione dei prodotti.' , 'Attenzione' , 1 , 400 , 300 );
			DocShowFolder( 'FLD_PRODOTTI' );	   
			return - 1;
		}
	}	
	
	
 }
}

function Reati1() 
{
	if( getObj( 'CheckReati1' ).checked == true )
    {
		
		getObj('CheckReati2').checked = false;
		getObj( 'SentenzaReati').value="";
		getObj( 'SentenzaReati').disabled=true;
		
		
	}
}
function Reati2() 
{
	if( getObj( 'CheckReati2' ).checked == true )
    {
		getObj('CheckReati1').checked = false;	    
		getObj( 'SentenzaReati').disabled=false;
	}
}
function Divieto1() 
{
	if( getObj( 'Checkdivieto1' ).checked == true )
    {
		
		getObj('Checkdivieto2').checked = false;
		
	}
}
function Divieto2() 
{
	if( getObj( 'Checkdivieto2' ).checked == true )
    {
		getObj('Checkdivieto1').checked = false;
	}
}

function Obbligo1() 
{
	if( getObj( 'Checkobbligo1' ).checked == true )
    {
		
		getObj('Checkobbligo2').checked = false;
		
	}
}
function Obbligo2() 
{
	if( getObj( 'Checkobbligo2' ).checked == true )
    {
		getObj('Checkobbligo1').checked = false;
	}
}
function Cessati1() 
{
	if( getObj( 'Checkcessati1' ).checked == true )
    {
		if( GetProperty( getObj('CESSATIGrid') , 'numrow') > -1) 
		{
			DMessageBox( '../' , 'Prima di cambiare la selezione eliminare le righe dalla griglia sottostante' , 'Attenzione' , 1 , 400 , 300 );
			getObj('Checkcessati1').checked = false;
			return;			 
		}
		getObj('Checkcessati2').checked = false;
		document.getElementById('TOOLBAR_CESSATI_ADDNEW').style.display = "none";	   
		
	}
}
function Cessati2() 
{
	if( getObj( 'Checkcessati2' ).checked == true )
    {
		getObj('Checkcessati1').checked = false;
		document.getElementById('TOOLBAR_CESSATI_ADDNEW').style.display = "";	   
	}
}

function Letteran1() 
{
	if( getObj( 'Checkletteran1' ).checked == true )
    {
		
		getObj('Checkletteran2').checked = false;
		getObj('Checkletteran3').checked = false;
		
	}
}
function Letteran2() 
{
	if( getObj( 'Checkletteran2' ).checked == true )
    {
		getObj('Checkletteran1').checked = false;
		getObj('Checkletteran3').checked = false;
	}
}

function Letteran3() 
{
	if( getObj( 'Checkletteran3' ).checked == true )
    {
		getObj('Checkletteran1').checked = false;
		getObj('Checkletteran2').checked = false;
	}
}



function callGerarchia(IDMP,StrDescGerarchia,GerarchieDinamiche,NomeFormCampi,nomecombo,idTipoGerarchia,pathGerarchia,RifFormDestHidden,NomeHiddenIdent,NomeHiddenDesc,nMaxElementi,bIsObligatory,strNomeFrameCombo,lIdAzi,OptionalConfirmScript,dztNomeAttrib)
{
	var sChiave
	
	const_width=600;
	const_height=500;
	sinistra=(screen.width-const_width)/2;
	alto=(screen.height-const_height)/2;
	
	var sChiave
	if (idTipoGerarchia=='21')
	sChiave=lIdAzi;
	else
	sChiave='0';
	NomeFormCampi=escape(NomeFormCampi);
	nomecombo=escape(nomecombo);
	RifFormDestHidden=escape(RifFormDestHidden);
	NomeHiddenIdent=escape(NomeHiddenIdent);
	NomeHiddenDesc=escape(NomeHiddenDesc);
	window.open(pathGerarchia+'?dztNomeAttrib='+dztNomeAttrib+'&RifActionScript='+OptionalConfirmScript+'&strNomeFrameCombo='+strNomeFrameCombo+'&bIsObligatory='+bIsObligatory+'&nMaxElementi='+nMaxElementi+'&NomeHiddenIdent='+NomeHiddenIdent+'&StrDescGerarchia='+StrDescGerarchia+'&NomeHiddenDesc='+NomeHiddenDesc+'&RifFormDestHidden='+RifFormDestHidden+'&GerarchieDinamiche='+GerarchieDinamiche+'&NomeFormCampi='+NomeFormCampi+'&nomecombo='+nomecombo+'&IDMP='+IDMP+'&sChiave='+sChiave+'&idTipoGerarchia='+idTipoGerarchia,'','toolbar=no,location=no,directories=no,status=<%=CONST_STATUS%>,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
	return;
}

function AggiornaComboGerarchie(nomeCombo,nomeIdent,nomeDesc,nomeForm,rifCampiHidden,strDescAtt)
{
	
	var iLoop;
	var ArrayIdent=new Array()
	var ArrayDesc=new Array()
	
	
	ComboGerarchia1=eval("document."+nomeForm+"."+nomeCombo);
	campohiddenIdent=eval("document."+nomeForm+"."+nomeIdent);
	campohiddenDesc=eval("document."+nomeForm+"."+nomeDesc);
	//aggiorno i campi hidden delle descrizioni e dei codici da nascosto
	sopraId=eval(rifCampiHidden+"."+nomeIdent);
	sopraDesc=eval(rifCampiHidden+"."+nomeDesc);
	campohiddenIdent.value=sopraId.value;
	campohiddenDesc.value=sopraDesc.value;
	if (campohiddenIdent!=null)
	{
		if (campohiddenIdent.value!='')
		{
			ArrayIdent=campohiddenIdent.value.split('#');
			ArrayDesc=campohiddenDesc.value.split('#');
			ComboGerarchia1.length=0;
			for (iLoop=0;iLoop<ArrayIdent.length-1;iLoop++)
			{
				var aggiunto=new Option('a');
				aggiunto.text=ArrayDesc[iLoop];
				aggiunto.value=ArrayIdent[iLoop];
				ComboGerarchia1.options[ComboGerarchia1.length]=aggiunto;
			}
			
			}else{
			
			ComboGerarchia1.length=0;
			var aggiunto=new Option('a');
			aggiunto.text = strDescAtt;
			aggiunto.value="";
			ComboGerarchia1.options[0]=aggiunto;
		}
		ComboGerarchia1.focus();
	}
	
	
}


function MyExecDocProcess(param){
	
	//ReplaceSepClasseIscriz('ClasseIscriz');
	//ReplaceSepClasseIscriz('SettoriCCNL');
	ExecDocProcess(param);
}

function MySaveDoc(){
	
	//ReplaceSepClasseIscriz('ClasseIscriz');
	//ReplaceSepClasseIscriz('SettoriCCNL');
	SaveDoc();
	
}


function ReplaceSepClasseIscriz( NomeAttributo )
{
	
    try
    {
		
		
		v=getObj( NomeAttributo ).value;
		if ( trim(v) == '' )
		return;
		//if( v.slice(0,3) !="###")
		if( v == '#' ){
			v=ReplaceExtended(v,'#',''); 
			getObj( NomeAttributo ).value=v;
			return;	
		}
		if(v.indexOf("###") == -1 )
		{
			v=ReplaceExtended(v,'#',';');
			v1=ReplaceExtended(v,';','###');
			
			if (v1.charAt(0)!= '#') 
		    v1='###' + v1;
			getObj( NomeAttributo ).value=v1;
		}  
	}
    catch(e){};
	
}



function Doc_DettagliDel( grid , r , c )
{
	var v = '0';
	try
	{
		v = getObj( 'RDOCUMENTAZIONEGrid_' + r + '_Obbligatorio' ).value ;
		}catch(e){};
	
    if( v == '1' )
    {
        //DMessageBox( '../' , 'La documentazione è obbligatoria' , 'Attenzione' , 1 , 400 , 300 );
	}
    else
    {
        DettagliDel( grid , r , c );
	}
}

function DOCUMENTAZIONE_AFTER_COMMAND ()
{
	HideCestinodoc();
	FormatAllegato();
	
}
function HideCestinodoc()
{
    try{
        var i = 0;
		
		var documentReadonly = getObj('DOCUMENT_READONLY').value;
		
		//Se non è readonly
		if (documentReadonly !== '1')
		{
			for( i=0; i < DOCUMENTAZIONEGrid_EndRow+1 ; i++ )
			{
				if( getObj( 'RDOCUMENTAZIONEGrid_' + i + '_Obbligatorio' ) . value == '1' )
				{
					getObj( 'DOCUMENTAZIONEGrid_r' + i + '_c0' ).innerHTML = '&nbsp;';
				}
			}
		}
	}catch(e){}
	
}


function OnClickProdotti( obj )
{
	var Stato = '';
	Stato = getObjValue('StatoDoc');

	if( Stato == '' ) 
    {
		DMessageBox( '../' , 'Prima di procedere con l\'importazione dei prodotti è necessario effettuare un salvataggio del documento' , 'Attenzione' , 1 , 400 , 300 );
	}
	else
	{
        var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;
        if ( DOCUMENT_READONLY == "1" )
            DMessageBox( '../' , 'Documento in sola lettura' , 'Attenzione' , 1 , 400 , 300 );
        else
    	    ImportExcel( 'CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,ISTANZA_SDA_FARMACI&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#400,300' );
	}
}


function RefreshContent()
{
    RefreshDocument('');
      
}

function DownLoadCSV()
{

    var TipoBando = getObjValue( 'TipoBando' );
    var LinkedDoc = getObjValue( 'LinkedDoc' );
    
    ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + LinkedDoc + '&TIPODOC=BANDO_SDA&MODEL=MODELLI_LOTTI_' + TipoBando + '_MOD_OffertaInd' );
    
}


function initAziEnte()
{
	enableDisableAziGeo('LocalitaRapLeg','ProvinciaRapLeg','StatoRapLeg','apriGEO',true);
	enableDisableAziGeo('ResidenzaRapLeg','ProvResidenzaRapLeg','StatoResidenzaRapLeg','apriGEO2',true);
	enableDisableAziGeo('LOCALITALEG','PROVINCIALEG','STATOLOCALITALEG','apriGEO3',true);
}


function impostaLocalita(cod,fieldname)
{
	ajax = GetXMLHttpRequest(); 
	
	var comuneTec;
	var provinciaTec;
	var statoTec;
	var comuneDesc; 
	var provinciaDesc;
	var statoDesc;
	
	if ( fieldname == 'RapLeg' )
	{
		comuneTec='LocalitaRapLeg2';
		provinciaTec='ProvinciaRapLeg2';
		statoTec='StatoRapLeg2';
		comuneDesc='LocalitaRapLeg';
		provinciaDesc='ProvinciaRapLeg';
		statoDesc='StatoRapLeg';
		geo='apriGEO'
	}
	if ( fieldname == 'ResidenzaRapLeg' )
	{
		comuneTec='ResidenzaRapLeg2';
		provinciaTec='ProvResidenzaRapLeg2';
		statoTec='StatoResidenzaRapLeg2';
		comuneDesc='ResidenzaRapLeg';
		provinciaDesc='ProvResidenzaRapLeg';
		statoDesc='StatoResidenzaRapLeg';
		geo='apriGEO2'
	}
	if ( fieldname == 'LOCALITALEG' )
	{
		comuneTec='LOCALITALEG2';
		provinciaTec='PROVINCIALEG2';
		statoTec='STATOLOCALITALEG2';
		comuneDesc='LOCALITALEG';
		provinciaDesc='PROVINCIALEG';
		statoDesc='STATOLOCALITALEG';
		geo='apriGEO3'
	}
	

	if(ajax)
	{
		ajax.open("GET", '../../ctl_library/functions/infoNodoGeo.asp?fldname=localita&cod=' + escape(cod), false);
		//output nella forma : COD-COMUNE#@#DESC-COMUNE#@#COD-PROVINCIA#@#DESC-PROVINCIA#@#COD-STATO#@#DESC-STATO
		ajax.send(null);

		if(ajax.readyState == 4) 
		{
			//Se non ci sono stati errori di runtime
			if(ajax.status == 200)
			{
				if ( ajax.responseText != '' ) 
				{
					var res = ajax.responseText;
					
					//Se l'esito della chiamata è stato positivo
					if ( res.substring(0, 2) == '1#' ) 
					{
						try
						{
							var vet = res.substring(4).split( '#@#' );
							
							var codLoc;
							var descLoc;
							var codProv;
							var descProv;
							var codStato;
							var descStato;

							codLoc = vet[0];
							descLoc = vet[1];
							codProv = vet[2];
							descProv = vet[3];
							codStato = vet[4];
							descStato = vet[5];

							getObj(comuneTec).value = codLoc;
							getObj(comuneDesc).value = descLoc;

							if ( codLoc == '' || codLoc.substring( codLoc.length-3, codLoc.length ) == 'XXX' )
								disableGeoField( comuneDesc, false);
							else
								disableGeoField( comuneDesc, true);

							getObj(provinciaTec).value = codProv;
							getObj(provinciaDesc).value = descProv;

							if ( codProv == '' || codProv.substring( codProv.length-3, codProv.length ) == 'XXX' )
								disableGeoField( provinciaDesc, false);
							else
								disableGeoField( provinciaDesc, true);

							getObj(statoTec).value = codStato;
							getObj(statoDesc).value = descStato;

							if ( codStato == ''  || codStato.substring( codStato.length-3, codStato.length ) == 'XXX' )
								disableGeoField( statoDesc, false);
							else
								disableGeoField( statoDesc, true);

						}
						catch(e)
						{
							alert('Errore:' + e.message);
						}
					}
					else
					{
						alert('errore.msg:' + res.substring(2));
						enableDisableAziGeo(comuneDesc,provinciaDesc,statoDesc,geo,false);
					}
				}
			}
			else
			{
				alert('errore.status:' + ajax.status);
				enableDisableAziGeo(comuneDesc,provinciaDesc,statoDesc,geo,false);
				
			}
		}
		else
		{
			alert('errore in impostaLocalita');
			enableDisableAziGeo(comuneDesc,provinciaDesc,statoDesc,geo,false);
		}
	}
}
function Vittime1() 
{
if( getObj( 'CheckVittime1' ).checked == true )
    {
      
	  getObj('CheckVittime2').checked = false;
	  
    }
}
function Vittime2() 
{
if( getObj( 'CheckVittime2' ).checked == true )
    {
       getObj('CheckVittime1').checked = false;
    }
}
function Obblighi1() 
{
if( getObj( 'CheckObblighi1' ).checked == true )
    {
      
	  getObj('CheckObblighi2').checked = false;
	  
    }
}
function Obblighi2() 
{
if( getObj( 'CheckObblighi2' ).checked == true )
    {
      
	  getObj('CheckObblighi1').checked = false;
	  
    }
}
function Intestazione1() 
{
if( getObj( 'CheckIntestazione1' ).checked == true )
    {
      
	  getObj('CheckIntestazione2').checked = false;
	  
    }
}
function Intestazione2() 
{
if( getObj( 'CheckIntestazione2' ).checked == true )
    {
       getObj('CheckIntestazione1').checked = false;
    }
}

function Casellario1() 
{
if( getObj( 'CheckCasellario1' ).checked == true )
    {
      
	  getObj('CheckCasellario2').checked = false;
	  
    }
}
function Casellario2() 
{
if( getObj( 'CheckCasellario2' ).checked == true )
    {
       getObj('CheckCasellario1').checked = false;
    }
}

function DownloadFileSenzaBusta(att_hash,fileName)
{
	var hash;
	var attIdObj;
	var url;
	var nomeFile;
	var ext;
	
	hash = '';
	attIdObj = '';
	
	if (att_hash === undefined)
	{
		hash = document.getElementById('ATT_Hash').value;
	}
	else
	{
		hash = att_hash;
	}

	if ( document.getElementById('attIdObj') )
		attIdObj = document.getElementById('attIdObj').value;
		
	var tmpVirtualDir;
	tmpVirtualDir = '/Application';

	if ( isSingleWin() )
		tmpVirtualDir = urlPortale;
	
	//Se stiamo nella scheda di un allegato del vecchio documento
	if ( hash == '' || hash == 'NULL')
	{
		url = tmpVirtualDir + '/pdf.aspx?mode=ESCLUDI_BUSTA&ATT_HASH=&ATTIDOBJ=' + attIdObj;
	}
	else
	{
		if (fileName === undefined)
			nomeFile  = document.getElementById('nomeFile_V').innerHTML;
		else
			nomeFile  = fileName;
		
		ext = nomeFile.split('.').pop();
	
		url = tmpVirtualDir + '/pdf.aspx?mode=ESCLUDI_BUSTA&ATT_HASH=' + hash + '&ATTIDOBJ=';
		//url = tmpVirtualDir + '/CTL_Library/functions/field/DisplayAttach.ASP?ESCLUDI_BUSTA=YES&OPERATION=DISPLAY&FIELD=&PATH=&TECHVALUE=' + nomeFile + '*' + ext + '*0*' + hash + '&FORMAT=INT';
	}
	
	ExecFunction( url , 'DownloadAttach' , ',height=200,width=500' );	
}

function MyCheckCF( fielcomune,fieldcf,obj)
{
	//var obj=this;
	var cf=obj.value;
	
	var controllo='';
	controllo=ControllaCF(cf);
	//se il codice fiscale è valido allora va tutto bene
	if ( controllo == '' )
	{
		return;
	}
	else //se non è valido controllo se il comune di nascita è italiano allora mostriamo il messaggio altrimenti non fa niente
	{
		var comune=getObj(obj.id.replace(fieldcf,fielcomune)).value;
		//se il comune è vuoto costringo l'utente ad inserirlo
		if ( comune == '' )
		{
			obj.value='';
			AF_Alert('Prima di inputare il codice fiscale compilare il campo comune di nascita');
		}
		ajax = GetXMLHttpRequest(); 
	
		if(ajax)
		{
			var nocache = new Date().getTime();
			ajax.open("GET", pathRoot + 'customdoc/InfoStatoComune.asp?nocache=' + nocache + '&comune=' + escape(comune), false);
			ajax.send(null);

			if(ajax.readyState == 4) 
			{
				//Se non ci sono stati errori di runtime
				if(ajax.status == 200)
				{
					if ( ajax.responseText != '' ) 
					{
						var res = ajax.responseText; //1 se italiano 0 altrimenti
					}
				}
				else
				{
					alert('errore.status:' + ajax.status);							
				}
			}			
		}
		if ( ajax.responseText == 1 )
		{
			controllo=ControllaCF(cf);
			if ( controllo != '' )
			{
				obj.value='';
				AF_Alert(controllo);
			}
			
		}
		
	}
}
function ChangedComune(fielcomune,fieldcf,obj)
{
	getObj(obj.id.replace(fielcomune,fieldcf)).value='';
}

function Gestione_Categorie()
{
	//verifico se sono presenti categorie sullo SDA
	try
	{
	   //quando ci sono filtro l'elenco con le categorie dispobibili in base allo sda di proveniena LINKEDDOC 
	   //EVOLUZIONE 25/10/2019 se non ci sono elenco_categorie_sda ma ci sono Elenco_Categorie_Merceologiche e Livello_Categorie_Merceologiche sullo sda filtriamo come fatto sullo sda
	   //EVOLUZIONE DEL 28/11/2019 GESTIAMO QUANTO FATTO SOPRA CON UN PARAMETRO
	   //ed se richieste le info aggiuntive mostra la griglia	   
	   if (  getObjValue( 'elenco_categorie_sda' ) != '' || ( getObjValue( 'Elenco_Categorie_Merceologiche' ) != ''  && getObjValue( 'Livello_Categorie_Merceologiche' ) != '' && Get_CTL_PARAMETRI('SDA','EMPTY_IS_ALL','DefaultValue','true','-1') == 'true' ) )   
	   {
			var id_sda=getObjValue( 'LinkedDoc' );
			var filtro='';
			
			if  ( getObjValue( 'elenco_categorie_sda' ) != '' )
			{
				filtro= 'SQL_WHERE= dmv_cod in ( select dmv_cod from SDA_Categorie_Merceologiche_SELECTED where idheader = ' + id_sda + ' ) ';
			}
			else
			{	
			
				filtro= 'SQL_WHERE= DMV_DM_ID = \'' + getObjValue( 'Elenco_Categorie_Merceologiche' ) + '\' and DMV_LEVEL <= ' + getObjValue( 'Livello_Categorie_Merceologiche' ) 
			
			}
			
			SetProperty( getObj('Categorie_Merceologiche'),'filter',filtro);

			
			if ( getObjValue( 'Richiesta_Info' ) != '1' )  //se non sono richieste le informazioni aggiuntive sullo SDA nascondo la griglia
			{
				document.getElementById('GRIGLIA_CATEGORIEGrid').style.display = "none";
			}
			
	   }
	   else //se non sono presenti sullo sda allora rimuovo la griglia e il dominio
	   {
			document.getElementById('categorie_merceologiche').style.display = "none";
			document.getElementById('GRIGLIA_CATEGORIEGrid').style.display = "none";
	   }
	}
	catch(e){}
}
function Onchange_Categorie_Merceologiche()
{  
	//aggiunge alla griglia solo se sono richieste le informazioni aggiuntiva
	if ( getObjValue( 'Richiesta_Info' ) == '1' )
	{	
		ExecDocProcess( 'FITTIZIO,ISTANZA_SDA_2,,NO_MSG'); //FITTIZIO per salvare le categorie scelte
	}	
		
}
function Compila_DOC_DGUE()
{
	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
    if (DOCUMENT_READONLY == "1")
	{
		MakeDocFrom('MODULO_TEMPLATE_REQUEST##ISTANZA');
	}
	else
	{
		ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');
	}
}
function afterProcess( param )
{
    if (  ( param == 'FITTIZIO' ) && ( getQSParam('PROCESS_PARAM') == 'FITTIZIO,DOCUMENT,,NO_MSG' )  )
    {
		ShowWorkInProgress();

		setTimeout(function()
		{ 
			
			ShowWorkInProgress();
			MakeDocFrom('MODULO_TEMPLATE_REQUEST##ISTANZA');

		}, 1 );
    }
}

function OnChangeCheck(obj)
{
	var name=obj.name;
	var valore=obj.value;	
	
	
	
	if  ( getObj(name).checked == true )
	{
		
		if ( name == 'CheckAutorizzazioni1' )
		{
			getObj('CheckAutorizzazioni2').checked = false;	
		}
		else
		{
			getObj('CheckAutorizzazioni1').checked = false;	
		}
		
	}
	

}

