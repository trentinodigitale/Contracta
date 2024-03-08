window.onload = setdocument;

function setdocument() {
	
	
	try
	{
		//Se il documento è nello statoFunzionale di 'InAttesaTed' apriamo il documento di invio dati di rettifica TED ( fintanto che il finalizza non cambia lo stato funzionale di questo documento, cioè al completamento della rettifica ted )
		var StatoFunzionale = getObjValue('StatoFunzionale');
		
		if ( StatoFunzionale == 'InAttesaTed' )
		{
			MakeDocFrom ( 'RETTIFICA_GARA_TED##RETTIFICA' );
			return;
		}
		
	}
	catch(e)
	{
	}
	
	//attivazione meccanismo DRAG&DROP sulla griglia degli ATTI
	if(getObj('DOCUMENT_READONLY').value == '0') 
	{
		//console.log(getObjValue('DOCUMENT_READONLY'), "Entrato e attivo d&d");
		ActiveDrag();	
		
	}else
	{
		HideColDrag();
	}
	
    //nascondo i campi relativi a termine richiesta quesiti se non è una proroga del 167 oppure del BANDO_GARA

    if (getObjValue('JumpCheck') != '55;167' && getObjValue('JumpCheck') != 'BANDO_GARA' && getObjValue('Caption') != 'RichiestaQuesiti:1') {

      //risale fino alla table e la mette nascosta
		try{ getObj('DataTermineQuesiti').parentNode.parentNode.parentNode.parentNode.style.display = "none"; }catch(e){};
		try{ getObj('OLD_DataTermineQuesiti').parentNode.parentNode.parentNode.parentNode.style.display = "none"; }catch(e){};
		try {getObj('DataTermineRispostaQuesiti').parentNode.parentNode.parentNode.parentNode.style.display = "none";} catch (e) {};
		try {getObj('OLD_DataTermineRispostaQuesiti').parentNode.parentNode.parentNode.parentNode.style.display = "none";} catch (e) {};		
		
		try{ setVisibility( getObj( 'cap_DataTermineQuesiti' ) , 'none' ); }catch(e){};
		try{ setVisibility( getObj( 'cap_OLD_DataTermineQuesiti' ) , 'none' ); }catch(e){};
		try {setVisibility(getObj('cap_DataTermineRispostaQuesiti'), 'none');} catch (e) {};
		try {setVisibility(getObj('cap_OLD_DataTermineRispostaQuesiti'), 'none');} catch (e){};

		

    } 
	/*
	else {
        try {
            setClassName(getObj('cap_DataTermineQuesiti').parentNode, 'VerticalModel_ObbligCaption');
        } catch (e) {};
    }
	*/
	
	

	
	var tipoGara;
	
	try
	{
		tipoGara = getObjValue('TipoGara');
	}
	catch(e){}
	
    //if (getObjValue('FascicoloGenerale') == 'RDO' || tipoGara == 'AVVISO') 
	if (getObjValue('FascicoloGenerale') == 'RDO') 	
	{
		/*
			try 
			{
				//Modificare l’intestazione "rettifica gara" in "rettifica RDO"
				var htmlTitle;
				var titolo;
				
				titolo = CNV(pathRoot , 'Rettifica RDO');	
				htmlTitle = '<tr><td>' + titolo + '</td></tr>';
				
				getObj('CAPTION_DOCUMENT_ID').innerHTML = htmlTitle;
				
			}
			catch (e) {}
		*/
		
        try {
            getObj('OLD_DataSeduta').parentNode.parentNode.parentNode.parentNode.style.display = "none";
        } catch (e) {};
        try {
            getObj('DataSeduta').parentNode.parentNode.parentNode.parentNode.style.display = "none";
        } catch (e) {};
        try {
            setVisibility(getObj('cap_OLD_DataSeduta'), 'none');
        } catch (e) {};
        try {
            setVisibility(getObj('cap_DataSeduta'), 'none');
        } catch (e) {};

    }
	
	//se avviso cambio la caption 
	if (tipoGara == 'AVVISO'){
		
		getObj('cap_DataSeduta').innerHTML = CNV('../', 'Nuova Data Presunta Pubblicazione Invito');
		getObj('cap_OLD_DataSeduta').innerHTML = CNV('../', 'Data Presunta Pubblicazione Invito Corrente');
		
	}
	
	/*
    try 
	{
        setClassName(getObj('cap_DataSeduta').parentNode, 'VerticalModel_ObbligCaption');
    } catch (e) {};
	*/
	//se vengo da un BANDO_SEMPLIFICATO nascondo datapresentazionerisposte
	
	if (tipoGara == 'BANDO_SEMPLIFICATO')
	{
		
		//ShowField('DataPresentazioneRisposte',false);
		ShowField('DataRiferimentoInizio',false);
		ShowField('OLD_DataRiferimentoInizio',false);
		//ShowField('OLD_DataPresentazioneRisposte',false);
	}
	else
	{	
		// se non è un SEMPLIFCATO nascondo la colonna 
		ShowCol( 'ATTI_GARA' , 'EvidenzaPubblica' , 'none' );
		ShowCol( 'ATTI_GARA' , 'EvidenzaPubblica_OLD' , 'none' );
		
	}	
	
    if (getObjValue('JumpCheck') == '55;167') 
	{
		
        ShowCol('ATTI_GARA', 'Descrizione', 'none');
        ShowCol('ATTI_GARA', 'Descrizione_OLD', 'none');
    }

	
	
	
	//IMPOSTO UN EVENTO DI ONCHANGESULLEDATE PER LE QUALI E' RICHIESTO UN CONTROLLO CHE NON RICADONO IN UN FERMO SISTEMA
	//CONSERVANDO UNO PRECEDENTE SE LO TROVA		
	if (getObj('DOCUMENT_READONLY').value == '0') 
	{
		onchangepresente = GetProperty(getObj('DataTermineQuesiti_V'),'onchange');		
		if ( onchangepresente == null )
		{
			onchangepresente='';
		}
		if (  onchangepresente != '' && onchangepresente.indexOf(";",onchangepresente.length-1) < 0 )
		{
			onchangepresente=onchangepresente + ';';
		}	
		onchangepresente=onchangepresente + 'onChangeCheckFermoSistema(this);';
		getObj('DataTermineQuesiti_V' ).setAttribute('onchange', onchangepresente );		
		getObj('DataTermineQuesiti_HH_V' ).setAttribute('onchange', 'onChangeCheckFermoSistema(this);');		
		getObj('DataTermineQuesiti_MM_V' ).setAttribute('onchange', 'onChangeCheckFermoSistema(this);');	
		
		onchangepresente = GetProperty(getObj('DataPresentazioneRisposte_V'),'onchange');		
		if ( onchangepresente == null )
		{
			onchangepresente='';
		}
		if (  onchangepresente != '' && onchangepresente.indexOf(";",onchangepresente.length-1) < 0 )
		{
			onchangepresente=onchangepresente + ';';
		}	
		onchangepresente=onchangepresente + 'onChangeCheckFermoSistema(this);';
		getObj('DataPresentazioneRisposte_V' ).setAttribute('onchange', onchangepresente );		
		getObj('DataPresentazioneRisposte_HH_V' ).setAttribute('onchange', 'onChangeCheckFermoSistema(this);');		
		getObj('DataPresentazioneRisposte_MM_V' ).setAttribute('onchange', 'onChangeCheckFermoSistema(this);');	
		
		if (getObjValue('FascicoloGenerale') != 'RDO') 	
		{
			onchangepresente = GetProperty(getObj('DataSeduta_V'),'onchange');		
			if ( onchangepresente == null )
			{
				onchangepresente='';
			}
			if (  onchangepresente != '' && onchangepresente.indexOf(";",onchangepresente.length-1) < 0 )
			{
				onchangepresente=onchangepresente + ';';
			}	
			onchangepresente=onchangepresente + 'onChangeCheckFermoSistema(this);';
			getObj('DataSeduta_V' ).setAttribute('onchange', onchangepresente );		
			getObj('DataSeduta_HH_V' ).setAttribute('onchange', 'onChangeCheckFermoSistema(this);');		
			getObj('DataSeduta_MM_V' ).setAttribute('onchange', 'onChangeCheckFermoSistema(this);');	
		}

		//gestione per la data 'Nuova Data Termine Risposta Quesiti' per messaggio di warning 
		try {
			
			onchangepresente = GetProperty(getObj('DataTermineRispostaQuesiti_V'),'onchange');		
			if ( onchangepresente == null )
			{
				onchangepresente='';
			}
			if (  onchangepresente != '' && onchangepresente.indexOf(";",onchangepresente.length-1) < 0 )
			{
				onchangepresente=onchangepresente + ';';
			}	
			onchangepresente=onchangepresente + 'onChangeCheckFermoSistema(this);';
			getObj('DataTermineRispostaQuesiti_V' ).setAttribute('onchange', onchangepresente );		
			getObj('DataTermineRispostaQuesiti_HH_V' ).setAttribute('onchange', 'onChangeCheckFermoSistema(this);');		
			getObj('DataTermineRispostaQuesiti_MM_V' ).setAttribute('onchange', 'onChangeCheckFermoSistema(this);');	
		
		} catch (e) {};
	}	
	
	
    HideCestinodoc();
    Recupero_Descrizione();
	ControlloEliminato();
	
	
}

