//Variabile di appoggio per contenere l'idpfu dell'utente collegato e gestire l'applicazione sia se accessibile sia no
var tmp_idpfuUtenteCollegato;


//--Versione=2&data=2012-06-27&Attvita=38848&Nominativo=Sabato
function MySend(param) {
	try 
	{
		
		if ( VerificaObbligoCigDerivato() )
		{	
		
			try {
				if (verifyCap('ReferenteLocalita2', getObj('ReferenteCap')) && verifyCap('FatturazioneLocalita2', getObj('FatturazioneCap'))) {
					ExecDocProcess(param);
				}
			} catch (e) 
			{
				ExecDocProcess(param);
			}
		
		}
	} catch (e) 
	{
		ExecDocProcess(param);
	}
}

function PRODOTTI_MakeTotal() {

    /*
        var RDA_Total = Number( getObj( 'RDA_Total' ).value ) ;
        var IVA = Number( GetProperty(getObj( 'val_IVA' ), 'value') );
        
        if ( IVA !=''){
          var ValoreIva = ( RDA_Total * IVA ) / 100;
          var TotalIva = ValoreIva + RDA_Total;
          SetNumericValue( 'ValoreIva' , ValoreIva );
          SetNumericValue( 'TotalIva' , TotalIva );
        }
    */
}


function LocDetailMakeTotal(Section, obj) {
    /*  
    //-- controollo che la qt non sia inferiore all qtmin
    var r = obj.id.split( '_' )[0];
    var QtMinTot = 0;
    var result = '';
    
    try{
        QtMinTot = Number( getObj( 'QtMinTot' ).value );
    }catch( e ) {
        QtMinTot = 0;
    }



    var qt =  Number( getObj( r + '_RDP_Qt' ).value ).toFixed(6);
    
    
    if ( QtMinTot == 0 ) 
    {
        var qtMin = Number( getObj( r +  '_QtMin' ).value ).toFixed(6);

        if ( Number( qt ) < Number( qtMin ))
        {
            //SetNumericValue(  r + '_RDP_Qt' , qtMin );
            alert( CNV ('../../' , 'Qt inferiore alla Qt min' ) );
            
        }
    }

    var TipoOrdine = 'S';
    try{ TipoOrdine = getObjValue( 'val_TipoOrdine' );   } catch ( e ) {TipoOrdine = 'S';};

    //-- per gli ordini con coefficiente occorre recuperare il valore tramite aiax
    if ( TipoOrdine == 'C' )
    {

	    ajax = GetXMLHttpRequest(); 

	    if(ajax){
    				 
    		
		    ajax.open("GET", '../../customDoc/Coefficienti.asp?VAL=' + escape( qt ) + '&ID_DOC=' + getObj( 'Id_Convenzione' ).value , false);
			 
		    ajax.send(null);
		    if(ajax.readyState == 4) {
			    if(ajax.status == 200)
			    {
				    result =  ajax.responseText;
				    var v = result.split(',');
				    
				    if( v[0] == '0' )
				    {
					SetNumericValue( r + '_RDP_Qt' , 0);
				        alert( v[1] );
				    }
				    else
				    {
				        SetNumericValue( r + '_CoefCorr' , v[0] );
				        var costo = Number(  v[0] ) * qt * Number( getObj( r + '_RDP_Importo' ).value )
				        costo = costo.toFixed(3);
				        SetNumericValue( r + '_CostoComplessivo' , costo );
				    }
			    }
		    }
	    }
	    
	    if ( result == '' )
	    {

	        alert( CNV ('../../' , 'Errore nel recupero del coefficiente') );

	    }
    }
    
    
    DetailMakeTotal( Section , obj );
    
    //azzero valoreiva e totaleconiva in copertina se iva in copertina è vuoto ma stà sui dettagli
    var IVA = Number( GetProperty(getObj( 'val_IVA' ), 'value') );
    if ( IVA ==''){
      SetNumericValue( 'ValoreIva' , 0 );
      SetNumericValue( 'TotalIva' , 0 );
    }
   */
}

function ChangeDir(obj) {
    /*
      getObj( 'ODC_PEG' ).value = getObj( 'Plant' ).value;
    */
}

function ChangePeg(obj) {
    /*
      getObj( 'Plant' ).value = getObj( 'ODC_PEG' ).value;
    */
}



