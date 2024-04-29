//Variabile di appoggio per contenere l'idpfu dell'utente collegato e gestire l'applicazione sia se accessibile sia no
var tmp_idpfuUtenteCollegato;

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
'INDIRIZZOLEG',
'LOCALITALEG', 
'CAPLEG', 
'PROVINCIALEG', 
'STATOLOCALITALEG', 
'NUMTEL', 
//'NUMFAX', 
'codicefiscale', 
'PIVA',
'ClasseIscriz',
'sede_disabili',
'PEC_disabili',
'IndirizzoEntrate',
'PEC_Entrate',
'Province_Dove_Opera',
'Tempi_Medi_gg_consegna',
'Fatturato_ultimo_anno'
];


var NumControlli = LstAttrib.length;

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
			ExecDocProcess( 'PRE_SEND,ISTANZA_AlboOperaEco');
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
			ExecDocProcess( 'PRE_SEND,ISTANZA_AlboOperaEco');
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
	for( i = 0 ; i < NumControlli ; i++ )
	{
		if ( getObjValue('Not_Editable').indexOf( LstAttrib[i] + ' ,') < 0 )
		{
			TxtOK( LstAttrib[i] );
		}
	}
    
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
	
	
	
	if (getObj('DOCUMENT_READONLY').value != '1' )
	{	
		CampiNotEdit();
	}
	
	
	HideCestinodoc();
	HideProdotti();
	FormatAllegato();
	
	
	Stato ='';
	Stato = getObjValue('StatoDoc');
	IdpfuInCharge = getObjValue('IdpfuInCharge');
	
	try
	{
		if (getObj('DOCUMENT_READONLY').value != '1' )
		{
			OnChange_ClasseIscriz();
		}
		else
		{
			if ( getObjValue('Richiesta_Info') == '1' )
			{
				document.getElementById('INFO_ADD').style.display = "block";		
			}
		}
	}catch(e){}
	
	//if ( idpfuUtenteCollegato == undefined )
	//	var idpfuUtenteCollegato = getObjValue('IdpfuInCharge');
	
	if ( idpfuUtenteCollegato == undefined )
		tmp_idpfuUtenteCollegato = getObjValue('IdpfuInCharge');
	else
		tmp_idpfuUtenteCollegato = 	idpfuUtenteCollegato;
	
	/*if ( Stato != 'Saved' && Stato != '' )
		{
		document.getElementById('DIV_FIRMA').style.display = "none";	
	}*/
	if ( getObjValue('RichiestaFirma') == 'no')
	{
		document.getElementById('DIV_FIRMA').style.display = "none";	
	}
	
	if ((getObjValue('SIGN_LOCK') =='0' || getObjValue('SIGN_LOCK') =='')   && (Stato=='Saved' || Stato=="") && IdpfuInCharge == tmp_idpfuUtenteCollegato )
    {
		document.getElementById('generapdf').disabled = false; 
		document.getElementById('generapdf').className ="generapdf";
	}
	else
	{
		document.getElementById('generapdf').disabled = true; 
		document.getElementById('generapdf').className ="generapdfdisabled";
	}
	
	
	if ( getObjValue('SIGN_LOCK') != '0'   && (Stato=='Saved') && IdpfuInCharge == tmp_idpfuUtenteCollegato )
    {
		document.getElementById('editistanza').disabled = false; 
		document.getElementById('editistanza').className ="attachpdf";
	}
	else
	{
		document.getElementById('editistanza').disabled = true; 
		document.getElementById('editistanza').className ="attachpdfdisabled";
	} 
	if (getObjValue('SIGN_ATTACH') ==''  &&  (Stato=='Saved') && getObjValue('SIGN_LOCK') != '0'  && IdpfuInCharge == tmp_idpfuUtenteCollegato )
    {
		document.getElementById('attachpdf').disabled = false; 
		document.getElementById('attachpdf').className ="editistanza";
	}
	else
	{
		document.getElementById('attachpdf').disabled = true; 
		document.getElementById('attachpdf').className ="editistanzadisabled";
	}
	if (  IdpfuInCharge != tmp_idpfuUtenteCollegato )
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
	
	initAziEnte();
	Messaggio_Readonly();
	Filtro_Classe_Iscrizione();
    
	
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
		
		
		//-- effettuare tutti i controlli
		
		
		//-- controllo i dati della richiesta
		var i = 0;
		var err = 0;
		
		for( i = 0 ; i < NumControlli ; i++ )
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
								//alert(LstAttrib[i]);
								TxtErr( LstAttrib[i] );
							}
						}
						
						if ( getObj(LstAttrib[i]).type == 'checkbox' )
						{
							if( getObj( LstAttrib[i] ).checked == false )
							{
								err = 1;
								//alert(LstAttrib[i]);
								TxtErr( LstAttrib[i] );
							}
						}
					}
					
			}catch(e)
				{
					alert( i + ' - ' +  LstAttrib[i] );
				}
				
		}	
		
		
		
		
		//controllo la prensenza di allegati nella sezione della documentazione
		var numeroRigheDOC = GetProperty( getObj('DOCUMENTAZIONEGrid') , 'numrow');
		
		for( i = 0 ; i <= numeroRigheDOC ; i++ )
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
		if ( getObj( 'check_blacklist_1' ).checked == false &&  getObj( 'check_blacklist_2' ).checked == false )
		{
			err = 1;
			TxtErr( 'check_blacklist_1' );
			TxtErr( 'check_blacklist_2' );
		
		}
		else
		{
			TxtOK( 'check_blacklist_1' );
			TxtOK( 'check_blacklist_2' );
		} 
		
		if ( getObj( 'CheckSoggetti1' ).checked == false &&  getObj( 'CheckSoggetti2' ).checked == false )
		{
			err = 1;
			TxtErr( 'CheckSoggetti1' );
			TxtErr( 'CheckSoggetti2' );
		
		}
		else
		{
			TxtOK( 'CheckSoggetti1' );
			TxtOK( 'CheckSoggetti2' );
		} 

		if ( getObj( 'CheckIscritta1' ).checked == false &&  getObj( 'CheckIscritta2' ).checked == false &&  getObj( 'CheckIscritta3' ).checked == false )
		{
			err = 1;
			TxtErr( 'CheckIscritta1' );
			TxtErr( 'CheckIscritta2' );
			TxtErr( 'CheckIscritta3' );
			
		}
		else
		{
			TxtOK( 'CheckIscritta1' );
			TxtOK( 'CheckIscritta2' );
			TxtOK( 'CheckIscritta3' );
			
		}  
		/*	
		if ( getObj( 'check_art_80_1' ).checked == false )
		{
			err = 1;
			TxtErr( 'check_art_80_1' );			
						
		}
		else
		{
			TxtOK( 'check_art_80_1' );			
						
		}  
		
		
		
		if ( getObj('check_art_80_1').checked == true )
		{
			if (getObj( 'Dichiarazione_check_art_80_1' ).value == '')
			{
				err = 1;
				TxtErr( 'Dichiarazione_check_art_80_1' );
			}
			else
			{
				TxtOK( 'Dichiarazione_check_art_80_1' );
			}
		}		
		*/
		if ( getObj( 'CheckIscritta1' ).checked == true )
		{
			if (getObj( 'Registro_Camera_Provincia_Artigianato' ).value == '')
			{
				err = 1;
				TxtErr( 'Registro_Camera_Provincia_Artigianato' );
			}
			else
			{
				TxtOK( 'Registro_Camera_Provincia_Artigianato' );
			}
			if (getObj( 'elenco_camera_attivita_artigianato' ).value == '') 
			{
				err = 1;
				TxtErr( 'elenco_camera_attivita_artigianato' );
			}
			else
			{
				TxtOK( 'elenco_camera_attivita_artigianato' );
			}
			/*if (getObj( 'NaGi' ).value == '')
			{
				err = 1;
				TxtErr( 'NaGi' );
			}
			else
			{
				TxtOK( 'NaGi' );
			}*/
			
			if (getObj( 'data_iscrizione' ).value == '')
			{
				err = 1;
				TxtErr( 'data_iscrizione' );
			}
			else
			{
				TxtOK( 'data_iscrizione' );
			}
			
			if (getObj( 'sede_iscrizione' ).value == '')
			{
				err = 1;
				TxtErr( 'sede_iscrizione' );
			}
			else
			{
				TxtOK( 'sede_iscrizione' );
			}		
		}
		else
		{
			TxtOK( 'Registro_Camera_Provincia_Artigianato' );
			TxtOK( 'elenco_camera_attivita_artigianato' );
			//TxtOK( 'NaGi' );
			TxtOK( 'data_iscrizione' );
			TxtOK( 'sede_iscrizione' );
		}
		if ( getObj( 'CheckIscritta2' ).checked == true )
		{
			if (getObj( 'Registro_Provincia_Artigianato' ).value == '')
			{
				err = 1;
				TxtErr( 'Registro_Provincia_Artigianato' );
			}
			else
			{
				TxtOK( 'Registro_Provincia_Artigianato' );
			}		
		}
		else
		{
			TxtOK( 'Registro_Provincia_Artigianato' );
		}
		
		
		if(  err > 0 )
		{
			
			DMessageBox( '../' , 'Per proseguire e\' necessaria la compilazione di tutti i campi evidenziati' , 'Attenzione' , 1 , 400 , 300 );
			return -1;
		}
		
		
		
		
	
	}
}