function MySend(param) 
{
    //alert(param);
    if (ControlliSend(param) == -1) return -1;
    ExecDocProcess(param);
}


function ControlliSend(param) 
{
	try
	{
		if ( getObjValue('DataTermineQuesiti') !='')
		{
			if (CheckDataOrarioOK('DataTermineQuesiti', 'Indicare un orario per il campo "' + getObj('cap_DataTermineQuesiti').innerHTML + '" diverso da zero') == -1) return -1;
			
		}
		if ( getObjValue('DataPresentazioneRisposte') !='')
		{
			if (CheckDataOrarioOK('DataPresentazioneRisposte', 'Indicare un orario per il campo "' + getObj('cap_DataPresentazioneRisposte').innerHTML + '" diverso da zero') == -1) return -1;
			
		}
		if (getObjValue('FascicoloGenerale') != 'RDO') 	
		{
			if ( getObjValue('DataSeduta') !='')
			{
				if (CheckDataOrarioOK('DataSeduta', 'Indicare un orario per il campo "' + getObj('cap_DataSeduta').innerHTML + '" diverso da zero') == -1) return -1;
				
			}		
		}
		
	}catch (e){}
}
	
function OpenBando(param) {
	
	debugger
	
    if (getObjValue('JumpCheck') == 'BANDO_GARA')
        ShowDocumentFromAttrib('BANDO_GARA,' + param);
    else if (getObjValue('JumpCheck') == 'BANDO_CONCORSO')
        ShowDocumentFromAttrib('BANDO_CONCORSO,' + param);
	else
        OpenDocGen(param);
}

