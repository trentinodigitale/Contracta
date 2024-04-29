var ruoloPrevalentePO;
var ruoloPrevalentePI;
var ruoloPrevalenteRUP;
var ruoloPrevalenteRUP_PDG;
var UserRoleDefaultValue;
var ruoloPrevalenteRESP_PEPPOL;

//window.onload = DISPLAY_FIRMA_OnLoad;

$( document ).ready(function() {
    DISPLAY_FIRMA_OnLoad();
});

function trim(str)
{
   return str.replace(/^\s+|\s+$/g,"");
}

function sceltaRuolo(obj)
{
	nascondiSezioni();
	reloadRuoloPrevalente();
}

function reloadRuoloPrevalente()
{
	var po;
	var pi;
	var rup;
	var statoDoc;
	var totChecked;
	var toSelect;
	var oldSelected;
	
	var objPep;
	var selObjPep;
	
	statoDoc = '1';
	totChecked = 0;
	toSelect = '';
	
	if ( getObj('StatoDoc') )
		statoDoc = getObj('DOCUMENT_READONLY').value;

	if ( statoDoc !== '1' )
	{
		po = getObj('PO');
		pi = getObj('PI');
		rup = getObj('scelta_RUP');
		rup_pdg = getObj('scelta_RUP_PDG');
		objPep = getObj('ResponsabilePEPPOL');
		
		oldSelected = getObj('UserRoleDefault').value;
		
		if ( po.checked )
		{
			totChecked = totChecked + 1;
			toSelect = 'PO';
			//getObj('UserRoleDefault_PO').style.display = '';
			getObj('UserRoleDefault').appendChild(ruoloPrevalentePO);
		}
		else
		{
			if ( getObj('UserRoleDefault_PO') )
				getObj('UserRoleDefault').removeChild( ruoloPrevalentePO );

			//getObj('UserRoleDefault_PO').style.display = 'none';
		}
		
		if ( pi.checked )
		{
			totChecked = totChecked + 1;
			toSelect = 'PI';
			//getObj('UserRoleDefault_PI').style.display = '';
			getObj('UserRoleDefault').appendChild(ruoloPrevalentePI);
		}
		else
		{
			if ( getObj('UserRoleDefault_PI') )
				getObj('UserRoleDefault').removeChild( ruoloPrevalentePI );
				
			//getObj('UserRoleDefault_PI').style.display = 'none';
		}
		
		//Se il campo esiste ed è checked
		if ( rup && rup.checked )
		{
			totChecked = totChecked + 1;
			toSelect = 'RUP';
			//getObj('UserRoleDefault_RUP').style.display = '';
			getObj('UserRoleDefault').appendChild(ruoloPrevalenteRUP);
		}
		else
		{
			if ( getObj('UserRoleDefault_RUP') )
				getObj('UserRoleDefault').removeChild( ruoloPrevalenteRUP );
				
			//getObj('UserRoleDefault_RUP').style.display = 'none';
		}
		
		selObjPep = 0;
		
		if ( objPep )
		{
			try
			{
				if ( objPep.checked )
					selObjPep = 1;
			}
			catch(e){}
		}
		
		try
		{
			if ( selObjPep == 1 )
			{
				totChecked = totChecked + 1;
				toSelect = 'RESPONSABILE_PEPPOL';
				getObj('UserRoleDefault').appendChild(ruoloPrevalenteRESP_PEPPOL);
			}
			else
			{
				if ( getObj('UserRoleDefault_RESPONSABILE_PEPPOL') )
					getObj('UserRoleDefault').removeChild( ruoloPrevalenteRESP_PEPPOL );

			}
		}
		catch(e){}
		
		
		
		if ( RecuperaValore(rup_pdg) == 1 )
		{
			totChecked = totChecked + 1;
			toSelect = 'RUP_PDG';
			//getObj('UserRoleDefault_RUP').style.display = '';
			getObj('UserRoleDefault').appendChild(ruoloPrevalenteRUP_PDG);
		}
		else
		{
			if ( getObj('UserRoleDefault_RUP_PDG') )
				getObj('UserRoleDefault').removeChild( ruoloPrevalenteRUP_PDG );
				
			//getObj('UserRoleDefault_RUP').style.display = 'none';
		}
		
		
		
		if ( totChecked == 1 )
		{
			getObj('UserRoleDefault').value = toSelect;
		}
		else //if  ( totChecked == 0 )
		{
			//getObj('UserRoleDefault').value = '';
			//getObj('UserRoleDefault').value = oldSelected;
			getObj('UserRoleDefault').value = UserRoleDefaultValue;
		}
		
		
		
		
	}

}

