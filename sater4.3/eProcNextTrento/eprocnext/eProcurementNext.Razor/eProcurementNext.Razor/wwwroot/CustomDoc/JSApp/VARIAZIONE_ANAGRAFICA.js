
window.onload = Init_VARIAZIONE_ANAGRAFICA;

function Init_VARIAZIONE_ANAGRAFICA()
{
	var statoFunzionale = '';
	
	//evidenzio i campi modificati
	view_differenze();

	//inizializzo il genera pdf
	Init_Firma_VARIAZIONE_ANAGRAFICA();

	//inizializzo i campi GEO
	InitCampiGEO();
	
	//controllo assenza PIVA
	checkAssenzaPIVA()
	try
	{
		statoFunzionale = getObjValue('StatoFunzionale');
		
		debugger
		//DOCUMENT_READONLY
		//Gestisco il filtro nel campo Forma Giuridica
		if (getObj(DOCUMENT_READONLY != 1))
		{
			filtraFormaGiuridica()
		}
		else
		{
			enableDisableAziGeo('aziLocalitaAmm','aziProvinciaAmm','aziStatoAmm','apriGEO2',false);
			enableDisableAziGeo('aziLocalitaLeg','aziProvinciaLeg','aziStatoLeg','apriGEO',false);
		}
		
		
		if ( statoFunzionale == 'InLavorazione' )
		{			
			// filtraFormaGiuridica()
	
			getObj('Note').disabled = true;
			getObj('Note').readOnly = true;
			getObj('Note').style.backgroundColor='#ECECEC';
			$( "#cap_IdpfuInCharge" ).parents("table:first").css({"display":"none"})
			
		}		
		
	}
	catch(e)
	{
	}
	
	

}

function checkAssenzaPIVA()
{
	//Controllo se il campo è da checkare
	if(getObjValue('AssenzaPIVA') == "1")
	{
		DisableObj('aziPartitaIVA', true)
	}
	else
	{
		DisableObj('aziPartitaIVA', false)
	}
	
	//Aggiungo i listener agli elementi
	// document.getElementById("AssenzaPIVA").addEventListener("click", resettaPIVA);
	// document.getElementById("AssenzaPIVA").addEventListener("click", filtraFormaGiuridica);
	
}

function resettaPIVA()
{
	//Controllo se il campo è da checkare
	if(getObjValue('AssenzaPIVA') == true)
	{
		getObj('aziPartitaIVA').value = '';
		DisableObj('aziPartitaIVA', true)
		// $('#aziPartitaIVA').prop( "disabled", true );
		//$( "#x" ).prop( "disabled", true );
	}
	else
		DisableObj('aziPartitaIVA', false)
}

function filtraFormaGiuridica()
{
	let subFilter
	
	console.log(trim(getObjValue('aziPartitaIVA')))
	//Filtro sulla natura giuridica da applicare solo in presenza del parametro nella CTL_Doc con setting valore = 1
	if(getObjValue('filtroAttivo') == 1)
	{
			
		if(getObjValue('aziStatoLeg2') == '') //la prima volta il valore di questo elemento è vuoto e quindi eseguo il controllo su azistatoleg.
		{
			if (getObjValue('aziStatoLeg').includes("Italia"))
			{
				//Lo stato è Italia
				if (getObjValue('AssenzaPIVA') == '1')
				{
					if (getObjValue('codicefiscale').length == 16)
						subFilter = "REL_ValueOutput = 'SI-SI'"
					else
						subFilter = "REL_ValueOutput = 'NO-SI'"
				}
				else
				{
					if (getObjValue('codicefiscale').length == 16)
						subFilter = "REL_ValueOutput = 'SI-NO'"
					else
						subFilter = "REL_ValueOutput = 'NO-NO'"
				}
			}
			else 
			{
				//Lo stato non è Italia
				if (getObjValue('AssenzaPIVA') == '1')
					subFilter = "(REL_ValueOutput = 'SI-SI' or REL_ValueOutput = 'NO-SI')"
				else
					subFilter = "(REL_ValueOutput = 'SI-NO' or REL_ValueOutput = 'NO-NO')"
			}
		}
		else
		{
			if (getObjValue('aziStatoLeg2').includes("M-1-11-ITA"))
			{
				//Lo stato è Italia
				if (getObjValue('AssenzaPIVA') == '1')
				{
					if (getObjValue('codicefiscale').length == 16)
						subFilter = "REL_ValueOutput = 'SI-SI'"
					else
						subFilter = "REL_ValueOutput = 'NO-SI'"
				}
				else
				{
					if (getObjValue('codicefiscale').length == 16)
						subFilter = "REL_ValueOutput = 'SI-NO'"
					else
						subFilter = "REL_ValueOutput = 'NO-NO'"
				}
			}
			else 
			{
				//Lo stato non è Italia
				if (getObjValue('AssenzaPIVA') == '1')
					subFilter = "(REL_ValueOutput = 'SI-SI' or REL_ValueOutput = 'NO-SI')"
				else
					subFilter = "(REL_ValueOutput = 'SI-NO' or REL_ValueOutput = 'NO-NO')"
			}
		}
		
		let filterToAdd = "(tdrcodice in ( select rel_valueinput from CTL_Relations with(nolock) where rel_type = 'DOM_131' and " + subFilter + " ))" 

		
		FilterDom('aziIdDscFormaSoc', 'aziIdDscFormaSoc', getObjValue('aziIdDscFormaSoc'), 'SQL_WHERE=' + filterToAdd, '', '');
	}	
}