function PRODOTTI_OnLoad() {
    /*
      ShowCol_TipoOrdine();

      PRODOTTI_MakeTotal();
      
      
      if ( getObj( 'val_RDA_Stato' ) .value == '' )
      {
          try{
              //opener.alert( 'delete carrello' );
              //opener.getObj('CARRELLO_TOOLBAR_DOCUMENT_del').innerHTML = 'ATTENZIONE';
              //opener.ExecDocProcess( 'DELETE,CARRELLO,,NO_MSG');"
              opener.ExecDocProcess( 'DELETE,CARRELLO,,NO_MSG');
          }catch(e){};
      }    


      if(  getObj( 'val_RDA_Stato' ).value ==  'Saved' || getObj( 'val_RDA_Stato' ).value == ''  )
      {
      
      
          var over = '';
          var TipoOrdine = 'S';
          try{ TipoOrdine = getObjValue( 'val_TipoOrdine' );   } catch ( e ) {TipoOrdine = 'S';};
          try{ over  = getObj( 'MSG_OVER_MSG' ).innerHTML }catch(e){over = '';}
          if( over == '' && TipoOrdine == 'B' )
          {
     		    DMessageBox( '../' , 'Si ricorda di tener conto per l\'impegno di spesa dell\'importo di Euro 1.81 relativo all\'imposta di bollo' , 'Attenzione' , 1 , 400 , 300 );
          }
      }
      
      MostraEvidenza( 'PRODOTTI' , 'Evidenzia');
    */
}


function ShowCol_TipoOrdine() {
    /*
            var TipoOrdine = 'S';
            try{ TipoOrdine = getObjValue( 'val_TipoOrdine' );   } catch ( e ) {TipoOrdine = 'S';};



            if( TipoOrdine == 'S' )
            {

                //ShowCol( 'PRODOTTI' , 'RDP_CodArtProd' , '' );
                ShowCol( 'PRODOTTI' , 'QtMin' , '' );
                //ShowCol( 'PRODOTTI' , 'RDP_Qt' , '' );

                ShowCol( 'PRODOTTI' , 'CostoComplessivo' , 'none' );
                ShowCol( 'PRODOTTI' , 'CoefCorr' , 'none' );
                ShowCol( 'PRODOTTI' , 'PercSconto' , 'none' );
                ShowCol( 'PRODOTTI' , 'DataUtilizzo' , 'none' );
                ShowCol( 'PRODOTTI' , 'ImportoCompenso' , 'none' );
                ShowCol( 'PRODOTTI' , 'FNZ_COPY' , 'none' );
            
            }
            
            if( TipoOrdine == 'P' )
            {
            
                //ShowCol( 'PRODOTTI' , 'RDP_CodArtProd' , 'none' );
                ShowCol( 'PRODOTTI' , 'QtMin' , 'none' );
                //ShowCol( 'PRODOTTI' , 'RDP_Qt' , 'none' );

                ShowCol( 'PRODOTTI' , 'CostoComplessivo' , 'none' );
                ShowCol( 'PRODOTTI' , 'CoefCorr' , 'none' );
                ShowCol( 'PRODOTTI' , 'PercSconto' , '' );
                ShowCol( 'PRODOTTI' , 'DataUtilizzo' , '' );
                ShowCol( 'PRODOTTI' , 'ImportoCompenso' , 'none' );
                ShowCol( 'PRODOTTI' , 'FNZ_COPY' , 'none' );
                
            }

            if( TipoOrdine == 'C' )
            {
            
                //ShowCol( 'PRODOTTI' , 'RDP_CodArtProd' , '' );
                ShowCol( 'PRODOTTI' , 'QtMin' , '' );
                //ShowCol( 'PRODOTTI' , 'RDP_Qt' , '' );

                ShowCol( 'PRODOTTI' , 'CostoComplessivo' , '' );
                ShowCol( 'PRODOTTI' , 'CoefCorr' , '' );
                ShowCol( 'PRODOTTI' , 'PercSconto' , 'none' );
                ShowCol( 'PRODOTTI' , 'DataUtilizzo' , 'none' );
                ShowCol( 'PRODOTTI' , 'ImportoCompenso' , 'none' );
                ShowCol( 'PRODOTTI' , 'FNZ_COPY' , 'none' );  
            
            }
            
            if( TipoOrdine == 'B' )
            {
            
                //ShowCol( 'PRODOTTI' , 'RDP_CodArtProd' , 'none' );
                ShowCol( 'PRODOTTI' , 'QtMin' , 'none' );
                //ShowCol( 'PRODOTTI' , 'RDP_Qt' , 'none' );

                ShowCol( 'PRODOTTI' , 'CostoComplessivo' , 'none' );
                ShowCol( 'PRODOTTI' , 'CoefCorr' , 'none' );
                ShowCol( 'PRODOTTI' , 'PercSconto' , '' );
                ShowCol( 'PRODOTTI' , 'DataUtilizzo' , '' );
                ShowCol( 'PRODOTTI' , 'ImportoCompenso' , '' );
                
            
            }
            
            //se iva in coeprtina è vuota la nascondo
            var IVA = Number( GetProperty(getObj( 'val_IVA' ), 'value') );
            if ( IVA == '')  {
                 getObj( 'val_IVA' ).style.display='none';
                 getObj( 'cap_IVA' ).style.display='none';
            }
                 
    */
}


