window.onload = setdocument;

function setdocument()
{
	
	
	//aggiungo alle date editabili i nuovi controlli per data utile
  AddControlliDate();
  
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
		
		
	}catch (e){}
}
	



function OpenBando(param)
{
if ( getObjValue('JumpCheck') == 'BANDO_CONSULTAZIONE' )
	ShowDocumentFromAttrib('BANDO_CONSULTAZIONE,' + param);
else
	alert('Tipo Documento non gestito.')
}





function RefreshContent()
{ 	
	RefreshDocument('');      
}


//aggiunge i controlli alle date su onchange
function AddControlliDate(){

  
	//getObj('DataTermineQuesiti_V').onchange = CheckDataUtile (  getObj('DataTermineQuesiti_V') );
	getObj('DataTermineQuesiti_V').onchange = CheckDataUtile ; 
	getObj('DataTermineQuesiti_HH_V').onchange = CheckDataUtile ; 
	getObj('DataTermineQuesiti_MM_V').onchange = CheckDataUtile ; 

	getObj('DataPresentazioneRisposte_V').onchange = CheckDataUtile ; 
	getObj('DataPresentazioneRisposte_HH_V').onchange = CheckDataUtile ; 
	getObj('DataPresentazioneRisposte_MM_V').onchange = CheckDataUtile ; 
  
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
		
		

		
	}
   
  
}



function CheckDataUtile(){
  
  var NameControlloData = this.id;
  NameControlloData = NameControlloData.replace('_HH_V','_V');
  NameControlloData = NameControlloData.replace('_MM_V','_V');
  
  var objFieldData = getObj(NameControlloData);
  
  GetDataUtile ( '../../', objFieldData , '' );

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
				Get_CheckFermoSistema ( '../../', objFieldData );				
				
				
			}
			
		}
		
	}catch(e){}
}