function InitCampiGEO()
{
	enableDisableAziGeo('aziLocalitaLeg','aziProvinciaLeg','aziStatoLeg','apriGEO',true);
	enableDisableAziGeo('aziLocalitaAmm','aziProvinciaAmm','aziStatoAmm','apriGEO2',true);
}


function view_differenze()
{
  
  try{ShowEvidenza( 'Evidenzia' , '1px solid red' );}catch(e){}
		
}

function Init_Firma_VARIAZIONE_ANAGRAFICA()
{
  
  var StatoFunzionale = '';
  
  StatoFunzionale = getObj('StatoFunzionale').value ;
  
	if ( (getObjValue('SIGN_LOCK') =='0' || getObjValue('SIGN_LOCK') =='')   && StatoFunzionale=='InLavorazione' )
  {
		document.getElementById('generapdf').disabled = false; 
		document.getElementById('generapdf').className ="generapdf";
	}
	else
	{
		document.getElementById('generapdf').disabled = true; 
		document.getElementById('generapdf').className ="generapdfdisabled";
	}	
	
	if ( getObjValue('SIGN_LOCK') != '0'   && StatoFunzionale=='InLavorazione' )
  {
		document.getElementById('editistanza').disabled = false; 
		document.getElementById('editistanza').className ="attachpdf";
	}
	else
	{
		document.getElementById('editistanza').disabled = true; 
		document.getElementById('editistanza').className ="attachpdfdisabled";
	} 
	
	if ( getObjValue('SIGN_ATTACH') == ''  &&  StatoFunzionale=='InLavorazione' &&  getObjValue('SIGN_LOCK') != '0'  )
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


function impostaLocalita(cod,fieldname)
{
	ajax = GetXMLHttpRequest(); 
	
	var comuneTec;
	var provinciaTec;
	var statoTec;
	var comuneDesc; 
	var provinciaDesc;
	var statoDesc;
	var regioneTec;
	var regioneDesc;
	
	if ( fieldname == 'sedeLegale' )
	{
		comuneTec='aziLocalitaLeg2';
		provinciaTec='aziProvinciaLeg2';
		statoTec='aziStatoLeg2';
		comuneDesc='aziLocalitaLeg';
		provinciaDesc='aziProvinciaLeg';
		statoDesc='aziStatoLeg';
		regioneTec = '';
		regioneDesc = '';
		geo='apriGEO';
	}
	if ( fieldname == 'sedeAmministrativa' )
	{
		comuneTec='aziLocalitaAmm2';
		provinciaTec='aziProvinciaAmm2';
		statoTec='aziStatoAmm2';
		comuneDesc='aziLocalitaAmm';
		provinciaDesc='aziProvinciaAmm';
		statoDesc='aziStatoAmm';
		regioneTec = 'aziRegioneAmm2';
		regioneDesc = 'aziRegioneAmm';
		geo='apriGEO2';
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

							getObj(comuneTec).value = codLoc;
							getObj(comuneDesc).value = descLoc;

							if ( codLoc == '' || codLoc.substring( codLoc.length-3, codLoc.length ) == 'XXX' )
								disableGeoField(comuneDesc, false);
							else
								disableGeoField(comuneDesc, true);

							getObj(provinciaTec).value = codProv;
							getObj(provinciaDesc).value = descProv;

							if ( codProv == '' || codProv.substring( codProv.length-3, codProv.length ) == 'XXX' )
								disableGeoField(provinciaDesc, false);
							else
								disableGeoField(provinciaDesc, true);

							getObj(statoTec).value = codStato;
							getObj(statoDesc).value = descStato;

							if ( codStato == ''  || codStato.substring( codStato.length-3, codStato.length ) == 'XXX' )
								disableGeoField(statoDesc, false);
							else
								disableGeoField(statoDesc, true);
							
							if ( regioneTec != '' )
							{
								try
								{
									if ( codRegione == ''  || codRegione.substring( codRegione.length-3, codRegione.length ) == 'XXX' )
										getObj('aziRegioneLeg').readOnly = false;
									else
										getObj('aziRegioneLeg').readOnly = true;
								}
								catch(e){}

								getObj(regioneTec).value = codRegione;
								getObj(regioneDesc).value = descRegione;
							}
								
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
			
			//Richiamo dopo il popolamento dei campi la funzione i filtro formagiuridica da riapplicare
			if (getObj(DOCUMENT_READONLY != 1))
			{
				filtraFormaGiuridica();
			}
			
		}
		else
		{
			alert('errore in impostaLocalita');
			enableDisableAziGeo(comuneDesc,provinciaDesc,statoDesc,geo,false);
		}
	}
}



