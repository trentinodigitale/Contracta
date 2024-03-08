
window.onload =OnLoadPage;
function OnLoadPage() 
{
	
	 var DOCUMENT_READONLY = '0';
	
	try
	{
		DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	}
	catch(e)
	{
		
	}
	
	
	if (DOCUMENT_READONLY == '0') 
	{
		//gestisco i campi per gli appalti verdi
		try {
			if (getObjValue('Appalto_Verde') != 'si') {
				getObj('Motivazione_Appalto_Verde').value = '';
				getObj('Motivazione_Appalto_Verde').disabled = true;

			}

		} catch (e) {}

		try {
			if (getObjValue('Acquisto_Sociale') != 'si') {
				getObj('Motivazione_Acquisto_Sociale').value = '';
				getObj('Motivazione_Acquisto_Sociale').disabled = true;

			}
		} catch (e) {}	
		
		 //gestisco i campi per Appalto In Emergenza
		try 
		{
			if (getObjValue('AppaltoInEmergenza') != 'si' && getObj( 'AppaltoInEmergenza' ).type == 'select-one' ) 
			{
				getObj('MotivazioneDiEmergenza').value = '';
				getObj('MotivazioneDiEmergenza').disabled = true;

			}
		} catch (e) {}   
			
	 }
	 //Se il documento è editabile
    if (DOCUMENT_READONLY == '0') 
	{
      try
	  {
        AddControlliDate();
	  }catch(e){}
	  
	  FilterRiferimenti();
	  
    }
	
}


function MySend(param,param2) 
{

    if (param2 == undefined )
		param2='';
	
    //alert(param);    
	if (ControlliSend(param,param2) == -1) return -1;
    ExecDocProcess(param);

}