function PRODOTTI_AFTER_COMMAND(com) {
    /*
        ShowCol_TipoOrdine( );
        PRODOTTI_MakeTotal();
    */

}



function MYDettagliDelCarrello(objGrid, Row, c) {
    /*
      var TipoProdotto;
      //TipoProdotto = getObjGrid( 'val_R' + Row + '_TipoProdotto').value;
      TipoProdotto = GetProperty( getObjGrid( 'val_R' + Row + '_TipoProdotto') , 'value' ); 
      
      //se è un accessorio cancello la riga
      if ( TipoProdotto == 'accessorio' )
        DettagliDel ( objGrid , Row , c  );
        
      //se è uno richiesto no posso cancellare
      if ( TipoProdotto == 'richiesto' ){
        DMessageBox( '../../CTL_Library/' , 'prodotto selezionato obbligatorio' , 'Attenzione' , 2 , 400 , 300 );
    	  return ;
    	}
    	
    	//se si tratta di un principale setto un flag a 1 per indicare ad un processo DELPRINCIPALE su quale riga stò lavorando
    	if ( TipoProdotto == 'principale' ){
    	   
    	   getObjGrid( 'R' + Row + '_ToDelete').value = 1 ;
    	   
    	   //invoco un processo sul documento che si preoccupa di cancellare il principale 
    	   //e i suoi collegati se possibile (nn ci deve essere un altro princiapale acui sono collegati)
    	   ExecDocProcess ('DELETEPRINCIPALE,ODC');
    	   
      }  
     */
}