function GeneraPDF ()
{
	//ToPrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=Variazione Dati OE&lo=print&NO_SECTION_PRINT=FIRMA,APPROVAL');
  
	//chiamata ai controlli del documento
	var value = Controlli_Obblig ( );
 
	if (value == -1)
		return;
	
	
	//se sono stati superati i controlli obblig faccio quelli formali(Controllo PIVA)
	if ( onChangePIVA() == -1)
		return;
	
	scroll(0,0);
	
	ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');
  
}


function TogliFirma () 
{
	DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );	
	ExecDocProcess( 'SIGN_ERASE,VARIAZIONE_ANAGRAFICA');
}

function TxtErr( field )
{
    
		try{ getObj(field ).style.backgroundColor='#FFBE7D'; }catch(e){}; // F80

		try{ getObj(field + '_V' ).style.backgroundColor='#FFBE7D'; }catch(e){}; //FFC


		try{ getObj(field + '_edit' ).style.backgroundColor='#FFBE7D'; }catch(e){};
		try{ getObj(field + '_edit' ).style.backgroundColor='#FFBE7D'; }catch(e){};
	
		try{ getObj( field  + '_edit_new' ).style.borderColor='#FFBE7D'; }catch(e){};
		try{ getObj(field + '_edit_new' ).style.backgroundColor='#FFBE7D'; }catch(e){};
 		if ( getObj(field  ).type == 'checkbox' )
 		{
   		try{ getObj(field  ).offsetParent.style.backgroundColor='#FFBE7D'; }catch(e){};
    		
   	}
} 

function trim(str){
    return str.replace(/^\s+|\s+$/g,"");
}


function allegafilefirmato()
{
	//se ritorna 0 non è estero e quindi controllo che il file firmato digitalmente
	if ( getObj('Estero').value == '0' )
	{
		ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=ctl_doc&IDDOC=' + getObjValue('IDDOC') + '&OPERATION=INSERTSIGN&IDENTITY=Id&AREA=&DOMAIN=FileExtention&FORMAT=#AllegaFirma#600,400');
	}
	else
	{
		ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=ctl_doc&IDDOC=' + getObjValue('IDDOC') + '&OPERATION=INSERTSIGN&IDENTITY=Id&SIGN_OR_ATTACH=YES&AREA=&DOMAIN=FileExtention&FORMAT=#AllegaFirma#600,400');
	}
}