function ATTI_GARA_AFTER_COMMAND() {
	
	try {
		setdocument();
	}
	catch(e){}
	
	//attivo DRAG&DROP sulla griglia degli Atti
	//ActiveGridDrag (  'ATTI_GARAGrid' , MoveAllAtti );
	
	var tipoGara;
	
	try
	{
		tipoGara = getObjValue('TipoGara');
	}
	catch(e){}
	
	if (tipoGara != 'BANDO_SEMPLIFICATO')	
	{	
		// se non è un SEMPLIFCATO nascondo la colonna 
		ShowCol( 'ATTI_GARA' , 'EvidenzaPubblica' , 'none' );
		ShowCol( 'ATTI_GARA' , 'EvidenzaPubblica_OLD' , 'none' );
	}	
	
	
}

function HideCestinodoc() {
    try {
        var i = 0;

		
        if ((getObj('StatoDoc').value == 'Saved' || getObj('StatoDoc').value == '')) {
            for (i = 0; i < 10000; i++) {
                try {
                    if (getObj('R' + i + '_Allegato_OLD').value != '' || getObj('R' + i + '_Descrizione_OLD').value != '') {
                        getObj('ATTI_GARAGrid_r' + i + '_c1').innerHTML = '&nbsp;';
                    }
                    if (getObj('R' + i + '_Allegato_OLD').value == '' && getObj('R' + i + '_Descrizione_OLD').value == '') {
                        getObj('ATTI_GARAGrid_r' + i + '_c4').innerHTML = '&nbsp;';
                    }
                    if (getObj('R' + i + '_AnagDoc').value != '')
                        getObj('R' + i + '_Descrizione').disabled = true;
                    else
                        getObj('R' + i + '_Descrizione').disabled = false;
                } catch (e) {
                    break;
                }
            }
        }
    } catch (e) {}

}

function Doc_DettagliDel(grid, r, c) {
    var v = '0';
    try {
        v = getObj('R' + r + '_Allegato_OLD').value;
    } catch (e) {};

    if (v != '') {

    } else {
        DettagliDel(grid, r, c);
    }
}


function GetXMLHttpRequest() {
    var
        XHR = null,
        browserUtente = navigator.userAgent.toUpperCase();

    if (typeof(XMLHttpRequest) === "function" || typeof(XMLHttpRequest) === "object")
        XHR = new XMLHttpRequest();
    else if (window.ActiveXObject && browserUtente.indexOf("MSIE 4") < 0) {
        if (browserUtente.indexOf("MSIE 5") < 0)
            XHR = new ActiveXObject("Msxml2.XMLHTTP");
        else
            XHR = new ActiveXObject("Microsoft.XMLHTTP");
    }
    return XHR;
};
ajax = GetXMLHttpRequest();

