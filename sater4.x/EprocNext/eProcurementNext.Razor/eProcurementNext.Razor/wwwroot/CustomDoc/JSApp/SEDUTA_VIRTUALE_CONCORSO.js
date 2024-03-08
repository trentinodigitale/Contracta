var AreeSedutaVirtuale_TimeRefresh = 600000;

window.onload = OnLoadPage;

// Funzione che aggiorna le aree Informazioni Amministrative e  Informazioni Tecnico / Economiche ( visualizzato se gara a singolo lotto )
function AggiornaAreeSedutaVirtuale() {
	debugger
    var param;
    var idDoc = getObj('IDDOC').value;

    param = 'IDDOC=' + idDoc + '&COMMAND=INFO_AMM&LOTTO=';
	
	
	//Senza blocco try_catch la pagina va in errore non avendo SV_INFO_AMM quando le info sono anonime non viene disegnato
	try
	{
		getObj('SV_INFO_AMM').innerHTML = CallAjax(param);
		
	}
	catch
	{
		
	}

    param = 'IDDOC=' + idDoc + '&COMMAND=INFO_LOTTO&LOTTO=';

    var svInfoLotto = getObj('SV_INFO_LOTTO');

    if (svInfoLotto != null) {
        svInfoLotto.innerHTML = CallAjax(param);
    }

    //AggiornaAreaLotti();
}

// function AggiornaAreaLotti()
// {
    // var idDoc = getObj('IDDOC').value;
    // var param = 'IDDOC=' + idDoc + '&COMMAND=INFO_LOTTI&LOTTO=';
    // svInfoLotto = getObj('SV_INFO_LOTTI');
    // if (svInfoLotto != null) {
        // svInfoLotto.innerHTML = CallAjax(param);
    // }
// }

// Funzione che effettua la chiamata ajax a la pagina SEDUTA_VERTULA.asp
function CallAjax(param) {

    var ritorno = '';
    ajax = GetXMLHttpRequest();

    var nocache = new Date().getTime();

    ajax.open("GET", '../../CustomDoc/SEDUTA_VIRTUALE_CONCORSO.asp?' + param + '&nocache=' + nocache, false);
    ajax.send(null);

    if (ajax.readyState == 4) {
        //alert(ajax.status); 
        if (ajax.status == 404 || ajax.status == 500) {
            alert('Errore invocazione pagina con i parametri ' + ajax.responseText);
        }
        else {
            ritorno = ajax.responseText;
        }
    }

    return ritorno;
}


function OnLoadPage() {
	
    //AttivaChat();
    AggiornaAreeSedutaVirtuale();
    window.setInterval(AggiornaAreeSedutaVirtuale, AreeSedutaVirtuale_TimeRefresh);
    // if (getObj('R0_Lista_Lotti') != null) {
        // var visualizzaListaLotti = getObj('R0_Lista_Lotti').value;
        // if (visualizzaListaLotti != 'nonvisualizza' || getObj('StatoFunzionale').value =='VERIFICA_AMMINISTRATIVA') {
            // window.setInterval(AggiornaAreaLotti, AreeSedutaVirtuale_TimeRefresh);
        // }
    // }
}

// Funzione che attiva la chat.
// function AttivaChat() {
    
	// var StatoChat = getObj('StatoChat').value;
    // //-- attivo la chat per la seduta virtuale
    // DOC_CHAT_Room = getObj('idPdA').value;

    // if (StatoChat == 'OLD') {
        // //-- se la chat è chiusa visualizzo il contenuto solo una volta
        // DOC_CHAT_UpdateWin();
    // }
    // else {
        // //-- se la conversazione è aperta aggiorno il contenuto della chat ogni TOT secondi
        // window.setInterval(DOC_CHAT_UpdateWin, CHAT_TimeRefresh);
    // }
// }

function MyOpenDocumentColumn(objGrid, row, c) 
{
    
	var lotto = '';
	
	try	{ 	lotto = getObj( 'R' + row + '_Lotto').value;	}catch( e ) {};
	
	if ( lotto == '' || lotto == undefined )
	{
		try	{ 	lotto = getObj( 'R' + row + '_Lotto')[0].value; }catch( e ) {};
	}
	
	ShowDocument( 'SEDUTA_VIRTUALE_LOTTO' , lotto );
}


function Apri_dettaglio_OffertaEconomica(objGrid, row, c) 
{
	if(getObj( 'val_R' + row + '_BustaEconomica_extraAttrib').value == 'value#=#ok')
	{
		var cod = '';
	
		try	{ 	cod = getObj( 'R' + row + '_IdOffertaLotto').value;	}catch( e ) {};
		
		if ( cod == '' || cod == undefined )
		{
			try	{ 	cod = getObj( 'R' + row + '_IdOffertaLotto')[0].value; }catch( e ) {};
		}
		
		MakeDocFrom( 'SEDUTA_VIRTUALE_LOTTO_OFFERTO#900,800#SEDUTA_VIRTUALE#' + cod );
		return;
		
	}
	else
	{
		return -1;
	}
	
}



function MybreadCrumbPop( param ){
	
	//effettuo la chiamata sulla chat per indicare l'uscita OUT dalla seduta virtuale
	//AF_CHAT_IN_OUT_USER ( DOC_CHAT_Room , 'OUT' );
	
	//chiudi documento
	breadCrumbPop('');
}