function GeneraPDF() {

    //Controllo che ho inserito Titolo,Gic derivato e descrizione
    var TitoloValue = getObjValue('Titolo');

    if (TitoloValue == '') {
        getObj('Titolo').focus();
        DMessageBox('../', 'Per procedere si richiede l\'inserimento del Nome Ordinativo', 'Attenzione', 1, 400, 300);
        return;

    }

    var CIGValue = getObjValue('CIG');
	var ObbligoCigDerivato = getObjValue('Obbligo_Cig_Derivato');
	
    if (CIGValue == '' && ObbligoCigDerivato == 'si') {
		
		if ( getObjValue( 'RichiestaCigSimog' ) == 'si' )
		{
			DMessageBox('../', 'Attenzione, se Obbligo Cig Derivato = si occorre procedere con la richiesta del Cig Derivato sul SIMOG', 'Attenzione', 1, 400, 300);
		
		}
		else{
			getObj('CIG').focus();
			//DMessageBox('../', 'Per procedere si richiede l\'inserimento del CIG Derivato', 'Attenzione', 1, 400, 300);
		
			DMessageBox('../', 'Attenzione, Se Obbligo Cig Derivato = si valorizzare il campo Cig Derviato', 'Attenzione', 1, 400, 300);
		}
        return;

    }

    var NoteValue = getObjValue('Note');
    if (NoteValue == '') {
        getObj('Note').focus();
        DMessageBox('../', 'Per procedere si richiede l\'inserimento della Descrizione Ordinativo', 'Attenzione', 1, 400, 300);
        return;

    }

    //-- verifico la presenza degli articoli
    var numeroRigheProdotti = GetProperty(getObj('PRODOTTIGrid'), 'numrow');
    if (numeroRigheProdotti == '-1') {
        DMessageBox('../', 'Per procedere si richiede l\'inserimento degli articoli', 'Attenzione', 1, 400, 300);
        return;
    }

    //-- verifico la presenza degli allegati obbligatoria
    if (VerificaAllegati() == '1') {
        DMessageBox('../', 'Per procedere si richiede l\'inserimento degli allegati', 'Attenzione', 1, 400, 300);
        return;
    }




    //solo per gli ORDINATIVI CALSSICI SETTO DATO INIZIO E DATA SCADENZA 
    if (getObj('IdDocIntegrato').value == '0') 
	{

		// TOGLIERE IL CALCOLO PER DATA INIZIO.
	
		/*
	
        var strVal2;
		strVal2 = GetDataServer('../../', '');         //effettuo chiamata AJX che setta DataInizioOrdinativo
        var aInfoData = strVal2.split('T');

        var strValTemp = aInfoData[0];
        var strValTime = aInfoData[1]


        //recupero la forma visuale
        var extra_attrib = getObj('RDA_DataCreazione_extraAttrib').value;

        //alert(extra_attrib);

        var ainfo = extra_attrib.split('#=#');
        var strFormat = ainfo[1];
        var vetValue = strValTemp.split('-');
        var dateObj = new Date();
        var VisValuDataInizio = '';

        if (strFormat.substr(0, 10).toLowerCase() == 'dd/mm/yyyy') {

            dateObj.setMonth(0);
            dateObj.setDate(vetValue[0]); // 1-31
            dateObj.setMonth(vetValue[1] - 1); // 0-11 Month within the year (January = 0)
            VisValuDataInizio = zero(dateObj.getDate(), 2) + '/' + zero((dateObj.getMonth() + 1), 2) + '/' + zero(dateObj.getFullYear(), 4);

        } else {

            dateObj.setMonth(0);
            dateObj.setDate(vetValue[1]); // 1-31
            dateObj.setMonth(vetValue[0] - 1); // 0-11 Month within the year (January = 0)
            VisValuDataInizio = zero((dateObj.getMonth() + 1), 2) + '/' + zero(dateObj.getDate(), 2) + '/' + zero(dateObj.getFullYear(), 4);

        }

        if (strFormat.length == 10)
            strValTemp = strValTemp + 'T00:00:00';
        if (strFormat.length == 13)
            strValTemp = strValTemp + '00:00';
        if (strFormat.length == 16)
            strValTemp = strValTemp + '00';

        SetDataValue('RDA_DataCreazione', strValTemp, VisValuDataInizio);

		*/
		

        //se TipoScadenzaOrdinativo uguale duratafissata calcolo in automatico data scadenza = data inizio + numero mesi indicati sulla convenzione
		
		/*
		
			Togliere il calcolo della data scadenza se tipo scadenza è "Durata Fissata"
		
			if (getObj('TipoScadenzaOrdinativo').value == 'duratafissata') 
			{

				dateObj = new Date();

				strNumeroMesi = getObj('NumeroMesi').value;
				var paramdata = 'ADD,m,' + strNumeroMesi;
				strVal2 = GetDataServer('../../', paramdata);

				aInfoData = strVal2.split('T');

				strValTemp = aInfoData[0];
				strValTime = aInfoData[1]
				var vetValue = strValTemp.split('-');

				if (strFormat.substr(0, 10).toLowerCase() == 'dd/mm/yyyy') {

					dateObj.setMonth(0);
					dateObj.setDate(vetValue[0]); // 1-31
					dateObj.setMonth(vetValue[1] - 1); // 0-11 Month within the year (January = 0)
					VisValuDataInizio = zero(dateObj.getDate(), 2) + '/' + zero((dateObj.getMonth() + 1), 2) + '/' + zero(dateObj.getFullYear(), 4);

				} else {

					dateObj.setMonth(0);
					dateObj.setDate(vetValue[1]); // 1-31
					dateObj.setMonth(vetValue[0] - 1); // 0-11 Month within the year (January = 0)
					VisValuDataInizio = zero((dateObj.getMonth() + 1), 2) + '/' + zero(dateObj.getDate(), 2) + '/' + zero(dateObj.getFullYear(), 4);

				}

				strValTemp = strValTemp + 'T00:00:00';
				SetDataValue('RDA_DataScad', strValTemp, VisValuDataInizio);

			}
			
		*/

    }

    PrintPdfSign('TABLE_SIGN=CTL_DOC&URL=/report/prn_OrdinativoFornitura.ASP?SIGN=YES&PDF_NAME=Ordinativo di Fornitura&PROCESS=ODC%40%40%40CAN_GENERA_PDF:-1:CHECKOBBLIG');

}

window.onload = Init_ODC;

