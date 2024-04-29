
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
	initAziEnte();
}
window.onload = DISPLAY_FIRMA_OnLoad;

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
								getObj(comuneDesc).readOnly = false;
							else
								getObj(comuneDesc).readOnly = true;

							getObj(provinciaTec).value = codProv;
							getObj(provinciaDesc).value = descProv;

							if ( codProv == '' || codProv.substring( codProv.length-3, codProv.length ) == 'XXX' )
								getObj(provinciaDesc).readOnly = false;
							else
								getObj(provinciaDesc).readOnly = true;

							getObj(statoTec).value = codStato;
							getObj(statoDesc).value = descStato;

							if ( codStato == ''  || codStato.substring( codStato.length-3, codStato.length ) == 'XXX' )
								getObj(statoDesc).readOnly = false;
							else
								getObj(statoDesc).readOnly = true;
								
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

function RefreshContent()
{
	RefreshDocument('');	
}	