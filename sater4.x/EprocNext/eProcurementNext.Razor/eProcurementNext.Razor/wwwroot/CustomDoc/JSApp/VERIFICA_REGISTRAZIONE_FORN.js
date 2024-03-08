var LstAttrib = [

'aziRagioneSociale',
'aziStatoLeg', 
'CAPLEG',
'codicefiscale',
'EMAIL',
'INDIRIZZOLEG',
'LOCALITALEG',
'NaGi',
//'NUMFAX',
'NUMTEL',
'PIVA',
'PROVINCIALEG',
'CognomeRapLeg',
'EmailRapLeg',
'NomeRapLeg',
'pfuRuoloAziendale',
'TelefonoRapLeg',
'CFRapLeg'
];


var NumControlli = LstAttrib.length;

function trim(str)
{
   return str.replace(/^\s+|\s+$/g,"");
}

function InvioDati( param )
{	
	
	
//	if (getObjValue('SIGN_ATTACH') == ""  )
//	{
//		DMessageBox( '../' , 'Prima di Inviare il documento allegare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
//		return;
//	}
//	if (getObjValue('SIGN_ATTACH') != "" )
	{
		
		ExecDocProcess( 'SEND,VERIFICA_REGISTRAZIONE_FORN');
		
	}
	
}

function GeneraPDF ()
{
	
	
	var value2=controlli('');
	if (value2 == -1)
	return;  
	
    scroll(0,0);  
    PrintPdfSign('URL=/report/prn_VERIFICA_REGISTRAZIONE_FORN.ASP?SIGN=YES&PDF_NAME=VERIFICA_REGISTRAZIONE');
		
		
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
    param = '/report/prn_' + getObj('TYPEDOC').value + '.ASP?';       
    PrintPdf( param );
}
function DISPLAY_FIRMA_OnLoad()
{
   
	var Stato ='';
	var statFunz = '';
	
	Stato = getObjValue('StatoDoc');
	statFunz = getObjValue('StatoFunzionale');
	
	if (statFunz == 'InLavorazione' )
		Stato = 'Saved';
	
	
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
	
	enableDisableAziGeo(true);
	
}

window.onload = DISPLAY_FIRMA_OnLoad;


function controlli (param)
{
	
	var err = 0;
    var	cod = getObj( "IDDOC" ).value;
	
	
    var strRet = CNV( '../' , 'ok' );
	
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
	
	
	
	//controllo la prensenza di allegati nella sezione della documentazione
	var i=0;
	try{
		
		for( i = 0 ; i <= 100 ; i++ )
		{
			try
			{
				
				if( getObjValue( 'R' + i + '_Allegato' ) == '' )
				{
					err = 1;
					TxtErr( 'R' + i + '_Allegato' );
				}
				else
				{
					
					TxtOK( 'R' + i + '_Allegato' );
				}
				
				
				if( getObjValue( 'R' + i + '_Descrizione' ) == '' )
				{
					err = 1;
					TxtErr( 'R' + i + '_Descrizione' );
				}
				else
				{
					
					TxtOK( 'R' + i + '_Descrizione' );
				}
								
			}catch(e)	  {	  }
		}
	}
	catch(e){}
	
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

function openGEO()
{
	codApertura = 'M-1-11-ITA';
	
	var tmp = getObj('aziLocalitaLeg2').value;
	
	if ( tmp !== '' )
	{
		codApertura = tmp;
	}
	else
	{
		var tmp = getObj('aziProvinciaLeg2').value;
		
		if ( tmp !== '' )
			codApertura = tmp;
	}
	
	
	ExecFunction(  '../../Ctl_Library/gerarchici.asp?lo=content&portale=no&fieldname=localita&path_filtra=GEO&caption=Dominio GEO&help=help_geo_azienda&path_start=GEO&lvl_sel=,3,6,7,&lvl_max=7&cod=' + codApertura + '&js=impostaLocalita' , 'DOMINIO_GEO' , ',width=700,height=750' );
}

function impostaLocalita(cod,fieldName)
{
	ajax = GetXMLHttpRequest(); 

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

							getObj('aziLocalitaLeg2').value = codLoc;
							getObj('LOCALITALEG').value = descLoc;

							if ( codLoc == '' || codLoc.substring( codLoc.length-3, codLoc.length ) == 'XXX' )
								disableGeoField( 'LOCALITALEG', false);
							else
								disableGeoField( 'LOCALITALEG', true);

							getObj('aziProvinciaLeg2').value = codProv;
							getObj('PROVINCIALEG').value = descProv;

							if ( codProv == '' || codProv.substring( codProv.length-3, codProv.length ) == 'XXX' )
								disableGeoField( 'PROVINCIALEG', false);
							else
								disableGeoField( 'PROVINCIALEG', true);

							getObj('aziStatoLeg2').value = codStato;
							getObj('aziStatoLeg').value = descStato;

							if ( codStato == ''  || codStato.substring( codStato.length-3, codStato.length ) == 'XXX' )
								disableGeoField( 'aziStatoLeg', false);
							else
								disableGeoField( 'aziStatoLeg', true);
								
						}
						catch(e)
						{
							alert('Errore:' + e.message);
							//enableDisableAziGeo(false);
						}
					}
					else
					{
						alert('errore.msg:' + res.substring(2));
						enableDisableAziGeo(false);
					}
				}
			}
			else
			{
				alert('errore.status:' + ajax.status);
				enableDisableAziGeo(false);
			}
		}
		else
		{
			alert('errore in impostaLocalita');
			enableDisableAziGeo(false);
		}
	}
}

function enableDisableAziGeo(bool)
{
	getObj('LOCALITALEG').readOnly = bool;
	getObj('PROVINCIALEG').readOnly = bool;
	getObj('aziStatoLeg').readOnly = bool;
}
