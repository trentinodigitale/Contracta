window.onload = DisplaySection;

var grigliaProdottiVariata = 'NO';

var LstAttrib = [

    'NomeRapLeg',
    'CognomeRapLeg',
    'LocalitaRapLeg',
    'ProvinciaRapLeg',

];


var NumControlli = LstAttrib.length;
var wincoppia;

function trim(str)
 {
    return str.replace(/^\s+|\s+$/g, "");
}



function LocDMessageBox(path, Text, Title, ICO, w, h) {
    //alert(CNV('../../', Text));
	ML_text = Text
	Title = 'Informazione';					
	ICO = 1;
	page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

	ExecFunctionModale( page, null , 200 , 420 , null  );
	
}



function SetInitField() 
{

    var i = 0;
    for (i = 0; i < NumControlli; i++) {
        TxtOK(LstAttrib[i]);
    }


}

function TxtErr(field) 
{
	
    if (field != 'DichiaraTipoImpresa') 
	{
        try {
            getObj(field).style.backgroundColor = '#FFBE7D';
        } catch (e) {}; // F80
        //try{ getObj( field  ).style.borderColor='#F00'; }catch(e){};

        try {
            getObj(field + '_V').style.backgroundColor = '#FFBE7D';
        } catch (e) {}; //FFC
        //try{ getObj( field  + '_V' ).style.borderColor='#F00'; }catch(e){};


        try {
            getObj(field + '_edit').style.backgroundColor = '#FFBE7D';
        } catch (e) {};
        try {
            getObj(field + '_edit').style.backgroundColor = '#FFBE7D';
        } catch (e) {};
        //try{ getObj( field  + '_edit1' ).style.borderColor='#F00'; }catch(e){};


        if (getObj(field).type == 'checkbox') {
            try {
                getObj(field).offsetParent.style.backgroundColor = '#FFBE7D';
            } catch (e) {};
            //try{ getObj( field  ).offsetParent.style.borderColor='#F00'; }catch(e){};

        }
    } else {
        try {
            getObj(field)[0].offsetParent.style.backgroundColor = '#FFBE7D';
        } catch (e) {};
        try {
            getObj(field)[1].offsetParent.style.backgroundColor = '#FFBE7D';
        } catch (e) {};
        try {
            getObj(field)[2].offsetParent.style.backgroundColor = '#FFBE7D';
        } catch (e) {};

    }


}

function TxtOK(field) {
    if (field != 'DichiaraTipoImpresa') {

        try {
            getObj(field).style.backgroundColor = '#FFF';
        } catch (e) {};
        //try{ getObj( field  ).style.borderColor='lightgrey'; }catch(e){};

        try {
            getObj(field + '_V').style.backgroundColor = '#FFF';
        } catch (e) {};
        //try{ getObj( field  + '_V' ).style.borderColor='lightgrey'; }catch(e){};

        try {
            getObj(field + '_edit').style.backgroundColor = '#FFF';
        } catch (e) {};
        //try{ getObj( field  + '_edit1' ).style.borderColor='lightgrey'; }catch(e){};

        try {
            if (getObj(field).type == 'checkbox') {
                //try{ getObj( field  ).offsetParent.style.borderColor='#FFF'; }catch(e){};
                try {
                    getObj(field).offsetParent.style.backgroundColor = '#F4F4F4';
                } catch (e) {};
            }
        } catch (e) {
            alert(field);
        }

    } else {
        try {
            getObj(field)[0].offsetParent.style.backgroundColor = '#FFF';
        } catch (e) {};
        try {
            getObj(field)[1].offsetParent.style.backgroundColor = '#FFF';
        } catch (e) {};
        try {
            getObj(field)[2].offsetParent.style.backgroundColor = '#FFF';
        } catch (e) {};
    }
}