function ControlliSend(param,param2) 
{

	if (param2 == undefined )
		param2='';
	
    
	var flag_warning_emergenza='';
	
	if ( param2 != '' )
	{
		flag_warning_emergenza = param2.split( '@@@' )[1]
	}
  
	
	var dateObj = new Date();
    
	var Riferimento = zero(dateObj.getFullYear(), 4) + '-' + zero((dateObj.getMonth() + 1), 2) + '-' + zero(dateObj.getDate(), 2) ;

	//AGGIUNGO QUESTO CONTROLLO SOLO SE SULLA GARA IL CAMPO AppaltoInEmergena è nascosto
	//Le date del Bando non rispettano i requisiti minimi di distanza tra loro. Se si ci trova in un caso di emergenza premere il tasto “conferma”, altrimenti premere il tasto “Ignora” e controllare le date
	if ( getObj( 'AppaltoInEmergenza' ).type != 'select-one'  && flag_warning_emergenza != 'no' )
	{
		var warning_emergenza;
		warning_emergenza=false;
		
		
		
		//Controllo se Data Termine Quesiti quesiti sia superiore ad oggi 
		if ( getObjValue('DataTermineQuesiti') !='' && getObjValue('DataTermineQuesiti').substring(0,10) <= Riferimento ) 
		{
			warning_emergenza=true;
		}
		
		//Controllo se Data Termine Quesiti quesiti sia superiore ad oggi 
		if ( getObjValue('DataScadenzaOfferta') !='' &&  getObjValue('DataScadenzaOfferta').substring(0,10) <= Riferimento ) 
		{
			warning_emergenza=true;
		}
		

		if ( warning_emergenza == true )
		{
			var ML_text = 'Le date del Bando non rispettano i termini minimi per la proposizione delle risposte. Se si ci trova in un caso di emergenza premere il tasto "conferma", altrimenti premere il tasto "Ignora" e controllare le date.';
			var Title = 'Informazione';					
			var ICO = 3;
			var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
					
			ExecFunctionModaleConfirm( page, Title , 200 , 400 , null , 'conferma_warning_emergenza@@@@' + param ,'cancel_warning_emergenza');
			return -1;
		}
		
	}
  
  
  
  
  
  if (GetProperty(getObj('RIFERIMENTIGrid'), 'numrow') == -1) 
  {

		DocShowFolder('FLD_RIFERIMENTI');
		tdoc();
		DMessageBox('../', 'Compilare correttamente la sezione dei Riferimenti', 'Attenzione', 1, 400, 300);
		return -1;

   }
   
   
   if (CheckData('DataTermineQuesiti', Riferimento, 'Compilare Termine Richiesta Quesiti', 'Termine Richiesta Quesiti deve essere maggiore di oggi','day') == -1) return -1;
   if (CheckData('DataScadenzaOfferta', getObjValue('DataTermineQuesiti'), 'Compilare Termine Presentazione Risposte', 'Termine Presentazione Risposte deve essere maggiore di Termine Richiesta Quesiti') == -1) return -1;
   
   //Per i campi "Termine Richiesta Quesiti", "Termine Presentazione Offerta" e "Data Prima Seduta" se valorizzati controlliamo se l'orario presenti valore vuoto oppure 0
	try
	{
		if ( getObjValue('DataTermineQuesiti') !='')
		{
			if (CheckDataOrarioOK('DataTermineQuesiti', 'Indicare un orario per il campo "Termine Richiesta Quesiti" diverso da zero') == -1) return -1;
		}
		if ( getObjValue('DataScadenzaOfferta') !='')
		{
			if (CheckDataOrarioOK('DataScadenzaOfferta', 'Indicare un orario per il campo "Termine Presentazione Risposte" diverso da zero') == -1) return -1;
		}
		
		
	}catch (e){}
   
   
   //controllo che siano presenti le motivazioni per un appalto verde oppure per un acquisto sociale
    try {
        if (getObjValue('Appalto_Verde') == 'si') {
            if (getObjValue('Motivazione_Appalto_Verde') == '') {
                DocShowFolder('FLD_COPERTINA');
                tdoc();
                DMessageBox('../', 'Per un bando con "Appalto Verde" indicare una motivazione', 'Attenzione', 1, 400, 300);
                getObj('Motivazione_Appalto_Verde').focus();
                return -1;
            }
        }
    } catch (e) {}
    try {
        if (getObjValue('Acquisto_Sociale') == 'si') {
            if (getObjValue('Motivazione_Acquisto_Sociale') == '') {
                DocShowFolder('FLD_COPERTINA');
                tdoc();
                DMessageBox('../', 'Per un bando con "Acquisto_Sociale" indicare una motivazione', 'Attenzione', 1, 400, 300);
                getObj('Motivazione_Acquisto_Sociale').focus();
                return -1;
            }
        }
    } catch (e) {}
	
	 //controllo che siano presenti le motivazioni per un appalto in emergenza
    try {
        if (getObjValue('AppaltoInEmergenza') == 'si') {
            if (getObjValue('MotivazioneDiEmergenza') == '') {
                DocShowFolder('FLD_COPERTINA');
                tdoc();
                DMessageBox('../', 'Per un bando con "Appalto In Emergenza" indicare una motivazione', 'Attenzione', 1, 400, 300);
                getObj('MotivazioneDiEmergenza').focus();
                return -1;
            }
        }
    } catch (e) {}
	// ODIROS -- controllo sulla sezione Busta documentazione richiesta
	// function ControlliSend
	// numero di criteri 0-based
	try
	{
		var NumDocRic =  GetProperty(getObj('DOCUMENTAZIONE_RICHIESTAGrid'), 'numrow')  ;
		var RichiediFirma;
		var TipoFile;
		
		if (NumDocRic >= 0)
		{
			for (indice = 0; indice <= NumDocRic; indice++) 
			{
					  
				RichiediFirma = getObj('RDOCUMENTAZIONE_RICHIESTAGrid_' + indice + '_RichiediFirma').checked;
				TipoFile = getObj('RDOCUMENTAZIONE_RICHIESTAGrid_' + indice + '_TipoFile').value;
				
				TipoFile = TipoFile.toUpperCase();
				
				if ( (RichiediFirma == true) && (TipoFile.indexOf('###PDF###') < 0 || TipoFile.indexOf('###P7M###') < 0) )
				{
					DocShowFolder('FLD_DOCUMENTAZIONE_RICHIESTA');
					tdoc();
					DMessageBox('../', 'Nella Busta Documentazione sulle righe con Richiedi Firma = SI il Tipo File deve contenere obbligatoriamente almeno i tipi P7M e PDF', 'Attenzione', 1, 400, 300);
					//getObj('Motivazione_Acquisto_Sociale').focus();
					return -1;
				}
				//alert (RichiediFirma);
				//alert (TipoFile);
			}
		}
		
	}
	catch(e)
	{
	}
	
	
	
	
}

