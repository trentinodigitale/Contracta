var LstAttrib = [

    'NomeRapLeg',
    'CognomeRapLeg',
    'LocalitaRapLeg',
    'ProvinciaRapLeg',

];


var NumControlli = LstAttrib.length;

function trim(str) {
    return str.replace(/^\s+|\s+$/g, "");
}


function LocDMessageBox(path, Text, Title, ICO, w, h) {
    alert(CNV('../../', Text));
}

function InvioOfferta(param) {

    //alert(param);
    /*
    var bret = false;
    var bret = ControlliOfferta('');
    //alert(bret);
    if (!bret) {
        return;
    }
    */
    
    ExecDocProcess('SEND,OFFERTA_ASTA');

}

function GeneraPDF() {
    
    PrintPdfSign('URL=/report/prn_OFFERTA_ASTA.ASP?PDF_NAME=Offerta&SIGN=YES&PROCESS=OFFERTA_ASTA%40%40%40SIGN_ERASE');

}


function SetInitField() {

    var i = 0;
    for (i = 0; i < NumControlli; i++) {
        TxtOK(LstAttrib[i]);
    }


}



function IsNumeric2(sText) {
    var ValidChars = '0123456789.';
    var IsNumber = true;
    var Char;

    for (i = 0; i < sText.length && IsNumber == true; i++) {
        Char = sText.charAt(i);
        if (ValidChars.indexOf(Char) == -1) {
            IsNumber = false;
        }
    }
    return IsNumber;

}


function roundTo(X, decimalpositions) {
    var i = X * Math.pow(10, decimalpositions);
    i = Math.round(i);
    return i / Math.pow(10, decimalpositions);
}

function OFFDettagliDel(x, y, z) {

    if (getObjValue('R' + y + '_NotEditable') == '') {
		OnChangeEdit( this );
        return DettagliDel(x, y, z);
    }
}

function OffExecDocCommand( param )
{
	OnChangeEdit( this );
	return ExecDocCommand( param );
}



//funzione per inserire nella sezione documentazione i tipi allegati consentiti scelti in creazione del BANDO
function FormatAllegato() {

    var numDocu = GetProperty(getObj('DOCUMENTAZIONEGrid'), 'numrow');
    var tipofile;
    var richiestaFirma;
    var onclick;
    var obj;

    for (i = 0; i <= numDocu; i++) {
        try {

            tipofile = getObj('RDOCUMENTAZIONEGrid_' + i + '_TipoFile').value;

            try {
                richiestaFirma = getObj('RDOCUMENTAZIONEGrid_' + i + '_RichiediFirma').value;
            } catch (e) {
                richiestaFirma = '';
            }

            tipofile = ReplaceExtended(tipofile, '###', ',');
            tipofile = 'INTEXT:' + tipofile.substring(1, tipofile.length);
            tipofile = tipofile.substring(0, tipofile.length - 1) + '-';
            tipofile = 'FORMAT=HINTV' + tipofile;

            if (richiestaFirma == '1') {
                tipofile = tipofile + 'INTVB'; //format per forzare la verifica di firma bloccante in caso di mancata firma o file corrotto
            }

            obj = getObj('RDOCUMENTAZIONEGrid_' + i + '_Allegato_V_BTN').parentElement;
            onclick = obj.innerHTML;
            //onclick = onclick.replace('FORMAT=INT', tipofile);
			onclick=onclick.replace(/FORMAT=INTV/g,tipofile);
			onclick=onclick.replace(/FORMAT=INT/g,tipofile);
            obj.innerHTML = onclick;

        } catch (e) {}
    }

}



function MyExecDocProcess(param) {

    ExecDocProcess(param);
}

function MySaveDoc() {

    SaveDoc();

}


function RefreshContent() {
    RefreshDocument('');
}


window.onload = DisplaySection;

function OnChangeEdit( obj )
{
	
	SetTextValue( 'RTESTATA_PRODOTTI_MODEL_EsitoRiga' , CNV( '../../',  'L\'elenco Prodotti e\' stato modificato, e\' necessario eseguire il comando Verifica Informazioni'));
	
}

var myInterval ;

