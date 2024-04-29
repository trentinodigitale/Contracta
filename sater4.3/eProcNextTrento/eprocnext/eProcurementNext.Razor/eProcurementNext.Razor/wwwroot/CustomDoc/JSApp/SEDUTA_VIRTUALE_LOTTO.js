var AreeSedutaVirtuale_TimeRefresh = 600000;

window.onload = OnLoadPage;

// Funzione che aggiorna le aree Informazioni Amministrative e  Informazioni Tecnico / Economiche ( visualizzato se gara a singolo lotto )
function AggiornaAreeSedutaVirtuale() {
    var param;
    var idDoc = getObj('IDDOC').value;

    param = 'idDoc=' + idDoc + '&LOTTO=' + idDoc + '&COMMAND=INFO_LOTTO';

    var svInfoLotto = getObj('SV_INFO_LOTTO');

    if (svInfoLotto != null) {
        svInfoLotto.innerHTML = CallAjax(param);
    }
}

// Funzione che effettua la chiamata ajax a la pagina SEDUTA_VERTULA.asp
function CallAjax(param) {

    var ritorno = '';
    ajax = GetXMLHttpRequest();

    var nocache = new Date().getTime();

    ajax.open("GET", '../../CustomDoc/SEDUTA_VIRTUALE.asp?' + param + '&nocache=' + nocache, false);
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

function AttivaChat() {

    var StatoChat = getObj( 'StatoChat' ).value;            	 
	//-- attivo la chat per la seduta virtuale
	DOC_CHAT_Room =  getObj( 'idPdA' ).value;


	if( StatoChat == 'OLD' )
	{
		
		//-- se la chat è chiusa visualizzo il contenuto solo una volta
		DOC_CHAT_UpdateWin();
							
	}
	else
	{
		//-- se la conversazione è aperta aggiorno il contenuto della chat ogni TOT secondi
		window.setInterval ( DOC_CHAT_UpdateWin ,CHAT_TimeRefresh );

	}

}

function OnLoadPage()
{
    AttivaChat();
    AggiornaAreeSedutaVirtuale();
    window.setInterval(AggiornaAreeSedutaVirtuale, AreeSedutaVirtuale_TimeRefresh);
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