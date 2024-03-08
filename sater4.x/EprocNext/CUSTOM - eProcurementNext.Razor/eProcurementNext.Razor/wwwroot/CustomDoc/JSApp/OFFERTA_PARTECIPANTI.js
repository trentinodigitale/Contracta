window.onload = Init_Offerta_Partecipanti;

function Init_Offerta_Partecipanti() {

    //se ho chiamto il save chiudo il doc
    //if ( getQSParam('COMMAND') != null )
    //  parent.close();

    //if ( GetProperty(getObj('val_StatoFunzionale'),'value') == 'InLavorazione'){
	if ( getObj('StatoGD') )
	{
		if (getObj('StatoGD').value != '2') 
		{

			HideShowAree();

		}
		else
			Show_Hide_dgue_COL();
	}
	
    //alert(getObjValue('StatoGD' ));
    //if( getObjValue('StatoGD' ) == '2' ){

    //}
	if( getObj('VersioneLinkedDoc' ).value != 'SUBENTRO' )
	{
		try{getObj('div_TESTATA_SUBENTROGrid').style.display = 'none';}catch (e) {}	
		try{getObj('TESTATA_SUBENTRO').style.display = 'none';}catch (e) {}	
	}
	if( getObj('VersioneLinkedDoc' ).value == 'SUBENTRO' )
	{
		try{ getObj('Fornitore_edit_new').setAttribute("onchange", "OnChangeNuovoFornitore();" );}catch( e ) {};
	}
}
	


//nasconde le griglie secondo i campi settati si/no per le RTI
function HideShowAree() 
{


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
	
	Show_Hide_dgue_COL();

}

//cancella tutte le righe di una griglia
function MyDelete_RTIGrid(grid, obj) {

    if (obj.value == '0') {

        if (confirm(CNV('../../', 'Sei sicuro di cancellare ' + grid)) == true) {

            var sec = getObj(grid + '_SECTION_DETTAGLI_NAME').value;
			if( grid != 'SUBAPPALTOGRIDGrid' )
				ExecDocCommand(sec + '#DELETE_ALL#');

            //ShowLoading( sec );

        } else
            obj.value = '1';

    } else {

        //se sono sulla griglia RTI è vuota allora inserisco in automatico prima riga con azienda loggata
        if (grid == 'RTIGRIDGrid' && obj.value == '1') {

            //recupero azienda fornitore che ha fatto il documento
            var Azienda = getObj('Azienda').value;
            var sec = getObj(grid + '_SECTION_DETTAGLI_NAME').value;
            var Param = 'IDROW=' + Azienda + '&TABLEFROMADD=Seleziona_Fornitore_RTI';
            ExecDocCommand(sec + '#ADDFROM#' + Param);

            //ShowLoading( sec );

        }


    }


    HideShowAree();


}


