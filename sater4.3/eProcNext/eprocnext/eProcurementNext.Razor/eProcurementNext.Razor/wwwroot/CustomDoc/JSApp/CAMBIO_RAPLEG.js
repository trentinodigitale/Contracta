var LstAttrib = [

'Utente',
'StatoRapLeg',
'ProvinciaRapLeg',
'LocalitaRapLeg',
'DataRapLeg',
'StatoResidenzaRapLeg',
'ProvResidenzaRapLeg',
'ResidenzaRapLeg',
'IndResidenzaRapLeg',
'CapResidenzaRapLeg'    
];

var NumControlli = LstAttrib.length;

function trim(str)
{
   return str.replace(/^\s+|\s+$/g,"");
}

function InvioDati( param )
{	
	
	
	if (getObjValue('SIGN_ATTACH') == ""  )
	{
		DMessageBox( '../' , 'Prima di Inviare il documento allegare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
		return;
	}
	
	if (getObjValue('SIGN_ATTACH') != "" && verifyCap( 'ResidenzaRapLeg2', getObj('CapResidenzaRapLeg') ) )
	{
		ExecDocProcess( param );
	}

}

function GeneraPDF ()
{
	Stato = getObjValue('StatoDoc');
    
    if( Stato == '' ) 
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
    PrintPdfSign('URL=/report/prn_CAMBIO_RAPLEG.ASP?SIGN=YES&PDF_NAME=CAMBIO_RAP_LEG');
		
}

 

function TogliFirma () 
{
	DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
	ExecDocProcess( 'SIGN_ERASE,FirmaDigitale');
	
	
}

function SetInitField()
{
    
	var i = 0;
	for( i = 0 ; i < NumControlli ; i++ )
	{
		TxtOK( LstAttrib[i] );
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
	Stato = getObjValue('StatoDoc');
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
	
	OnchangeRapLegInAzi();
	initAziEnte();
}
window.onload = DISPLAY_FIRMA_OnLoad;




function controlli (param)
{
	
	var err = 0;
    var	cod = getObj( "IDDOC" ).value;
	
		
    var strRet = CNV( '../' , 'ok' );
	SetInitField();
    //-- controllo i dati della richiesta
    var i = 0;
    var err = 0;
	
	for( i = 0 ; i < NumControlli ; i++ )
	{
		
		try{
			
			
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
			
			
		}catch(e)
		{
			alert( i + ' - ' +  LstAttrib[i] );
		}
		
	}
	
	//-- se il precedente rappresentante legale non è dimesso si deve metterela qualifica che prenderà
	if ( getObj('Dimesso').checked == false )
	{
	    if( getObjValue( 'pfuRuoloAziendalePrecRapleg' ) == '' )
	    {
			err = 1;
			TxtErr( 'pfuRuoloAziendalePrecRapleg'  );
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

function OnchangeRapLegInAzi()
{
	if ( getObj('Dimesso').checked == true )
		getObj('pfuRuoloAziendalePrecRapleg').disabled=true;
	else
		getObj('pfuRuoloAziendalePrecRapleg').disabled=false;

}


//GESTIONE DEI CAMPI LOCALITA PROVINCIA E STATO

function initAziEnte()
{
	enableDisableAziGeo('LocalitaRapLeg','ProvinciaRapLeg','StatoRapLeg','apriGEO',true);
	enableDisableAziGeo('ResidenzaRapLeg','ProvResidenzaRapLeg','StatoResidenzaRapLeg','apriGEO2',true);
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

function onchangeNuovoRapLeg(obj)
{
	  UpdateFieldVisual(getObj('Utente'),'DATI_NUOVO_RAPLEG','DATI_NUOVO_RAPLEG','no','=','parent');
}