function Init_ODC() {

	if ( typeof idpfuUtenteCollegato == 'undefined' )
		tmp_idpfuUtenteCollegato = getObjValue('IdpfuInCharge');
	else
		tmp_idpfuUtenteCollegato = idpfuUtenteCollegato;
	
    //se senza quote nascondo ResiduoQuote
    if (getObj('GestioneQuote').value == 'senzaquote') 
	{
        $("#cap_ImportoQuota").parents("table:first").css({
                "display": "none"
            })
            // getObj('cap_ImportoQuota').style.display='none';
            // getObj('Cell_ImportoQuota').style.display='none';

        //DA FARE devo togliere la classe alla tabella contenitore che è senza id
    }
	if (getObj('PO_ORIGINARIO').value == '') 
	{
		$("#cap_PO_ORIGINARIO").parents("table:first").css({
                "display": "none"
            })
	}
    //inizializzo i campi GEO
    initAziEnte();

    //inizializzo il genera pdf
    Init_Firma_ODC();

    //inizializza la sezione prodotti
    DOCUMENTAZIONE_OnLoad();

    //aggiorno la griglia del carrello in memoria se il documento è InLavorazione/InApprovazione
    //alert('aggiorno griglia carrello');

    ExecDocCommandInMem('PRODOTTI#RELOAD', tmp_idpfuUtenteCollegato, 'CARRELLO');



    //se TipoScadenzaOrdinativo sulla convenzione =immediatamenteesecutivo
    //nascondo data sacdenza ordinativo
    if (getObj('TipoScadenzaOrdinativo').value == 'immediatamenteesecutivo') {
        $("#cap_RDA_DataScad").parents("table:first").css({
            "display": "none"
        })
    }



    //se tipoimporto è ivainclusa o esente nascondo valoreiva e totaleordinativocon iva
    //if ( getObj('TipoImporto').value == 'esente' || getObj('TipoImporto').value == 'ivainclusa' ){
    if (getObj('TipoImporto').value == 'esente') {
        $("#cap_ValoreIva").parents("table:first").css({
            "display": "none"
        })
        $("#cap_TotalIva").parents("table:first").css({
            "display": "none"
        })
    }


    //se il doc non è in lavorazione non posso cancellare articoli
    if (getObj('StatoFunzionale').value != 'InLavorazione')
        ShowCol('PRODOTTI', 'FNZ_DEL', 'none');
		
		
	//se senza TipoScadenzaOrdinativo non è a duratafissata nasconde il campo numeromesi
    if (getObj('TipoScadenzaOrdinativo').value != 'duratafissata') 
	{
       $("#cap_NumeroMesi").parents("table:first").css({"display": "none"})
    }
	
	
	if (getObj('DOCUMENT_READONLY').value == '0' && getObj('StatoFunzionale').value == 'InLavorazione') 
	{
		var strNotEdit = getObjValue('NotEditable');

		//Applico il filterdom solo se il campo cig_madre è editabile
		if ( strNotEdit.indexOf(' CIG_MADRE ') < 0 )
		{
			var filter =  'SQL_WHERE= idHeader = \'' + getObj( 'Id_Convenzione' ).value +  '\' ';
			FilterDom( 'CIG_MADRE' , 'CIG_MADRE' ,  getExtraAttrib( 'val_CIG_MADRE', 'value' ) , filter ,'', '');
		}
		
		
	}
	
	if (getObj('DOCUMENT_READONLY').value == '0' )
	{
		getObj( 'CIG' ).onchange = 	onChangeCigDerivato;
	}

}



function Init_Firma_ODC() {
    var JumpCheck = '';
    var StatoFunzionale = '';

    StatoFunzionale = getObjValue('StatoFunzionale');
    JumpCheck = getObj('JumpCheck').value;
	
	//if ( idpfuUtenteCollegato == undefined )
	//	var idpfuUtenteCollegato = getObjValue('IdpfuInCharge');

    if (getObj('RichiediFirmaOrdine').value == '1') {

        if ((getObjValue('SIGN_LOCK') == '0' || getObjValue('SIGN_LOCK') == '') && (StatoFunzionale == 'InLavorazione' || StatoFunzionale == 'InApprove') && getObj('IdpfuInCharge').value == tmp_idpfuUtenteCollegato) {
            document.getElementById('generapdf').disabled = false;
            document.getElementById('generapdf').className = "generapdf";
        } else {
            document.getElementById('generapdf').disabled = true;
            document.getElementById('generapdf').className = "generapdfdisabled";
        }

        if (getObjValue('SIGN_LOCK') != '0' && (StatoFunzionale == 'InLavorazione' || StatoFunzionale == 'InApprove') && getObj('IdpfuInCharge').value == tmp_idpfuUtenteCollegato) {
            document.getElementById('editistanza').disabled = false;
            document.getElementById('editistanza').className = "attachpdf";
        } else {
            document.getElementById('editistanza').disabled = true;
            document.getElementById('editistanza').className = "attachpdfdisabled";
        }

        if (getObjValue('SIGN_ATTACH') == '' && (StatoFunzionale == 'InLavorazione' || StatoFunzionale == 'InApprove') && getObjValue('SIGN_LOCK') != '0' && getObj('IdpfuInCharge').value == tmp_idpfuUtenteCollegato) {
            document.getElementById('attachpdf').disabled = false;
            document.getElementById('attachpdf').className = "editistanza";
        } else {
            document.getElementById('attachpdf').disabled = true;
            document.getElementById('attachpdf').className = "editistanzadisabled";
        }
    } else {

        getObj('DIV_FIRMA').style.display = 'none';

    }

}