function GetDescrizioneAttiGara() {
    var IDDOC = '';
    IDDOC = getObj('LinkedDoc').value;

    if (ajax) {
        ajax.open("GET", '../../CustomDoc/GetDescrizioneAttiGara.asp?IDDOC=' + IDDOC, false);
        ajax.send(null);
    }
    if (ajax.readyState == 4) {
        if (ajax.status == 200) {

            try {
                if (ajax.responseText != '') {
                    arr = ajax.responseText.split("@@@");
                    for (i = 0; i < 10000; i++) {
                        try {
                            if (getObj('R' + i + '_Allegato_OLD').value != '') {
                                //getObj( 'R' + i + '_Descrizione_OLD' ).value =  arr[i];

                                SetTextValue('R' + i + '_Descrizione_OLD', arr[i]);

                            }

                        } catch (e) {
                            break;
                        }
                    }
                }
            } catch (e) {};
        }
    }

}


function Recupero_Descrizione() {
    try {
        var i = 0;
        var sentinella = '';

        if (getObjValue('JumpCheck') != '55;167') {
            if ((getObj('StatoDoc').value == 'Saved' || getObj('StatoDoc').value == '')) {
                for (i = 0; i < 10000; i++) {
                    try {
                        if (getObj('R' + i + '_Allegato_OLD').value != '') {
                            if (getObj('R' + i + '_Descrizione_OLD').value != '') {
                                sentinella = 'no'
                            }
                        }

                    } catch (e) {
                        break;
                    }
                }
            }
            if (sentinella == '') {
                GetDescrizioneAttiGara();
            }
        }
    } catch (e) {}


}


function RefreshContent() {
    RefreshDocument('');
}

function OnchangeEliminato (obj)
{
	//se scelto eliminato = si allora nasconde il contenuto della colonna NuovaDescrizione e NuovoAllegato
	
	
	
	var i = obj.id.split('_');
	var row =  i[0];
	
	if ( obj.value == 'si' )
	{
		$("#"+ row + "_Descrizione").css({	"display": "none"})
		$("#"+ row + "_Allegato_V").css({	"display": "none"})
		
	}
	if ( obj.value != 'si' )
	{
		$("#"+ row + "_Descrizione").css({	"display": "block"})
		$("#"+ row + "_Allegato_V").css({	"display": "block"})
		
	}
	


}
function ControlloEliminato()
{
	var numeroRighe = GetProperty( getObj('ATTI_GARAGrid') , 'numrow');
	for( i = 0 ; i <= numeroRighe ; i++ )
	{
		OnchangeEliminato (getObj('R'+ i + '_Eliminato'));
	}
}





function CheckDataOrarioOK(FieldData, msgVuoto) 
{
    var ORE=0;
	try
	{
		var ORARIO = getObjValue(FieldData).split('T')[1];
		var ORE = ORARIO.split(':')[0];
	}catch(e){}
	
	if ( ORE > 0 ) 
	{
		return 0;
	}
	else
	{
        
        try {
            getObj(FieldData + '_V').focus();
        } catch (e) {};
        DMessageBox('../', msgVuoto, 'Attenzione', 1, 400, 300);
        return -1;
    }

    

    
}

function onChangeCheckFermoSistema(obj)
{
	
	
	
	//INVOCAZIONE SU ONCHANGE DEL CAMPO
	try
	{
		if ( obj.name != '' && obj.name != null )
		{
			
			var NameControlloData = obj.id;
			
			NameControlloData = NameControlloData.replace('_HH_V','_V');
			NameControlloData = NameControlloData.replace('_MM_V','_V');  
			var objFieldData = getObj(NameControlloData);
			//SOLO SE DATA E ORA E MIN SONO VALORIZZATI FACCIO IL CONTROLLO DEL FERMO SISTEMA ALTRIMENTI LO FARA' IL PROCESSO DI INVIO
			//SE LO AVREI FATTO SOLO CON LA DATA RISCHIAMO DI NON CONSENTIRE AGLI UTENTI DI METTERE UN ORARIO OLTRE IL FERMO SISTEMA
			NameControlloORA = NameControlloData.replace('_V','_HH_V');  	
			NameControlloMIN = NameControlloData.replace('_V','_MM_V');  				
			if (  getObj(NameControlloData).value != '' && getObj(NameControlloORA).value != '' && getObj(NameControlloMIN).value != '' )
			{
				//passo come parametro anche il warning a 'si'
				Get_CheckFermoSistema ( '../../', objFieldData, 'si' );				
				
				
			}
			
		}
		
	}catch(e){}
}