function CheckData( FieldData, Riferimento, msgVuoto, msgMinoreRif, tipoconfronto ) 
{
	if (tipoconfronto == undefined )
		tipoconfronto='';
	
	if (getObjValue(FieldData) == '') {
        DocShowFolder('FLD_COPERTINA');
        tdoc();
        try {
            getObj(FieldData + '_V').focus();
        } catch (e) {};
        DMessageBox('../', msgVuoto, 'Attenzione', 1, 400, 300);
        return -1;
    }
	
	if ( tipoconfronto == 'day' && getObj( 'AppaltoInEmergenza' ).value != 'si' )  //fa il confronto se richiesto esplicitamente per day e sul bando per il campo Appalto in Emergenza non si è scelto "si"
	{
		if (getObjValue(FieldData).substring(0,10) <= Riferimento) 
		{
			DocShowFolder('FLD_COPERTINA');
			tdoc();
			try {
				getObj(FieldData + '_V').focus();
			} catch (e) {};
			DMessageBox('../', msgMinoreRif, 'Attenzione', 1, 400, 300);
			return -1;
		}
		
	}
	else
	{
		if (getObjValue(FieldData) <= Riferimento) 
		{
			DocShowFolder('FLD_COPERTINA');
			tdoc();
			try {
				getObj(FieldData + '_V').focus();
			} catch (e) {};
			DMessageBox('../', msgMinoreRif, 'Attenzione', 1, 400, 300);
			return -1;
		}
	}
    return 0;
}



function onchangeAppalto_Verde() 
{
    try {
        if (getObjValue('Appalto_Verde') != 'si') {
            getObj('Motivazione_Appalto_Verde').value = '';
            getObj('Motivazione_Appalto_Verde').disabled = true;

        }
    } catch (e) {}
    try {
        if (getObjValue('Appalto_Verde') == 'si') {

            getObj('Motivazione_Appalto_Verde').disabled = false;

        }
    } catch (e) {}

}

function onchangeAcquisto_Sociale() 
{
    try {
        if (getObjValue('Acquisto_Sociale') != 'si') {
            getObj('Motivazione_Acquisto_Sociale').value = '';
            getObj('Motivazione_Acquisto_Sociale').disabled = true;

        }
    } catch (e) {}
    try {
        if (getObjValue('Acquisto_Sociale') == 'si') {
            getObj('Motivazione_Acquisto_Sociale').disabled = false;

        }
    } catch (e) {}

}


//aggiunge i controlli alle date su onchange
function AddControlliDate()
{

	 //IMPOSTO UN EVENTO DI ONCHANGESULLEDATE PER LE QUALI E' RICHIESTO UN CONTROLLO CHE NON RICADONO IN UN FERMO SISTEMA
	//CONSERVANDO UNO PRECEDENTE SE LO TROVA		
	onchangepresente = GetProperty(getObj('DataTermineQuesiti_V'),'onchange');		
	if ( onchangepresente == null )
	{
		onchangepresente='';
	}
	if (  onchangepresente != '' && onchangepresente.indexOf(";",onchangepresente.length-1) < 0 )
	{
		onchangepresente=onchangepresente + ';';
	}
	onchangepresente=onchangepresente + 'CheckDataUtile(this);onChangeCheckFermoSistema(this);'
	getObj('DataTermineQuesiti_V' ).setAttribute('onchange', onchangepresente );		
	getObj('DataTermineQuesiti_HH_V' ).setAttribute('onchange', 'CheckDataUtile(this);onChangeCheckFermoSistema(this);');		
	getObj('DataTermineQuesiti_MM_V' ).setAttribute('onchange', 'CheckDataUtile(this);onChangeCheckFermoSistema(this);');		
	
	
	onchangepresente = GetProperty(getObj('DataScadenzaOfferta_V'),'onchange');
	if ( onchangepresente == null )
	{
		onchangepresente='';
	}
	if (  onchangepresente != '' && onchangepresente.indexOf(";",onchangepresente.length-1) < 0 )
	{
		onchangepresente=onchangepresente + ';';
	}
	onchangepresente=onchangepresente + 'CheckDataUtile(this);onChangeCheckFermoSistema(this);'
	getObj('DataScadenzaOfferta_V' ).setAttribute('onchange', onchangepresente );  
	getObj('DataScadenzaOfferta_HH_V' ).setAttribute('onchange', 'CheckDataUtile(this);onChangeCheckFermoSistema(this);');		
	getObj('DataScadenzaOfferta_MM_V' ).setAttribute('onchange', 'CheckDataUtile(this);onChangeCheckFermoSistema(this);');		
	
	
	
	
	
	
  //getObj('DataTermineQuesiti_V').onchange = CheckDataUtile (  getObj('DataTermineQuesiti_V') );
  /*getObj('DataTermineQuesiti_V').onchange = CheckDataUtile ; 
  getObj('DataTermineQuesiti_HH_V').onchange = CheckDataUtile ; 
  getObj('DataTermineQuesiti_MM_V').onchange = CheckDataUtile ; 
  
  getObj('DataScadenzaOfferta_V').onchange = CheckDataUtile ; 
  getObj('DataScadenzaOfferta_HH_V').onchange = CheckDataUtile ; 
  getObj('DataScadenzaOfferta_MM_V').onchange = CheckDataUtile ; */
  
   
  
}