function impostaLocalita(cod, fieldname) {
    ajax = GetXMLHttpRequest();

    var comuneTec;
    var provinciaTec;
    var statoTec;
    var comuneDesc;
    var provinciaDesc;
    var statoDesc;

    if (fieldname == 'consegna') {
        comuneTec = 'ReferenteLocalita2';
        provinciaTec = 'ReferenteProvincia2';
        statoTec = 'ReferenteStato2';
        comuneDesc = 'ReferenteLocalita';
        provinciaDesc = 'ReferenteProvincia';
        statoDesc = 'ReferenteStato';
        geo = 'apriGEO';
    }

    if (fieldname == 'fatturazione') {
        comuneTec = 'FatturazioneLocalita2';
        provinciaTec = 'FatturazioneProvincia2';
        statoTec = 'FatturazioneStato2';
        comuneDesc = 'FatturazioneLocalita';
        provinciaDesc = 'FatturazioneProvincia';
        statoDesc = 'FatturazioneStato';
        geo = 'apriGEO2';
    }


    if (ajax) {
        ajax.open("GET", '../../ctl_library/functions/infoNodoGeo.asp?fldname=localita&cod=' + escape(cod), false);
        //output nella forma : COD-COMUNE#@#DESC-COMUNE#@#COD-PROVINCIA#@#DESC-PROVINCIA#@#COD-STATO#@#DESC-STATO
        ajax.send(null);

        if (ajax.readyState == 4) {
            //Se non ci sono stati errori di runtime
            if (ajax.status == 200) {
                if (ajax.responseText != '') {
                    var res = ajax.responseText;

                    //Se l'esito della chiamata è stato positivo
                    if (res.substring(0, 2) == '1#') {
                        try {
                            var vet = res.substring(4).split('#@#');

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

                            if (codLoc == '' || codLoc.substring(codLoc.length - 3, codLoc.length) == 'XXX')
								disableGeoField(comuneDesc, false);
                            else
								disableGeoField(comuneDesc, true);

                            getObj(provinciaTec).value = codProv;
                            getObj(provinciaDesc).value = descProv;

                            if (codProv == '' || codProv.substring(codProv.length - 3, codProv.length) == 'XXX')
								disableGeoField(provinciaDesc, false);
                            else
								disableGeoField(provinciaDesc, true);

                            getObj(statoTec).value = codStato;
                            getObj(statoDesc).value = descStato;

                            if (codStato == '' || codStato.substring(codStato.length - 3, codStato.length) == 'XXX')
								disableGeoField(statoDesc, false);
                            else
								disableGeoField(statoDesc, true);

                        } catch (e) {
                            alert('Errore:' + e.message);

                        }
                    } else {
                        alert('errore.msg:' + res.substring(2));
                        enableDisableAziGeo(comuneDesc, provinciaDesc, statoDesc, geo, false);
                    }
                }
            } else {
                alert('errore.status:' + ajax.status);
                enableDisableAziGeo(comuneDesc, provinciaDesc, statoDesc, geo, false);

            }
        } else {
            alert('errore in impostaLocalita');
            enableDisableAziGeo(comuneDesc, provinciaDesc, statoDesc, geo, false);
        }
    }
}



function initAziEnte() {
    enableDisableAziGeo('ReferenteLocalita', 'ReferenteProvincia', 'ReferenteStato', 'apriGEO', true);
    enableDisableAziGeo('FatturazioneLocalita', 'FatturazioneProvincia', 'FatturazioneStato', 'apriGEO2', true);
}



function TogliFirma() {
    //DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );	
    if (confirm(CNV('../../', 'Si sta per eliminare il file firmato.')))
        ExecDocProcess('ODC_SIGN_ERASE,FIRMA');
}

function MyDeleteArticolo(objGrid, Row, c) {

    //setto statoriga a deleted sulla riga

    getObj('R' + Row + '_StatoRiga').value = 'deleted';

    ExecDocProcess('ELIMINARIGA,ODC');


}

function validateCodiceIPA(obj) {

    //validateField( '^[\\dA-Z]{6,6}$', obj , false )

}




function Doc_DettagliDel(grid, r, c) {
    var v = '0';
    try {
        v = getObj('RDOCUMENTAZIONEGrid_' + r + '_Obbligatorio').value;
    } catch (e) {};

    if (v == '1') {
        //DMessageBox( '../' , 'La documentazione è obbligatoria' , 'Attenzione' , 1 , 400 , 300 );
    } else {
        DettagliDel(grid, r, c);
    }
}

function DOCUMENTAZIONE_OnLoad() {
    DOCUMENTAZIONE_AFTER_COMMAND();
}

function DOCUMENTAZIONE_AFTER_COMMAND() {
    HideCestinodoc();
    FormatAllegato();

}