function ActiveDrag ()
{
	//attivo DRAG&DROP sulla griglia degli Atti
	ActiveGridDrag (  'ATTI_GARAGrid' , MoveAllAtti );
}

function HideColDrag ()
{
	//nascondo drag_drop quando non editabile
	ShowCol( 'ATTI_GARA' , 'FNZ_DRAG' , 'none' );
	ShowCol( 'ATTI_GARA' , 'FNZ_COPY' , 'none' );
	ShowCol( 'ATTI_GARA' , 'FNZ_UPD' , 'none' );
}

function ClickDown( grid , r , c )
{
	MoveAllAtti(  r , 1 )
	
	
}

function ClickUp( grid , r , c )
{
	MoveAllAtti(  r , -1 )
	
}

//funzione che sposta tutti campi della griglia
function MoveAllAtti(  r , verso )
{

	move_Descrizione_Atti( 'Descrizione' , r  , verso );
	
	
	move_Descrizione_Atti( 'Descrizione_OLD' , r  , verso );

	
	Move_FNZ_DEL( 'FNZ_DEL' , r  , verso );
	
	Move_Eliminato( 'Eliminato' , r  , verso );
	
	
	Move_Abstract( '', 'EvidenzaPubblica' , r  , verso );
	
	
	Move_Abstract( '', 'EvidenzaPubblica_OLD' , r  , verso );
	Move_Abstract( '', 'AnagDoc' , r  , verso );
	Move_Abstract( '', 'NotEditable' , r  , verso );
	
	move_Allegati_Atti( 'Allegato' , r  , verso );
	move_Allegati_Atti( 'Allegato_OLD' , r  , verso );
	

}

//inverte il campo descrizione di due righe
//contemplando anche i casi in cui su una riga il campo è editabile e su un'altra no
function move_Descrizione_Atti( field , row , verso ) 
{

	try
    {
        var f1 = getObj( 'R' + row + '_' + field );
        var f2 = getObj( 'R' + ( row + verso ) + '_' + field ) ;
        var app;
		
		var f1_edit =0 ;
		var f2_edit =0 ;
		
		
		
		f1_V = getObj( 'R' + row + '_' + field + '_V');
			
		if ( f1_V == null ){
			
			f1_edit = 1 ; 
		}
		
		f2_V = getObj( 'R' + ( row + verso ) + '_' + field + '_V') ;
		
		
		if ( f2_V == null ){
			
			f2_edit = 1 ;
		}
		
		//alert(f1_edit + '---' + f2_edit);
		//sorgente non editabile e destinazione editabile
		if ( f1_edit != f2_edit )
		{
			if ( f1_edit == 0)
			{	
				
				
				//la destinazione diventa non editabile con il valore di f1
				f2.parentNode.innerHTML = Descrizione_NotEditable ( field , ( row + verso )  , f1.value );
				
				
				//la sorgente diventa editabile con il valore di f2
				f1.parentNode.innerHTML =  Descrizione_Editable (   field,  row  , f2.value );
				
			}
			else
			{	
				
				
				//la destinazione diventa  editabile con il valore di f1
				f2.parentNode.innerHTML = Descrizione_Editable ( field , ( row + verso )  , f1.value );
				
				
				//la sorgente diventa non editabile con il valore di f2
				f1.parentNode.innerHTML =  Descrizione_NotEditable ( field,    row  , f2.value );
				
			}
			
		}
		else
		{
			
			//inverte i valori dei campi (visuali/nascosti) se entrambi editabili oppure no
			app = f1.value;
			f1.value = f2.value;
			f2.value = app;
			
			//alert(f1.value);
			//alert(f2.value);
			
			f1 = getObj( 'R' + row + '_' + field + '_V');
			f2 = getObj( 'R' + ( row + verso ) + '_' + field + '_V') ;


			app = f1.value;
			
			f1.value = f2.value;
			f2.value = app
			
			if ( app == undefined )
			{
				try{
					app = f1.innerHTML;
					
					f1.innerHTML = f2.innerHTML;
					f2.innerHTML = app;
					
				}catch(e){}
			}
		}
		
	}
	catch(e)
	{
	}
}