//non rimosso visto che la toolbar è in comune con altri doc

function MyExecDocProcess(param){
	
	ExecDocProcess(param);
}

function MySaveDoc(){
	
	SaveDoc();
	
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




function RefreshContent()
{
    RefreshDocument('');
      
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

function OnCheckSoggetti(obj)
{
	
	var name=obj.name;
	var valore=obj.value;
	if ( valore == '1' )
	{
		 getObj('CheckSoggetti1').checked = false;	
		 getObj('CheckSoggetti2').checked = false;	
		getObj(name).checked = true;	
	}
	
}

function OnCheckIscritta(obj)
{	
	var name=obj.name;
	var valore=obj.value;
	if ( valore == '1' )
	{
		 getObj('CheckIscritta1').checked = false;	
		 getObj('CheckIscritta2').checked = false;	
		 getObj('CheckIscritta3').checked = false;			
		getObj(name).checked = true;	
	}
		
		CampiNotEdit();
	
}
function OnChangeCheck(obj)
{
	var name=obj.name;
	var valore=obj.value;

	if ( name.substring(0,name.length - 2) == 'check_art_80')
	{
		if ( getObj('check_art_80_1').checked == false )
		{
			TextreadOnly( 'Dichiarazione_check_art_80_1' ,true);
			
		}
		if ( getObj('check_art_80_1').checked == true )
		{
			TextreadOnly( 'Dichiarazione_check_art_80_1' ,false);

		}	
	}
	
	if ( name.substring(0,name.length - 2) == 'check_art_80_violazioni' && valore == '1' )
	{
		 getObj('check_art_80_violazioni_1').checked = false;	
		 getObj('check_art_80_violazioni_2').checked = false;	
		 getObj(name).checked = true;
		return;		 
	}
	if ( name.substring(0,name.length - 2) == 'check_art_80_infrazioni' && valore == '1' )
	{
		 getObj('check_art_80_infrazioni_1').checked = false;	
		 getObj('check_art_80_infrazioni_2').checked = false;	
		 getObj(name).checked = true;
		 return;
	}
	if ( name.substring(0,name.length - 2) == 'check_art_80_conflitti' && valore == '1' )
	{
		 getObj('check_art_80_conflitti_1').checked = false;	
		 getObj('check_art_80_conflitti_2').checked = false;	
		 getObj(name).checked = true;
		 return;
	}
	if ( name.substring(0,name.length - 2) == 'check_art_80_illeciti' && valore == '1' )
	{
		 getObj('check_art_80_illeciti_1').checked = false;	
		 getObj('check_art_80_illeciti_2').checked = false;	
		 getObj(name).checked = true;
		 return;
	}
	
	if ( name.substring(0,name.length - 2) == 'check_art_80_appalto' && valore == '1' )
	{
		 getObj('check_art_80_appalto_1').checked = false;	
		 getObj('check_art_80_appalto_2').checked = false;	
		 getObj(name).checked = true;
		 return;
	}
	
	if ( name.substring(0,name.length - 2) == 'check_art_80_fiduciaria' && valore == '1' )
	{
		 getObj('check_art_80_fiduciaria_1').checked = false;	
		 getObj('check_art_80_fiduciaria_2').checked = false;	
		 getObj(name).checked = true;
		 return;
	}
	if ( name.substring(0,name.length - 2) == 'check_art_80_assunzioni' && valore == '1' )
	{
		 getObj('check_art_80_assunzioni_1').checked = false;	
		 getObj('check_art_80_assunzioni_2').checked = false;	
		 getObj(name).checked = true;
		 return;
	}
	if ( name.substring(0,name.length - 2) == 'check_art_80_controllo' && valore == '1' )
	{
		 getObj('check_art_80_controllo_1').checked = false;	
		 getObj('check_art_80_controllo_2').checked = false;	
		 getObj(name).checked = true;
		 return;
	}
	
	if ( name.substring(0,name.length - 2) == 'check_blacklist' && valore == '1' )
	{
		 getObj('check_blacklist_2').checked = false;	
		 getObj('check_blacklist_1').checked = false;
		 getObj(name).checked = true;
		 return;
	}	
	
	

}

function CampiNotEdit()
{
	
	
	if ( getObj('check_art_80_1').checked == false )
	{
		TextreadOnly( 'Dichiarazione_check_art_80_1' ,true);		
	}
	
	
	if ( getObj('CheckIscritta1').checked == false )
	{
		TextreadOnly( 'Registro_Camera_Provincia_Artigianato' ,true);
		TextreadOnly( 'elenco_camera_attivita_artigianato',true );		
		//SelectreadOnly( 'NaGi',true );
		DatareadOnly( 'data_iscrizione' ,true);
		TextreadOnly( 'sede_iscrizione' ,true);
	}
	if ( getObj('CheckIscritta1').checked == true )
	{
		TextreadOnly( 'Registro_Camera_Provincia_Artigianato' ,false);
		TextreadOnly( 'elenco_camera_attivita_artigianato',false );		
		//SelectreadOnly( 'NaGi',false );
		DatareadOnly( 'data_iscrizione' ,false);
		TextreadOnly( 'sede_iscrizione' ,false);
	}
	
	if ( getObj('CheckIscritta2').checked == false )
	{
		TextreadOnly( 'Registro_Provincia_Artigianato' ,true);	
	}
	if ( getObj('CheckIscritta2').checked == true )
	{
		TextreadOnly( 'Registro_Provincia_Artigianato' ,false);
	}

	
	


}



function Filtro_Classe_Iscrizione()
{
	
	if(  getObjValue( 'StatoFunzionale' ) == 'InLavorazione'  )
	{
		
		var class_bando = getObj('ClasseIscriz_Bando').value;
		var filter = '';
		
		filter =  GetProperty ( getObj('ClasseIscriz'),'filter') ;				
		
			if ( filter == '' || filter == undefined || filter == null )
			{					
				
				SetProperty( getObj('ClasseIscriz'),'filter','SQL_WHERE= dmv_cod in (  select top 1000000  B.dmv_cod  from ClasseIscriz a  INNER JOIN ClasseIscriz B ON a.dmv_father = left( b.dmv_father , len ( a.dmv_father ) )  or  b.dmv_father = \'000.\'  or b.dmv_father = left( a.dmv_father , len ( b.dmv_father ) )     where  \'' + class_bando + '\' like \'%###\' + A.DMV_COD + \'###%\'    )');
				
			}			
	}	
}

function afterProcess( param )
{
    
	if ( param == 'FITTIZIO2' )
    {
		ShowWorkInProgress();

		setTimeout(function()
		{ 
			
			ShowWorkInProgress();
			MakeDocFrom('INSTANZA_ME_INFO_AGGIUNTIVE##ISTANZA');

		}, 1 );
    }	
}

function OnChange_ClasseIscriz()
{
	try
	{
		var classi_sel=getObjValue('ClasseIscriz');
			
			ajax = GetXMLHttpRequest();
			  
			var nocache = new Date().getTime();
			  
			if (ajax) 
			{
				ajax.open("GET", '../../customdoc/PresenzaInfoAggiuntive.asp?IDDOC=' + getObj('IDDOC').value  + '&classi_sel=' + encodeURIComponent(classi_sel) + '&nocache=' + nocache  , false);

				ajax.send(null);

				if (ajax.readyState == 4) 
				{
					//alert(ajax.status);
					if (ajax.status == 200) 
					{
						if ( ajax.responseText == '1' )
						{
							getObj('Richiesta_Info').value='1';
							document.getElementById('INFO_ADD').style.display = "block";
						}
						else
						{
							getObj('Richiesta_Info').value='';
							document.getElementById('INFO_ADD').style.display = "none";
						}
					}
				}
			}
	}catch(e){}
}

function Compila_Info_Add ()
{
	if ( getObjValue('Richiesta_Info') == '1' )
	{
	
		if (getObj('DOCUMENT_READONLY').value == "1")
		{
			MakeDocFrom('INSTANZA_ME_INFO_AGGIUNTIVE##ISTANZA');
		}
		else
		{
			ExecDocProcess( 'FITTIZIO2,DOCUMENT,,NO_MSG');
		}
	}
}

function getQSParam(ParamName)
{
	// Memorizzo tutta la QueryString in una variabile
	QS=window.location.toString(); 
	// Posizione di inizio della variabile richiesta
	var indSta=QS.indexOf(ParamName); 
	// Se la variabile passata non esiste o il parametro è vuoto, restituisco null
	if (indSta==-1 || ParamName=="") return null; 
	// Posizione finale, determinata da una eventuale &amp; che serve per concatenare più variabili
	var indEnd=QS.indexOf('&',indSta); 
	// Se non c'è una &amp;, il punto di fine è la fine della QueryString
	if (indEnd==-1) indEnd=QS.length; 
	// Ottengo il solore valore del parametro, ripulito dalle sequenze di escape
	var valore = unescape(QS.substring(indSta+ParamName.length+1,indEnd));
	// Restituisco il valore associato al parametro 'ParamName'
	return valore; 
}