function HideCestinodoc() {
    try {
        var i = 0;

        if (getObj('DOCUMENT_READONLY').value == '0') {
            for (i = 0; i < DOCUMENTAZIONEGrid_EndRow + 1; i++) {
                if (getObj('RDOCUMENTAZIONEGrid_' + i + '_Obbligatorio').value == '1') {
                    getObj('DOCUMENTAZIONEGrid_r' + i + '_c0').innerHTML = '&nbsp;';
                }
            }
        }
    } catch (e) {}

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
            tipofile = 'FORMAT=' + tipofile;

            if (richiestaFirma == '1') {
                tipofile = tipofile + 'VB'; //format per forzare la verifica di firma bloccante in caso di mancata firma o file corrotto
            }

            obj = getObj('RDOCUMENTAZIONEGrid_' + i + '_Allegato_V_BTN').parentElement;
            onclick = obj.innerHTML;
            onclick = onclick.replace('FORMAT=INT', tipofile);
            obj.innerHTML = onclick;

        } catch (e) {}
    }

}

function VerificaAllegati() {
    var err = 0;
    //controllo la prensenza di allegati nella sezione della documentazione
    var numeroRigheDOC = GetProperty(getObj('DOCUMENTAZIONEGrid'), 'numrow');

    for (i = 0; i <= numeroRigheDOC; i++) {
        try {

            if (getObjValue('RDOCUMENTAZIONEGrid_' + i + '_Allegato') == '') {
                err = 1;
            }


        } catch (e) {}
    }
    return err;
}

function RefreshContent()
{
	if ( isSingleWin() == false )
	{
		ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');
	}
}


function ChangePO(){
	ExecDocProcess( 'CHANGEPO,ODC,,NO_MSG');	
}

/* INIZIO GESTIONE SIMOG */

function onChangeRichiestaSimog()
{
	var docRichiestaCig;
	var RichiestaCigSimog;
	
	if ( getObj('docRichiestaCig') )
	{
		docRichiestaCig = getObjValue('docRichiestaCig');
		RichiestaCigSimog = getObjValue('RichiestaCigSimog');
		
		/* SE E' PRESENTE UN DOCUMENTO DI RICHIESTA CIG E SI STA PASSANDO ALLA SCELTA DI NON AVERE L'INTEGRAZIONE CON IL SIMOG */
		if ( docRichiestaCig == '1' && RichiestaCigSimog == 'no' )
		{
			//Setto preventivamente il valore al suo precedente per evitare che se l'utente clicca sulla 'X' della finestra modale 
			//riesca a cambiare la scelta senza attivare il processo di onChange
			getObj('RichiestaCigSimog').value = 'si';
			
			var ml_text = 'Cambiando questa scelta verranno annullate tutte le richieste SIMOG effettuate su ODC. Proseguire ?';
			var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ml_text ) +'&CAPTION=Informazione&ICO=1';
			
			ExecFunctionModaleConfirm( page, null , 200 , 420 , null , 'confermaCambioRichiestaSimog' );
		}
		else
		{
			if ( RichiestaCigSimog == 'no' )
				ExecDocProcess('CAMBIA_RICHIESTA_SIMOG_NO,SIMOG');
			else
				ExecDocProcess('CAMBIA_RICHIESTA_SIMOG_SI,SIMOG');	
		}
	}
}

/* FINE GESTIONE SIMOG */


function confermaCambioRichiestaSimog()
{
	//Ripristino la scelta dell'utente
	getObj('RichiestaCigSimog').value = 'no';
	
	ExecDocProcess('CAMBIA_RICHIESTA_SIMOG_NO,SIMOG');
	
}

function onChangeUserRUP(obj)
{
	//Salvataggio del documento
	//ExecDocProcess('CAMBIO_RUP,DOCUMENT');
	
	var RichiestaCigSimog = getObjValue('RichiestaCigSimog');
	var StrValueRup = getObj('idpfuRup').value;
	var ObjCigDerivato = getObj('CIG');
	
	//se valorizzato anche idpfurup (RUP) e richiesta cig simog = no allora innesco un processo che effettua 
	// verifica sincrona del CIG - RUP e se positiva conserva nella ctl_doc_value
    // CIG_VALIDO_SUL_SIMOG , CIG_CONTROLLATO, RUP_CONTROLLATO
	if ( RichiestaCigSimog == 'no' && StrValueRup != '' && ObjCigDerivato.value != '' && IsSmartCIg( ObjCigDerivato.value ) == 0 )
		ExecDocProcess('VERIFICA_CIG_DERIVATO_SIMOG,ODC,,NO_MSG');
	else
		ExecDocProcess('CAMBIO_RUP,DOCUMENT,,NO_MSG');
	
}