function move_Allegati_Atti( field , row , verso ) 
{
	//parte tecnica
	var f1 = getObj( 'R' + row + '_' + field );
	var f2 = getObj( 'R' + ( row + verso ) + '_' + field ) ;
	var app;
	var f1_empty = 0;
	var f2_empty = 0;
	app = f1.value;

	f1.value = f2.value;
	f2.value = app;
	
	//per gestire la parte visuale allegato
	try{
		//DIV_RDOCUMENTAZIONEGrid_0_Allegato_Multivalore se contiene un valore 
		//DIV_RDOCUMENTAZIONEGrid_1_Allegato_ATTACH_EMPTY se vuoto
		f1 = getObj( 'DIV_R' + row + '_' + field + '_Multivalore');
		//se non presente allora vuol dire che è vuoto
		if ( f1 == undefined )
		{
			
			f1 = getObj( 'DIV_R' + row + '_' + field + '_ATTACH_EMPTY');
			
			f1_empty = 1 ;
		}
		
		f2 = getObj( 'DIV_R' + ( row + verso ) + '_' + field + '_Multivalore') ;
		//se non presente allora vuol dire che è vuoto
		if ( f2 == undefined )
		{
			f2 = getObj( 'DIV_R' + ( row + verso ) + '_' + field + '_ATTACH_EMPTY');
			
			f2_empty = 1
		}
		
		app = f1.innerHTML;
		//alert(app);
		f1.innerHTML = f2.innerHTML;
		f2.innerHTML = app
		
		//inverto le classi di stile se uno dei 2 era vuoto
		if ( f1_empty != f2_empty )
		{
			//recupero classe di f1
			//recupero classe di f2
			strClassf1 = GetProperty(f1, 'class') ;
			strClassf2 = GetProperty(f2, 'class') ;
			SetProperty(f1, 'class', strClassf2) ;
			SetProperty(f2, 'class', strClassf1) ;
		}
		
		
		//inverto le div del bottone per selezionare l'allegato
		//DIV_RDOCUMENTAZIONEGrid_1_Allegato_BTN
		f1 = getObj( 'DIV_R' + row + '_' + field + '_BTN');
		f2 = getObj( 'DIV_R' + ( row + verso ) + '_' + field + '_BTN') ;
			
		app = f1.innerHTML;
		//alert(app);
			
		f1.innerHTML = f2.innerHTML;
		f2.innerHTML = app;
		
		//cambio il nome del campo per associarlo alla riga giusta
		f1.innerHTML = ReplaceExtended ( f1.innerHTML,  'R' + ( row + verso ) + '_' + field , 'R' + row + '_' + field  ) ;
		f2.innerHTML = ReplaceExtended ( f2.innerHTML,  'R' +  row  + '_' + field , 'R' + ( row + verso ) + '_' + field  ) ;
	}catch(e){}
}



function Descrizione_NotEditable ( field, rowRiga , strValue )
{
	var StrHtml =''
	StrHtml = '<span class="Text" id="R' + rowRiga + '_' + field + '_V">' +  strValue + '</span>';
	StrHtml = StrHtml  + '<input type="hidden" name="R' +  rowRiga  + '_' + field + '" id="R' +  rowRiga  + '_' + field + '" value="' + strValue + '">';
	return StrHtml;
}	

function Descrizione_Editable ( field, rowRiga , strValue )
{
	var StrHtml =''
	StrHtml = '<input type="text" name="R' +  rowRiga  + '_' + field + '" id="R' +  rowRiga  + '_' + field + '" class="Text" maxlength="250" size="50" value="' + strValue + '">';
	return StrHtml;
}


