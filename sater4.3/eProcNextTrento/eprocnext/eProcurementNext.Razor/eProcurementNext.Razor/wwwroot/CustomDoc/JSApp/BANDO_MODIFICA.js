window.onload = OnLoadPage; 

function OnLoadPage()
{
	
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
	
	var VersioneLinkedDoc = getObjValue( 'VersioneLinkedDoc' ); 
	var numrighe=GetProperty( getObj('RIFERIMENTIGrid') , 'numrow');
	var filter = '';
	var filterUser = '';
	var DOCUMENT_READONLY = '0';	
	
    // Nascondo le due sezioni del folder testata
    var testataMeSda = getObj('TESTA_ME_SDA');
    if (testataMeSda != null) {
        testataMeSda.style.display = 'none';
    }

    var testata = getObj('TESTATA');
    if (testata != null) {
        testata.style.display = 'none';
    }
 
    
	if (VersioneLinkedDoc == 'BANDO_SEMPLIFICATO' || VersioneLinkedDoc == 'BANDO_GARA' || VersioneLinkedDoc == 'BANDO_CONCORSO' )
	{
        if (testata != null) {
            testata.style.display = '';
        }
	}

    
	//SOLO PER BANDO,BANDO LAVORI e BANDO SDA FILTRO I RESPONSABILI
    if ( VersioneLinkedDoc == 'BANDO' || VersioneLinkedDoc == 'BANDO_SDA' || VersioneLinkedDoc == 'BANDO_ALBO_LAVORI' )
	{
		
		if (testataMeSda != null) {
            testataMeSda.style.display = '';
        }
       
		//aggiorno anche i responsabili
		numrighe=GetProperty( getObj('COMMISSIONEGrid') , 'numrow');
		filterUser = 'SQL_WHERE= idpfu in ( select idpfu from ResponsabiliForBando where DOC_ID = \'' + VersioneLinkedDoc + '\'  and  OWNER = <ID_USER> )' ;

		var i;

		try
		{
			if( getObjValue(   'StatoFunzionale' ) == 'InLavorazione' )
			{
				for( i = 0 ; i < numrighe+1 ; i++ )
				{
			  
					try
					{
						FilterDom(  'RCOMMISSIONEGrid_' + i + '_IdPfu' , 'IdPfu' , getObjValue( 'RCOMMISSIONEGrid_' + i + '_IdPfu' ), filterUser , 'COMMISSIONEGrid_' + i  , '')
					}
					catch(e)
					{
					}

				}
			}
		}catch(e){};
  
	}
	
	
	try
	{
		if ( typeof InToPrintDocument !== 'undefined' )
		{
			DOCUMENT_READONLY='1';
		}
		else
		{
			DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
		}	
	}
	catch(e)
	{
	}
	
	if (DOCUMENT_READONLY == '0') 
	{		
		FilterRiferimenti();
	}
	
	try{getObj( 'STRUTTURA' ).style.display='none';}catch(e){};
	
	HideCestinodoc();
	Recupero_Descrizione();
	ControlloEliminato();
	HideCestinoENTI();
	
	//nascondo la colonna "Evidenza Pubblica" se non provengo da un BANDO_SEMPLIFICATO
	if  ( VersioneLinkedDoc != 'BANDO_SEMPLIFICATO' )
	{
		ShowCol( 'ATTI_GARA' , 'EvidenzaPubblica' , 'none' );
	}
	
	//attivazione meccanismo DRAG&DROP sulla griglia degli ATTI
	if (DOCUMENT_READONLY == '0' ) 
	{
			
		ActiveDrag();	
		
	}else
	{
		HideColDrag();
	}
	
	
	
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
	
	
	Move_Abstract( '', 'Eliminato' , r  , verso );
	Move_Abstract( '', 'EvidenzaPubblica' , r  , verso );
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




function RIFERIMENTI_AFTER_COMMAND( param )
{
  OnLoadPage();
}


function HideCestinodoc() {
    try {
        var i = 0;


        if ((getObj('StatoDoc').value == 'Saved' || getObj('StatoDoc').value == '')) {
            for (i = 0; i < 10000; i++) {
                try {
                   //modificato indice della colonna perchè aggiunta colonna fnz_drag
 				   if (getObj('R' + i + '_Allegato_OLD').value != '' || getObj('R' + i + '_Descrizione_OLD').value != '') {
                        getObj('ATTI_GARAGrid_r' + i + '_c1').innerHTML = '&nbsp;';
                    }
					 //modificato indice della colonna da svuotare perchè aggiunta colonna fnz_copy e fnz_upd in mezzo
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


function HideCestinoENTI() {
    try {
        var i = 0;


        if ((getObj('StatoDoc').value == 'Saved' || getObj('StatoDoc').value == '')) {
            for (i = 0; i < 10000; i++) {
                try {
                    if (getObj('RENTIGrid_' + i + '_Not_Editable').value != '') {
                        getObj('ENTIGrid_r' + i + '_c0').innerHTML = '&nbsp;';
                    }
                    if ( getObj('RENTIGrid_' + i + '_Not_Editable').value == '') {
                        getObj('ENTIGrid_r' + i + '_c1').innerHTML = '&nbsp;';
                    }                    
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
	try
	{	
		var numeroRighe = GetProperty( getObj('ATTI_GARAGrid') , 'numrow');

		for( i = 0 ; i <= numeroRighe ; i++ )
		{
			OnchangeEliminato (getObj('R'+ i + '_Eliminato'));
		}
	
	}catch(e){};
	
}

function RefreshContent() {
    RefreshDocument('');
}

function ATTI_GARA_AFTER_COMMAND() {
	
    OnLoadPage();
		
	
}
function ENTI_AFTER_COMMAND() {
    OnLoadPage();
}


function ActiveSelStruttura()
 {
	 getObj( 'TIPO_AMM_ER_button' ).onclick();
 }
 
  function ADD_Enti( obj)
 {
	 ExecDocProcess( 'ADD_ENTI,BANDO_GARA,,NO_MSG' );
 }

 
 function OnChangeSedutaVirtuale()
 {
	 if ( getObj('Scelta_Seduta_Virtuale').value == 'si' )
	 {
		 getObj('TipoSedutaGara').value='virtuale';
		 
	 }
	 else
	 {
		 getObj('TipoSedutaGara').value='no';
	 }
	 
	 
 }
 
 function RIFERIMENTI_AFTER_COMMAND( param )
{
  FilterRiferimenti();
}

function FilterRiferimenti()
{
	
	var filterUser = '';	
	var i;
	var numrighe=GetProperty( getObj('RIFERIMENTIGrid') , 'numrow');
	var VersioneLinkedDoc = getObjValue( 'VersioneLinkedDoc' ); 
	

	filterUser = 'SQL_WHERE= idpfu in ( select idpfu from RiferimentiForBando where DOC_ID = \'' + VersioneLinkedDoc + '\'  and  OWNER = <ID_USER> )';

	var i;

	try
	{
		if( getObjValue(   'StatoFunzionale' ) == 'InLavorazione' )
		{
			for( i = 0 ; i < numrighe+1 ; i++ )
			{
				try
				{
					
					
					if (VersioneLinkedDoc == 'BANDO_SEMPLIFICATO' || VersioneLinkedDoc == 'BANDO_GARA' || VersioneLinkedDoc == 'BANDO_CONCORSO' )    
					{
						
						//AGGIUNGO IL FILTRO QUANDO LA RIGA E' REFERENTE TECNICO per mostrare  gli utenti con il profilo di referente tecnico di tutte le aziende
						if ( getObjValue( 'RRIFERIMENTIGrid_' + i + '_RuoloRiferimenti' ) == 'ReferenteTecnico' )
						{
							filter =  'none';
						}
						else
						{				
							filter =  'SQL_WHERE= DMV_Cod in ( 	 \'Quesiti\', \'Bando\'  ) ';
						}
						
						
					}
					else
					{
							filter =  'SQL_WHERE= DMV_Cod in ( 	 \'Quesiti\',\'Istanze\',\'Albo\' ) ';
					}
					
					if ( filter != 'none' )
					{
						FilterDom(  'RRIFERIMENTIGrid_' + i + '_RuoloRiferimenti' , 'RuoloRiferimenti' , getObjValue( 'RRIFERIMENTIGrid_' + i + '_RuoloRiferimenti' ), filter , 'RIFERIMENTIGrid_' + i  , '', 'TDYV');
					}
				}
				catch(e)
				{
				}

				try
				{
					
					//AGGIUNGO IL FILTRO QUANDO LA RIGA E' REFERENTE TECNICO per mostrare  gli utenti con il profilo di referente tecnico di tutte le aziende
					if ( getObjValue( 'RRIFERIMENTIGrid_' + i + '_RuoloRiferimenti' ) == 'ReferenteTecnico'   )
					{
						filterUser = 'SQL_WHERE= idpfu in ( select ID_FROM from USER_DOC_PROFILI_FROM_UTENTI where profilo =\'Referente_Tecnico\' )';
					}
					else
					{				
						filterUser = 'SQL_WHERE= idpfu in ( select idpfu from RiferimentiForBando where DOC_ID = \'' + VersioneLinkedDoc + '\' and  OWNER = <ID_USER> )';
					}
					
					FilterDom(  'RRIFERIMENTIGrid_' + i + '_IdPfu' , 'IdPfu' , getObjValue( 'val_RRIFERIMENTIGrid_' + i + '_IdPfu' ), filterUser , 'RIFERIMENTIGrid_' + i  , '')
					
				}
				catch(e)
				{
				}

			}
		}
	}catch(e){};
	
	
	
	

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