function IsNumeric2(sText) 
{
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

function roundTo(X, decimalpositions) 
{
    var i = X * Math.pow(10, decimalpositions);
    i = Math.round(i);
    return i / Math.pow(10, decimalpositions);
}

function OFFDettagliDel(x, y, z) 
{

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

function GeneraPDF_FID() {
    //chiamata ai controlli del documento
    var bret = false;
    var bret = ControlliOfferta('');
    if (!bret) {
        return;
    }
    
    //per poter procedere deve avere generato il pdf di tutte le bust
    //alert(getObjValue('STATE_PDF_BUSTE'));
    if (getObjValue('STATE_PDF_BUSTE') == 'all') 	
      LocalPrintPdf('/report/OFFERTA_CAUZIONE.asp?&TO_SIGN=YES&TABLE_SIGN=CTL_DOC_SIGN&IDENTITY_SIGN=idHeader&PDF_NAME=Fideiussione&AREA_SIGN=F2');
    else{
      LocDMessageBox('../', 'Per creare il PDF necessario aver generato il pdf di tutte le buste', 'Attenzione', 1, 400, 300);
      return;
    }
        
}

function HideProdotti() {

    if (getObjValue('RichiediProdotti') == '0') {

        document.getElementById('PRODOTTI').style.display = "none";
    }


}

//funzione per inserire nella sezione documentazione i tipi allegati consentiti scelti in creazione del BANDO
function FormatAllegato(TipoGriglia) {

    var numDocu = GetProperty(getObj(TipoGriglia + 'Grid'), 'numrow');
    var tipofile;
    var richiestaFirma;
    var onclick;
    var obj;

    for (i = 0; i <= numDocu; i++) {
        try 
		{
			tipofile='';
			tipofile = getObj('R' + TipoGriglia + 'Grid_' + i + '_TipoFile').value;

            try {
                richiestaFirma = getObj('R' + TipoGriglia + 'Grid_' + i + '_RichiediFirma').value;
            } catch (e) {
                richiestaFirma = '';
            }
			
			if ( tipofile != ''){
				
				tipofile = ReplaceExtended(tipofile, '###', ',');
				tipofile = 'EXT:' + tipofile.substring(1, tipofile.length);
				tipofile = tipofile.substring(0, tipofile.length - 1) + '-';
			}	

           //RECUPERO DINAMICAMENTE LA Format			
			obj = getObj('R'+ TipoGriglia +'Grid_' + i + '_Allegato_V_BTN').parentElement;
			onclick = obj.innerHTML;
			nPosStartFormat = onclick.indexOf('&amp;FORMAT=');
			strTailOnclick = onclick.substring(nPosStartFormat+12, nPosStartFormat+100);
			nPosEndParametri = strTailOnclick.indexOf('\' ');
			
			nPosEndFormat = strTailOnclick.indexOf('&amp;');
			if (nPosEndFormat == -1)
				nPosEndFormat = nPosEndParametri;
			
			strHeadFormat =  strTailOnclick.substring(0 , nPosEndFormat);
			strPatternFormat = 'FORMAT=' + strHeadFormat;
			if (richiestaFirma == '1') 
			{
				strHeadFormat = strHeadFormat + 'B'; //format per forzare la verifica di firma bloccante in caso di mancata firma o file corrotto
			}
			tipofile =  strHeadFormat + tipofile;			
			strExt = 'FORMAT=' + tipofile;
			onclick=onclick.replace(new RegExp(strPatternFormat, 'g'), strExt);
			
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

function Doc_DettagliDel(grid, r, c) {
    var v = '0';
    try {
        v = getObj('RDOCUMENTAZIONEGrid_' + r + '_Obbligatorio').value;
    } catch (e) {};

	AggiuntoSecondaFase = 'OK';
	try {
        AggiuntoSecondaFase = getObj('RDOCUMENTAZIONEGrid_' + r + '_Esito').value;
    } catch (e) {};
	
	
	
    if (v == '1' || AggiuntoSecondaFase == 'KO' ) {
        //DMessageBox( '../' , 'La documentazione è obbligatoria' , 'Attenzione' , 1 , 400 , 300 );
    } else {
        DettagliDel(grid, r, c);
    }
}

function DOCUMENTAZIONE_AFTER_COMMAND() {
    HideCestinodoc();
    try{FormatAllegato('DOCUMENTAZIONE');  } catch(e){}
	try{FormatAllegato('DOCUMENTAZIONE_TECNICA');  } catch(e){}
	FormatNumDec();
	
	attachFilePending();
	
	try
	{
		getObj('DOCUMENTAZIONEGrid').onchange = OnChangeEdit_DOC;
	}catch(e){};
	
	try
	{
		// Con il settaggio precedente l'evento di onchange si propaga solo sui field visuali che prevedono l'evento onchange.
		// Lasciando fuori quindi, ad esempio, i campi hidden. Vado ad aggiungere una funzione specifica per questi ultimi 
		// così da accorgerci di un cambiamento effettuato anche sui campi attach (che fanno scattare programmaticamente l'evento di onchange
		// sul campo tecnico nascosto )
		$('#DOCUMENTAZIONEGrid').find("input[type='hidden']").each(function( index ) 
		{
			$( this ).get()[0].onchange = OnChangeEdit_DOC;
		});

	}catch(e){alert(e.message);}


}


function HideCestinodoc() {
	
    try {
        var i = 0;
		var AggiuntoSecondaFase = 'OK';
		
        if (getObj('StatoDoc').value == 'Saved' || getObj('StatoDoc').value == '') 
		{
            for (i = 0; i < DOCUMENTAZIONEGrid_EndRow + 1; i++) 
			{
				
				try 
				{
					AggiuntoSecondaFase = getObj('RDOCUMENTAZIONEGrid_' + i + '_Esito').value ; 
				} catch (e) {}
    
				
                if ( getObj('RDOCUMENTAZIONEGrid_' + i + '_Obbligatorio').value == '1' || AggiuntoSecondaFase == 'KO' )  
				{
                    getObj('DOCUMENTAZIONEGrid_r' + i + '_c0').innerHTML = '&nbsp;';
                }
				
            }
        }
    } catch (e) {}

}


function RefreshContent() 
{
    RefreshDocument('');
}


function FIRMA_FIDEUSSIONE_OnLoad() 
{
    try 
	{
        if (getObjValue('RichiestaFirma') == 'no' || getObjValue('ClausolaFideiussoria') != '1') 
		{
            document.getElementById('DIV_FIRMA_FID').style.display = "none";
        }
		else 
		{
            FieldToSign('F2');
        }
        try{FormatAllegato('DOCUMENTAZIONE');  } catch(e){}
		try{FormatAllegato('DOCUMENTAZIONE_TECNICA');  } catch(e){}

    } 
	catch (e) 
	{
		
	}
}



function OnChangeEdit( obj )
{
	grigliaProdottiVariata = 'YES';

	try
	{
		SetTextValue( 'RTESTATA_PRODOTTI_MODEL_EsitoRiga' , CNV( '../../',  'L\'elenco Prodotti e\' stato modificato, e\' necessario eseguire il comando Verifica Informazioni'));
	}
	catch(e){}
	
	try
	{
		var targ = '';
		
		//Se l'evento di onchange non è scattato da un iterazione utente
		if ( obj == undefined )
			targ = this.id;
		else
			targ = obj.srcElement.id;

		//alert(targ);

		sganciaEsitoRiga(targ);

	}
	catch(e)
	{
	}
	
}


function OnChangeEdit_DOC( obj )
{
	

	
	
	try
	{
		SetTextValue( 'RTESTATA_DOCUMENTAZIONE_MODEL_EsitoRiga' ,  '<img src="../images/Domain/State_Warning.gif"><br>' + CNV( '../../',  'La Lista Allegati e\' stata modificata, e\' necessario eseguire il comando Verifica Informazioni'));
	}
	catch(e){}
	
	try
	{
		var targ = '';
		
		//Se l'evento di onchange non è scattato da un iterazione utente
		if ( obj == undefined )
			targ = this.id;
		else
			targ = obj.srcElement.id;

//		alert(targ);

		sganciaEsitoRiga_DOC(targ);

	}
	catch(e)
	{
	}
	
}

function DisplaySection(obj) 
{
	var bVisualMessageDataSuperata;
	
	bVisualMessageDataSuperata = 0;
	
	//SE OFFERTA IN QUESTO CASO APRO ANOMALIA AMMINISTRATIVA
	if( getObjValue( "StatoFunzionale" ) == 'InvioInCorso_amministrativa' )
	{
		//apro ildoc di anomalia se: la data di invio superata ed è consentito il fuori termine oppure se la data di invio non è superata	
		if ( ( getObjValue("CONSENTI_INVIO_FT") == '1' && getObjValue("DATA_INVIO_SUPERATA") == '1' ) || getObjValue("DATA_INVIO_SUPERATA") == '0' ){
		
			var IDDOC = getObjValue('IDDOC');
			param ='OFFERTA_ANOMALIE_AMMINISTRATIVA##OFFERTA#' + IDDOC + '#' ;		
			MakeDocFrom ( param ) ;   
			return;
		}else{
			bVisualMessageDataSuperata = 1;
		}	
	}
	
	
	//se staofunzionale in lavorazione e se la data di invio superata e non previsto fuori termine visualizzo messaggio termini scaduti
	if( getObjValue( "StatoFunzionale" ) == 'InLavorazione' && getObjValue("DATA_INVIO_SUPERATA") == '1' && getObjValue("CONSENTI_INVIO_FT") == '0'  ){
		
		bVisualMessageDataSuperata = 1; 
	}
	
	if ( bVisualMessageDataSuperata == 1) {
		
			AF_Alert('i termini di presentazione della Domanda di partecipazione sono superati');
		
	}
	
	
	try	{	HideShowAreeRTI(); } catch(e){}
	try	{	HideCestinodoc();  } catch(e){}
	try	{	FormatAllegato('DOCUMENTAZIONE');  } catch(e){}
	try	{	FormatAllegato('DOCUMENTAZIONE_TECNICA');  } catch(e){}
	
	try	{	Show_Hide_dgue_COL();} catch(e){}
	
	try	{	attachFilePending();} catch(e){}
	
	
	if (  getObjValue('PresenzaDGUE') != 'si')
	{
	  document.getElementById('DIV_DGUE').style.display = "none";	
	}
	if ( getObjValue('PresenzaDGUE') == 'si' )
	{	  
		document.getElementById('CompilaDGUE').disabled = false; 
		document.getElementById('CompilaDGUE').className ="CompilaDGUE";		
	}

  if (getObjValue('PresenzaQuestionario') !== 'si') {
    document.getElementById('DIV_QUESTIONARIO_AMMINISTRATIVO').style.display = "none";
  }

  if (getObjValue('PresenzaQuestionario') === 'si') {
    document.getElementById('CompilaQuestionarioAmministrativo').disabled = false;
    document.getElementById('CompilaQuestionarioAmministrativo').className = "compilaQuestionario";
  }

	try	{
		if ( getObjValue('Richiesta_terna_subappalto_sul_bando')  && getObjValue('Richiesta_terna_subappalto_sul_bando') != '1' )
		{
			getObj('div_SUBAPPALTOGRIDGrid').style.display = 'none';
			$("#cap_Richiesta_terna_subappalto").parents("table:first").css({"display": "none"});	
			$("#Richiesta_terna_subappalto").parents("table:first").css({"display": "none"});	
			
		}
	} catch(e){}
	
	//-- controlli su associazione RTI
	try
	{
		if ( getObj('PartecipaFormaRTI').value == '1' ) 
		{
			document.getElementById('Associazione_RTI').style.display = "";
			document.getElementById('cap_Associazione_RTI').style.display = "";
		}
		else
		{
			document.getElementById('Associazione_RTI').style.display = "none";
			document.getElementById('cap_Associazione_RTI').style.display = "none";
		}
		
	}
	catch(e)
	{
	}
	
	try
	{
		getObj('DOCUMENTAZIONEGrid').onchange = OnChangeEdit_DOC;
	}catch(e){};
	
	try
	{
		// Con il settaggio precedente l'evento di onchange si propaga solo sui field visuali che prevedono l'evento onchange.
		// Lasciando fuori quindi, ad esempio, i campi hidden. Vado ad aggiungere una funzione specifica per questi ultimi 
		// così da accorgerci di un cambiamento effettuato anche sui campi attach (che fanno scattare programmaticamente l'evento di onchange
		// sul campo tecnico nascosto )
		$('#DOCUMENTAZIONEGrid').find("input[type='hidden']").each(function( index ) 
		{
			$( this ).get()[0].onchange = OnChangeEdit_DOC;
		});

	}catch(e){alert(e.message);}
	
	icona_folder_documento();
}

function DownloadZipBuste() 
{


  //permetto apertura della tecnica per generare pdf solo se ho composto RTI in modo corretto
	var bret = false;
    var bret = CanSendRTI();

    if ( !bret ) {
		DocShowFolder( 'FLD_BUSTA_DOCUMENTAZIONE' );
		tdoc();
        return ;
    }
		

	
	//se ho fatto modifiche alla RTI e non ho salvato avviso
	if ( getObj('DenominazioneATI_DB').value  != getObj('DenominazioneATI').value )
	{
	/*		
		if ( confirm( CNV('../../', 'Sono stati modificati i dati della RTI.Per procedere si richiede prima un salvataggio.') ) ){
				SaveDoc('');
				return ;
		}else
			return ;
	*/
		ML_text = 'Sono stati modificati i dati della RTI.Per procedere si richiede prima un salvataggio.';
		Title = 'Informazione';					
		ICO = 1;
		page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
			
		ExecFunctionModaleConfirm( page, Title , 200 , 420 , null , 'SaveDoc' ,'');	
		return;
		
	}
	

  var IDDOC = getObjValue('IDDOC');
	
	var tmpVirtualDir;
	tmpVirtualDir = '/Application';

	if ( isSingleWin() )
		tmpVirtualDir = urlPortale;
	//controllo se numero lotti offerta non è superiore a quello ammesso
	var Num_max_lotti_offerti;
	var numero_lotti_off;
	
	Num_max_lotti_offerti=Number(getObj('Num_max_lotti_offerti').value);
	numero_lotti_off = Number(GetProperty(getObj('LISTA_BUSTEGrid'), 'numrow'))+1;
	
	if ( numero_lotti_off > Num_max_lotti_offerti && Num_max_lotti_offerti > 0 && grigliaProdottiVariata != 'YES' )
	{
		DMessageBox( '../' , 'Il numero dei lotti a cui si sta partecipando e superiore rispetto al numero massimo previsto nel bando' , 'Attenzione' , 1 , 400 , 300 );
		return;		
	}
	
	

}

//nasconde le griglie secondo i campi settati si/no per le RTI
function HideShowAreeRTI() {


    //alert('HideShowAreeRTI');

	try
	{
		//se settata RTI disabilito la possibilità di cancellare la prima riga
		if ( getObj('PartecipaFormaRTI').value == '1') 
		{
			//visualizzo help RTI
			try{$("#cap_label1").parents("table:first").css({"display": "block"});} catch (e) {}
			try{$("#cap_label1").parents("table:first").css({"width": "20px"});} catch (e) {}
			try 
			{
				getObj('RTIGRIDGrid_r0_c1').onclick = '';
				try 
				{
					getObjGrid('RRTIGRIDGrid_0_FNZ_DEL').style.display = 'none';
					TextreadOnly( 'RRTIGRIDGrid_0_codicefiscale', true);
				} catch (e) {}
			} catch (e) {}
			
			try{getObj('div_RTIGRIDGrid').style.display = '';}catch (e) {}	
			try{getObj('RTIGRID').style.display = '';}catch (e) {}	
		} 
		else 
		{

			//nascondo help RTI
			try{$("#cap_label1").parents("table:first").css({"display": "none"});} catch (e) {}
			
			//nascondo area relativa
			try{getObj('div_RTIGRIDGrid').style.display = 'none';}catch (e) {}	
			try{getObj('RTIGRID').style.display = 'none';}catch (e) {}	
			try 
			{
				getObj('OFFERTA_PARTECIPANTI_RTI_TOOLBAR_ADDNEW').style.display = 'none';
			} catch (e) {}
		}
	}catch(e){}

    //SE la configurazione di sistema prevede le subappaltatrici SYS_OFFERTA_PRESENZA_ESECUTRICI ( YES/NO) default NO
	try
	{
		if ( getObjValue('SYS_OFFERTA_PRESENZA_ESECUTRICI') == 'NO' )
		{
			try{getObj('ESECUTRICI').style.display = 'none';}catch (e) {}	
			try{getObj('ESECUTRICIGRID').style.display = 'none';}catch (e) {}	
			try{getObj('div_ESECUTRICIGRIDGrid').style.display = 'none';}catch (e) {}
			try{getObj('OFFERTA_PARTECIPANTI_ESECUTRICI_TOOLBAR_ADDFROM').style.display = 'none';}catch (e) {}
		}
		else
		{
			//se non settata CONSORZIO nascondo area relativa
			
			if (getObj('InserisciEsecutriciLavori') && getObj('InserisciEsecutriciLavori').value == '1') 
			{

				//visualizzo help
				try{$("#cap_label2").parents("table:first").css({"display": "block"});} catch (e) {}
				try{$("#cap_label2").parents("table:first").css({"width": "20px"});} catch (e) {}
				getObj('div_ESECUTRICIGRIDGrid').style.display = '';
				getObj('ESECUTRICIGRID').style.display = '';
				getObj('ESECUTRICI').style.display = '';				
				try {
					getObj('OFFERTA_PARTECIPANTI_ESECUTRICI_TOOLBAR_ADDFROM').style.display = '';
				} catch (e) {}

			} 
			else 
			{

				if (getObj('div_ESECUTRICIGRIDGrid') )
				{

					//nascondo help
					try{$("#cap_label2").parents("table:first").css({"display": "none"});} catch (e) {}
					//nascondo area relativa
					//try{getObj('ESECUTRICI').style.display = 'none';}catch (e) {}	
					try{getObj('ESECUTRICIGRID').style.display = 'none';}catch (e) {}	
					try{getObj('div_ESECUTRICIGRIDGrid').style.display = 'none';}catch (e) {}
					
					try 
					{
						getObj('OFFERTA_PARTECIPANTI_ESECUTRICI_TOOLBAR_ADDFROM').style.display = 'none';
					} catch (e) {}

				}

			}
		}
	} catch (e) {}


    //gestione AVVALIMENTO 
    if ( getObj('RicorriAvvalimento') && getObj('RicorriAvvalimento').value == '1') 
	{
        //visualizzo help
		try{$("#cap_label3").parents("table:first").css({"display": "block"});} catch (e) {}
		try{$("#cap_label3").parents("table:first").css({"width": "20px"});} catch (e) {}
		getObj('div_AUSILIARIEGRIDGrid').style.display = '';
		getObj('AUSILIARIEGRID').style.display = '';
        try {
            getObj('OFFERTA_PARTECIPANTI_AUSILIARIE_TOOLBAR_ADDFROM').style.display = '';
        } catch (e) {}

    } 
	else 
	{
		//nascondo help
		try{$("#cap_label3").parents("table:first").css({"display": "none"});} catch (e) {}
		//nascondo area relativa
        try{getObj('div_AUSILIARIEGRIDGrid').style.display = 'none';} catch (e) {}
		try{getObj('AUSILIARIEGRID').style.display = 'none';} catch (e) {}
        try 
		{
          getObj('OFFERTA_PARTECIPANTI_AUSILIARIE_TOOLBAR_ADDFROM').style.display = 'none';
        } catch (e) {}
    }
	
	//gestione SUBAPPALTO 
    if ( getObj('Richiesta_terna_subappalto') && getObj('Richiesta_terna_subappalto').value == '1') 
	{
        //visualizzo help
		try{$("#cap_label4").parents("table:first").css({"display": "block"});} catch (e) {}
		try{$("#cap_label4").parents("table:first").css({"width": "20px"});} catch (e) {}
		getObj('div_SUBAPPALTOGRIDGrid').style.display = '';
		getObj('SUBAPPALTOGRID').style.display = '';
        try {
            getObj('OFFERTA_PARTECIPANTI_SUBAPPALTO_TOOLBAR_ADDFROM').style.display = '';
        } catch (e) {}

    } 
	else 
	{
        //nascondo help
		try{$("#cap_label4").parents("table:first").css({"display": "none"});} catch (e) {}
		//nascondo area relativa
		try{getObj('div_SUBAPPALTOGRIDGrid').style.display = 'none';} catch (e) {}
		try{getObj('SUBAPPALTOGRID').style.display = 'none';} catch (e) {}
        
    }

    try 
	{

        //setto onchange sulla colonna codice fiscale
        SetOnChangeOnCodiceFiscale('RTIGRIDGrid');
        SetOnChangeOnCodiceFiscale('AUSILIARIEGRIDGrid');
        SetOnChangeOnCodiceFiscale('ESECUTRICIGRIDGrid');
		SetOnChangeOnCodiceFiscale('SUBAPPALTOGRIDGrid');

    } catch (e) {}
	
	if ( getObj('DOCUMENT_READONLY').value == "1" )	
	{
		try{$("#cap_label1").parents("table:first").css({"display": "none"});} catch (e) {}
		try{$("#cap_label2").parents("table:first").css({"display": "none"});} catch (e) {}
		try{$("#cap_label3").parents("table:first").css({"display": "none"});} catch (e) {}
		try{$("#cap_label4").parents("table:first").css({"display": "none"});} catch (e) {}
	}

}


//cancella tutte le righe di una griglia
function MyDelete_RTIGrid(grid, obj) 
{

    if (obj.value == '0') 
	{

		ML_text = 'Sei sicuro di cancellare ' + grid
		Title = 'Informazione';					
		ICO = 1;
		page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
			
		ExecFunctionModaleConfirm( page, Title , 200 , 420 , null , 'MyDelete_RTIGrid_OK@@@@' + grid ,'MyDelete_RTIGrid_CANCEL@@@@' + obj.id );	
	


		/*
	   if (confirm(CNV('../../', 'Sei sicuro di cancellare ' + grid)) == true) 
		{

            var sec = getObj(grid + '_SECTION_DETTAGLI_NAME').value;
			if( grid != 'SUBAPPALTOGRIDGrid' )
				ExecDocCommand(sec + '#DELETE_ALL#');
			
			else{
				Reset_SUBAPPALTOGRID();
			}	
            //ShowLoading( sec );

        } 
		else
            obj.value = '1';
		*/
    } 
	else 
	{

        //se sono sulla griglia RTI è vuota allora inserisco in automatico prima riga con azienda loggata
        if (grid == 'RTIGRIDGrid' && obj.value == '1') {

            //recupero azienda fornitore che ha fatto il documento
            var Azienda = getObj('Azienda').value ;

            var sec = getObj(grid + '_SECTION_DETTAGLI_NAME').value;

            var Param = 'IDROW=' + Azienda + '&TABLEFROMADD=Seleziona_Fornitore_RTI';
            
            ExecDocCommand(sec + '#ADDFROM#' + Param);

            //ShowLoading( sec );

        }
	
		pros_MyDelete_RTIGrid();
		
    }
}
function pros_MyDelete_RTIGrid()
{	
	//-- controlli su associazione RTI
	try
	{
		if ( getObj('PartecipaFormaRTI').value == '1' ) 
		{
			document.getElementById('Associazione_RTI').style.display = "";
			document.getElementById('cap_Associazione_RTI').style.display = "";
		}
		else
		{
			document.getElementById('Associazione_RTI').style.display = "none";
			document.getElementById('cap_Associazione_RTI').style.display = "none";
		}
		
	}
	catch(e)
	{
	}


    HideShowAreeRTI();


}

function MyDelete_RTIGrid_OK(grid) 
{
	
    var sec = getObj(grid + '_SECTION_DETTAGLI_NAME').value;
	if( grid != 'SUBAPPALTOGRIDGrid' )
		ExecDocCommand(sec + '#DELETE_ALL#');
	
	else{
		Reset_SUBAPPALTOGRID();
	}

	pros_MyDelete_RTIGrid();
	
}
function MyDelete_RTIGrid_CANCEL(param) 
{
	
	getObj(param).value = '1';
	pros_MyDelete_RTIGrid();
}


function Reset_SUBAPPALTOGRID(){
	
	try{ nNumRowSUB = Number(GetProperty(getObj('SUBAPPALTOGRIDGrid'), 'numrow')); }catch(e){}
	for (i = 0; i <= nNumRowSUB; i++) 
	{
		getObj( 'RSUBAPPALTOGRIDGrid_' + i + '_codicefiscale' ).value = '';
		getObj( 'RSUBAPPALTOGRIDGrid_' + i + '_RagSoc_V' ).innerHTML = '';
		getObj( 'RSUBAPPALTOGRIDGrid_' + i + '_RagSoc' ).value = '';
		getObj( 'RSUBAPPALTOGRIDGrid_' + i + '_INDIRIZZOLEG_V' ).innerHTML = '';
		getObj( 'RSUBAPPALTOGRIDGrid_' + i + '_INDIRIZZOLEG' ).value = '';
		getObj( 'RSUBAPPALTOGRIDGrid_' + i + '_LOCALITALEG_V' ).innerHTML = '';
		getObj( 'RSUBAPPALTOGRIDGrid_' + i + '_LOCALITALEG' ).value = '';
		getObj( 'RSUBAPPALTOGRIDGrid_' + i + '_PROVINCIALEG_V' ).innerHTML = '';
		getObj( 'RSUBAPPALTOGRIDGrid_' + i + '_PROVINCIALEG' ).value = '';
		getObj( 'RSUBAPPALTOGRIDGrid_' + i + '_IdAzi' ).value = '';
	}	
}


//viene eseguita dopo i comandio sulla griglia RTI
function RTIGRID_AFTER_COMMAND(command) {


    //alert(command);
    if (command == 'DELETE_ALL') {

        //se ho cancellato la griglia nascondo area relativa
        getObj('div_RTIGRIDGrid').style.display = 'none';
        getObj('OFFERTA_PARTECIPANTI_RTI_TOOLBAR_ADDNEW').style.display = 'none';

    } else {

        getObj('div_RTIGRIDGrid').style.display = '';
        getObj('OFFERTA_PARTECIPANTI_RTI_TOOLBAR_ADDNEW').style.display = '';

    }


    var NumRowRti = GetProperty(getObj('RTIGRIDGrid'), 'numrow');

    if (NumRowRti != -1) {
        //alert( GetProperty ( getObjGrid('val_RRTIGRIDGrid_0_Ruolo_Impresa'), 'value'));
        //se è la prima riga
        if (GetProperty(getObjGrid('val_RRTIGRIDGrid_0_Ruolo_Impresa'), 'value') == '') {

            //alert('setto la mandataria');
            //setto il ruolo a mandataria
            SetProperty(getObjGrid('val_RRTIGRIDGrid_0_Ruolo_Impresa'), 'value', 'Mandataria');
            getObjGrid('val_RRTIGRIDGrid_0_Ruolo_Impresa').innerHTML = 'Mandataria';
            getObjGrid('RRTIGRIDGrid_0_Ruolo_Impresa').value = 'Mandataria';
        }



        //nascondo il cestino prima riga
        getObjGrid('RRTIGRIDGrid_0_FNZ_DEL').style.display = 'none';
        //disabilito onclick sul cestino prima riga
        getObj('RTIGRIDGrid_r0_c1').onclick = '';
        //disabilito onchange su codice fiscale prima riga
        getObjGrid('RRTIGRIDGrid_0_codicefiscale').onchange = '';
		TextreadOnly( 'RRTIGRIDGrid_0_codicefiscale', true);


        for (nIndRrow = 1; nIndRrow <= NumRowRti; nIndRrow++) {

            SetProperty(getObjGrid('val_RRTIGRIDGrid_' + nIndRrow + '_Ruolo_Impresa'), 'value', 'Mandante');
            getObjGrid('val_RRTIGRIDGrid_' + nIndRrow + '_Ruolo_Impresa').innerHTML = 'Mandante';

        }
    }

    //setto onkeyup
    SetOnChangeOnCodiceFiscale('RTIGRIDGrid');

    //aggiorno il campo denominazioneATI
    UpgradeDenominazioneRTI();
	
	//funzione per gestire le colonne dgue
	Show_Hide_dgue_COL();
}



//SETTO EVENTO ON CHANGE SULLA COLONNA CODICE FISCALE DELLE GRIGLIE RTI
function SetOnChangeOnCodiceFiscale(strFullNameArea) {

    var nNumRow = GetProperty(getObj(strFullNameArea), 'numrow');
    var nIndRrow;
    for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

        if (nIndRrow == 0 && strFullNameArea == 'RTIGRIDGrid') {

            //disabilito onkeyup su codice fiscale
            getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').onkeyup = '';

        } else {
            getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').onkeyup = GetInfoAziendaFromCF;
            //getObjGrid( 'R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').onblur = MakeAlertAzienda ;
        }

    }

}




//ricostruisce il campo denominazione
function UpgradeDenominazioneRTI() {

    var strTempValue;
    //aggiorno campo nascosto con la denominazione
    var objDenominazioneATI = getObj('DenominazioneATI');
    objDenominazioneATI.value = '';

    var nIndRrow;
    var strFullNameArea;
    var nNumRow;

    //controllo se partecipacomeRTI è settato
    if (getObj('PartecipaFormaRTI').value == '1') 
	{

        strFullNameArea = 'RTIGRIDGrid';
		nNumRow = -1;
		
		try
		{
			nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
		}
		catch(e)
		{
		}
		
        if (nNumRow >= 0 && getObjGrid('R' + strFullNameArea + '_0_RagSoc').value != '') {

            objDenominazioneATI.value = 'RTI ';

            for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

                strTempValue = getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc').value;

                if (strTempValue != '') {
                    if (nIndRrow == 0)
                        objDenominazioneATI.value = objDenominazioneATI.value + strTempValue;
                    else
                        objDenominazioneATI.value = objDenominazioneATI.value + ' - ' + strTempValue;
                }

            }
        }
    }

	
	

    //controllo se InserisciEsecutriciLavori è settato
    if (getObj('InserisciEsecutriciLavori') && getObj('InserisciEsecutriciLavori').value == '1') 
	{

        strFullNameArea = 'ESECUTRICIGRIDGrid';

        nNumRow = 0

        try {
            nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
        } catch (e) {}

        if (nNumRow >= 0 && getObjGrid('R' + strFullNameArea + '_0_RagSoc').value != '') {

            objDenominazioneATI.value = objDenominazioneATI.value + ' Esecutrice ';

            for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

                strTempValue = getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc').value;

                if (strTempValue != '') 
				{
                    if (nIndRrow == 0)
                        objDenominazioneATI.value = objDenominazioneATI.value + strTempValue;
                    else
                        objDenominazioneATI.value = objDenominazioneATI.value + ' - ' + strTempValue;
                }

            }

            //se non è settata RTI aggiungo all'inizio la ragsoc del consorzio
            if (getObj('PartecipaFormaRTI').value != '1') {
                objDenominazioneATI.value = getObjGrid('R' + strFullNameArea + '_0_RagSocRiferimento').value + ' ' + objDenominazioneATI.value;
            }

        }
    }


    //se il campo DenominazioneATI è vuoto setto la ragione sociale del fornitore che ha fatto l'offerta
    
    if (objDenominazioneATI.value == '') {

        ajax = GetXMLHttpRequest();

        if (ajax) {

            ajax.open("GET", '../../ctl_library/functions/InfoAziFromCF.asp?IdAzi=' + getObj('Azienda').value, false);

            ajax.send(null);

            if (ajax.readyState == 4) {

                if (ajax.status == 200) {
                    if (ajax.responseText != '') {

                        //alert(ajax.responseText);
                        var strTempValue = ajax.responseText;
                        var ainfo = strTempValue.split('#');
                        objDenominazioneATI.value = ainfo[0];

                    }
                }
            }

        }


    }

    
    //aggiorno il campo visuale
	  getObj('DenominazioneATI_V').innerHTML = objDenominazioneATI.value;
	  
	  //se il campo tecnico di confronto è vuoto inizializzo anche quello con lo stesso valore
	  if ( getObj('DenominazioneATI_DB').value == '' )
	   getObj('DenominazioneATI_DB').value = objDenominazioneATI.value;
	  
    
}



//per eseguire aggiungi esecutrici e aggiungi ausiliarie
function My_Detail_AddFrom(param) {

    //recupero le aziende della griglia RTI
    var strIdaziRTI = GetAziRTI();
    //alert(strIdaziRTI);

    var strIdAziEsecutrici = GetEsecutriciConsorzio();
    //alert(strIdAziEsecutrici);
    if (strIdAziEsecutrici != '')
        strIdaziRTI = strIdaziRTI + ',' + strIdAziEsecutrici;

    var npos = strIdaziRTI.indexOf(',');

    if (npos == -1) {

        //aggiungo direttamente l'azienda loggata

        //recupero azienda fornitore che ha fatto il documento
        var Azienda = getObj('Azienda').value;
        var strDoc = getQSParamFromString(param, 'DOCUMENT');
        v = strDoc.split('.');

        //-- compone il comando per aggiungere la riga
        strCommand = v[0] + '#' + v[1] + '#' + 'IDROW=' + Azienda + '&TABLEFROMADD=' + v[2];
        ExecDocCommand(strCommand);

        //ShowLoading( sec );

    } else {

        vet = param.split('#');

        var w;
        var h;
        var Left;
        var Top;
        var altro;

        if (vet.length < 3) {
            w = screen.availWidth;
            h = screen.availHeight;
            Left = 0;
            Top = 0;
        } else {
            var d;
            d = vet[2].split(',');
            w = d[0];
            h = d[1];
            Left = (screen.availWidth - w) / 2;
            Top = (screen.availHeight - h) / 2;

            if (vet.length > 3) {
                altro = vet[3];
            }
        }

        var strUrl = vet[0];

        strUrl = strUrl + '&FilterHide= id in (' + strIdaziRTI + ')';

        return window.open(strUrl, vet[1], 'toolbar=no,location=no,directories=no,status=no,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes,left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro);
    }
}



//recupera la lista delle aziende della griglia RTI
function GetAziRTI() {

    var strTempList = '';
    var strTempValue = '';

    var nIndRrow;

    var nNumRow = GetProperty(getObj('RTIGRIDGrid'), 'numrow');

    //alert(nNumRow)
    if (nNumRow >= 0) {

        for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

            strTempValue = getObjGrid('RRTIGRIDGrid_' + nIndRrow + '_IdAzi').value;
            if (strTempValue != '') {
                if (strTempList == '')
                    strTempList = strTempValue;
                else
                    strTempList = strTempList + ',' + strTempValue;
            }
        }
    } else {

        //recupero idazi azienda loggata
        strTempList = getObj('Azienda').value;
    }

    return strTempList;

}



//recupera la lista delle aziende esecutrici nei CONSORZI
function GetEsecutriciConsorzio() {

    var strTempList = '';
    var strTempValue = '';

    var nIndRrow;

    var nNumRow = -1;
	
	try
	{
		nNumRow = GetProperty(getObj('ESECUTRICIGRIDGrid'), 'numrow');
	}
	catch(e)
	{
	}

    if (nNumRow >= 0) {

        for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {
            strTempValue = getObjGrid('RESECUTRICIGRIDGrid_' + nIndRrow + '_IdAzi').value;
            if (strTempValue != '') {
                if (strTempList == '')
                    strTempList = strTempValue;
                else
                    strTempList = strTempList + ',' + strTempValue;
            }
        }
    } else {

        //recupero idazi azienda loggata
        strTempList = getObj('Azienda').value;
    }

    return strTempList;


}




//a partire dal codice fiscale ritorna le info di azienda
function GetInfoAziendaFromCF() {

	var IDDOC = getObjValue('IDDOC');
    //RRTIGRIDGrid_0_codicefiscale
    var strNameCtl = this.name;

    var aInfo = strNameCtl.split('_');

	

    var nIndRrow = aInfo[1];

    var strCF = this.value;

    var Grid = aInfo[0].substr(1, aInfo[0].length);
	
	var bIsUnique_blocco=false;
	
	

    var ValoreListaAlbi = '';

    //tranne che per le aziende avvalimento considero ListaAlbi
    if (Grid != 'AUSILIARIEGRIDGrid' && Grid != 'SUBAPPALTOGRIDGrid') {
        try {
            ValoreListaAlbi = getObj('ListaAlbi').value;
        } catch (e) {}
    }

    //alert(strCF);
    if (strCF.length >= 7) {

        //if  ( bIsUnique ){

        //provo a ricercare le info azienda
        ajax = GetXMLHttpRequest();
	
        if (ajax) {
            ajax.open("GET", '../../ctl_library/functions/InfoAziFromCF.asp?ListaAlbi=' + encodeURIComponent(ValoreListaAlbi) + '&AZIPROFILO=S&CodiceFiscale=' + encodeURIComponent(strCF) + '&IDDOC=' + IDDOC + '&Grid=' + encodeURIComponent(Grid), false);

            ajax.send(null);

            if (ajax.readyState == 4) {
                //alert(ajax.status);
                if (ajax.status == 200) {
                    //alert(ajax.responseText);
                    if (ajax.responseText != '' && ajax.responseText.indexOf('#', 0) > 0) 
					{

                        //alert(ajax.responseText);    
                        this.style.color = 'black';
                        var strresult = ajax.responseText;
						
						//blocco se cf gia presente in griglia RTI
						if ( Grid == 'SUBAPPALTOGRIDGrid' )							
							bIsUnique_blocco = AziIsUnique_blocco(Grid, nIndRrow, strCF);
						
						if ( bIsUnique_blocco != true )
						{
							SetInfoAziendaRow(Grid, nIndRrow, strresult);

							//faccio alert se azienda presente in altra griglia
							var bIsUnique = AziIsUnique(Grid, nIndRrow, strCF);
						}
						

                    } 
					else 
					{

						if (ajax.responseText != '')
							LocDMessageBox('../', ajax.responseText, 'Attenzione', 1, 400, 300);

						//setto i caratteri in rosso
						this.style.color = 'red';

						//svuoto i campi
						SetInfoAziendaRow(Grid, nIndRrow, '#######');


                    }
                }
            }

        }
        //}else{

        //svuoto il campo del CF che non è univoco
        //  this.value='';
        //  SetInfoAziendaRow( Grid , nIndRrow ,'#####' );
        //}
    } else {
        //setto i caratteri in rosso
        this.style.color = 'red';

        //svuoto i campi
        SetInfoAziendaRow(Grid, nIndRrow, '#######');
    }

    //aggiorno campo denominazione
    UpgradeDenominazioneRTI();
}




//controlla che questo codice fiscale non sia già presente
function AziIsUnique(strNameAreaCurrent, nRowCurrent, strCF ) {

    var bIsUnique = true;

    //griglia RTI
    var nIndRrow;
    var strFullNameArea = 'RTIGRIDGrid';

    var nNumRow = -1;
	
	try
	{
		nNumRow=Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch(e)
	{
	}
	
    for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

        if( strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent)) ) 
		{

            if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value.toUpperCase() == strCF.toUpperCase()) 
			{
                //alert( CNV ('../../' , 'azienda gia inserita nella griglia RTI') );
                LocDMessageBox('../', 'azienda gia inserita nella griglia RTI', 'Attenzione', 1, 400, 300);				
                bIsUnique = false;
                return bIsUnique;
				
            }
        }
    }



    //griglia Consorzio
    strFullNameArea = 'ESECUTRICIGRIDGrid';
    nNumRow = -1;
	
	try
	{
		nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch(e)
	{
	}
	
    for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

        if (strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent))) 
		{

            if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value.toUpperCase() == strCF.toUpperCase()) {
                //alert( CNV ('../../' , 'azienda gia inserita nella griglia Consorzio') );
                LocDMessageBox('../', 'azienda gia inserita nella griglia Consorzio', 'Attenzione', 1, 400, 300);
                bIsUnique = false;
                return bIsUnique;
            }
        }
    }


    //griglia Avvalimento
    strFullNameArea = 'AUSILIARIEGRIDGrid';
    nNumRow = -1;
	
	try
	{
		nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch(e)
	{
	}
	
    for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

        if (strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent))) 
		{

            if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value.toUpperCase() == strCF.toUpperCase()) {
                //alert( CNV ('../../' , 'azienda gia inserita nella griglia Avvalimento') );
                LocDMessageBox('../', 'azienda gia inserita nella griglia Avvalimento', 'Attenzione', 1, 400, 300);
                bIsUnique = false;
                return bIsUnique;
            }
        }
    }
	
	//griglia SUBAPPALTO codice fiscale univoco per appaltatore
    strFullNameArea = 'SUBAPPALTOGRIDGrid';
    nNumRow = -1;
	
	try
	{
		nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch(e)
	{
	}
	//alert (IdAziRiferimento);
    for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) 
	{
        if (strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent)))
		{

            if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value.toUpperCase() == strCF.toUpperCase()) 
			{
                //alert( CNV ('../../' , 'azienda gia inserita nella griglia Avvalimento') );
                LocDMessageBox('../', 'Azienda gia inserita nella griglia Subappalto', 'Attenzione', 1, 400, 300);
                bIsUnique = false;
                return bIsUnique;
            }
        }
    }



    return bIsUnique;

}