function Move_FNZ_DEL( field , row , verso ) 
{
	//se il campo è editabile (esiste l'icona e lo script per fare l'azione)
	//non devo fare nulla
		//se uno dei due è diverso cioè 1 editabile e l'altro no
		//per tutti e due sali alla TD padre che lo contiene
			//in uno ci metti innerHTML di quello editabile modificato (Doc_DettagliDel('ATTI_GARAGrid' , 2 , 1 )  con Doc_DettagliDel('ATTI_GARAGrid' , 1 , 1 ) )
				//nell'altro non ci deve mettere niente 
	try
    {
		
        var f1 = getObj( 'R' + row + '_' + field );
        var f2 = getObj( 'R' + ( row + verso ) + '_' + field ) ;
        var app;
		
		var f1_edit =0 ;
		var f2_edit =0 ;
		
		
			
		if ( f1 != null ){
			
			f1_edit = 1 ; 
		}
		
		
		if ( f2 != null ){
			
			f2_edit = 1 ;
		}
		
	
		//sorgente non editabile e destinazione editabile
		if ( f1_edit != f2_edit )
		{
			if ( f1_edit == 0)
			{	
				//recupero td che contiene f1
		        //<td id="ATTI_GARAGrid_r1_c1" class="GR1_FLbl nowrap">&nbsp;</td>
				f1_parent = getObj( 'ATTI_GARAGrid_r' + row + '_c1' );

				
				//la destinazione diventa non editabile con il valore di f1
				f2.parentNode.innerHTML = Move_FNZ_DEL_NotEditable ( field , ( row + verso ));
				//alert(Move_FNZ_DEL_NotEditable ( field , ( row + verso )));
				
				//la sorgente diventa editabile con il valore di f2
                //alert(Move_FNZ_DEL_Editable (   field,  row  ));
				f1_parent.innerHTML =  Move_FNZ_DEL_Editable (   field,  row );
			}
			else
			{	
				//recupero td che contiene f2
			    f2_parent = getObj( 'ATTI_GARAGrid_r' + ( row + verso ) + '_c1' );

				//la destinazione diventa  editabile con il valore di f1
				//alert(Move_FNZ_DEL_Editable ( field , ( row + verso )));
				f2_parent.innerHTML = Move_FNZ_DEL_Editable ( field , ( row + verso ));
				
				//la sorgente diventa non editabile con il valore di f2
				f1.parentNode.innerHTML =  Move_FNZ_DEL_NotEditable ( field,    row  );
				//alert(Move_FNZ_DEL_NotEditable ( field,    row ));
			}
			
		}
	}
	catch(e)
	{
	}
}

function Move_FNZ_DEL_NotEditable ( field, row )
{
	var StrHtml =''
	//StrHtml = '<table id="R' +  rowRiga  + '_' + field + '" class="FLbl_Tab">';
	return StrHtml;
}


function Move_FNZ_DEL_Editable ( field, row )
{
	var GridName = 'ATTI_GARAGrid';
	var StrHtml =''
	StrHtml = '<a class="link_grid" href="#" onclick="Doc_DettagliDel(\'' + GridName + '\'  , ' + row + ' , 1 );return false;">' ;
	StrHtml = StrHtml + '<table id="R' +  row  + '_' + field + '" class="FLbl_Tab">';
	StrHtml = StrHtml + '<tbody><tr><td title=""><img class="img_label_alt" alt="../toolbar/Delete_Light.GIF" src="../images/Domain/../toolbar/Delete_Light.GIF"></td>';
	StrHtml = StrHtml + '<td class="nowrap FLbl_label" id="R' +  row  + '_' + field + '_label"></td></tr></tbody></table></a></td>';
	return StrHtml;
}

function Move_Eliminato( field , row , verso ) 
{
	//se su entrambe le righe è editabile chiamo Move_Abstract
		//se sulle due righe ho una situazione diversa (presente non presente)
		//allora lo gestisco il caso specifico
			//due funzioni che mi danno la versione editabile e non editabile
				//<input type="hidden" id="val_R1_Eliminato_extraAttrib" value="value#=#"><div id="val_R1_Eliminato" class="FldDomainValue"><select id="R1_Eliminato" size="0" name="R1_Eliminato" class="FldDomainValue" onchange="javascript:OnchangeEliminato(this);"><option value="">Seleziona</option><option value="no" id="R1_Eliminato_no">no</option><option value="si" id="R1_Eliminato_si">si</option></select></div>
	
	try
    {
        var f1 = getObj( 'R' + row + '_' + field );
        var f2 = getObj( 'R' + ( row + verso ) + '_' + field ) ;
        var app;
		
		var f1_edit =0 ;
		var f2_edit =0 ;
		
		
			
		if ( f1 != null ){
			
			f1_edit = 1 ; 
		}
		
		
		if ( f2 != null ){
			
			f2_edit = 1 ;
		}
		
		
		//alert(f1_edit + '---' + f2_edit);
		//sorgente non editabile e destinazione editabile
		if ( f1_edit != f2_edit )
		{
			if ( f1_edit == 0)
			{	
				//ATTI_GARAGrid_r1_c4
				f1_parent = getObj( 'ATTI_GARAGrid_r' + row + '_c4' );
				
				//la destinazione diventa non editabile con il valore di f1
				f2.parentNode.innerHTML = Move_Eliminato_NotEditable ( field , ( row + verso ) );
				//alert(Move_Eliminato_NotEditable ( field , ( row + verso )));
				
				//la sorgente diventa editabile con il valore di f2
				f1_parent.innerHTML =  Move_Eliminato_Editable (   field,  row , f2.value );
				//alert(Move_Eliminato_Editable (   field,  row  ));
				
				//chiamo la funzione OnchangeEliminato (obj) per nascondere / visualizzare correttamente le colonne descrizione e allegato
				OnchangeEliminato ( getObj( 'R' + row + '_' + field ) );
				
				//f2 diventa non editabile ed è vuoto allora per la sua riga  che è di iniziativa visualizzo descrizione e allegato
				getObj('R' + ( row + verso ) + '_Descrizione').style.display ='block';
				
			}
			else
			{	
				//ATTI_GARAGrid_r1_c4
				f2_parent = getObj( 'ATTI_GARAGrid_r' + ( row + verso ) + '_c4' );
				
				//la destinazione diventa  editabile con il valore di f1
				f2_parent.innerHTML = Move_Eliminato_Editable ( field , ( row + verso ), f1.value  );
				//alert(Move_Eliminato_Editable ( field , ( row + verso )));

				
				//la sorgente diventa non editabile con il valore di f2
				f1.parentNode.innerHTML =  Move_Eliminato_NotEditable ( field,    row );
				//alert(Move_Eliminato_NotEditable (   field,  row  ));
				//OnchangeEliminato ( getObj( 'R' + row + '_' + field ) );
				OnchangeEliminato ( getObj( 'R' + ( row + verso ) + '_' + field ) );
				
				
				//f1 diventa non editabile ed è vuoto allora nascondo descrizione e allegato
				getObj('R' + row + '_Descrizione').style.display ='block';
				
				
				
				
		
			}
			
		}
		else
		{
			
			Move_Abstract( '', field , row  , verso );
			
			//chiamo la funzione OnchangeEliminato (obj) per nascondere / visualizzare correttamente le colonne descrizione e allegato
			OnchangeEliminato ( f1 );
			
			OnchangeEliminato ( f2 );
			
		}		
	}
	catch(e)
	{
	}
}

