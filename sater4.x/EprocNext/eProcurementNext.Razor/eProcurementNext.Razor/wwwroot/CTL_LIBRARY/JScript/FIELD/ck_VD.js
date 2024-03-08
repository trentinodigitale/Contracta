
//-- controlla il valore immesso per le date e lo riporta nel campo nascosto in forma tecnica
function ck_VD( obj_field ) {
	
	var ObjHidde,n;
	var textDate;
	var dateObj = new Date();
	var strFormat = '';
	
  ObjHidden = getObjGrid( obj_field.id.substr( 0, obj_field.id.length -2  ));
	
  try{
		strFormat = GetProperty( ObjHidden , 'F' );
	}catch(e)
	{
		strFormat = 'dd/mm/yyyy';
	}
	if ( strFormat == '' ) strFormat = 'dd/mm/yyyy';
		
	try
	{
		textDate = obj_field.value;
	
		if( textDate == '' )
		{
			ObjHidden.value = '';
		}
		else
		{
			var vetValue;
			//-- spezza la data nelle componenti
			if ( textDate.search( '/' ) > 0 )
				vetValue = textDate.split( '/' );
			if ( textDate.search( '-' ) > 0 )
				vetValue = textDate.split( '-' );
				
			
			//-- controlla che i valori dei campi siano corretti
			if( CheckDateValue( vetValue , strFormat ) == 1 )
			{

				//-- nel caso l'anno sia su due cifre lo completa
				if( vetValue[2].length == 2 )
					if(  vetValue[2] <= 50 )
						vetValue[2] = '20' + vetValue[2];
					else
						vetValue[2] = '19' + vetValue[2];

        //controlla che l'anno sia superiore a 1753
				if ( vetValue[2] >= 1753 )
				{
			
					//-- aggiorna il campo nascosto e riorganizza quello a video
					dateObj.setMinutes( 0 );
					dateObj.setSeconds( 0 );
					dateObj.setHours( 0 );
					dateObj.setYear(vetValue[2]); 
					if( strFormat.substr( 0 , 10 ).toLowerCase() == 'dd/mm/yyyy' )
					{
						dateObj.setMonth(0);
						dateObj.setDate(vetValue[0]); // 1-31
						dateObj.setMonth(Number( vetValue[1])-1); // 0-11 Month within the year (January = 0)
		
						//ObjHidden.value = textDate.substr( 6 , 4) + '-' + textDate.substr( 3 , 2) + '-' + textDate.substr( 0 , 2) + 'T00:00:00';
						ObjHidden.value = zero( dateObj.getFullYear(),4) + '-' + zero( (dateObj.getMonth()+1),2) + '-' + zero(dateObj.getDate(),2) + 'T00:00:00';
						obj_field.value = zero(dateObj.getDate(),2) + '/' + zero( (dateObj.getMonth()+1),2) + '/' + zero( dateObj.getFullYear(),4);
					}
					else
					{
						dateObj.setMonth(0);
						dateObj.setDate(vetValue[1]); // 1-31
						dateObj.setMonth(Number( vetValue[0] ) -1); // 0-11 Month within the year (January = 0)
		
						ObjHidden.value = zero( dateObj.getFullYear(),4) + '-' + zero( (dateObj.getMonth()+1),2) + '-' + zero(dateObj.getDate(),2) + 'T00:00:00';
						obj_field.value =  zero( (dateObj.getMonth()+1),2) + '/' + zero(dateObj.getDate(),2) + '/' + zero( dateObj.getFullYear(),4);
					}
					RecuperaOrario( ObjHidden.id );
			 
				}else
				{
       
				  //-- svuota i campi perchè errati
						ObjHidden.value = '';
						obj_field.value = '';
				  
				  //se definito uso il path della pagina
				  var path;
				  path = '../../';
				  try{
					if ( pathRoot != undefined )
					  path=pathRoot;
				  }catch(e){}  
				  
				  strAlert=CNV ( path , 'Controllare la data: l\'anno digitato e\' inferiore a 1800' );
				  
				  alert(strAlert);
				  
				  return;
				}
       
			}
			else
			{
				//-- svuota i campi perchè errati
				ObjHidden.value = '';
				obj_field.value = '';
			
			}
		}
	} catch( e ) {
	
		ObjHidden.value = '';
		obj_field.value = '';
		
	};
	
}