function CheckDataUtile(obj){
  
  var NameControlloData = obj.id;
  NameControlloData = NameControlloData.replace('_HH_V','_V');
  NameControlloData = NameControlloData.replace('_MM_V','_V');
  
  var objFieldData = getObj(NameControlloData);
  GetDataUtile ( '../../', objFieldData , '' );
  
  
}

function EsportaRisposteInXLSX() 
{
	var extraHideCol = '';
	
		extraHideCol = ',Name';		
	
	
    ExecFunction('../../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=Risposte&FILTER=linkeddoc%3D' + getObjValue('IDDOC') + '&TIPODOC=RISPOSTA_CONSULTAZIONE&MODEL=BANDO_CONSULTAZIONE_LISTA_RISPOSTE&VIEW=BANDO_CONSULTAZIONE_LISTA_RISPOSTE&HIDECOL=FNZ_OPEN,' + extraHideCol + '&Sort=DataInvio%20asc&IDDOC=' + getObjValue('IDDOC'), '_blank', '');
}

function MyOpenDocument( objGrid , Row , c , path )
{
	var cod;
	var nq;
  
    var objFormDoc = getObj('FORMDOCUMENT');
  
	//se sono sul documeneto e non ho passato il path lo setto a '../'
	if ( path == undefined ){

	if (objFormDoc != null)
	  path = '../'
	}
    
  
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
 
	var strDoc = 'RISPOSTA_CONSULTAZIONE';
	
	if ( path )
		return ShowDocument( strDoc , cod  , path );
	else
		return ShowDocument( strDoc , cod   );
	
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
        DocShowFolder('FLD_COPERTINA');
        tdoc();
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
				Get_CheckFermoSistema ( '../../', objFieldData );					
				
			}
			
		}
		
	}catch(e){}
}

function RIFERIMENTI_AFTER_COMMAND( param )
{
  FilterRiferimenti();
}

function FilterRiferimenti(){
	
	
	var filterUser = '';	
	var i;
	var numrighe=GetProperty( getObj('RIFERIMENTIGrid') , 'numrow');

	
	
	
	filterUser = 'SQL_WHERE= idpfu in ( select idpfu from RiferimentiForBando where DOC_ID = \'BANDO_SEMPLIFICATO\'  and  OWNER = <ID_USER> )';
	
	
	try
	{
		
		for( i = 0 ; i < numrighe+1 ; i++ )
		{
		

			try
			{
				//AGGIUNGO IL FILTRO QUANDO LA RIGA E' ReferenteTecnico per mostrare  gli utenti con il profilo di ReferenteTecnico di tutte le aziende
				if ( getObjValue( 'RRIFERIMENTIGrid_' + i + '_RuoloRiferimenti' ) == 'ReferenteTecnico' )
				{
					filterUser = 'SQL_WHERE= idpfu in ( select ID_FROM from USER_DOC_PROFILI_FROM_UTENTI where profilo =\'Referente_Tecnico\' )';
				}
				else
				{				
					filterUser = 'SQL_WHERE= idpfu in ( select idpfu from RiferimentiForBando where DOC_ID = \'BANDO_SEMPLIFICATO\'  and  OWNER = <ID_USER> )';
				}
				
				FilterDom(  'RRIFERIMENTIGrid_' + i + '_IdPfu' , 'IdPfu' , getObjValue( 'val_RRIFERIMENTIGrid_' + i + '_IdPfu' ), filterUser , 'RIFERIMENTIGrid_' + i  , '')
			}
			catch(e)
			{
			}

		}
		
	}catch(e){};

}


function onchangeAppaltoInEmergenza() {
    try {
        if (getObjValue('AppaltoInEmergenza') != 'si') {
            getObj('MotivazioneDiEmergenza').value = '';
            getObj('MotivazioneDiEmergenza').disabled = true;

        }
    } catch (e) {}
    try {
        if (getObjValue('AppaltoInEmergenza') == 'si') {

            getObj('MotivazioneDiEmergenza').disabled = false;

        }
    } catch (e) {}

}

function conferma_warning_emergenza(param)
{
	
	flag_warning_emergenza=1;
	SetDomValue('AppaltoInEmergenza' , 'si' , 'si');
	SetTextValue('MotivazioneDiEmergenza', 'Appalto di Emergenza');
	$( "#finestra_modale_confirm" ).dialog( "close" );
	MySend(param,'wrng_data@@@no');
	
}

function cancel_warning_emergenza()
{
	SetDomValue('AppaltoInEmergenza' , 'no' , 'no');
	SetTextValue('MotivazioneDiEmergenza', '');
    
	return-1;
}