window.onload = setdocument;

function setdocument()
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
	
	//nascondo i campi relativi a termine richiesta quesiti se non è una proroga del 167 oppure del BANDO_GARA
	
	if( getObjValue('JumpCheck') != '55;167' &&  getObjValue('JumpCheck') != 'BANDO_GARA' &&  getObjValue('Caption') != 'RichiestaQuesiti:1' )	
	{		
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
	else
	{	
		try{setClassName( getObj('cap_DataTermineQuesiti').parentNode , 'VerticalModel_ObbligCaption');}catch(e){};
	}
	if ( getObjValue('FascicoloGenerale') == 'RDO' )
	{
		 try{ getObj('OLD_DataSeduta').parentNode.parentNode.parentNode.parentNode.style.display = "none"; }catch(e){};
		 try{ getObj('DataSeduta').parentNode.parentNode.parentNode.parentNode.style.display = "none"; }catch(e){};
		 try{ setVisibility( getObj( 'cap_OLD_DataSeduta' ) , 'none' ); }catch(e){};
		 try{ setVisibility( getObj( 'cap_DataSeduta' ) , 'none' ); }catch(e){};	
	
	}
	try{setClassName( getObj('cap_DataSeduta').parentNode , 'VerticalModel_ObbligCaption');}catch(e){};
	
	
	
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
	

function OpenBando(param)
{
	
	if ( getObjValue('VersioneLinkedDoc') == 'PROROGA_CONCORSO' ){ 
		ShowDocumentFromAttrib('BANDO_CONCORSO,' + param);
	}
	else
    {		
		if ( getObjValue('JumpCheck') == 'BANDO_GARA' )
			ShowDocumentFromAttrib('BANDO_GARA,' + param);
		else
			OpenDocGen(param);
	}
}





function RefreshContent()
{ 	
	RefreshDocument('');      
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