//-- controlla il valore immesso per le date e lo riporta nel campo nascosto in forma tecnica
function ck_VD_Ext( obj_field ) 
{
	var ObjHidde,n;
	var textDate;
	var dateObj = new Date();
	
	ObjHidden = getObjGrid( obj_field.id.substr( 0, obj_field.id.length -2  ));
	
	strDescPredefinite=obj_field.PredefiniteVisualDescription;

	var strFormat = '';
	try{
		strFormat = GetProperty( ObjHidden , 'F' );
	}catch(e)
	{
		strFormat = 'dd/mm/yyyy';
	}
	if ( strFormat == '' ) strFormat = 'dd/mm/yyyy';
	
	try
	{
		textDate = obj_field.value;
	
		if( textDate == '' )
		{
			obj_field.value=strDescPredefinite;
			ObjHidden.value = '1900-01-01';
		}
		else
		{
			var vetValue;
			//-- spezza la data nelle componenti
			if ( textDate.search( '/' ) > 0 )
				vetValue = textDate.split( '/' );
			if ( textDate.search( '-' ) > 0 )
				vetValue = textDate.split( '-' );
				
			
			//-- controlla che i valori dei campi siano corretti
			if( CheckDateValue( vetValue , strFormat ) == 1 )
			{

				//-- nel caso l'anno sia su due cifre lo completa
				if( vetValue[2].length == 2 )
					if(  vetValue[2] <= 50 )
						vetValue[2] = '20' + vetValue[2];
					else
						vetValue[2] = '19' + vetValue[2];

			
				//-- aggiorna il campo nascosto e riorganizza quello a video
				dateObj.setMinutes( 0 );
				dateObj.setSeconds( 0 );
				dateObj.setHours( 0 );
				dateObj.setYear(vetValue[2]); 

				if( strFormat.substr( 0 , 10 ).toLowerCase() == 'dd/mm/yyyy' )
				{
					dateObj.setMonth(0);
					dateObj.setDate(vetValue[0]); // 1-31
					dateObj.setMonth(vetValue[1]-1); // 0-11 Month within the year (January = 0)
	
					//ObjHidden.value = textDate.substr( 6 , 4) + '-' + textDate.substr( 3 , 2) + '-' + textDate.substr( 0 , 2) + 'T00:00:00';
					ObjHidden.value = zero( dateObj.getFullYear(),4) + '-' + zero( (dateObj.getMonth()+1),2) + '-' + zero(dateObj.getDate(),2) + 'T00:00:00';
					obj_field.value = zero(dateObj.getDate(),2) + '/' + zero( (dateObj.getMonth()+1),2) + '/' + zero( dateObj.getFullYear(),4);
				}
				else
				{
					dateObj.setMonth(0);
					dateObj.setDate(vetValue[1]); // 1-31
					dateObj.setMonth(vetValue[0]-1); // 0-11 Month within the year (January = 0)
	
					ObjHidden.value = zero( dateObj.getFullYear(),4) + '-' + zero( (dateObj.getMonth()+1),2) + '-' + zero(dateObj.getDate(),2) + 'T00:00:00';
					obj_field.value =  zero( (dateObj.getMonth()+1),2) + '/' + zero(dateObj.getDate(),2) + '/' + zero( dateObj.getFullYear(),4);
				}

				RecuperaOrario( ObjHidden.id );
			}
			else
			{
				//-- svuota i campi perchè errati
				ObjHidden.value = '';
				obj_field.value = '';
			
			}
		}
	} catch( e ) {
	
		ObjHidden.value = '';
		obj_field.value = '';
	};
	
}


function zero( val, len )
{

	var tzero = '0000000';
	tzero = tzero + val;
	
	return tzero.substr( tzero.length - len ); 

}


