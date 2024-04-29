	
window.onload = initAziEnte;

function LocControllaCF_PG( obj ) 
{
	try
	{	
		if( getObjValue ( 'SYS_MNEMONICOMARKETPLACE' ) == 'IM' )
		{
			CheckCF( obj ) ;
		}
		else
		{
			ControllaCF_PG_Extended( obj ) ;
		}
		
	}
	catch(e){
		ControllaCF_PG_Extended( obj ) ;
	}
	
	
	
}


function MySend(param)
{
	// DMessageBox( '../' , 'Prima di Inviare il documento allegare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );

	//checkCoerenzaCF() == 1 &&
	
	if (  verifyCap( 'aziLocalitaLeg2', getObj('aziCAPLeg') ) )
	{
		ExecDocProcess( param );
	}
}


function SetProfiliFunzionalita( obj )
{
	//-- recupera la riga dove si trova l'attributo
	strNameAttrib = obj.name;
	vPartName=strNameAttrib.split('_');
	
	indRow = parseInt(vPartName[0].substr(1,vPartName[0].lenght));
	
	tempvalue=obj.value;
	ainfo=tempvalue.split('###');
	getObjGrid('R' + indRow + '_pfuprofili').value=ainfo[0];
	getObjGrid('R' + indRow + '_pfufunzionalita').value=ainfo[1];
}

function initAziEnte()
{
	localEnableDisableAziGeo(true);
}

function openGEO()
{
	//codApertura = 'M-1-11-ITA';
	codApertura = 'M-1-11-ITA-ITH-ITH5';
	
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
	
	//aggiunto il parametro cod_to_exclude per non visualizzare i codici che finiscono con XXX, quindi gli elementi 'altro' del dominio
	ExecFunction(  '../../Ctl_Library/gerarchici.asp?lo=content&portale=no&cod_to_exclude=%25XXX&fieldname=localita&path_filtra=GEO&caption=Dominio GEO&help=help_geo_ente&path_start=GEO&lvl_sel=,3,6,7,&lvl_max=7&cod=' + codApertura + '&js=impostaLocalita' , 'DOMINIO_GEO' , ',width=700,height=750' );
}

function impostaLocalita(cod,fieldName)
{
	ajax = GetXMLHttpRequest(); 

	if(ajax)
	{
		ajax.open("GET", '../../ctl_library/functions/infoNodoGeo.asp?fldname=localita&cod=' + escape(cod), false);
		//output nella forma : COD-COMUNE#@#DESC-COMUNE#@#COD-PROVINCIA#@#DESC-PROVINCIA#@#COD-STATO#@#DESC-STATO#@#COD-REGIONE#@#DESC-REGIONE
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
							var codRegione;
							var descRegione;

							codLoc = vet[0];
							descLoc = vet[1];
							codProv = vet[2];
							descProv = vet[3];
							codStato = vet[4];
							descStato = vet[5];
							codRegione = vet[6];
							descRegione = vet[7];
							

							getObj('aziLocalitaLeg2').value = codLoc;
							getObj('aziLocalitaLeg').value = descLoc;

							if ( codLoc == '' || codLoc.substring( codLoc.length-3, codLoc.length ) == 'XXX' )
								disableGeoField('aziLocalitaLeg', false);
							else
								disableGeoField('aziLocalitaLeg', true);

							getObj('aziProvinciaLeg2').value = codProv;
							getObj('aziProvinciaLeg').value = descProv;

							if ( codProv == '' || codProv.substring( codProv.length-3, codProv.length ) == 'XXX' )
								disableGeoField('aziProvinciaLeg', false);
							else
								disableGeoField('aziProvinciaLeg', true);

							getObj('aziStatoLeg2').value = codStato;
							getObj('aziStatoLeg').value = descStato;

							if ( codStato == ''  || codStato.substring( codStato.length-3, codStato.length ) == 'XXX' )
								disableGeoField('aziStatoLeg', false);
							else
								disableGeoField('aziStatoLeg', true);
								
							if ( codRegione == ''  || codRegione.substring( codRegione.length-3, codRegione.length ) == 'XXX' )
								getObj('aziRegioneLeg').readOnly = false;
							else
								getObj('aziRegioneLeg').readOnly = true;
							
							getObj('aziRegioneLeg2').value = codRegione;
							getObj('aziRegioneLeg').value = descRegione;
								
						}
						catch(e)
						{
							alert('Errore:' + e.message);
							//localEnableDisableAziGeo(false);
						}
					}
					else
					{
						alert('errore.msg:' + res.substring(2));
						localEnableDisableAziGeo(false);
					}
				}
			}
			else
			{
				alert('errore.status:' + ajax.status);
				localEnableDisableAziGeo(false);
			}
		}
		else
		{
			alert('errore in impostaLocalita');
			localEnableDisableAziGeo(false);
		}
	}
}


function localEnableDisableAziGeo(bool)
{
	enableDisableAziGeo('aziLocalitaLeg','aziProvinciaLeg','aziStatoLeg','apriGEO',bool,'aziRegioneLeg');
	
	/*
	getObj('aziLocalitaLeg').readOnly = bool;
	getObj('aziProvinciaLeg').readOnly = bool;
	getObj('aziStatoLeg').readOnly = bool;
	*/
}

function checkCoerenzaCF()
{
	var nome = getObjValue('NomeRapLeg').replace(/^\s+|\s+$/gm,'');
	var cognome = getObjValue('CognomeRapLeg').replace(/^\s+|\s+$/gm,'');
	var cf = getObjValue('CFRapLeg').replace(/^\s+|\s+$/gm,'');
	
	var resFunct = 1;
	
	/* Se sono avvalorati tutti i campi utili */
	if ( nome !== '' && cognome !== '' && cf !== '' )
	{
		if ( !isMyCF('../../', nome , cognome, cf) )
		{
			resFunct = 0;
			
			alert( CNV( '../../' , 'Codice fiscale rappresentante legale non coerente con nome e cognome' ) );
			
			TxtErr( 'NomeRapLeg' );
			TxtErr( 'CognomeRapLeg' );
			TxtErr( 'CFRapLeg' );
		}
		else
		{
			resFunct = 1;
			
			TxtOK( 'NomeRapLeg' );
			TxtOK( 'CognomeRapLeg' );
			TxtOK( 'CFRapLeg' );
		}

	}
	
	return resFunct;
	
	
	//isMyCF
}