function Move_Eliminato_NotEditable ( field, row )
{
	var StrHtml =''
	//StrHtml = '';
	return StrHtml;
}

function Move_Eliminato_Editable ( field, row, value )
{
	
	//value si/no
	//se value no selziono no altrimenti seleziono si
	
	var StrHtml =''
	StrHtml = '<input type="hidden" id="val_R' +  row  + '_' + field + '_extraAttrib " value="value#=#' + value + '">';
	StrHtml = StrHtml + '<div id="val_R' +  row  + '_' + field + '" class="FldDomainValue"><select id="R' +  row  + '_' + field + '" size="0" name="R' +  row  + '_' + field + '" class="FldDomainValue" onchange="javascript:OnchangeEliminato(this);">';
	StrHtml = StrHtml + '<option value="">Seleziona</option>';
	if ( value == 'no' )
	{	
		StrHtml = StrHtml + '<option value="no" id="R' +  row  + '_' + field + '_no" selected="selected">no</option><option value="si" id="R' +  row  + '_' + field + '_si" >si</option>';
	}
	if ( value == 'si' )
	{
		StrHtml = StrHtml + '<option value="no" id="R' +  row  + '_' + field + '_no" >no</option><option value="si" id="R' +  row  + '_' + field + '_si" selected="selected">si</option>';
	}
	StrHtml = StrHtml + '</select></div>';
	
	return StrHtml;
}

/* function Move_Eliminato_Editable ( field, row, value )
{
	
	//value 0/1
	//se value 0 selziono no altrimenti seleziono si
	
	var StrHtml =''
	StrHtml = '<input type="hidden" id="val_R' +  row  + '_' + field + '_extraAttrib " value="value#=#' + value + '">';
	StrHtml = StrHtml + '<div id="val_R' +  row  + '_' + field + '" class="FldDomainValue"><select id="R' +  row  + '_' + field + '" size="0" name="R' +  row  + '_' + field + '" class="FldDomainValue" onchange="javascript:OnchangeEliminato(this);">';
	if ( value == '' )
	{
		StrHtml = StrHtml + '<option value="" selected="selected">Seleziona</option>';
	}
	else if ( value == 'no' )
	{	
		StrHtml = StrHtml + '<option value="no" id="R' +  row  + '_' + field + '_no" selected="selected">no</option><option value="si" id="R' +  row  + '_' + field + '_si" >si</option>';
	}
	else
	{
		StrHtml = StrHtml + '<option value="no" id="R' +  row  + '_' + field + '_no" >no</option><option value="si" id="R' +  row  + '_' + field + '_si" selected="selected">si</option>';
	}
	StrHtml = StrHtml + '</select></div>';
	
	return StrHtml;
}
 */