function CheckDateValue( vetValue , strFormat)
{
	
	
	
	if( vetValue.length < 3 )
		return 0;

	if( strFormat.substr( 0 , 10 ).toLowerCase()  == 'dd/mm/yyyy' )
	{
		//-- formato italiano
		if ( vetValue[0] < 1 && vetValue[0] > 31 )
			return 0;
				
	
		if ( vetValue[1] < 1 && vetValue[1] > 12 )
			return 0;
	}
	else
	{	//-- formato inglese
		if ( vetValue[1] < 1 && vetValue[1] > 31 )
			return 0;
				
	
		if ( vetValue[0] < 1 && vetValue[0] > 12 )
			return 0;
	}
	
	if ( vetValue[2].length != 2 && vetValue[2].length != 4 )
		return 0;

	return 1;

}

//function Run_Calendar(objCampo, nomeFormOrigine,RifFormHidden, nomeFormProdotti, SuffLing, IdMp, path_var, strModifyObject, strCalendarType)

function Run_Calendario(objCampo,  path_var,  strCalendarType)
{	
	var SuffLing = 'I';
	var IdMp = 1;
	var strModifyObject = '';
	var nomeFormProdotti = '';
	var RifFormHidden = '';
	
	var campoHidden, campoVis, strcampoHidden, strcampoVis
 	
 	//Definizione delle dimensioni della popup
 	switch (strCalendarType) 
		{ 
		    case '': case '1': //classico
 				const_width=285;
				const_height=255;
				break;
			
			case '2': //settimanale
				const_width=300;
				const_height=100;
				break;
				
			case '3': //mensile 
				const_width=300;
				const_height=100;
				break;
			
		}//end switch
		
	const_left=(screen.width-const_width)/2;
	const_top=(screen.height-const_height)/2;	
 
 	//strcampoHidden=RifFormHidden+ '.'+ objCampo 
 	strcampoHidden= objCampo 
 	
 	//nome completo del form dell'hidden che rileva le modifiche
 	if (strModifyObject != '')
 	  {
 		strModifyObject = RifFormHidden+ '.'+ strModifyObject ;
 	  }
 	if (nomeFormProdotti != "")
 		nomeFormProdotti=nomeFormProdotti+ '.'+ objCampo 
 		
 	//strcampoVis=nomeFormOrigine+ '.'+ objCampo +'_V'
 	strcampoVis=objCampo +'_V';
 	
 	campoHidden=getObj(strcampoHidden);
 	campoVis=getObj(strcampoVis);

	
	
	//Verifico se la variabile esiste
 	if (typeof pathRoot !== 'undefined') 
	{
		path_var = pathRoot + 'functions';
	}
 	else
	{
		path_var = location.pathname;
		var vp;
		vp = location.pathname.split('/');
		try{
			var slash = '/';//vp[1].charAt(0);
			var i = vp[1].indexOf('/' );
			if ( i > -1 ) 
			{
				path_var = '/' + vp[1].substr(0,i) + '/Functions';
			}
			else
			{
				path_var = '/' + vp[1] + '/Functions';

			}
		
		}
		catch( e ) {
			path_var = '/' + vp[1] + '/Functions';
		}
	
	}

	window.open(path_var+'/Calendario.asp?CTL=yes&strCalendarType='+escape(strCalendarType)+'&strModifyObject='+escape(strModifyObject)+'&SuffLing='+SuffLing+'&IdMp='+IdMp+'&strDataVis='+campoVis.value+'&strData='+escape(campoHidden.value)+'&campoHidden='+strcampoHidden+'&campoVis='+strcampoVis+'&nomeFormProdotti='+nomeFormProdotti,'DeskTop','toolbar=no,location=no,directories=no,status=<%=CONST_STATUS%>,menubar=no,resizable=no,copyhistory=no,scrollbars=no,width='+const_width+',height='+const_height+', top='+const_top+',left='+const_left+'');
}