//controlla che questo codice fiscale non sia già presente
function AziIsUnique_blocco(strNameAreaCurrent, nRowCurrent, strCF ) {

    var bIsUnique_blocco = false;

    //griglia RTI
    var nIndRrow;
    var strFullNameArea = 'RTIGRIDGrid';

    var nNumRow = -1;
	
	try
	{
		nNumRow=Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch(e)
	{
	}
	
    for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) 
	{

        if( strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent)) ) 
		{

            if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value.toUpperCase() == strCF.toUpperCase()) 
			{
                //alert( CNV ('../../' , 'azienda gia inserita nella griglia RTI') );
                LocDMessageBox('../', 'Azienda gia inserita nella griglia RTI, non puo essere inserita in Subappalto', 'Attenzione', 1, 400, 300);
				
                bIsUnique_blocco = true;
				break;
                return bIsUnique_blocco;
            }
        }
    }
	
	 //griglia Consorzio
    strFullNameArea = 'ESECUTRICIGRIDGrid';
    nNumRow = -1;
	
	try
	{
		nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch(e)
	{
	}
	
    for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

        if (strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent))) 
		{

            if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value.toUpperCase() == strCF.toUpperCase()) {
                //alert( CNV ('../../' , 'azienda gia inserita nella griglia Consorzio') );
                LocDMessageBox('../', 'azienda gia inserita nella griglia Consorzio', 'Attenzione', 1, 400, 300);
                bIsUnique_blocco = true;
				break;
                return bIsUnique_blocco;
            }
        }
    }


    //griglia Avvalimento
    strFullNameArea = 'AUSILIARIEGRIDGrid';
    nNumRow = -1;
	
	try
	{
		nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch(e)
	{
	}
	
    for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

        if (strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent))) 
		{

            if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value.toUpperCase() == strCF.toUpperCase()) {
                //alert( CNV ('../../' , 'azienda gia inserita nella griglia Avvalimento') );
                LocDMessageBox('../', 'azienda gia inserita nella griglia Avvalimento', 'Attenzione', 1, 400, 300);
				bIsUnique_blocco = true;
				break;
				return bIsUnique_blocco;
            }
        }
    }
	
	
	
	
	
    return bIsUnique_blocco;

}




