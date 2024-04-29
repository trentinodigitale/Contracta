
//-- controlla il valore immesso per le date e lo riporta nel campo nascosto in forma tecnica
function ck_VD( obj_field ) {
	
	
	var ObjHidde,n;
	var textDate;
	var dateObj = new Date();
	var strFormat = '';
	ObjHidden = getObjGrid( obj_field.id.substr( 0, obj_field.id.length -2  ));
	try{
		strFormat = ObjHidden.F;
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

			
				//-- aggiorna il campo nascosto e riorganizza quello a video
				dateObj.setYear(vetValue[2]); 
				if( strFormat == 'dd/mm/yyyy' )
				{
					dateObj.setMonth(vetValue[1]-1); // 0-11 Month within the year (January = 0)
					dateObj.setDate(vetValue[0]); // 1-31
	
					//ObjHidden.value = textDate.substr( 6 , 4) + '-' + textDate.substr( 3 , 2) + '-' + textDate.substr( 0 , 2) + 'T00:00:00';
					ObjHidden.value = zero( dateObj.getFullYear(),4) + '-' + zero( (dateObj.getMonth()+1),2) + '-' + zero(dateObj.getDate(),2) + 'T00:00:00';
					obj_field.value = zero(dateObj.getDate(),2) + '/' + zero( (dateObj.getMonth()+1),2) + '/' + zero( dateObj.getFullYear(),4);
				}
				else
				{
					dateObj.setMonth(vetValue[0]-1); // 0-11 Month within the year (January = 0)
					dateObj.setDate(vetValue[1]); // 1-31
	
					ObjHidden.value = zero( dateObj.getFullYear(),4) + '-' + zero( (dateObj.getMonth()+1),2) + '-' + zero(dateObj.getDate(),2) + 'T00:00:00';
					obj_field.value =  zero( (dateObj.getMonth()+1),2) + '/' + zero(dateObj.getDate(),2) + '/' + zero( dateObj.getFullYear(),4);
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
function ck_VD_Ext( obj_field ) {
	
	
	var ObjHidde,n;
	var textDate;
	var dateObj = new Date();
	
	ObjHidden = getObjGrid( obj_field.id.substr( 0, obj_field.id.length -2  ));
	
	strDescPredefinite=obj_field.PredefiniteVisualDescription;

	var strFormat = '';
	try{
		strFormat = ObjHidden.F;
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
			if( CheckDateValue( vetValue ) == 1 )
			{

				//-- nel caso l'anno sia su due cifre lo completa
				if( vetValue[2].length == 2 )
					if(  vetValue[2] <= 50 )
						vetValue[2] = '20' + vetValue[2];
					else
						vetValue[2] = '19' + vetValue[2];

			
				//-- aggiorna il campo nascosto e riorganizza quello a video
				dateObj.setYear(vetValue[2]); 

				if( strFormat == 'dd/mm/yyyy' )
				{
					dateObj.setMonth(vetValue[1]-1); // 0-11 Month within the year (January = 0)
					dateObj.setDate(vetValue[0]); // 1-31
	
					//ObjHidden.value = textDate.substr( 6 , 4) + '-' + textDate.substr( 3 , 2) + '-' + textDate.substr( 0 , 2) + 'T00:00:00';
					ObjHidden.value = zero( dateObj.getFullYear(),4) + '-' + zero( (dateObj.getMonth()+1),2) + '-' + zero(dateObj.getDate(),2) + 'T00:00:00';
					obj_field.value = zero(dateObj.getDate(),2) + '/' + zero( (dateObj.getMonth()+1),2) + '/' + zero( dateObj.getFullYear(),4);
				}
				else
				{
					dateObj.setMonth(vetValue[0]-1); // 0-11 Month within the year (January = 0)
					dateObj.setDate(vetValue[1]); // 1-31
	
					ObjHidden.value = zero( dateObj.getFullYear(),4) + '-' + zero( (dateObj.getMonth()+1),2) + '-' + zero(dateObj.getDate(),2) + 'T00:00:00';
					obj_field.value =  zero( (dateObj.getMonth()+1),2) + '/' + zero(dateObj.getDate(),2) + '/' + zero( dateObj.getFullYear(),4);
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

	if( strFormat == 'dd/mm/yyyy' )
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
 				const_width=255;
				const_height=225;
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

	if (Number(HHDate) >= 0 && Number(HHDate) < 24){
		HHDate = zero(HHDate,2);
		ObjHidden.value = strValueHidden.substr( 0,11 ) + HHDate + strValueHidden.substr( 13, 6) 
		//alert(ObjHidden.value );
		// '2007-12-24T00:00:00'

	}else{
		objHHDate.value='00';
		ObjHidden.value = strValueHidden.substr( 0,11 ) + '00' + strValueHidden.substr( 13, 6); 		
	}
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
	
	if (Number(HHDate) >= 0 && Number(HHDate) < 60){
		HHDate = zero(HHDate,2);
		ObjHidden.value = strValueHidden.substr( 0,14 ) + HHDate + strValueHidden.substr( 16, 3); 
		//alert(ObjHidden.value );
		// '2007-12-24T00:00:00'

	}else{
		objHHDate.value='00';
		ObjHidden.value = strValueHidden.substr( 0,14 ) + '00' + strValueHidden.substr( 16, 3); 		
	}
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

	if (Number(HHDate) >= 0 && Number(HHDate) < 60){
		HHDate = zero(HHDate,2);
		ObjHidden.value = strValueHidden.substr( 0,17 ) + HHDate ; 
		//alert(ObjHidden.value );
		// '2007-12-24T00:00:00'

	}else{
		objHHDate.value='00';
		ObjHidden.value = strValueHidden.substr( 0,17 ) + '00' ; 		
	}
}

function CompletaCampoTecnicoDate(namefield){

	ObjHidden=getObj(namefield);
	strValueHidden=ObjHidden.value;
	if (strValueHidden.length==10)
		ObjHidden.value = strValueHidden +'T00:00:00';
	if (strValueHidden.length==13)
		ObjHidden.value = strValueHidden + '00:00';
	if (strValueHidden.length==16)
		ObjHidden.value = strValueHidden + '00';

}