function ck_HH_VD( namefield ){
	
	var ObjHidden;
	var objcampoVis;
	var objHHDate;
	
	CompletaCampoTecnicoDate(namefield);

	ObjHidden=getObj(namefield);
	strValueHidden=ObjHidden.value;
	objHHDate = getObj(namefield +'_HH_V');
	HHDate=objHHDate.value;

	//if ( HHDate != '' )
	//{
		
		if (Number(HHDate) >= 0 && Number(HHDate) < 24)
		{
			HHDate = zero(HHDate,2);
			if (ObjHidden.value != '')
			{
				ObjHidden.value = strValueHidden.substr( 0,11 ) + HHDate + strValueHidden.substr( 13, 6) 
				objHHDate.value = HHDate;
			}
			
			
			//alert(ObjHidden.value );
			// '2007-12-24T00:00:00'

		}
		else
		{
			objHHDate.value='00';
			if (ObjHidden.value != '')
				ObjHidden.value = strValueHidden.substr( 0,11 ) + '00' + strValueHidden.substr( 13, 6); 		
		}
	//}
	//else
	//{
	//	ObjHidden.value = strValueHidden.substr( 0,11 ) + '' + strValueHidden.substr( 13, 6); 		
	//}
}

function ck_MM_VD( namefield ){
	
	var ObjHidden;
	var objcampoVis;
	var objHHDate;
	
	CompletaCampoTecnicoDate(namefield);

	ObjHidden=getObj(namefield);
	strValueHidden=ObjHidden.value;
	objHHDate = getObj(namefield +'_MM_V');
	HHDate=objHHDate.value;
	
	//if ( HHDate != '' )
	//{
		if (Number(HHDate) >= 0 && Number(HHDate) < 60)
		{
			HHDate = zero(HHDate,2);
			if (ObjHidden.value != '')
			{
				ObjHidden.value = strValueHidden.substr( 0,14 ) + HHDate + strValueHidden.substr( 16, 3); 
				objHHDate.value = HHDate;
			}	
			//alert(ObjHidden.value );
			// '2007-12-24T00:00:00'

		}
		else
		{
			objHHDate.value='00';
			if (ObjHidden.value != '')
				ObjHidden.value = strValueHidden.substr( 0,14 ) + '00' + strValueHidden.substr( 16, 3); 		
		}
	//}
	//else
	//{
	//	objHHDate.value='';
	//	ObjHidden.value = strValueHidden.substr( 0,14 ) + '' + strValueHidden.substr( 16, 3); 	
	//}
}

function ck_SS_VD( namefield ){
	
	var ObjHidden;
	var objcampoVis;
	var objHHDate;
	
	CompletaCampoTecnicoDate(namefield);

	ObjHidden=getObj(namefield);
	strValueHidden=ObjHidden.value;
	objHHDate = getObj(namefield +'_SS_V');
	HHDate=objHHDate.value;
	
	//if ( HHDate != '' )
	//{
		if (Number(HHDate) >= 0 && Number(HHDate) < 60)
		{
			HHDate = zero(HHDate,2);
			if (ObjHidden.value != '')
			{
				ObjHidden.value = strValueHidden.substr( 0,17 ) + HHDate ; 
				objHHDate.value = HHDate;
			}
			//alert(ObjHidden.value );
			// '2007-12-24T00:00:00'

		}
		else
		{
			objHHDate.value='00';
			if (ObjHidden.value != '')
				ObjHidden.value = strValueHidden.substr( 0,17 ) + '00' ; 		
		}
	//}
	//else
	//{
	//	objHHDate.value='';
	//	ObjHidden.value = strValueHidden.substr( 0,17 ) + '' ;
	//}
}

function CompletaCampoTecnicoDate(namefield){

	ObjHidden=getObj(namefield);
	strValueHidden=ObjHidden.value;
	
	//alert(strValueHidden + '    =LENGHT=' + strValueHidden.length);
	
	if (strValueHidden.length == 10)
		ObjHidden.value = strValueHidden +'T00:00:00';
	
	if (strValueHidden.length == 13)
		ObjHidden.value = strValueHidden + ':00:00';
	
	if (strValueHidden.length == 16)
		ObjHidden.value = strValueHidden + ':00';

}