function DisplaySection(obj) 
{
	//-- avvia l'aggiornamento dell'asta
	myInterval = setInterval( DisplayAvanzamentoAsta , 1000);
	
	
	try
	{
		getObj('PRODOTTIGrid').onchange = OnChangeEdit;
	}catch(e){};
	

	ShowCol( 'PRODOTTI' , 'FNZ_DEL'  , 'none' )
	FormatNumDec();
	
	
	Init_Firma_OFFERTA();
	
}


function ControlliOfferta(param) {

    //CONTROLLO IN CASO DI RTI
    var bret = false;
    var bret = CanSendRTI();

    if (!bret) {
        return false;
    }

    return true;


}

function FormatNumDec()
{
	var colonna=getObj('colonnatecnica').value;
	var numdec=getObj('NumDec').value;
	var blur='';
	var blurtmp='';
	var blurtmp2='';
	var onclick;
	var tipofile;
	
	try
	{
		var numrrowprod = Number(GetProperty( getObj('PRODOTTIGrid') , 'numrow') );
		if(   numrrowprod  >= 0 )
		{
			var t=0;
			for (t=0;t<numrrowprod+1;t++)
			
			{
				
				if ( numdec > 0 )
				{
					tipofile='format#=####,###,##0.' + pad(0, numdec);
				}
				else
				{
					tipofile='format#=####,###,##0' ;
				}
				obj=getObj('R' + t + '_' + colonna + '_V').parentElement;	
				onclick=obj.innerHTML;
				onclick=onclick.replace(/format#=####,###,##0.00###/g,tipofile);
				obj.innerHTML = onclick;
				
				
				
				
			}
		
		}
	} catch (e) {}

}

function PRODOTTI_AFTER_COMMAND() {
   
	FormatNumDec();
}

function pad(number, length) {
   
    var str = '' + number;
    while (str.length < length) {
        str = '0' + str;
    }
   
    return str;

}


function EseguiRilancio()
{
	if ( getObjValue( 'StatoAsta' ) == 'InCorso' )
	{
		ExecDocProcess( 'NUOVO_RILANCIO,OFFERTA_ASTA');	
	}
	else
	{
		DMessageBox('../', 'Lo stato dell asta non consente di eseguire un rilancio', 'Attenzione', 1, 400, 300);
		
	}
	
}



function DisplayAvanzamentoAsta()
{
	//-- invoca la pagina che restituisce l'avanzamento
    //SE LA SESSIONE E' SCADUTA BLOCCO LE CHIAMATE
	if ( document.getElementById('tempo_di_sessione').innerHTML.indexOf('00:00') == 0    )
	{
		clearInterval(myInterval);
	}
	else
	{
		var nocache = new Date().getTime();
		ajax = GetXMLHttpRequest();

		if(ajax)
		{
				ajax.open("GET", 'ElencoRilanci.asp?DOCUMENT=OFFERTA_ASTA&IDDOC=' + getObjValue('IDDOC') + '&nocache=' + nocache, true);
				ajax.onreadystatechange = function() 
				{
					if(ajax.readyState == 4) {
						if(ajax.status == 200)
						{
							DisplayRilanci(   ajax.responseText  );
						}
					}
				}
				ajax.send(null);
			return true;
		}
		return false;
	}
	
	
}



function DisplayRilanci(  dati  )
{
	eval( dati );
	
	
	if ( VarStatoAsta == 'Chiusa' || VarStatoAsta == 'AggiudicazioneDef'  || VarStatoAsta == 'AggiudicazioneProvv' || VarStatoAsta == 'AggiudicazioneCond' )
	{
		clearInterval( myInterval );
	}
	
	var TabRilanci = '<table class="Grid"  id="RilanciGrid"  width="300"  cellspacing="0" cellpadding="0" >';
	TabRilanci += '<tr><th class=" nowrap  access_width_10 Grid_RowCaption" >Data Ricezione</th><th class=" nowrap  access_width_10 Grid_RowCaption" >Valore Offerta</th></tr>';

	var r = 1;
	for ( i = 0 ; i < NumeroRilanci ; i++ )
	{
		if ( r == 0 ) 
			r = 1;
		else
			r = 0;
		
		var sel = '';
		if ( VarRilanci[i][2] == 'BLUE' )
			sel = '_Sel'
		
		TabRilanci += '<tr id="PRODOTTIGridR0" class="GR' + r + sel + '"  ><td id="PRODOTTIGrid_r0_c0"  class="GR0_Text nowrap"  >' + VarRilanci[i][0] + '</td><td id="PRODOTTIGrid_r0_c0"  class="GR0_Text nowrap"  >' + VarRilanci[i][1] + '</td>';
	}
	
	TabRilanci += '</tr></table>';
	
	getObj( 'RilanciGrid').outerHTML = TabRilanci;
	
	if ( VarResiduo > 60  )
	{
		varSecondi = VarResiduo - (Math.floor( VarResiduo / 60 ) * 60 );
		VarResiduo = Math.floor( VarResiduo / 60 );
		getObj( 'Cell_Residuo' ).innerHTML = '<span style="font-size:2em" class="nowrap" >' + VarResiduo + ' Minuti ' + varSecondi + ' Secondi</span>';
	}
	else
	if ( VarResiduo < 0  || VarStatoAsta == 'Chiusa' || VarStatoAsta == 'AggiudicazioneDef' || VarStatoAsta == 'AggiudicazioneProvv' || VarStatoAsta == 'AggiudicazioneCond' )
  {
		getObj( 'Cell_Residuo' ).innerHTML = '<span style="font-size:2em ;color:black" class="nowrap">Tempo terminato</span>'
		getObj('val_StatoAsta').innerHTML = VarStatoAstaCNV + '<input type="hidden" name="StatoAsta" id="StatoAsta" value="' + VarStatoAsta + '" >';
		getObj('StatoAsta').value = 'Chiusa';
    
    //chiamo il refresh del documento per aggiornarel o stato a video
    //if ( getObjValue('StatoFunzionale') == 'InLavorazione' )
    //  ReloadDocFromDB( getObjValue('IDDOC') , 'OFFERTA_ASTA' );
    //  RefreshContent();
	}
	else
	{
		getObj( 'Cell_Residuo' ).innerHTML = '<span style="font-size:2em ;color:red" class="nowrap" >' + VarResiduo + ' Secondi</span>'
	}
	
	
	getObj( 'DataScadenzaAsta_L').innerHTML = VarDataScadenzaAsta ;
	
	
}




//inizializzo bottoni per la firma
function Init_Firma_OFFERTA(){
   
  
  var StatoFunzionale ='';
  
  StatoFunzionale = getObjValue('StatoFunzionale');
  
  /*
  alert(getObjValue('SIGN_LOCK'));
  alert(getObjValue('SIGN_ATTACH'));
  alert(getObj('IdpfuInCharge').value);
  */
  
  if ( StatoFunzionale != 'InLavorazione' )
    getObj('Rilancia').style.display='none';
  
  if ( StatoFunzionale=='InAttesaFirma' ){
    document.getElementById('generapdf').disabled=false;
    document.getElementById('attachpdf').disabled=false;
  }else{
    document.getElementById('generapdf').disabled = true; 
		document.getElementById('generapdf').className ="generapdfdisabled";
    document.getElementById('attachpdf').disabled = true; 
		document.getElementById('attachpdf').className ="editistanzadisabled";
  }
  
  /*    	
	if ( (getObjValue('SIGN_LOCK') == '0' || getObjValue('SIGN_LOCK') == '')   &&  StatoFunzionale=='InAttesaFirma'  &&  getObj('IdpfuInCharge').value == idpfuUtenteCollegato )
  {
		document.getElementById('generapdf').disabled = false; 
		document.getElementById('generapdf').className ="generapdf";
	}
	else
	{
		document.getElementById('generapdf').disabled = true; 
		document.getElementById('generapdf').className ="generapdfdisabled";
	}	
	  	
	if ( getObjValue('SIGN_ATTACH') == '' && StatoFunzionale == 'InAttesaFirma' &&  getObjValue('SIGN_LOCK') != '0' &&  getObj('IdpfuInCharge').value == idpfuUtenteCollegato )
  {
		document.getElementById('attachpdf').disabled = false; 
		document.getElementById('attachpdf').className ="editistanza";
	}
	else
	{
		document.getElementById('attachpdf').disabled = true; 
		document.getElementById('attachpdf').className ="editistanzadisabled";
	}
  */
  
}