function VerificaObbligoCigDerivato()
{
	
	var  bRet = true;
	
	var strKey_ML = '';
	
	//se il campo "Obbligo Cig Derivato" = si "Cig Derivato" obbligatorio
	if ( getObj('Obbligo_Cig_Derivato').value == 'si' && getObj('CIG').value == '' )
	{	

		if ( getObjValue( 'RichiestaCigSimog' ) == 'si' )
		{
			strKey_ML = 'Attenzione, se Obbligo Cig Derivato = si occorre procedere con la richiesta del Cig Derivato sul SIMOG', 'Attenzione';
		
		}
		else
		{

			strKey_ML = 'Attenzione, Se Obbligo Cig Derivato = si valorizzare il campo Cig Derviato';
			getObj('CIG').focus();
		}
		bRet = false ;
	}
	
	
	//se il campo "Obbligo Cig Derivato" = no "Motivazione" obbligatorio
	if ( getObj('Obbligo_Cig_Derivato').value == 'no' && getObj('Motivazione_ObbligoCigDerivato').value == '' )
	{	
		strKey_ML = 'Attenzione, Se Obbligo Cig Derivato = no valorizzare il campo Motivazione';
		getObj('Motivazione_ObbligoCigDerivato').focus();
		bRet = false ;
	}
	
	
	if ( ! bRet )
	{	
		DMessageBox('../', strKey_ML , 'Errore', 2, 400, 300);
	}	
	
	return bRet;
	
	
}	

function onChangeObbligoCigDerivato()
{
	var docRichiestaCig;
	var RichiestaCigSimog;
	var ObbligoCigDerivato ;
	
	docRichiestaCig = getObjValue('docRichiestaCig');
	
	ObbligoCigDerivato = getObj('Obbligo_Cig_Derivato').value;
	
	RichiestaCigSimog = getObjValue('RichiestaCigSimog');
	
	
	//alert(docRichiestaCig);
	/* SE STO SETTANDO Obbligo_Cig_Derivato A NO e RichiestaCigSimog vale SI 
	   SE E' PRESENTE UN DOCUMENTO DI RICHIESTA CIG ALLORA CHIEDO CONFERMA PRIMA DI PROCEDERE
	   SE L'UTENTE CONFERMA VADO AD ANNULLARE EVENTUALI RICHIESTE CIG INVIATE 	
	*/
	if ( ObbligoCigDerivato == 'no' && docRichiestaCig == '1' && RichiestaCigSimog == 'si' )
	{
		
		getObj('Obbligo_Cig_Derivato').value = 'si';
		
		var ml_text = 'Cambiando questa scelta verranno annullate tutte le richieste SIMOG effettuate su ODC. Proseguire ?';
		var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ml_text ) +'&CAPTION=Informazione&ICO=1';
		
		ExecFunctionModaleConfirm( page, null , 200 , 420 , null , 'confermaCambioObbligoCigDerivato' );
	}
	else
	{
		ExecDocProcess('CHANGE_OBBLIGO_CIG_DERIVATO,ODC,,NO_MSG' );
	}
		
	
	
	
}


function confermaCambioObbligoCigDerivato()
{
	
	getObj('Obbligo_Cig_Derivato').value = 'no';
	
	ExecDocProcess('CHANGE_OBBLIGO_CIG_DERIVATO,ODC');
	
}

function onChangeCigDerivato()
{
	var RichiestaCigSimog = getObjValue('RichiestaCigSimog');
	var ObjCigDerivato = getObj('CIG');
	var StrValueRup = getObj('idpfuRup').value;
	
	
	if ( validateExtCig( ObjCigDerivato , false ) ) 
	{
	  //se non si tratta di uno SMART CIG
	  if ( IsSmartCIg( ObjCigDerivato.value ) == 0 )
	  {
		  //se valorizzato anche idpfurup (RUP) e richiesta cig simog = no allora innesco un processo che effettua 
		  // verifica sincrona del CIG - RUP e se positiva conserva nella ctl_doc_value
		  // CIG_VALIDO_SUL_SIMOG , CIG_CONTROLLATO, RUP_CONTROLLATO
		  if ( RichiestaCigSimog == 'no' && StrValueRup != ''  )
			  ExecDocProcess('VERIFICA_CIG_DERIVATO_SIMOG,ODC,,NO_MSG');
	  
	 }
	}
	else
	{
		DMessageBox( '../ctl_library/' , 'Valore CIG Derivato non ammesso' , 'Attenzione' , 2 , 400 , 300 );
	}

}


function afterProcess(param)
{
	//se stato eseguito iol processo VERIFICA_CIG_DERIVATO_SIMOG vado ad eseguire quello per completarlo
	if ( param == 'VERIFICA_CIG_DERIVATO_SIMOG')
		ExecDocProcess('AFTER_VERIFICA_CIG_DERIVATO_SIMOG,ODC,,NO_MSG');
}