function RecuperaOrario( namefield )
{
	var ObjHidden;
	var objcampoVis;
	var objHHDate;
	
	CompletaCampoTecnicoDate(namefield);

	ObjHidden=getObj(namefield);
	strValueHidden=ObjHidden.value;
	
	try {
		objHHDate = getObj(namefield +'_SS_V');
		HHDate=objHHDate.value;
		HHDate = zero(HHDate,2);
		strValueHidden = strValueHidden.substr( 0,17 ) + HHDate ; 
	} catch( e ) {};


	try {
		objHHDate = getObj(namefield +'_MM_V');
		HHDate=objHHDate.value;
		HHDate = zero(HHDate,2);
		strValueHidden = strValueHidden.substr( 0,14 ) + HHDate + strValueHidden.substr( 16, 3); 
	} catch( e ) {};


	try {
		objHHDate = getObj(namefield +'_HH_V');
		HHDate=objHHDate.value;
		HHDate = zero(HHDate,2);
		strValueHidden = strValueHidden.substr( 0,11 ) + HHDate + strValueHidden.substr( 13, 6) 
	} catch( e ) {};
	
	ObjHidden.value = strValueHidden;

}


//-- la funzione aggiorna un campo Data ed il suo corrispettivo visuale
function SetDataValue( objName , value , valuevis )
{
	var val;
	var Field;
	var Field_V;
	
	//-- aggiorno campo tecnico
	try 
	{
		Field = getObj( objName );
		Field.value = value;
		
		//se la classe è fld_Evidence la cambio
		if (Field.className=='fld_Evidence')
			Field.className='Text';
			
	}catch ( e ) {
		
	}
	
	//se la forma visuale non passata la recupero in funzione della formata del campo
	if ( valuevis == ''){
    
  }
	
	try 
	{
	  //aggiorno campo visuale editabile
		Field_V = getObj( objName + '_V' );
		if (valuevis=='')
			Field_V.value = ' ';
		else
			Field_V.value = valuevis;
		
		//se la classe è fld_Evidence la cambio
		if (Field_V.className=='fld_Evidence')
			Field_V.className='Text';
		
    	
	}catch ( e ) {
		//alert(e);
	}	
   
  try 
	{
	  //aggiorno campo visuale non editabile
		Field_V = getObj( objName + '_L' );
		if ( valuevis == '' )
			Field_V.innerHTML = ' ';
		else
			Field_V.innerHTML = valuevis ;
		
		//se la classe è fld_Evidence la cambio
		if (Field_V.className=='fld_Evidence')
			Field_V.className='Text';
		
    	
	}catch ( e ) {
		//alert(e);
	} 
}



function DatareadOnly(objName,b)
{
  
  try{ getObj(objName + '_V').readOnly=b; } catch( e ){};	
  
  if ( b == true ){
 
     try{getObj(objName + '_V').className =  getObj(objName + '_V').className + ' readonly';} catch( e ){};
	 try{getObj(objName + '_HH_V').className =  getObj(objName + '_HH_V').className + ' readonly';} catch( e ){};
	 try{getObj(objName + '_MM_V').className =  getObj(objName + '_MM_V').className + ' readonly';} catch( e ){};
	 try{getObj(objName + '_SS_V').className =  getObj(objName + '_SS_V').className + ' readonly';} catch( e ){};
 
     //nascondo il bottone
     //alert(getObj(objName + '_button').className);
     getObj(objName + '_button').className =  getObj(objName + '_button').className + ' display_none'; 
  }   
  
  if ( b == false ){
   
    //getObj(objName+ '_V').className = getObj(objName + '_V').className.replace (' readonly','');
	try{getObj(objName+ '_V').className =  ReplaceExtended(getObj(objName + '_V').className,' readonly','');} catch( e ){};
	try{getObj(objName+ '_HH_V').className =  ReplaceExtended(getObj(objName + '_HH_V').className,' readonly','');} catch( e ){};
	try{getObj(objName+ '_MM_V').className =  ReplaceExtended(getObj(objName + '_MM_V').className,' readonly','');} catch( e ){};
	try{getObj(objName+ '_SS_V').className =  ReplaceExtended(getObj(objName + '_SS_V').className,' readonly','');} catch( e ){};
	
	
 
	
    //visualizzo il bottone
    //getObj(objName+ '_button').className = getObj(objName + '_button').className.replace (' display_none','');
	getObj(objName+ '_button').className =  ReplaceExtended(getObj(objName + '_button').className,' display_none','')
   
  }  
  
}