function nascondiSezioni()
{

	//Se scelta PO o RUP. visualizzo la sezione di firma
	//Se scelta PI visualizzo sezione 'responsabili'
	var po;
	var pi;
	var rup;
	var statoDoc;
	var rup_pdg;
	var respPeppol;
	
	respPeppol = false;
	statoDoc = getObj('DOCUMENT_READONLY').value;
	
	var bCheckRup = false;
	
	if ( statoDoc == '1' )
	{	
		po = getObj('PO_V');
		pi = getObj('PI_V');
		rup = getObj('scelta_RUP_V');
		
		try
		{
			rup_pdg = getObj('scelta_RUP_PDG_V');
		}catch(e)
		{
			rup_pdg = getObj('scelta_RUP_PDG');
		}	
		
		var objPep = getObj('ResponsabilePEPPOL_V');
		
		if ( objPep )
			respPeppol = objPep.checked;
		
	}
	else
	{
		po = getObj('PO');
		pi = getObj('PI');
		rup = getObj('scelta_RUP');
		rup_pdg = getObj('scelta_RUP_PDG');
		
		//Controllo il checked solo se il campo esiste
		if ( rup ) 
		{
			bCheckRup = rup.checked;
		}
		
		var objPep = getObj('ResponsabilePEPPOL');
		
		if ( objPep )
			respPeppol = objPep.checked;
	}
	
	if ( po.checked || bCheckRup ||  RecuperaValore(rup_pdg) == 1 || respPeppol ) 
	{
		getObj('FIRMA').style.display = '';
	}
	else
	{
		getObj('FIRMA').style.display = 'none';
	}
	
	if ( pi.checked ) 
		getObj('RESPONSABILE').style.display = '';
	else
		getObj('RESPONSABILE').style.display = 'none';

}