function Controlli_Obblig ( )
{
	
	var err = 0;
	
	//controllo aziIdDscFormaSoc
	TxtOK( 'aziIdDscFormaSoc' );
	if( trim(getObjValue('aziIdDscFormaSoc')) == '' ){
		
		err = 1;
		TxtErr( 'aziIdDscFormaSoc' );
	}
	
	//controllo aziRagioneSociale
	TxtOK( 'aziRagioneSociale' );
	if( trim(getObjValue('aziRagioneSociale')) == '' ){
		
		err = 1;
		TxtErr( 'aziRagioneSociale' );
	}
	
	//controllo aziIndirizzoLeg
	TxtOK( 'aziIndirizzoLeg' );
	if( trim(getObjValue('aziIndirizzoLeg')) == '' ){
		
		err = 1;
		TxtErr( 'aziIndirizzoLeg' );
	}
	
	TxtOK( 'aziCAPLeg' );
	if( trim(getObjValue('aziCAPLeg')) == '' ){
		
		err = 1;
		TxtErr( 'aziCAPLeg' );
	}
	
	TxtOK( 'aziE_Mail' );
	if( trim(getObjValue('aziE_Mail')) == '' )
	{
		err = 1;
		TxtErr( 'aziE_Mail' );
	}
	
	// TxtOK( 'aziPartitaIVA' );
	// if( ( trim(getObjValue('aziPartitaIVA')) == '' || onChangePIVA() == -1 ) && ( getObjValue('colonnatecnica') != 'PARTITA_IVA_NON_PRESENTE' ) )
	// {
		// err = 1;
		// TxtErr( 'aziPartitaIVA' );
	// }
	
	/* Controllo sulla spunta assenza PIVA -- Imposto il controllo sulla partita IVA solo se la checkbox sull'assenza PIVA non è spuntata*/
	TxtOK( 'AssenzaPIVA' );
	//if(getObjValue('AssenzaPIVA') == false && ( trim(getObjValue('aziPartitaIVA')) == '' || onChangePIVA() == -1 ) && ( getObjValue('colonnatecnica') != 'PARTITA_IVA_NON_PRESENTE' )){
	if ( getObjValue('AssenzaPIVA') == false &&  trim(getObjValue('aziPartitaIVA')) == ''   ){
		
		err = 1;
		TxtErr( 'aziPartitaIVA' );
	}
	
	
	
	TxtOK( 'DataDecorrenzaVariazioni' );
	if( trim(getObjValue('DataDecorrenzaVariazioni')) == '' )
	{
		err = 1;
		TxtErr( 'DataDecorrenzaVariazioni' );
	}
	
	var OperazioniStraordinarie = getObjValue('OperazioniStraordinarie');
	var DataVariazione = getObjValue('DataVariazione');
	var AttoOperazioneStraordinaria = getObjValue('AttoOperazioneStraordinaria');

	if ( OperazioniStraordinarie != '' && ( DataVariazione == '' || AttoOperazioneStraordinaria == '' ) )
	{
		if ( DataVariazione == '' )
		{
			err = 1;
			TxtErr( 'DataVariazione' );
		}
		
		if ( AttoOperazioneStraordinaria == '' )
		{
			err = 1;
			TxtErr( 'AttoOperazioneStraordinaria' );
		}
	}

	if(  err > 0 )
	{
		
		DMessageBox( '../' , 'Per proseguire e\' necessaria la compilazione di tutti i campi evidenziati' , 'Attenzione' , 1 , 400 , 300 );
        return -1;
	}	
	
}

function afterProcess( param )
{
	var attivaPdfModuloVarAnag = '';

	if ( param == 'FITTIZIO' )
	{

		if ( getObj('attivaPdfModuloVarAnag') )
		{
			attivaPdfModuloVarAnag = getObjValue('attivaPdfModuloVarAnag');
		}
		
		if ( attivaPdfModuloVarAnag == 'CUSTOM' )
		{
			PrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=DICHIARAZIONE&PROCESS=&MODULO=DICHIARAZIONE_FORN_SATER.pdf&MODULO_VIEW=VIEW_MODULO_PDF_DICHIARAZIONE_FORN');
		}
		else
		{
			PrintPdfSign('TABLE_SIGN=CTL_DOC&lo=print&PROCESS=&PDF_NAME=Variazione Dati OE&URL=/report/prn_VARIAZIONE_ANAGRAFICA.asp?SIGN=YES');
		}

	}
}


function onChangePIVA()
{
	resp =  checkPIVA_ext('../../',getObjValue('aziStatoLeg2'),getObjValue('aziPartitaIVA'),'YES');
	
	var arr=resp.split("#");
			
	if ( arr[0] == '0' ) //Se è stato restituito il warning di controllo
	{
		
		DMessageBox( '../' , 'NO_ML###' + decodeHTMLEntities(arr[1]), 'Attenzione' , 1 , 400 , 300 );
		return -1;	
	}
	if ( arr[0] == '2' ) //Errore server
	{
		DMessageBox( '../' , 'NO_ML###Errore server' , 'Attenzione' , 1 , 400 , 300 );
		return -1;				
	}
	
	if ( arr[0] == '1' ) //OK
	{
		return;
	}
	
	
}

function myExecDocProcess(P){
	DisableObj('aziPartitaIVA', false);
	ExecDocProcess(P);
	
}

function mySaveDoc(){
	DisableObj('aziPartitaIVA', false);
	SaveDoc();
}