//viene eseguita dopo i comandio sulla griglia RTI
function RTIGRID_AFTER_COMMAND(command) {



 
 
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

        //se è la prima riga
        //if ( getObjGrid('val_RRTIGRIDGrid_0_Ruolo_Impresa').value == ''){
        if (GetProperty(getObjGrid('val_RRTIGRIDGrid_0_Ruolo_Impresa'), 'value') == '') {

            //setto il ruolo a mandataria
            SetProperty(getObjGrid('val_RRTIGRIDGrid_0_Ruolo_Impresa'), 'value', 'Mandataria');
            getObjGrid('val_RRTIGRIDGrid_0_Ruolo_Impresa').innerHTML = 'Mandataria';
            getObjGrid('RRTIGRIDGrid_0_Ruolo_Impresa').value = 'Mandataria';
        }


        //nascondo il cestino
        getObjGrid('RRTIGRIDGrid_0_FNZ_DEL').style.display = 'none';
        //disabilito onclick sul cestino
        getObj('RTIGRIDGrid_r0_c1').onClick = '';
        //disabilito onchange su codice fiscale
        getObjGrid('RRTIGRIDGrid_0_codicefiscale').onchange = '';


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

//a partire dal codice fiscale ritorna le info di azienda
function GetInfoAziendaFromCF() {

 
    //RRTIGRIDGrid_0_codicefiscale
    var strNameCtl = this.name;

    var aInfo = strNameCtl.split('_');

    var nIndRrow = aInfo[1];

    var strCF = this.value;
	
	var bIsUnique_blocco=false;

    var Grid = aInfo[0].substr(1, aInfo[0].length);
    //alert(strCF);
    if (strCF.length >= 7) {



        //if  ( bIsUnique ){

        //provo a ricercare le info azienda
        ajax = GetXMLHttpRequest();

        if (ajax) {

            ajax.open("GET", '../../ctl_library/functions/InfoAziFromCF.asp?FilterHide=azivenditore<>0 and aziacquirente=0&CodiceFiscale=' + escape(strCF), false);

            ajax.send(null);

            if (ajax.readyState == 4) {

                if (ajax.status == 200) {
                    if (ajax.responseText != '') {


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

                    } else {

                        //setto i caratteri in rosso
                        this.style.color = 'red';

                        //svuoto i campi
                        SetInfoAziendaRow(Grid, nIndRrow, '#####');
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
        SetInfoAziendaRow(Grid, nIndRrow, '#####');
    }

    //aggiorno campo denominazione
    UpgradeDenominazioneRTI();
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
        alert(CNV('../../', 'codice fiscale azienda non esistente'));

}


//controlla che questo codice fiscale non sia già presente
function AziIsUnique(strNameAreaCurrent, nRowCurrent, strCF) {

    var bIsUnique = true;

    //griglia RTI
    var nIndRrow;
    var strFullNameArea = 'RTIGRIDGrid';

    var nNumRow = -1;
	
	try
	{
		Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch(e)
	{
	}
	
    for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

        if (strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent))) {

            if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value.toUpperCase() == strCF.toUpperCase()) {
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

        if (strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent))) {

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

        if (strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent))) {

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


//setta le info di una azienda su una riga di una griglia
function SetInfoAziendaRow(strFullNameArea, nIndRrow, strresult) {

	
    var nPos;
    var ainfoAzi = strresult.split('#');

    var strRagSoc = ainfoAzi[0];
	try{getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_NotEditable').value = '';} catch (e) {}
    try {getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc').value = strRagSoc;}catch(e){}
    try {getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc_V').innerHTML = strRagSoc;}catch(e){}


    /*
    if (strFullNameArea == 'DOCUMENTAZIONE_ATIgriglia' && nIndRrow==0){
      var strCodicefiscale = ainfoAzi[4];
      getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value=strCodicefiscale;
    }*/
	var strCodicefiscale = ainfoAzi[4];
	if ( strCodicefiscale != '' )
		try{getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value=strCodicefiscale;}catch(e){}
	
    var strIndLeg = ainfoAzi[1];
    try { getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_INDIRIZZOLEG').value = strIndLeg;}catch(e){}
    try {getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_INDIRIZZOLEG_V').innerHTML = strIndLeg;}catch(e){}

    var strLocLeg = ainfoAzi[2];
    try {getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_LOCALITALEG').value = strLocLeg;}catch(e){}
    try {getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_LOCALITALEG_V').innerHTML = strLocLeg;}catch(e){}


    var strProvLeg = ainfoAzi[3];
    try {getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_PROVINCIALEG').value = strProvLeg;}catch(e){}
    try {getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_PROVINCIALEG_V').innerHTML = strProvLeg;}catch(e){}



    var strIdazi = ainfoAzi[5];
    try {getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_IdAzi').value = strIdazi;}catch(e){}
	
	

    var strRuolo = 'Mandataria';
    var strTechRuolo = 'Mandataria';
    if (nIndRrow != 0) {
        strRuolo = 'Mandante';
        strTechRuolo = 'Mandante';
    }


    if (strresult == '#####') 
	{
        strRuolo = '';
        strTechRuolo = '';
		
		 
		 //try{getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE').innerHTML = '';} catch (e) {}
		 //try{getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE').value = '';} catch (e) {}
		 try{getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE').innerHTML ='<input type=\"hidden\" name=\"R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE\" id=\"R' + strFullNameArea + '_' + nIndRrow + '_StatoDGUE\"  >';} catch (e) {}
		 
		 
		 
		 try{getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_AllegatoDGUE').value = '';} catch (e) {}
		 try{getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_AllegatoDGUE_V').innerHTML = '';} catch (e) {}
		 try{getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_AllegatoDGUE_V_N').value = '';} catch (e) {}
		 
		 try{SetTextValue('R' + strFullNameArea + '_' + nIndRrow + '_FNZ_OPEN','');} catch (e) {}
		 try{getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_FNZ_OPEN').innerHTML = '';} catch (e) {}
		 
		 try{SetTextValue('R' + strFullNameArea + '_' + nIndRrow + '_IdDocRicDGUE','');} catch (e) {} 
		 
		 
    }

    //getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa').value=strRuolo;
    //getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa').innerHTML=strTechRuolo;   

    //SetProperty(getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa'),'value',strTechRuolo);

        try{getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa').innerHTML = strRuolo;} catch (e) {}
        try{getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa').value = strTechRuolo;} catch (e) {}

    
	
	
	//SE HO TROVATO I DATI BLOCCO I DATI ANAGRAFICI
	if ( strIdazi != '')
	{
		try{getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_NotEditable').value = ' RagSoc INDIRIZZOLEG LOCALITALEG PROVINCIALEG ';} catch (e) {}		
	
	}
	//RICARICO SEMPRE L'AREA DALLA MEMORIA, SIA SE SVUOTO CHE SE RECUPERO I DATI SERVE
	if (strFullNameArea == 'RTIGRIDGrid')
		grid='RTIGRID'
	if (strFullNameArea == 'ESECUTRICIGRIDGrid')
		grid='ESECUTRICIGRID'
	if (strFullNameArea == 'AUSILIARIEGRIDGrid')
		grid='AUSILIARIEGRID'
	if (strFullNameArea == 'SUBAPPALTOGRIDGrid')
		grid='SUBAPPALTOGRID'	

	ExecDocCommand( grid+'#ADDFROM');
	
	

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
    if (getObj('PartecipaFormaRTI').value == '1') {

        strFullNameArea = 'RTIGRIDGrid';
        nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));

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
	if (getObj('InserisciEsecutriciLavori') && getObj('InserisciEsecutriciLavori').value == '1') {

        strFullNameArea = 'ESECUTRICIGRIDGrid';
        nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));

        if (nNumRow >= 0 && getObjGrid('R' + strFullNameArea + '_0_RagSoc').value != '') {

            objDenominazioneATI.value = objDenominazioneATI.value + ' Esecutrice ';

            for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

                strTempValue = getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc').value;

                if (strTempValue != '') {
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


}


function MyExecDocProcess(param) {

    //CONTROLLO IN CASO DI RTI
    var bret = false;
    var bret = CanSendRTI();

    if (!bret) {
        return;
    }

    /*
    //aggiorno la ragione sociale nella sezione evaluate con il campo denominazioneATI aggiornato
    var strQueryString = getObj('CommandQueryString').value;
  
    //alert(strQueryString);
  
    //recupero id offerta in arrivo della sezione evaluate
    var idDocOff = getQSParamFromString( strQueryString , 'IDDOC_OFFERTA'); 
  
  
  
    //aggiorno la desc della ragione sociale nella griglia evaluate
    var strFullNameArea = 'Valutazione_griglia' ;
  
    var objRow =  parent.opener.getObj('NumProduct_' + strFullNameArea ) ;
  
    var nNumRow = Number(objRow.value);
  
    var nPosIdMsg =  parent.opener.GetColumnPositionInGrid( 'IdMsg' ,strFullNameArea );
    var nPosRAGSOC = parent.opener.GetColumnPositionInGrid( 'RAGSOC' ,strFullNameArea );
    var nPosPresAvvalimenti = parent.opener.GetColumnPositionInGrid('PresenzaAvvalimenti',strFullNameArea);
  
    var strCurrIdMsg;
  
    var strRicorriAvvalimento = getObj('RicorriAvvalimento').value ;
    var objCellCurr ;
    var objhiddenCurr ;
  
  
  
    for ( nIndRrow=1; nIndRrow<=nNumRow; nIndRrow++){	
          
      strCurrIdMsg = parent.opener.getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosIdMsg ).value ;
      
      if ( strCurrIdMsg ==  idDocOff ){
        
          parent.opener.getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosRAGSOC ).value = getObj( 'DenominazioneATI' ).value ;
          parent.opener.getObj('SPN_' + strFullNameArea + '_' + nIndRrow + '_' + nPosRAGSOC ).innerHTML = getObj( 'DenominazioneATI' ).value ;
          
          //aggiorna colonna PresenzaAvvalimenti se presente
          if ( nPosPresAvvalimenti != -1 ){
          
            //aggiorno colonna Avvalimenti
            objCellCurr = null;
            objCellCurr = parent.opener.getObj('cell_Valutazione_griglia_' + nIndRrow + '_' + nPosPresAvvalimenti);
            
            objhiddenCurr = null;
            objhiddenCurr = parent.opener.getObj('Valutazione_griglia_' + nIndRrow + '_' + nPosPresAvvalimenti);
           
            if ( strRicorriAvvalimento != ''){
              if ( strRicorriAvvalimento == '0'){
                objCellCurr.innerHTML = 'No';
                objhiddenCurr.value= '0#~No';
              }else{
                objCellCurr.innerHTML = 'Si';
                objhiddenCurr.value= '1#~Si';     
              }
            }
          }
          
          break;
      }
            
          
    }  
    */


    //alert(IdDocPDA);

    ExecDocProcess(param);



    //EFFETTUO IL RICARICO DELLA SEZIONE DELLE BUSTE DOCUMENTAZIONE DELLA PDA

}

/*
function RefreshContent()
{
	alert('refresh');
	var IdDocPDA = getObj('idPdA').value ;
	if( getObjValue('StatoFunzionale' ) == 'Pubblicato' )
  	ExecDocCommandInMem( 'OFFERTE#RELOAD', IdDocPDA, 'PDA_MICROLOTTI');
	
}
*/

//CONTROLLA CHE IN CASO DI RTI LA COMPILAZIONE E' OK
function CanSendRTI() {



    var bret = false;


    //aggiorno coerentemente il campo denominazione ati
    UpgradeDenominazioneRTI();

    //controllo se partecipacomeRTI è settato che la griglia RTi è compilata correttamente
    bret = CanSendGridRTI('RTIGRIDGrid', 'PartecipaFormaRTI', 'mandante');
    if (!bret) {
        return false;
    }

    //controllo che per la RTI le righe devo essere almeno 2
    strFullNameArea = 'RTIGRIDGrid';
    nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
    if (nNumRow == 0) {
        alert(CNV('../../', 'inserire almeno una mandante'));
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
    bret = CanSendGridRTI('AUSILIARIEGRIDGrid', 'RicorriAvvalimento', 'ausiliaria');
    if (!bret) {
        return false;
    }

    //controllo che le ausiliate  della griglia Avvalimenti sono tutti nella griglia RTI
    bret = false;
    bret = RiferimentiGridIsInRTI('AUSILIARIEGRIDGrid', 'RagSocRiferimento', 'IdAziRiferimento');
    if (!bret) {
        return false;
    }


    return true;

}

//controlla che una griglia è compilata correttamente
function CanSendGridRTI(strFullNameArea, strAttrib, strCnv) {


    var iddztAttrib;
    var objAttrib;

    if (getObj(strAttrib) && getObj(strAttrib).value == '1') 
	{

        nNumRow = -1;
		
		try
		{
			nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
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
    var nNumRowRTI = -1;
	
	try
	{
		Number(GetProperty(getObj(strFullNameAreaRTI), 'numrow'));
	}
	catch(e)
	{
	}

    if (nNumRowRTI == -1)
        bRTI = false;

	var nNumRow = -1;
	
	try
	{
		Number(GetProperty(getObj(strFullNameArea), 'numrow'));
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
                else
                    alert(CNV('../../', 'attenzione azienda area ' + strFullNameArea) + ' "' + strCurrRagSoc + '" ' + CNV('../../', 'non azienda loggata'));

                return false;

            }


        }
    }

    return true;

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
			getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').onblur = VERIFICA_CF(strFullNameArea,nIndRrow);
			
            //getObjGrid( 'R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').onblur = MakeAlertAzienda ;
        }

    }

}


//recupera la lista delle aziende esecutrici nei CONSORZI
function GetEsecutriciConsorzio() {

    var strTempList = '';
    var strTempValue = '';

    var nIndRrow;

    var nNumRow = -1;
	
	try
	{
		GetProperty(getObj('ESECUTRICIGRIDGrid'), 'numrow');
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

//chiamata dopo il successo di un processo
function afterProcess(param) 
{

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
	else
	{
	
		var IdDocPDA = getObj('idPdA').value;
		ExecDocCommandInMem('OFFERTE#RELOAD', IdDocPDA, 'PDA_MICROLOTTI');
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
			try
			{
				if ( nNumRowRTI > -1 )
				{
					ShowCol( 'RTIGRID' , 'StatoDGUE' , 'none' );		
					ShowCol( 'RTIGRID' , 'AllegatoDGUE' , 'none' );
					ShowCol( 'RTIGRID' , 'FNZ_OPEN' , 'none' );
				}
			}catch(e){}
			try
			{
				if ( nNumRowESECU > -1 )
				{
					ShowCol( 'ESECUTRICIGRID' , 'StatoDGUE' , 'none' );		
					ShowCol( 'ESECUTRICIGRID' , 'AllegatoDGUE' , 'none' );
					ShowCol( 'ESECUTRICIGRID' , 'FNZ_OPEN' , 'none' );
				}
			}catch(e){}
			try
			{
				if ( nNumRowAUSI > -1 )
				{
					ShowCol( 'AUSILIARIEGRID' , 'StatoDGUE' , 'none' );		
					ShowCol( 'AUSILIARIEGRID' , 'AllegatoDGUE' , 'none' );
					ShowCol( 'AUSILIARIEGRID' , 'FNZ_OPEN' , 'none' );
				}
			}catch(e){}
			try
			{
				if ( nNumRowSUB > -1 )
				{
					ShowCol( 'SUBAPPALTOGRID' , 'StatoDGUE' , 'none' );		
					ShowCol( 'SUBAPPALTOGRID' , 'AllegatoDGUE' , 'none' );
					ShowCol( 'SUBAPPALTOGRID' , 'FNZ_OPEN' , 'none' );
				}
			}catch(e){}
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

function LocDMessageBox(path, Text, Title, ICO, w, h) {
    //alert(CNV('../../', Text));
	ML_text = Text
	Title = 'Informazione';					
	ICO = 1;
	page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

	ExecFunctionModale( page, null , 200 , 420 , null  );
	
}

function VERIFICA_CF(strFullNameArea,nIndRrow)
{
	 
	 if ( getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_IdAzi').value == '' )
	 {
		 
		if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value.length >= 11 ) 
		{
			
			ret = CheckCF(getObj('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale') );	
			
			if ( ret != '' &&  ret != undefined )
			{				
				getObj('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').style.color = 'red';
				LocDMessageBox('../', ret, 'Attenzione', 1, 400, 300);	
				return -1;
			}
			if ( ret == false )
			{
				getObj('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').style.color = 'red';
				
			}
			
			//try{ SetDomValue ( getObj('R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa'), 'Mandante', 'Mandante', '', '' );} catch (e) {}
				
			try{SetProperty(getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa'), 'value', 'Mandante');} catch (e) {}
            try{getObjGrid('val_R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa').innerHTML = 'Mandante';} catch (e) {}
            try{getObj('R' + strFullNameArea + '_' + nIndRrow + '_Ruolo_Impresa').value = 'Mandante';} catch (e) {}
			
				
		}
		else
		{
			try //SETTA IL FOCUS SUL CF ALLA FINE DEL TESTO DIGITATO
			{
				var $el = $(getObj('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale'));
				    el = getObj('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale');
				  if (!$el.is(":focus")) 
				  {
					$el.focus();
				  }
				   if (el.setSelectionRange) 
				   {

					  // Double the length because Opera is inconsistent about whether a carriage return is one character or two.
					  var len = $el.val().length * 2;
					  
					  // Timeout seems to be required for Blink
					  setTimeout(function() {
						el.setSelectionRange(len, len);
					  }, 1);

					} 
					else {
					  
					  // As a fallback, replace the contents with itself
					  // Doesn't work in Chrome, but Chrome supports setSelectionRange
					  $el.val($el.val());
					  
					}
				
			 } catch (e) {}
			 getObj('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').style.color = 'red';
		}
		 
	 }
}

function OnChangeNuovoFornitore()
{
	ExecDocProcess( 'SEL_NUOVO_FORNITORE,OFFERTA_PARTECIPANTI');
}