//setta le info di una azienda su una riga di una griglia
function SetInfoAziendaRow(strFullNameArea, nIndRrow, strresult) {


    var nPos;
    var ainfoAzi = strresult.split('#');

    var strRagSoc = ainfoAzi[0];

    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc').value = strRagSoc;
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc_V').innerHTML = strRagSoc;


    /*
    if (strFullNameArea == 'DOCUMENTAZIONE_ATIgriglia' && nIndRrow==0){
      var strCodicefiscale = ainfoAzi[4];
      getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value=strCodicefiscale;
    }*/

    var strIndLeg = ainfoAzi[1];
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_INDIRIZZOLEG').value = strIndLeg;
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_INDIRIZZOLEG_V').innerHTML = strIndLeg;

    var strLocLeg = ainfoAzi[2];
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_LOCALITALEG').value = strLocLeg;
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_LOCALITALEG_V').innerHTML = strLocLeg;


    var strProvLeg = ainfoAzi[3];
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_PROVINCIALEG').value = strProvLeg;
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_PROVINCIALEG_V').innerHTML = strProvLeg;



    var strIdazi = ainfoAzi[5];
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_IdAzi').value = strIdazi;


    var strRuolo = 'Mandataria';
    var strTechRuolo = 'Mandataria';
    if (nIndRrow != 0) {
        strRuolo = 'Mandante';
        strTechRuolo = 'Mandante';
    }
	 try 
	{
        //SetProperty(getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa'),'value',strTechRuolo);

        getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa').innerHTML = strRuolo;
        getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa').value = strTechRuolo;

    } catch (e) {}
	
	var IdDocRicDGUE = ainfoAzi[6];
	try
	{
		try{getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_IdDocRicDGUE').value = IdDocRicDGUE;} catch (e) {} 
		//getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_IdDocRicDGUE').value = IdDocRicDGUE;		
	} catch (e) {} 
	
	
	var StatoRichiesta= ainfoAzi[7];
	try
	{
		
		if ( StatoRichiesta == 'Ricevuto')
		{			
			try{SetDomValue( 'R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE', 'InviataRichiesta' , 'InviataRichiesta');}catch(e){}	
			
			ExecDocProcess( 'RECUPERO_DOCUMENTI_RICHIESTI,DOCUMENTO,,NO_MSG');
		}
		else
		{			
			try{SetDomValue( 'R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE', StatoRichiesta , StatoRichiesta);}catch(e){}	
			
		}
	} catch (e) {} 

    if (strresult == '#######') 
	{
        strRuolo = '';
        strTechRuolo = '';
		
		 
		 try{getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE').innerHTML = '';} catch (e) {}
		 try{getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE').value = '';} catch (e) {}
		 try{getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE').innerHTML ='<input type=\"hidden\" name=\"R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE\" id=\"R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE\"  >';} catch (e) {}
		 
		 
		 
		 try{getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_AllegatoDGUE').value = '';} catch (e) {}
		 try{getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_AllegatoDGUE_V').innerHTML = '';} catch (e) {}
		 try{getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_AllegatoDGUE_V_N').value = '';} catch (e) {}
		 
		 try{SetTextValue('R' + strFullNameArea + '_' + nIndRrow + '_FNZ_OPEN','');} catch (e) {}
		 try{getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_FNZ_OPEN').innerHTML = '';} catch (e) {}
		 
		// try{SetTextValue('R' + strFullNameArea + '_' + nIndRrow + '_IdDocRicDGUE','');} catch (e) {} 
		 
		 
    }

    //getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa').value=strRuolo;
    //getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa').innerHTML=strTechRuolo;   

   

	
}


//viene eseguita dopo i comandio sulla griglia RTI
function ESECUTRICIGRID_AFTER_COMMAND(command) {



    if (command == 'DELETE_ALL') {

        //se ho cancellato la griglia nascondo area relativa
        getObj('div_ESECUTRICIGRIDGrid').style.display = 'none';
        getObj('OFFERTA_PARTECIPANTI_ESECUTRICI_TOOLBAR_ADDFROM').style.display = 'none';

    } else {

        getObj('div_ESECUTRICIGRIDGrid').style.display = '';
        getObj('OFFERTA_PARTECIPANTI_ESECUTRICI_TOOLBAR_ADDFROM').style.display = '';

    }

    //setto onkeyup
    SetOnChangeOnCodiceFiscale('ESECUTRICIGRIDGrid');

    //aggiorno il campo denominazioneATI
    UpgradeDenominazioneRTI();
	
	//funzione per gestire le colonne dgue
	Show_Hide_dgue_COL();
	
}


//viene eseguita dopo i comandio sulla griglia RTI
function AUSILIARIEGRID_AFTER_COMMAND(command) {



    if (command == 'DELETE_ALL') {

        //se ho cancellato la griglia nascondo area relativa
        getObj('div_AUSILIARIEGRIDGrid').style.display = 'none';
        getObj('OFFERTA_PARTECIPANTI_AUSILIARIE_TOOLBAR_ADDFROM').style.display = 'none';

    } else {

        getObj('div_AUSILIARIEGRIDGrid').style.display = '';
        getObj('OFFERTA_PARTECIPANTI_AUSILIARIE_TOOLBAR_ADDFROM').style.display = '';

    }

    //setto onkeyup
    SetOnChangeOnCodiceFiscale('AUSILIARIEGRIDGrid');

    //aggiorno il campo denominazioneATI
    UpgradeDenominazioneRTI();
	
	//funzione per gestire le colonne dgue
	Show_Hide_dgue_COL();
	
}

//viene eseguita dopo i comandio sulla griglia RTI
function SUBAPPALTOGRID_AFTER_COMMAND(command) {


    //setto onkeyup
    SetOnChangeOnCodiceFiscale('SUBAPPALTOGRIDGrid');

    //aggiorno il campo denominazioneATI
    UpgradeDenominazioneRTI();
	
	//funzione per gestire le colonne dgue
	Show_Hide_dgue_COL();
	
}



//alert se azienda non trovata su onblur dal campo codicefiscale
function MakeAlertAzienda() {

    var strNameCtl = this.name;

    var aInfo = strNameCtl.split('_');

    var nIndRrow = aInfo[1];

    var strCF = this.value;

    var strFullNameArea = aInfo[0].substr(1, aInfo[0].length);

    //alert(getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc').value);

    if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc').value == '')
    //alert(CNV ('../../' , 'codice fiscale azienda non esistente') );
        LocDMessageBox('../', 'codice fiscale azienda non esistente', 'Attenzione', 1, 400, 300);
}




//CONTROLLA CHE IN CASO DI RTI LA COMPILAZIONE E' OK
function CanSendRTI() {

	
    var bret = false;
	
	//se non ho il campo PartecipaFormaRTI le aree della RTI sono bloccate ed esco
	if ( ! getObj('PartecipaFormaRTI') )
		return true;	
	
	
	
	
	
    //controllo se partecipacomeRTI è settato che la griglia RTi è compilata correttamente
    bret = CanSendGridRTI('RTIGRIDGrid', 'PartecipaFormaRTI', 'mandante');
    if (!bret) {
        return false;
    }

    //controllo che per la RTI le righe devo essere almeno 2
    strFullNameArea = 'RTIGRIDGrid';
	
    nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	
    if (nNumRow == 0) {
        //alert( CNV ('../../' , 'inserire almeno una mandante') );
        LocDMessageBox('../', 'inserire almeno una mandante', 'Attenzione', 1, 400, 300);
        return false;
    }

    //se ho settato Consorzio a si controllo che la griglia consorzio è compilata correttamente
    bret = false;
    bret = CanSendGridRTI('ESECUTRICIGRIDGrid', 'InserisciEsecutriciLavori', 'esecutrice')
    if (!bret) {
        return false;
    }

    //controllo che i consorzi della griglia Consorzio sono tutti nella griglia RTI
    bret = false;
    bret = RiferimentiGridIsInRTI('ESECUTRICIGRIDGrid', 'RagSocRiferimento', 'IdAziRiferimento');
    if (!bret) {
        return false;
    }

    //se ho settatto RicorriAvvalimento controllo che la griglia avvalimento è compilata correttamente
    bret = false;
    bret = CanSendGridRTI('AUSILIARIEGRIDGrid', 'RicorriAvvalimento', 'ausiliaria')
    if (!bret) {
        return false;
    }

    //controllo che le ausiliate  della griglia Avvalimenti sono tutti nella griglia RTI
    bret = false;
    bret = RiferimentiGridIsInRTI('AUSILIARIEGRIDGrid', 'RagSocRiferimento', 'IdAziRiferimento');
    if (!bret) {
        return false;
    }

	
	//aggiorno coerentemente il campo denominazione ati
    UpgradeDenominazioneRTI();
	
    return true;

}



//controlla che una griglia è compilata correttamente
function CanSendGridRTI(strFullNameArea, strAttrib, strCnv) {


    var iddztAttrib;
    var objAttrib;

    if (getObj(strAttrib) && getObj(strAttrib).value == '1') {

        nNumRow = 0;
		
		try
		{
			nNumRow=Number(GetProperty(getObj(strFullNameArea), 'numrow'));
		}
		catch(e)
		{
		}
		
        if (nNumRow == -1) {

            alert(CNV('../../', 'inserire almeno una ' + strCnv));
            return false;

        } else {

            for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

                if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc').value == '') {

                    //alert( CNV ('../../' , 'inserire codice fiscale della ' + strCnv ) );
                    LocDMessageBox('../', 'inserire codice fiscale della ' + strCnv, 'Attenzione', 1, 400, 300);

                    return false;

                }
            }
        }
    }

    return true;

}



//CONTROLLA CHE LE AZIENDE DI RIFERIMENTO DELLA GRIGLIA IN INPUT SIANO PRESENTI NELLA GRIGLIA RTI
//OPPURE DEVE ESSERE SOLO L'AZIENDA LOGGATA
function RiferimentiGridIsInRTI(strFullNameArea, strAttribRagSoc, strAttribIdAzi) {

    var strListAziendeRTI = GetAziRTI();

    var strIdAziEsecutrici = GetEsecutriciConsorzio();

    if (strIdAziEsecutrici != '')
        strListAziendeRTI = strListAziendeRTI + ',' + strIdAziEsecutrici;

    strListAziendeRTI = ',' + strListAziendeRTI + ','


    //determino se esiste un raggruppamento RTI
    var bRTI = true;
    var strFullNameAreaRTI = 'RTIGRIDGrid';
    var nNumRowRTI = Number(GetProperty(getObj(strFullNameAreaRTI), 'numrow'));

    if (nNumRowRTI == -1)
        bRTI = false;


    var nNumRow = -1;
	
	try
	{
		nNumRow=Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch(e)
	{
	}
	
    var strCurrIdAzi = '';

    if (nNumRow >= 0) {

        var nIndRrow;

        for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

            strCurrIdAzi = ',' + getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_' + strAttribIdAzi).value + ',';
            strCurrRagSoc = getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_' + strAttribRagSoc).value;

            if (strListAziendeRTI.indexOf(strCurrIdAzi, 0) < 0) {
                if (bRTI)
                    alert(CNV('../../', 'attenzione azienda area ' + strFullNameArea) + ' "' + strCurrRagSoc + '" ' + CNV('../../', 'non presente in rti'));
                //DMessageBox( '../' , 'attenzione azienda area ' + strFullNameArea  , 'Attenzione' , 1 , 400 , 300 ) 
                else
                    alert(CNV('../../', 'attenzione azienda area ' + strFullNameArea) + ' "' + strCurrRagSoc + '" ' + CNV('../../', 'non azienda loggata'));

                return false;

            }


        }
    }

    return true;

}

function ControlliOfferta(param) 
{

    //CONTROLLO IN CASO DI RTI
    var bret = false;
    var bret = CanSendRTI();

    if (!bret) {
        return false;
    }

    return true;


}



//cancella gli allegati per la coppia IdAzi_Ausiliata-IdAzi_Ausiliaria
function DeleteAllegati_Avvalimenti( IdAzi_Ausiliata, IdAzi_Ausiliaria )
{
  
  if ( IdAzi_Ausiliata != '' && IdAzi_Ausiliaria != ''){
  
    var Num_Allegati_Avvalimenti = GetProperty(getObj('ALLEGATI_AVVALIMENTIGrid'), 'numrow');
    
    var strListRowDelete ='';
     
    for (nIndRrow = 0; nIndRrow <= Num_Allegati_Avvalimenti; nIndRrow++) {
        
      if ( getObjGrid('RALLEGATI_AVVALIMENTIGrid_' + nIndRrow + '_IdAziAusiliata').value == IdAzi_Ausiliata && getObjGrid('RALLEGATI_AVVALIMENTIGrid_' + nIndRrow + '_IdAzi').value == IdAzi_Ausiliaria )
      {
        
        if ( strListRowDelete == '')
          strListRowDelete = nIndRrow.toString() ;
        else
          strListRowDelete = strListRowDelete + ',' + nIndRrow.toString() ;
          
      }
        
    }
  
    if (strListRowDelete != '' )
      ExecDocCommand( 'ALLEGATI_AVVALIMENTI#DELETE_ROW#' + 'IDROW=' + strListRowDelete );
  
  
  }

    
}



//aggiunge un allegato di iniziativa per gli avvalimenti
function AggiungiAllegatoAvvalimenti( param )
{

  //controllo le coppie nella griglia ausiliarie
  var Num_Row = GetProperty(getObj('AUSILIARIEGRIDGrid'), 'numrow');
  
  //se non ci sono coppie esco
  if ( Num_Row < 0 )
     return;
  
  var strCurrIdAziAusiliata;
  var strCurrIdAzi;
  var strCurrCoppia;
  var strCoppiaAusilia='';
  var KeyRiga;
  var nNumCoppie=0;
  var Progressivo;
  var aInfoKeyRiga;
  
  Progressivo = 0;
   
  for (nIndRrow = 0; nIndRrow <= Num_Row; nIndRrow++) 
  {
      
      strCurrIdAziAusiliata = getObj('RAUSILIARIEGRIDGrid_' + nIndRrow + '_IdAziRiferimento' ).value ;
      strCurrIdAzi = getObj('RAUSILIARIEGRIDGrid_' + nIndRrow + '_IdAzi' ).value ;
      
      if ( strCurrIdAziAusiliata != '' && strCurrIdAzi != '')
      {
        strCurrCoppia = strCurrIdAziAusiliata + '_' +  strCurrIdAzi;
        
        if ( strCoppiaAusilia.indexOf( ',' + strCurrCoppia + ',', 0) == -1 ){
          
          nNumCoppie = nNumCoppie + 1 ;
          strCoppiaAusilia = strCoppiaAusilia + strCurrCoppia + ',';
              
        }
      } 
  }
  
  
  
  
  if ( nNumCoppie == 1 ){
    
    strCoppiaAusilia = strCoppiaAusilia.substr(0,strCoppiaAusilia.length-1);
    
    var AinfoCoppia = strCoppiaAusilia.split('_');
    var IdAzi_Ausiliata = AinfoCoppia[0];
    var IdAzi_Ausiliaria = AinfoCoppia[1];
    
    //recupero il prossimo progressivo libero per la coppia
    var Num_Allegati_Avvalimenti = GetProperty(getObj('ALLEGATI_AVVALIMENTIGrid'), 'numrow');
    for (nIndRrow = 0; nIndRrow <= Num_Allegati_Avvalimenti; nIndRrow++) {
      
      if ( getObjGrid('RALLEGATI_AVVALIMENTIGrid_' + nIndRrow + '_IdAziAusiliata').value == IdAzi_Ausiliata && getObjGrid('RALLEGATI_AVVALIMENTIGrid_' + nIndRrow + '_IdAzi').value == IdAzi_Ausiliaria ){
        
        KeyRiga = getObj('RALLEGATI_AVVALIMENTIGrid_' + nIndRrow + '_KeyRiga' ).value ;
        
        aInfoKeyRiga = KeyRiga.split('_');
        if ( aInfoKeyRiga.length == 3){
         tempProgressivo = parseInt(aInfoKeyRiga[2]);
          if ( tempProgressivo > Progressivo )
            Progressivo = tempProgressivo ;
        }
        
      }
        
    }
     
    
    Progressivo = Progressivo + 2 ;
    //aggiungo un allegato di inizativa per la coppia
    idFrom = strCoppiaAusilia + '_' + Progressivo ;
        
    var sec = 'ALLEGATI_AVVALIMENTI' ; 
       
    var Param = 'IDROW=' + idFrom + '&TABLEFROMADD=SP_Aggiungi_Allegati_Avvalimento&MULTI_RECORD=YES';

    ExecDocCommand(sec + '#ADDFROM#' + Param);

    return;  
    
    
  }else{
  
    //apertura mascherina per selezione coppia
      
    var const_width=620;
    var const_height=400;
    		
    var sinistra=(screen.width-const_width)/2;
    var alto=(screen.height-const_height)/2;
    var Path='../../ctl_library/';
    
    /*
    <link rel=stylesheet href="../Themes/scrollpage.css" type="text/css">
    <link rel=stylesheet href="../Themes/body.css" type="text/css">
    <link rel=stylesheet href="../Themes/msgbox.css" type="text/css">
    <link rel=stylesheet href="../Themes/folder.css" type="text/css">
    */
    
    var strBodyWindow = '<html><head><link rel="stylesheet" href="' + Path + 'Themes/griddocument.css" type="text/css">' ;
    strBodyWindow =  strBodyWindow + '<link rel="stylesheet" href="' + Path + 'Themes/toolbarDocument.css" type="text/css">' ;
    strBodyWindow =  strBodyWindow + '<link rel="stylesheet" href="' + Path + 'Themes/field.css" type="text/css">' ;
    strBodyWindow =  strBodyWindow + '<link rel="stylesheet" href="' + Path + 'Themes/model.css" type="text/css">' ;
    strBodyWindow =  strBodyWindow + '<link rel="stylesheet" href="' + Path + 'Themes/caption.css" type="text/css">' ;
    strBodyWindow =  strBodyWindow + '<title>Seleziona Coppia Ausiliaria ausiliata</title></head><body>' ;
    strBodyWindow =  strBodyWindow + '<table border=0 width="100%"><tr><td>';
    strBodyWindow =  strBodyWindow + '<table height="30px" width="100%" ><tr><td width="100%" height="30px"><table width="100%" class="Caption"  border="0" cellspacing="0" cellpadding="0">' ;
    strBodyWindow =  strBodyWindow + '<tr><td>Seleziona Coppia Ausiliaria ausiliata</td><TD onclick="Javascript: parent.close();" class=Caption_Exit>chiudi</TD></tr></table></td></tr></table>' ;
    strBodyWindow =  strBodyWindow + '</td></tr><tr><td>';
    
    //nascondo colonne superflue
    
    ShowCol( 'AUSILIARIEGRID' , 'FNZ_ADD' , '' );
    ShowCol( 'AUSILIARIEGRID' , 'FNZ_DEL' , 'none' );
    ShowCol( 'AUSILIARIEGRID' , 'codicefiscale' , 'none' );
    ShowCol( 'AUSILIARIEGRID' , 'INDIRIZZOLEG' , 'none' );
    ShowCol( 'AUSILIARIEGRID' , 'LOCALITALEG' , 'none' );
    ShowCol( 'AUSILIARIEGRID' , 'PROVINCIALEG' , 'none' );
    
    
    var strGridAusiliarie = getObj('div_AUSILIARIEGRIDGrid').innerHTML ;
    strBodyWindow =  strBodyWindow + strGridAusiliarie ;
    strBodyWindow =  strBodyWindow + '</td></tr><table></body></html>';
    wincoppia=window.open('','selezionacoppia','toolbar=no,location=no,directories=no,status=no,menubar=no,resizable=yes,copyhistory=no,scrollbars=no,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
    wincoppia.document.write( strBodyWindow ); 
    
    //rivisualizzo colonne
    ShowCol( 'AUSILIARIEGRID' , 'FNZ_ADD' , 'none' );
    ShowCol( 'AUSILIARIEGRID' , 'FNZ_DEL' , '' );
    ShowCol( 'AUSILIARIEGRID' , 'codicefiscale' , '' );
    ShowCol( 'AUSILIARIEGRID' , 'INDIRIZZOLEG' , '' );
    ShowCol( 'AUSILIARIEGRID' , 'LOCALITALEG' , '' );
    ShowCol( 'AUSILIARIEGRID' , 'PROVINCIALEG' , '' );
    
    return;
      
  }
  

}




function AddAllegatoAvvalimenti(grid , r , c ){

  
  //recupero coppia riga r
  var IdAzi_Ausiliata = getObj('RAUSILIARIEGRIDGrid_' + r + '_IdAziRiferimento' ).value ;
  var IdAzi_Ausiliaria = getObj('RAUSILIARIEGRIDGrid_' + r + '_IdAzi' ).value ;
  var KeyRiga;
  var tempProgressivo;
  var Progressivo = 0;
  
  
  var Num_Allegati_Avvalimenti = GetProperty(getObj('ALLEGATI_AVVALIMENTIGrid'), 'numrow');
  
  for (nIndRrow = 0; nIndRrow <= Num_Allegati_Avvalimenti; nIndRrow++) {
    
    if ( getObjGrid('RALLEGATI_AVVALIMENTIGrid_' + nIndRrow + '_IdAziAusiliata').value == IdAzi_Ausiliata && getObjGrid('RALLEGATI_AVVALIMENTIGrid_' + nIndRrow + '_IdAzi').value == IdAzi_Ausiliaria ){
      
      KeyRiga = getObj('RALLEGATI_AVVALIMENTIGrid_' + nIndRrow + '_KeyRiga' ).value ;
      
      aInfoKeyRiga = KeyRiga.split('_');
      if ( aInfoKeyRiga.length == 3){
       tempProgressivo = parseInt(aInfoKeyRiga[2]);
        if ( tempProgressivo > Progressivo )
          Progressivo = tempProgressivo ;
      }
      
    }
      
  }
   
  wincoppia.close();
  
  Progressivo = Progressivo + 2 ;
  
  //alert(Progressivo);
  
  //aggiungo un allegato di inizativa per la coppia
  var idFrom = IdAzi_Ausiliata + '_' + IdAzi_Ausiliaria + '_' + Progressivo ;
      
  var sec = 'ALLEGATI_AVVALIMENTI' ; 
     
  var Param = 'IDROW=' + idFrom + '&TABLEFROMADD=SP_Aggiungi_Allegati_Avvalimento&MULTI_RECORD=YES';

  ExecDocCommand(sec + '#ADDFROM#' + Param);

  return;  
        

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
  
  var onclick2;
  	
	//per ogni colonna di tipo allegato se prevista setto le estensioni ammesse
	var strEstensioni_Prodotti_Gara = getObj('Estensioni_Prodotti_Gara').value;
	var aInfoAttach = strEstensioni_Prodotti_Gara.split('@@@');
	var nNumAttach = aInfoAttach.length;
	
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

function sganciaEsitoRiga_DOC(idCampo)
{
	var i = idCampo.split('_');
	var row = i[0];

	row = row.replace('R','') + '_' + i[1];
	
	var msg = '<img src="../images/Domain/State_Warning.gif"><br>La Riga e\' stata modificata.<br/>E\' necessario eseguire il comando "Verifica Informazioni"';
	
	getObj('R' + row + '_EsitoRiga_V').innerHTML = msg;
	getObj('R' + row + '_EsitoRiga').value = msg;

}

function sganciaEsitoRiga(idCampo)
{
	var i = idCampo.split('_');
	var row = i[0];

	row = row.replace('R','');

	//Lavoro sulle righe per andare a svuotare l'esito della voce 0 del lotto
	try
	{
		var numeroLotto = '-1';
		var voce = '0';

		if ( getObj('R' + row + '_NumeroLotto') )
			numeroLotto = getObjValue('R' + row + '_NumeroLotto');

		//Svuoto l'esito riga
		svuotaEsito(row,numeroLotto);
		
		//Se esiste il campo voce
		if ( getObj('R' + row + '_Voce') )
		{
			voce = getObjValue('R' + row + '_Voce');
			
			//Se non mi trovo sulla riga a voce 0 risalgo le righe per arrivare, a parità di lotto, alla voce 0&PARAM
			if (voce != '0')
			{
				
				var numrrowprod = Number(GetProperty( getObj('PRODOTTIGrid') , 'numrow') );
				if( numrrowprod  >= 0 )
				{
					var r=0;
					var voceRigaN;
					var numeroLottoRigaN;
					
					for (r=0; r < numrrowprod + 1; r++)
					{
						//Se non mi trovo sulla riga che ho già lavorato
						if ( r != row )
						{
							voceRigaN = getObjValue('R' + r + '_Voce');
							numeroLottoRigaN = getObjValue('R' + r + '_NumeroLotto');
							
							//Se mi trovo sul lotto giusto e la voce è la 0
							if ( numeroLottoRigaN == numeroLotto && voceRigaN == '0' )
							{
								svuotaEsito(r,numeroLottoRigaN);
								break;
							}

						}
					}

				}

			}

		}
	}
	catch(e)
	{
	}

}

function svuotaEsito(row,numeroLotto)
{
	var msg = '<img src="../images/Domain/State_ERR.gif"><br>L\'elenco Prodotti e\' stato modificato.<br/>E\' necessario eseguire il comando "Verifica Informazioni"';
	
	getObj('R' + row + '_EsitoRiga_V').innerHTML = msg;
	getObj('R' + row + '_EsitoRiga').value = msg;
	
	try
	{
		if ( numeroLotto != '-1' )
		{
			var numrrowprod = Number(GetProperty( getObj('LISTA_BUSTEGrid') , 'numrow') );
			var esito = '<img src="../images/Domain/State_OK.gif">';
				
			if( numrrowprod  >= 0 )
			{
				var r=0;
				var voceRigaN;
				var numeroLottoRigaN;

				for (r=0; r < numrrowprod + 1; r++)
				{

					numeroLottoRigaN = getObjValue('RLISTA_BUSTEGrid_' + r + '_NumeroLotto');
					
					if ( numeroLottoRigaN == numeroLotto )
					{
						getObj('RLISTA_BUSTEGrid_' + r + '_EsitoRiga_V').innerHTML = msg;
						getObj('RLISTA_BUSTEGrid_' + r + '_EsitoRiga').value = msg;
						break;
					}

				}

			}
		}
	}
	catch(e)
	{
	}
}


function MyMakeDocFrom(param)
{
	
	ML_text = 'OFFERTE_UTENTE_TOOLBAR_NEW';
	Title = 'Informazione';					
	ICO = 1;
	page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
		
	ExecFunctionModaleConfirm( page, Title , 200 , 420 , null , 'MakeDocFrom@@@@' + param  ,'');
	
	
	/*
	if( confirm(CNV( '../','OFFERTE_UTENTE_TOOLBAR_NEW')) )
	{
		MakeDocFrom(param);
	}
	*/
}

function Compila_DOC_DGUE()
{
	
	
    var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
    if (DOCUMENT_READONLY == "1")
	{
		MakeDocFrom('MODULO_TEMPLATE_REQUEST##MANIFESTAZIONE_INTERESSE');
	}
	else
	{	
		ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');
	}
	
}

function Compila_Questionario_Amministrativo() {
  var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
  if (DOCUMENT_READONLY == "1") {
    MakeDocFrom('MODULO_QUESTIONARIO_AMMINISTRATIVO##OFFERTA');
  }
  else {
    ExecDocProcess('FITTIZIO3,DOCUMENT,,NO_MSG');
  }
}


function Show_Hide_dgue_COL()
{
	try
	{
		if ( getObjValue('PresenzaDGUE') != 'si' )
		{	  
		
			try{ nNumRowRTI = Number(GetProperty(getObj('RTIGRIDGrid'), 'numrow')); }catch(e){}
			try{ nNumRowESECU = Number(GetProperty(getObj('ESECUTRICIGRIDGrid'), 'numrow')); }catch(e){}
			try{ nNumRowAUSI = Number(GetProperty(getObj('AUSILIARIEGRIDGrid'), 'numrow')); }catch(e){}
			try{ nNumRowSUB = Number(GetProperty(getObj('SUBAPPALTOGRIDGrid'), 'numrow')); }catch(e){}
			//se sono presenti righe nascondo le colonne DGUE
			if ( nNumRowRTI > -1 )
			{
				ShowCol( 'RTIGRID' , 'StatoDGUE' , 'none' );		
				ShowCol( 'RTIGRID' , 'AllegatoDGUE' , 'none' );
				ShowCol( 'RTIGRID' , 'FNZ_OPEN' , 'none' );
			}
			if ( nNumRowESECU > -1 )
			{
				ShowCol( 'ESECUTRICIGRID' , 'StatoDGUE' , 'none' );		
				ShowCol( 'ESECUTRICIGRID' , 'AllegatoDGUE' , 'none' );
				ShowCol( 'ESECUTRICIGRID' , 'FNZ_OPEN' , 'none' );
			}
			if ( nNumRowAUSI > -1 )
			{
				ShowCol( 'AUSILIARIEGRID' , 'StatoDGUE' , 'none' );		
				ShowCol( 'AUSILIARIEGRID' , 'AllegatoDGUE' , 'none' );
				ShowCol( 'AUSILIARIEGRID' , 'FNZ_OPEN' , 'none' );
			}
			if ( nNumRowSUB > -1 )
			{
				ShowCol( 'SUBAPPALTOGRID' , 'StatoDGUE' , 'none' );		
				ShowCol( 'SUBAPPALTOGRID' , 'AllegatoDGUE' , 'none' );
				ShowCol( 'SUBAPPALTOGRID' , 'FNZ_OPEN' , 'none' );
			}
			
		}
	}catch(e){}	
	//CICLO SULLE GRIGLIE RTI E Avvalimenti QUANDO TROVA INVIATA RICHIESTA per statodgue rende la colonna codicefiscale not edit
	try
	{
		if ( getObjValue('PresenzaDGUE') == 'si' )
		{
			try{ nNumRowRTI = Number(GetProperty(getObj('RTIGRIDGrid'), 'numrow')); }catch(e){}
			try{ nNumRowESECU = Number(GetProperty(getObj('ESECUTRICIGRIDGrid'), 'numrow')); }catch(e){}
			try{ nNumRowAUSI = Number(GetProperty(getObj('AUSILIARIEGRIDGrid'), 'numrow')); }catch(e){}
			try{ nNumRowSUB = Number(GetProperty(getObj('SUBAPPALTOGRIDGrid'), 'numrow')); }catch(e){}
			if ( nNumRowRTI > -1 )
			{
				for (i = 0; i <= nNumRowRTI; i++) 
				{
					if ( getObjValue('RRTIGRIDGrid_'+i+'_StatoDGUE') == 'InviataRichiesta')
					{
						TextreadOnly( 'RRTIGRIDGrid_'+i+'_codicefiscale', true);
					}
					if ( getObjValue('RRTIGRIDGrid_'+i+'_StatoDGUE') != 'Ricevuto')
					{
						getObj( 'RRTIGRIDGrid_' + i + '_FNZ_OPEN' ).innerHTML = '';
					}
					
				}
			}
			if ( nNumRowESECU > -1 )
			{
				for (i = 0; i <= nNumRowESECU; i++) 
				{
					if ( getObjValue('RESECUTRICIGRIDGrid_'+i+'_StatoDGUE') == 'InviataRichiesta')
					{	
						TextreadOnly( 'RESECUTRICIGRIDGrid_'+i+'_codicefiscale', true);	
					}
					if ( getObjValue('RESECUTRICIGRIDGrid_'+i+'_StatoDGUE') != 'Ricevuto')
					{
						getObj( 'RESECUTRICIGRIDGrid_' + i + '_FNZ_OPEN' ).innerHTML = '';
					}
					
				}
			}
			if ( nNumRowAUSI > -1 )
			{
				for (i = 0; i <= nNumRowAUSI; i++) 
				{
					if ( getObjValue('RAUSILIARIEGRIDGrid_'+i+'_StatoDGUE') == 'InviataRichiesta')
					{
						TextreadOnly( 'RAUSILIARIEGRIDGrid_'+i+'_codicefiscale', true);	
					}
					if ( getObjValue('RAUSILIARIEGRIDGrid_'+i+'_StatoDGUE') != 'Ricevuto')
					{
						getObj( 'RAUSILIARIEGRIDGrid_' + i + '_FNZ_OPEN' ).innerHTML = '';
					}
					
				}
			}	
			if ( nNumRowSUB > -1 )
			{
				for (i = 0; i <= nNumRowSUB; i++) 
				{
					if ( getObjValue('RSUBAPPALTOGRIDGrid_'+i+'_StatoDGUE') == 'InviataRichiesta')
					{
						TextreadOnly( 'RSUBAPPALTOGRIDGrid_'+i+'_codicefiscale', true);	
					}
					if ( getObjValue('RSUBAPPALTOGRIDGrid_'+i+'_StatoDGUE') != 'Ricevuto')
					{
						getObj( 'RSUBAPPALTOGRIDGrid_' + i + '_FNZ_OPEN' ).innerHTML = '';
					}
					
				}
			}				
			
		}
	}catch(e){}
	
}


function afterProcess( param )
{
    if ( param == 'FITTIZIO' )
    {
		ShowWorkInProgress();

		setTimeout(function()
		{ 
			
			ShowWorkInProgress();
			MakeDocFrom('MODULO_TEMPLATE_REQUEST##MANIFESTAZIONE_INTERESSE');

		}, 1 );
    }
	if ( param == 'FITTIZIO2' )
    {
		var cod = getObjValue('idDocR');
		
		if ( cod == '' ||  cod == undefined ) 
		{
			alert( 'Errore tecnico - IdDocRicDGUE - non trovato' );
			return;
		}
		  
		param ='RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA##OFFERTA#' + cod + '#' ;
		
		MakeDocFrom ( param ) ;   
	}
	
	if (param == 'FITTIZIO3') {
      ShowWorkInProgress();
  
      setTimeout(function () {
  
        ShowWorkInProgress();
        MakeDocFrom('MODULO_QUESTIONARIO_AMMINISTRATIVO##OFFERTA');
      }, 1);
    }
	
	
	if (param == 'BUSTA_DOCUMENTAZIONE_WARNING')
	{
		DisplaySection();  
	}
	
	if ( param == 'SEND' )
	{
		
		
		if( getObjValue( "StatoFunzionale" ) == 'Inviato' )
		{
			
			var Title = 'Informazione';
			var ML_text = 'Invio Risposta Concorso eseguito correttamente';
			var ICO = 1;
			var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);				
			ExecFunctionModaleWithAction( page, null , 200 , 420 , null , '' );
			
		}
	}
	
}


function MyMakeDocFrom2( objGrid , Row , c )
{
 	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	var cod = getObj( 'R'+ objGrid + '_' + Row + '_IdDocRicDGUE').value;
	var param='';
    if (DOCUMENT_READONLY == "1")
	{		
		
		if ( cod == '' ||  cod == undefined ) 
		{
			alert( 'Errore tecnico - IdDocRicDGUE - non trovato' );
			return;
		}		  
		param ='RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA##OFFERTA#' + cod + '#' ;		
		MakeDocFrom ( param ) ;   
	}
	else
	{				
		
		getObj('idDocR').value=cod;		
		ExecDocProcess( 'FITTIZIO2,DOCUMENT,,NO_MSG');
	}
    
}


function icona_folder_documento()
{
	
	var Divisione_lotti = getObjValue('Divisione_lotti');
	
	
	//SE E' PREVISTO IL DGUE INSERISCE ICONA DI WARNING SE NON E' PRESENTE
	if ( getObjValue('PresenzaDGUE') == 'si' )
	{
		if( getObj('RDISPLAY_DGUE_MODEL_Allegato').value == '' )
		{
			
			var val=$('#CompilaDGUE').parent().siblings('td:first').text();
			$('#CompilaDGUE').parent().siblings('td:first').html('<img src="../images/Domain/State_Warning.png"> <strong>' + val+ '</strong>');
		}
	}

	//SE E' PREVISTO IL QUESTIONARIO_AMMINISTRATIVO INSERISCE ICONA DI WARNING SE NON E' PRESENTE
	if ( getObjValue('PresenzaQuestionario') === 'si' )
	{
		if( getObj('RDISPLAY_QUESTIONARIO_MODEL_AllegatoQuestionario').value == '' )
		{			
			var val=$('#CompilaQuestionarioAmministrativo').parent().siblings('td:first').text();
			$('#CompilaQuestionarioAmministrativo').parent().siblings('td:first').html('<img src="../images/Domain/State_Warning.png"> <strong>' + val+ '</strong>');
		}
	}
	
	//SE E' PREVISTO ATTESTATO DI PARTECIPAZIONE INSERISCE ICONA DI WARNING SE NON E' PRESENTE
	 if (getObjValue('ClausolaFideiussoria') == '1') 
	 {
		if( getObj('F2_SIGN_ATTACH').value == '' )
		{			
			var val=$('#table_file_attestazione_partecipazione').text();			
			$('#table_file_attestazione_partecipazione').html('<img src="../images/Domain/State_Warning.png"> ' + val);
		}
	 }
	
	//--SUL FOLDER BUSTA DOCUMENTAZIONE SE CI SONO WARNING LO INSERISCO ANCHE PRIMA DEL TITOLO DEL FOLDER
	 var value = document.getElementsByName("folder_button_BUSTA_DOCUMENTAZIONE")[0].innerHTML;
	 if ( getObj('RTESTATA_DOCUMENTAZIONE_MODEL_EsitoRiga').value.indexOf('State_Warning.gif') > 0 )
	 {	 
		 $( "button[name='folder_button_BUSTA_DOCUMENTAZIONE']" ).html('<img src="../images/Domain/State_Warning.png"> ' + value );		 
	 }
	 else if ( getObj('RTESTATA_DOCUMENTAZIONE_MODEL_EsitoRiga').value.indexOf('State_Err.gif') > 0 )
	 {	 
		 $( "button[name='folder_button_BUSTA_DOCUMENTAZIONE']" ).html('<img src="../images/Domain/State_Err.png"> ' + value );		 
	 }
	 else
	 {				 
		 $( "button[name='folder_button_BUSTA_DOCUMENTAZIONE']" ).html('<img src="../images/Domain/State_OK.png"> ' + value );		
	 }
	 
	
	//setto icona anche sul folder "busta documentazione tecnica"
	var value = document.getElementsByName("folder_button_BUSTA_TECNICA")[0].innerHTML;
	if ( getObj('RTESTATA_DOCUMENTAZIONE_TECNICA_MODEL_EsitoRiga').value.indexOf('State_Err.gif') > 0 )
	{	 
	 $( "button[name='folder_button_BUSTA_TECNICA']" ).html('<img src="../images/Domain/State_Err.png"> ' + value );		 
	}
	
	
}


function FIRMA_FIDEUSSIONE_OnLoad() {
    try {

        if (getObjValue('RichiestaFirma') == 'no' || getObjValue('ClausolaFideiussoria') != '1') {
            document.getElementById('DIV_FIRMA_FID').style.display = "none";
        } else {
            FieldToSign('F2');
        }
        try{FormatAllegato('DOCUMENTAZIONE');  } catch(e){}
		try{FormatAllegato('DOCUMENTAZIONE_TECNICA');  } catch(e){}

    } catch (e) {};

}

function attachFilePending()
{
	var AttivaFilePending = getObj('AttivaFilePending');
	
	/* SE IL CAMPO ESISTE */
	if ( AttivaFilePending )
	{
		var DOCUMENT_READONLY = getObjValue('DOCUMENT_READONLY');
    
		//Se richiesta la verifica pending dei file ed il documento è editabile
		if (AttivaFilePending.value == 'si' && DOCUMENT_READONLY == '0')
		{
			
			/* ITERIAMO SU TUTTI I CAMPI DI TIPO INPUT CONTENENTE IN LIKE LA PAROLA UPLOADATTACH NEL LORO ATTRIBUTO ONCLICK, VERIFICA DI TIPO CASE INSENSITIVE ( a prescindere da dove si trovano, documentazione, prodotti, giri di firma ) */

			$( "input[onclick*='uploadattach' i]" ).each( function( index, element )
			{
				var attachOnClick = $( this ).attr('onclick');
				
				//Se non è già presente la format a J ( jump )
				if ( attachOnClick.indexOf('&FORMAT=J') == -1 ) 
				{
					attachOnClick = attachOnClick.replace(new RegExp( '&FORMAT=', 'g'), '&FORMAT=J');
					$( this ).attr('onclick', attachOnClick); // Sostituiamo l'onlick con il nuovo
				}

			});
			
			
			
		}
	}
	
}

function RitiraRisposta(param)
{
	if (getObjValue('id_ritira_offerta') == '0')
	{
		
		ML_text = 'MSG_ALERT_RITIRA_RISPOSTA ';
		Title = 'Informazione';					
		ICO = 1;
		page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
			
		ExecFunctionModaleConfirm( page, Title , 200 , 420 , null , 'MakeDocFrom@@@@' + param ,'');
		/*
		if( confirm(CNV( '../../','MSG_ALERT_RITIRA_RISPOSTA ')) )
		{
			MakeDocFrom(param);
		}
		*/
	}
	else
		MakeDocFrom(param);
	
}