function InvioDati( param )
{
	var esegui;
	var po;
	var pi;
	var rup;
	var statoDoc;
	var rup_pdg;
	var respPeppol;
	
	respPeppol = false;
	
	esegui = false;
	statoDoc = getObj('DOCUMENT_READONLY').value;

	//Se readonly
	if ( statoDoc == '1' )
	{	
		po = getObj('PO_V');
		pi = getObj('PI_V');
		rup = getObj('scelta_RUP_V');
		
		try
		{
			rup_pdg = getObj('scelta_RUP_PDG_V');
		}catch(e)
		{
			rup_pdg = getObj('scelta_RUP_PDG');
		}	
		
		var objPep = getObj('ResponsabilePEPPOL_V');
		
		if ( objPep )
			respPeppol = objPep.checked;
		
	}
	else
	{
		po = getObj('PO');
		pi = getObj('PI');
		rup = getObj('scelta_RUP');
		rup_pdg = getObj('scelta_RUP_PDG');
		
		var objPep = getObj('ResponsabilePEPPOL');
		
		if ( objPep )
			respPeppol = objPep.checked;
		
	}
	
	
	
	if (po.checked == false && pi.checked == false && rup.checked == false &&  RecuperaValore(rup_pdg) == 0 && respPeppol == false  )
	{
		DMessageBox( '../' , 'Prima di Inviare il documento selezionare un ruolo.' , 'Attenzione' , 1 , 400 , 300 );
		return;
	}

	if ( statoDoc == '0' && getObj('UserRoleDefault').value == '' )
	{
		DMessageBox( '../' , 'Prima di Inviare il documento selezionare un ruolo prevalente.' , 'Attenzione' , 1 , 400 , 300 );
		return;
	}

	//se il campo "Atto di nomina o idoneità” visibile allora se ho spuntato il campo "RUP PDG" allora è obbligatorio 
	//inserire l'allegato
	
	objBtn_Atto = getObj('AttoDiNomina_Idoneita_V_BTN');
	if (objBtn_Atto != null)
	{
		if ( RecuperaValore(rup_pdg) == 1 || RecuperaValore(rup) == 1 )
		{
			if ( getObj('AttoDiNomina_Idoneita').value == ''  )
			{
				DMessageBox( '../' , 'Prima di Inviare il documento allegare un atto di nomina' , 'Attenzione' , 1 , 400 , 300 );
				return;
			}
		}
	}
	
	
	if (getObj('FIRMA').style.display != 'none' && getObjValue('SIGN_ATTACH') == "")
	{
		DMessageBox( '../' , 'Prima di Inviare il documento allegare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
		return;
	}
	
	
	
	try
	{
		/* Se sono presenti degli elementi nel dominio allora rendo la selezione di un elemento obbligatorio */
		if ( getObj('SceltaAOO') )
		{
			if ( getObj('SceltaAOO').length > 1 && getObj('SceltaAOO').value == '')
			{
				DMessageBox( '../' , 'Prima di generare il pdf selezionare una AOO.' , 'Attenzione' , 1 , 400 , 300 );
				return;
			}
		}
	}
	catch(e){}

	esegui = true;

	if (esegui)
	{
		ExecDocProcess( param );
		// 'SEND,CAMBIO_RUOLO_UTENTE'
	}

}
function MyToPrint (param)
{
	if ( getObj('Visualizza_Altri_Dati').value == '0' )
	{
		ToPrint('NO_SECTION_PRINT=FIRMA,RESPONSABILE,SCELTA_RUOLO2');
	}
	else
	{
		ToPrint('NO_SECTION_PRINT=FIRMA,RESPONSABILE');
	}
}

function GeneraPDF()
{

	var statoDoc;
	statoDoc = getObj('DOCUMENT_READONLY').value;

    if( statoDoc == '' ) 
    {
        //alert( 'Per effettuare la stampa si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di stampa');
		DMessageBox( '../' , 'Compilare l\'istanza in tutti i suoi campi obbligatori, successivamente effettuare nuovamente il comando genera pdf.' , 'Attenzione' , 1 , 400 , 300 );
        SaveDoc();
        return;
    }

	var value2=controlli('');
	if (value2 == -1)
		return;  

    scroll(0,0);
	
	ExecDocProcess( 'SAVE_CAMBIO_RUOLO,CAMBIO_RUOLO_UTENTE');

    //PrintPdfSign('URL=/report/prn_CAMBIO_RAPLEG.ASP?SIGN=YES&PDF_NAME=CAMBIO_RAP_LEG');
	/*
	if ( getObj('Visualizza_Altri_Dati').value == '0' )
	{
		ToPrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=Cambio%20Ruolo&lo=print&NO_SECTION_PRINT=FIRMA%2CRESPONSABILE%2CSCELTA_RUOLO2&PROCESS=DOCUMENT%40%40%40PROTOCOLLA');
	}
	else
	{
		ToPrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=Cambio%20Ruolo&lo=print&NO_SECTION_PRINT=FIRMA%2CRESPONSABILE&PROCESS=DOCUMENT%40%40%40PROTOCOLLA');
	}
	*/
}

function afterProcess( param )
{
	if ( param == 'SAVE_CAMBIO_RUOLO' )
    {
		/*if ( getObj('Visualizza_Altri_Dati').value == '0' )
		{
			ToPrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=Cambio%20Ruolo&lo=print&NO_SECTION_PRINT=FIRMA%2CRESPONSABILE%2CSCELTA_RUOLO2&PROCESS=DOCUMENT%40%40%40PROTOCOLLA');
		}
		else
		{
			ToPrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=Cambio%20Ruolo&lo=print&NO_SECTION_PRINT=FIRMA%2CRESPONSABILE&PROCESS=DOCUMENT%40%40%40PROTOCOLLA');
		}*/
		
		scroll(0,0);  	
		PrintPdfSign('TABLE_SIGN=CTL_DOC&lo=print&PROCESS=&PDF_NAME=Cambio Ruolo&URL=/report/prn_CAMBIO_RUOLO_UTENTE.asp?SIGN=YES');
		
    }
	 if ( param == 'SEND,CAMBIO_RUOLO_UTENTE' )
    {
        if ( getObj('StatoFunzionale').value == 'Inviato' )
		{
			DMessageBox( '../' , 'Documento inviato correttamente. Per visualizzare le funzioni associate ai ruoli scelti effettuare di nuovo il login' , 'Attenzione' , 1 , 400 , 300 );	
		}
    }
}

function TogliFirma () 
{
	DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
	ExecDocProcess( 'SIGN_ERASE,FirmaDigitale');
}

function SetInitField()
{

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

function LocalPrintPdf( param )
{ 
    
	Stato = getObjValue('StatoDoc');
    param = '/report/prn_' + getObj('TYPEDOC').value + '.ASP?'
    if( Stato == '' ) 
    {
        //alert( 'Per effettuare la stampa si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di stampa');
		DMessageBox( '../' , 'Per effettuare la stampa si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di stampa.' , 'Attenzione' , 1 , 400 , 300 );
        
   
        SaveDoc();
        return;
    }
  
    
    PrintPdf( param );
	
}
function DISPLAY_FIRMA_OnLoad()
{
	var Stato ='';
	var userRoleDomain;
	
	
	DisplayRuoli_FromAziProfili();
	
	
	
	/*
	if ( getObj('StatoFunzionale') )
	{
		if ( getObj('StatoFunzionale').value == 'Inviato' )
		{
			DMessageBox( '../' , 'Documento inviato correttamente. Per visualizzare le funzioni associate ai ruoli scelti effettuare di nuovo il login' , 'Attenzione' , 1 , 400 , 300 );	
		}
	}
	*/

	if ( getObj('StatoDoc') )
	{
	
		try
		{
			UserRoleDefaultValue = '';
			userRoleDomain = getObj('UserRoleDefault');
			UserRoleDefaultValue = userRoleDomain.options[userRoleDomain.selectedIndex].value;
		}
		catch(e)
		{
		}

		/* Conservo le option del dominio */
		try
		{
			ruoloPrevalentePO = getObj('UserRoleDefault_PO');
			ruoloPrevalentePI = getObj('UserRoleDefault_PI');
			ruoloPrevalenteRUP = getObj('UserRoleDefault_RUP');
			ruoloPrevalenteRUP_PDG = getObj('UserRoleDefault_RUP_PDG');
			
			try
			{
				ruoloPrevalenteRESP_PEPPOL = getObj('UserRoleDefault_RESPONSABILE_PEPPOL');
			}
			catch(e){}
			
			
				
			var ver = getInternetExplorerVersion();
			var ie8ruoloPrevalentePO;
			var ie8ruoloPrevalentePI;
			var ie8ruoloPrevalenteRUP;
			var ie8ruoloPrevalenteRUP_PDG;
			var ie8ruoloPrevalenteRESP_PEPPOL;
			
			//Se non è IE o se è una versione superiore ad explorer 8
			if ( ver != -1 && ver <= 8.0 )
			{
			
				//alert('ie8!');
			
				ie8ruoloPrevalentePO = document.createElement('option');
				ie8ruoloPrevalentePO.value = ruoloPrevalentePO.value;
				ie8ruoloPrevalentePO.id = ruoloPrevalentePO.id;
				ie8ruoloPrevalentePO.innerHTML = ruoloPrevalentePO.innerHTML;
				
				ie8ruoloPrevalentePI = document.createElement('option');
				ie8ruoloPrevalentePI.value = ruoloPrevalentePI.value;
				ie8ruoloPrevalentePI.id = ruoloPrevalentePI.id;
				ie8ruoloPrevalentePI.innerHTML = ruoloPrevalentePI.innerHTML;
				
				ie8ruoloPrevalenteRUP = document.createElement('option');
				ie8ruoloPrevalenteRUP.value = ruoloPrevalenteRUP.value;
				ie8ruoloPrevalenteRUP.id = ruoloPrevalenteRUP.id;
				ie8ruoloPrevalenteRUP.innerHTML = ruoloPrevalenteRUP.innerHTML;
				
				ie8ruoloPrevalenteRUP_PDG = document.createElement('option');
				ie8ruoloPrevalenteRUP_PDG.value = ruoloPrevalenteRUP_PDG.value;
				ie8ruoloPrevalenteRUP_PDG.id = ruoloPrevalenteRUP_PDG.id;
				ie8ruoloPrevalenteRUP_PDG.innerHTML = ruoloPrevalenteRUP_PDG.innerHTML;
				
				ie8ruoloPrevalenteRESP_PEPPOL = document.createElement('option');
				ie8ruoloPrevalenteRESP_PEPPOL.value = ruoloPrevalenteRESP_PEPPOL.value;
				ie8ruoloPrevalenteRESP_PEPPOL.id = ruoloPrevalenteRESP_PEPPOL.id;
				ie8ruoloPrevalenteRESP_PEPPOL.innerHTML = ruoloPrevalenteRESP_PEPPOL.innerHTML;

				ruoloPrevalentePO = ie8ruoloPrevalentePO;
				ruoloPrevalentePI = ie8ruoloPrevalentePI;
				ruoloPrevalenteRUP = ie8ruoloPrevalenteRUP;
				ruoloPrevalenteRUP_PDG = ie8ruoloPrevalenteRUP_PDG;
				ruoloPrevalenteRESP_PEPPOL = ie8ruoloPrevalenteRESP_PEPPOL

			}
				
			//Svuoto il dominio per poi aggiungere soltanto i ruoli selezionati 
			getObj('UserRoleDefault').options.length = 0;
			
			/*getObj('UserRoleDefault').removeChild( ruoloPrevalentePO );
			getObj('UserRoleDefault').removeChild( ruoloPrevalentePI );
			getObj('UserRoleDefault').removeChild( ruoloPrevalenteRUP );*/

		}
		catch(e){}

		nascondiSezioni();
		reloadRuoloPrevalente();

		Stato = getObj('StatoDoc').value;
	
		if ((getObjValue('SIGN_LOCK') =='0' || getObjValue('SIGN_LOCK') =='')   && (Stato=='Saved' || Stato==""))
		{
			document.getElementById('generapdf').disabled = false; 
			document.getElementById('generapdf').className ="generapdf";
		}
		else
		{
			document.getElementById('generapdf').disabled = true; 
			document.getElementById('generapdf').className ="generapdfdisabled";
		}	
		if ( getObjValue('SIGN_LOCK') != '0'   && (Stato=='Saved') )
		{
			document.getElementById('editistanza').disabled = false; 
			document.getElementById('editistanza').className ="attachpdf";
		}
		else
		{
			document.getElementById('editistanza').disabled = true; 
			document.getElementById('editistanza').className ="attachpdfdisabled";
		} 
		if (getObjValue('SIGN_ATTACH') ==''  &&  (Stato=='Saved') && getObjValue('SIGN_LOCK') != '0'   )
		{
			document.getElementById('attachpdf').disabled = false; 
			document.getElementById('attachpdf').className ="editistanza";
		}
		else
		{
			document.getElementById('attachpdf').disabled = true; 
			document.getElementById('attachpdf').className ="editistanzadisabled";
		}
	}
	
	if ( getObj('Visualizza_Altri_Dati').value == '0' )
	{
		getObj('SCELTA_RUOLO2').style.display='none';
		
		/*
		try
		{
			getObj('cap_SceltaAOO').style.display='none';
			getObj('SceltaAOO').style.display='none';
		}
		catch(e)
		{
		}
		*/
	}
	
	
	
}

function controlli (param)
{
	var err = 0;
    var	cod = getObj( "IDDOC" ).value;
    var strRet = CNV( '../' , 'ok' );

	SetInitField();

    //-- controllo i dati della richiesta
    var i = 0;
    var err = 0;
	
	var po;
	var pi;
	var rup;
	var rup_pdg;
	var respPeppol;
	
	respPeppol = false;
	
	po = getObj('PO');
	pi = getObj('PI');
	rup = getObj('scelta_RUP');
	rup_pdg = getObj('scelta_RUP_PDG');
	
	var objPep = getObj('ResponsabilePEPPOL');
	
	try
	{
		if ( objPep )
			respPeppol = objPep.checked;
	}
	catch(e){}
	
	
	if (po.checked == false && pi.checked == false && rup.checked == false && RecuperaValore(rup_pdg) == 0 && respPeppol == false )
	{
		DMessageBox( '../' , 'Prima firmare il documento selezionare un ruolo.' , 'Attenzione' , 1 , 400 , 300 );
		return -1;
	}
	
	//se il campo "Atto di nomina o idoneità” visibile allora se ho spuntato il campo "RUP PDG" allora è obbligatorio 
	//inserire l'allegato
	
	objBtn_Atto = getObj('AttoDiNomina_Idoneita_V_BTN');
	if (objBtn_Atto != null)
	{
		if ( RecuperaValore(rup_pdg) == 1)
		{
			if ( getObj('AttoDiNomina_Idoneita').value == ''  )
			{
				DMessageBox( '../' , 'Prima di firmare il documento allegare un atto di nomina' , 'Attenzione' , 1 , 400 , 300 );
				return -1;
			}
		}
	}
	
	if ( getObj('UserRoleDefault').value == '' )
	{
		DMessageBox( '../' , 'Prima firmare il documento selezionare un Ruolo prevalente.' , 'Attenzione' , 1 , 400 , 300 );
        return -1;
	}
	
	/* Se sono presenti degli elementi nel dominio allora rendo la selezione di un elemento obbligatorio */
	if ( getObj('SceltaAOO') )
	{
		if ( getObj('SceltaAOO').length > 1 && getObj('SceltaAOO').value == '')
		{
			DMessageBox( '../' , 'Prima di generare il pdf selezionare una AOO.' , 'Attenzione' , 1 , 400 , 300 );
			return -1;
		}
	}

    if(  err > 0 )
	{
		DMessageBox( '../' , 'Per proseguire e\' necessaria la compilazione di tutti i campi evidenziati' , 'Attenzione' , 1 , 400 , 300 );
        return -1;
	}
}

function RefreshContent()
{
	RefreshDocument('');	
}

// Returns the version of Internet Explorer or a -1
// (indicating the use of another browser).
function getInternetExplorerVersion()
{
	var rv = -1; // Return value assumes failure.
	
	try
	{
		if (navigator.appName == 'Microsoft Internet Explorer')
		{
			var ua = navigator.userAgent;
			var re  = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
		
			if (re.exec(ua) != null)
				rv = parseFloat( RegExp.$1 );
		}
	}
	catch(e)
	{
	}
	
	return rv;
}

function testPdfAndroid()
{
	var w;
	var h;


		w = screen.availWidth-100;
		h = screen.availHeight-100;
		
		var newwin = window.open( '' , 'PrintPdf' ,'toolbar=no,location=no,directories=no,status=yes,resizable=yes,copyhistory=yes,scrollbars=yes,menubar=yes,left=0,top=0,width=' + w + ',height=' + h );
    	try{ newwin.document.write( '<html><body><table class="Loading" width="100%" height="100%" ><tr><td width="100%" height="100%" align="center" valign="center" >Loading ...</td></tr></table></body></html>'); }catch(e){};
		newwin.focus();
		
		var objForm=getObj('FORMDOCUMENT');
	
		objForm.action= '../../test2.asp?test=1';
		objForm.target='PrintPdf';
		try{  CloseRTE() }catch(e){};
		objForm.submit();



}



function RecuperaValore( objRup_Pdg )
{
		
	
	var TempValore = 0 ;
	
	if ( objRup_Pdg.type == 'hidden' )
	{
	 
		TempValore = 0;	  
	}
	else
	{
		//UN CHECKBOX
		if ( objRup_Pdg.type == 'checkbox' )
		{
			
			if ( objRup_Pdg.checked == true )
				TempValore = 1;
			else
				TempValore = 0;	
			
		}
		else
		{
			
			//UN CAMPO TESTO
			
			if ( objRup_Pdg.value == 1 )
				TempValore = 1;
			else
				TempValore = 0;	
			
		}		
	}	
	
	//alert(TempValore);
	return 	TempValore;
	
	
}	


function DisplayRuoli_FromAziProfili()
{
	
	//nascondo i ruoli seocndo il valore di aziProfili
	straziProfili = getObj('aziProfili').value;
	
	//alert(straziProfili);
	bVis_PI = 1;
	bVis_PO = 1;
	bVIS_scelta_RUP = 1;
	bVis_scelta_RUP_PDG = 1;
	
	var doc_readonly ;
	doc_readonly = getObj('DOCUMENT_READONLY').value;
	
	/*
	po = getObj('PO');
	pi = getObj('PI');
	rup = getObj('scelta_RUP');
	rup_pdg = getObj('scelta_RUP_PDG');
	*/
	
	//alert(straziProfili.indexOf('P'));
	//PI punto istruttore e PO punto ordinante
	//sono visibili se in aziprofili è presente la P oppure la E
	if ( straziProfili.indexOf('P') == -1 && straziProfili.indexOf('E') == -1  )
	{
		bVis_PI = 0;
		bVis_PO = 0;
	}
	
	//RUP RDO e RUP PDG sono visibili se in aziprofili è presente la P
	if ( straziProfili.indexOf('P') == -1 )
	{
		bVIS_scelta_RUP = 0;
		bVis_scelta_RUP_PDG = 0;
	}
	
	if ( bVis_PI == 0 )
	{
		if ( doc_readonly == 0 )
		{
			pi = getObj('PI');
			
			if ( pi.checked)
				pi.checked = false;
		}
		$("#cap_PI").parents("table:first").css({"display": "none"});	
	}
	
	if ( bVis_PO == 0 )
	{
		if ( doc_readonly == 0 )
		{
			po = getObj('PO');
			
			if ( po.checked)
				po.checked = false;
		}
		$("#cap_PO").parents("table:first").css({"display": "none"});	
	}
	
	if ( bVIS_scelta_RUP == 0 )
	{
		if ( doc_readonly == 0 )
		{
			rup = getObj('scelta_RUP');
			
			if ( rup.checked)
				rup.checked = false;
		}
		
		$("#cap_scelta_RUP").parents("table:first").css({"display": "none"});	
	}
	
	
	if ( bVis_scelta_RUP_PDG == 0 )
	{
		if ( doc_readonly == 0 )
		{
			rup_pdg = getObj('scelta_RUP_PDG');
			
			if ( rup_pdg.checked)
				rup_pdg.checked = false;
		}
		$("#cap_scelta_RUP_PDG").parents("table:first").css({"display": "none"});	
	}
	
	try
	{
		var BloccaResponsabilePEPPOL = getObjValue('BloccaResponsabilePEPPOL');
		
		//Se tra gli aziprofili non troviamo la R ( registrazione peppol ) disabilitiamo il checkbox
		// oppure se esiste già un utente nella mia azienda con associato il ruolo ResponsabilePeppol
		if ( straziProfili.indexOf('R') == -1 || BloccaResponsabilePEPPOL == '1' )
		{
			getObj('ResponsabilePEPPOL').disabled = true;
		}
	}
	catch(e){}
	
}

function AddCodiceIPA()
{
	//alert ( getObj('Plant').value );
	
	//innesco un command sulla griglia "Codici Uffici" per aggiungere se non esiste 
	//il codice IPA associato alla struttura aziendale selezionata
	
	ExecDocCommand ('IPA#ADDFROM#IDROW=' + escape(getObj('Plant').value) + '&TABLEFROMADD=STRUTTURA_APPARTENENZA_ADD_IPA&NODUPLICATI=CODICEIPA')
	
}