//ritorna in formato tecnico la data del server attuale
//Param indica operazioni da fare sulla data server attuale del tipo OPERATION,TYPEOFFSET,OFFSET
//ad es. ADD,m,20
function GetDataServer( path , Param ){
  
  //se definito uso il path della pagina
  try{
    if ( pathRoot != undefined )
      path=pathRoot
  }catch(e){}  
  
  ajax = GetXMLHttpRequest(); 

  if(ajax){
	   
    ajax.open("GET", path + '/CTL_Library/functions/GetDataServer.asp?Param=' + Param , false);
  
    ajax.send(null);
    //alert(ajax.readyState);
    if(ajax.readyState == 4) {
      //alert(ajax.status);
      if(ajax.status == 200)
      {
        result =  ajax.responseText;
	      return result;
	    }
    }
  }
  return '';

}


//la funzione ritorna una data utile (tenendo conto dei festivi e del calendario)
//obj_field oggetto data da aggiornare
//strAttribAzi nome del campo che contiene idazi
function GetDataUtile ( path, obj_field , strAttribAzi ){
  
  
  var dateObj = new Date();
  
  ck_VD( obj_field );
  
  //recupero il valore del campo tecnico
  ObjHidden = getObjGrid( obj_field.id.substr( 0, obj_field.id.length -2  ));
  //alert(ObjHidden.value);
  
  if ( ObjHidden.value == '')
    return;
  
  //devo passare solo il giorno quindi prendo i primi 10 caratteri
  var strDataValue = ObjHidden.value ; 
  strDataValue = strDataValue.substr( 0 , 10 );
  
  
  
  // passato recupero valore di azienda
  var strValueIdAzi ='';
  if ( strAttribAzi != '')
    strValueIdAzi = getObj(strAttribAzi).value ;
  
  //se definito uso il path della pagina
  try{
    if ( pathRoot != undefined )
      path=pathRoot;
  }catch(e){}  
  
  ajax = GetXMLHttpRequest(); 

  if(ajax){
	  
    ajax.open("GET", path + '/CTL_Library/functions/GetDataUtile.asp?DataIn=' + strDataValue + '&IdAzi=' + strValueIdAzi  , false);
  
    ajax.send(null);
    
    if(ajax.readyState == 4) {
    
      if(ajax.status == 200)
      {
        result =  ajax.responseText;
        
        //è il giorno utile nel formato tecnico aaaa-mm-gg
        //alert(result);
	      //ObjHidden.value = result;
	      
	      if ( result != strDataValue ){
	      
  	      //la rimetto sul campo
          try{
            strFormat = GetProperty( ObjHidden , 'F' );
          }catch(e)
          {
            strFormat = 'dd/mm/yyyy';
          }
          if ( strFormat == '' ) strFormat = 'dd/mm/yyyy';
  	      
          var vetValue = result.split( '-' );
  	      
          //-- aggiorna il campo nascosto e riorganizza quello a video
  				
  				if( strFormat.substr( 0 , 10 ).toLowerCase() == 'dd/mm/yyyy' )
  				{
  					
  					obj_field.value =  vetValue[2] + '/' + vetValue[1] + '/' + vetValue[0];
  				}
  				else
  				{
  					obj_field.value =  vetValue[1] + '/' + vetValue[2] + '/' + vetValue[0];
  				}
  	      
  	      
          ck_VD( obj_field );	      
          
          //messaggio di output
          //recupero caption del campo
          //cap_DataScadenza
          strNome = obj_field.name ;
          strNome = strNome.substr( 0, strNome.length -2 );
          
          //var CaptionField = getObj ( 'cap_' + strNome ).innerHTML;
		  var CaptionField = getObj ( 'cap_' + strNome ).innerText;
          //alert(CaptionField);
          //"la data  selezionata 'Presentare le Offerte Indicative entro "cade in un giorno non consentito, la data è stata spostata in avanti al primo giorno utile"
          alert (  CNV ( path , 'la data  selezionata' ) + ' "' + CaptionField + '" ' + CNV ( path , 'cade in un giorno non consentito') );
          
	      }
	    }
    }
  }
  
  return '';
  

}



