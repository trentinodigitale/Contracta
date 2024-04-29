function MyRefresh() 
{

	// Cambio la label "Registro di sistema Bando" in "Registro di sistema Bando SDA" solo se i quesiti sono riferiti ad uno SDA
	var strTypeDoc;

	if ( getObj('DOCUMENT') )
	{
	
		strTypeDoc = getObjValue('DOCUMENT');
		
		if ( strTypeDoc == 'BANDO_SDA')
		{
			try
			{
				getObj('cap_Static10').innerHTML = CNV( pathRoot , 'Registro di sistema Bando SDA' );
			}
			catch(e){}
		}
	
	}
	
	try
	{
		//Se il documento collegato è un rdo cambio la label e l'etichetta dei campi
		var tipoGara = getObjValue('TipoGara');
		
		if ( tipoGara == 'RDO' )
		{
			getObj('cap_Static10').innerHTML = CNV( pathRoot , 'Rdo' );
			getObj('cap_Oggetto').innerHTML = CNV( pathRoot , 'Oggetto' );
		}
			
	}
	catch(e)
	{
	}

	
    /*aggiorno i campi nel document opener
	telefono
	fax
	mail
	domanda
	risposta
	allegato
	
	ProtocolloGenerale
	*/

    var numRow;
    var IDDOC;

    IDDOC = getObj('IDDOC').value;


	try
	{
		//determino la riga interessata in base a iddoc
		numRow = eval('self.opener.ELENCOGrid_NumRow');

		for (i = 0; i <= numRow; i++) {
			if (self.opener.getObj('R' + i + '_ELENCOGrid_ID_DOC').value == IDDOC)
				break;
		}
		
	}
	catch(e)
	{
	}

    try {
        self.opener.SetTextValue('R' + i + '_aziTelefono1', getObj('aziTelefono1').value);
    } catch (e) {}
    try {
        self.opener.SetTextValue('R' + i + '_aziFAX', getObj('aziFAX').value);
    } catch (e) {}
    try {
        self.opener.SetTextValue('R' + i + '_aziE_Mail', getObj('aziE_Mail').value);
    } catch (e) {}

    try {
        self.opener.SetTAValue('R' + i + '_Domanda', getObj('Domanda').value);
    } catch (e) {}

    try {
        self.opener.SetTAValue('R' + i + '_Risposta', getObj('Risposta').value);
    } catch (e) {}

    try {
        self.opener.SetTAValue('R' + i + '_ProtocolloGenerale', getObj('ProtocolloGenerale').value);
    } catch (e) {}



    try {
        if (getObj('ChiarimentoEvaso').checked == true) {
            self.opener.document.getElementById('R' + i + '_ChiarimentoEvaso').checked = true;

        } else {
            self.opener.document.getElementById('R' + i + '_ChiarimentoEvaso').checked = false;
        }
    } catch (e) {}
    try {
        if (getObj('ChiarimentoPubblico').value == 1) {
            self.opener.document.getElementById('R' + i + '_ChiarimentoPubblico').checked = true;
        } else {
            self.opener.document.getElementById('R' + i + '_ChiarimentoPubblico').checked = false;
        }
    } catch (e) {}

    //try{self.opener.SetTAValue( 'R' + i + '_ChiarimentoEvaso'  , getObj('ChiarimentoEvaso').value );}catch(e){}		
    //try{self.opener.SetTAValue( 'R' + i + '_ChiarimentoPubblico'  , getObj('ChiarimentoPubblico').value );}catch(e){}		


    try {
        self.opener.SetAttachValue('R' + i + '_Allegato', getObj('Allegato').value, getObj('Allegato_V_N').outerHTML);
    } catch (e) {}


    //SaveDoc( '' );	
    return;
}

function MySaveDoc() {

    ExecDocProcess('SAVE,DETAIL_CHIARIMENTI_BANDO');
    MyRefresh();
    return;
}

function MyPubblica() {

    ExecDocProcess('PRE_PUBBLICA,DETAIL_CHIARIMENTI_BANDO');
    MyRefresh();
    return;
}

function MyNascondi() {

    ExecDocProcess('NASCONDI,DETAIL_CHIARIMENTI_BANDO');
    MyRefresh();
    return;
}

window.onload = MyRefresh;