//la funzione ritorna una risposta sulla data passata se per caso ricade in un fermo sistema
//obj_field oggetto data da aggiornare
//warning si/no  se vale si l apagina controlla se cade in un intervallo di warning altrimenti no
function Get_CheckFermoSistema ( path, obj_field , warning )
{  
	var dateObj = new Date();

	ck_VD( obj_field );

	//recupero il valore del campo tecnico
	ObjHidden = getObjGrid( obj_field.id.substr( 0, obj_field.id.length -2  ));
	//alert(ObjHidden.value);

	if ( ObjHidden.value == '')
		return;

	//devo passare solo il giorno quindi prendo i primi 10 caratteri
	var strDataValue = ObjHidden.value ; 
	//strDataValue = strDataValue.substr( 0 , 10 );
	//alert(strDataValue);

	//se definito uso il path della pagina
	try{
		if ( pathRoot != undefined )
			path=pathRoot;
	}catch(e){}  
	
	//se warning non definito lo setto a 'no'
	try{
		if ( warning == undefined )
		  warning='no';
	}catch(e){}

	ajax = GetXMLHttpRequest(); 

	if(ajax)
	{
		var nocache = new Date().getTime();
		ajax.open("GET", path + '/CTL_Library/functions/CheckFermoSistema.asp?warning=' + warning  + '&DataIn=' + strDataValue  + '&nocache=' + nocache , false);

		ajax.send(null);

		if(ajax.readyState == 4) 
		{

			if(ajax.status == 200)
			{
				result =  ajax.responseText;
				
				//è il giorno utile nel formato tecnico aaaa-mm-gg
				//alert(result);
				  //ObjHidden.value = result;
				if ( result != '')
				{        
				
					var aInfo = result.split( '@@@' );
					
					//se si tratta di un FERMO SISTEMA 
					if (aInfo[0] == 'FERMO')
					{
						var datainizio =aInfo[1];
						var datafine =aInfo[2];
						var descrizione =aInfo[3];
					
						descrizione = descrizione.replace("'","\'");
					
						//-- svuota i campi 
						if ( obj_field.name != '' )
						{
					  
							ObjHidden.value = '';
							obj_field.value = '';
							
							try{getObj(obj_field.id.replace('_V','_HH_V')).value=''; }catch(e){} 
							try{getObj(obj_field.id.replace('_V','_MM_V')).value=''; }catch(e){} 
							try{getObj(obj_field.id.replace('_V','_SS_V')).value=''; }catch(e){} 				
											  
					  
						}
						
						alert (  CNV( path , 'Gentile utente, la data indicata non e utilizzabile. Previsto Fermo Sistema con Data e Ora Inizio:' ) + ' "' + datainizio + '" ' + CNV( path , 'e Data e Ora Fine:') + ' "' + datafine + '" ' + '. \n ' + 'Descrizione:\n' +  descrizione );			  	
						return ;
					}
					
					//se si tratta di un WARNING
					if (aInfo[0] == 'WARNING')
					{
						var datainizio =aInfo[1];
						var datafine =aInfo[2];
						var descrizione =aInfo[3];
					
						descrizione = descrizione.replace("'","\'");
					
						
						alert (  CNV( path , 'Gentile utente, la data indicata e a ridosso di un Fermo Sistema con Data e Ora Inizio:' ) + ' "' + datainizio + '" ' + CNV( path , 'e Data e Ora Fine:') + ' "' + datafine + '" ' + '. \n ' + 'Descrizione:\n' +  descrizione );			  	
						return ;
					}
					
					
				}
				
			}

		}
	}
}