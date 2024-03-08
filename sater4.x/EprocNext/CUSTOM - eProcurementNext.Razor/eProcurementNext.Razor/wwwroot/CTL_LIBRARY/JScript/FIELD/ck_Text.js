
//-- Versione=1&data=2012-06-01&Attvita=37854&Nominativo=FedericoLeone

//-- la funzione aggiorna un campo testo ed il suo corrispettivo visuale
function SetTextValue( objName , value )
{
	var val;
	var Field;
	var Field_V;
	
	//-- verifica se il campo è unico o un array, in tal caso lavora sul primo
	try 
	{
		Field = getObj( objName );
		Field.value = value;
		
		//se la classe è fld_Evidence la cambio
		if (Field.className=='fld_Evidence')
			Field.className='Text';
			
	}catch ( e ) {
		
	}
	
	try 
	{
		Field_V = getObj( objName + '_V' );
		if (value=='')
			Field_V.innerHTML = ' ';
		else
			Field_V.innerHTML = value;
		
		//se la classe è fld_Evidence la cambio
		if (Field_V.className=='fld_Evidence')
			Field_V.className='Text';
			
	}catch ( e ) {
		
	}	

}

function CheckCF( obj )
{
	//Se il valore non è lungo ne 16 (cf) ne 11 (piva)
	if( obj.value.length != 16 & obj.value.length != 11 )
	{
		AF_Alert('La lunghezza del codice fiscale non e\' corretta: il codice fiscale deve essere lungo o 11 o 16 caratteri');
		return false;
	}

	if ( obj.value.length == 11 )
	{
		CheckIVA( obj, false );
		return false;
	}
  
	var r = ControllaCF( obj.value )
	if ( r != '' )
	{
		AF_Alert( r );
		obj.value = '';
	}
}

function CheckCfPersonaFisica( obj )
{
	var r = ControllaCF( obj.value )
	if ( r != '' )
	{
		AF_Alert( r );
		obj.value = '';
	}
}

function CheckIVA( obj, prefissoObbligatorio, codStato, ParamPath  )
{
	var pi = obj.value;
	
	if ( prefissoObbligatorio == false )
		pi = 'IT' + pi;
	/*
	//Se è stato messo il prefisso IT davanti la partita iva
	if ( pi.substring(0,2).toUpperCase() == 'IT' )
	{
		pi = pi.substring(2); //Ci tolgo la sigla dello stato
		var r = ControllaPIVA( pi );
		
		if ( r != '' )
		{
			AF_Alert( 'Partita iva non valida' );
			obj.value = '';
		}
		else
		{
			obj.value = obj.value.toUpperCase();
		}
	}
	else
	{
		AF_Alert('La partita iva deve iniziare per IT');
		obj.value = '';
	}
	
	*/
	
	//se codice dello stato non passato lo recuperoda un campo
	//fisso "STATOLOCALITALEG" utilizzato in tutte le istanze
	if ( codStato == undefined ) 
	{
		try 
		{
			codStato = 	getObjValue('STATOLOCALITALEG2');
		}
		catch(e)
		{
			codStato='';
		}
		
		//se vuoto allora lo settocome Italia
		if ( codStato == '')
			codStato = 'M-1-11-ITA';
	}
	
	//setto il path
	if ( isSingleWin() )
	{
		ParamPath = pathRoot;
	}
	else
	{
		/* PER LA VERSIONE MULTI FINESTRA, VEDI EMPULIA, IL PATH LO RECUPERIAMO DAL PARAMETRO OPZIONALE ALTRIMENTI USIAMO IL DEFAULT  */
		if ( ParamPath === undefined) 
		{
			ParamPath = '../../';
		}
	}
	
	
	var resp;
	resp =  checkPIVA_ext( ParamPath ,codStato,pi,'YES');
	
	var arr=resp.split("#");
			
	if ( arr[0] == '0' ) //Se è stato restituito il warning di controllo
	{
		
		//DMessageBox( '../' , 'NO_ML###' + decodeHTMLEntities(arr[1]), 'Attenzione' , 1 , 400 , 300 );
		AF_Alert( 'NO_ML###' + decodeHTMLEntities(arr[1]) );
	}
	if ( arr[0] == '2' ) //Errore server
	{
		obj.value = '';
		//DMessageBox( '../' , 'NO_ML###Errore server' , 'Attenzione' , 1 , 400 , 300 );
		AF_Alert( 'NO_ML###Errore server' );			
	}
	
	if ( arr[0] == '1' ) //OK
	{
			obj.value = obj.value.toUpperCase();
		return;
	}
	
	
}

function ControllaCF(cf)
{
    var validi, i, s, set1, set2, setpari, setdisp;
    if( cf == '' )  return '';
    cf = cf.toUpperCase();
    if( cf.length != 16 )
        return "La lunghezza del codice fiscale non e\' corretta: il codice fiscale dovrebbe essere lungo esattamente 16 caratteri.";
    validi = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    for( i = 0; i < 16; i++ ){
        if( validi.indexOf( cf.charAt(i) ) == -1 )
            return "Il codice fiscale contiene  caratteri non validi. I caratteri validi sono le lettere e le cifre.";
    }
    set1 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    set2 = "ABCDEFGHIJABCDEFGHIJKLMNOPQRSTUVWXYZ";
    setpari = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    setdisp = "BAKPLCQDREVOSFTGUHMINJWZYX";
    s = 0;
	
	//prima di fare il controllo gestisco i caratteri per l'OMOCODIA
	//non serve perchè non ritorna il codice fiscale 
	//per quei CF con omocodia la lettera di controllo cambia
	//cf = Handle_Omocodia(cf);
	
    for( i = 1; i <= 13; i += 2 )
        s += setpari.indexOf( set2.charAt( set1.indexOf( cf.charAt(i) )));
    for( i = 0; i <= 14; i += 2 )
        s += setdisp.indexOf( set2.charAt( set1.indexOf( cf.charAt(i) )));
    if( s%26 != cf.charCodeAt(15)-'A'.charCodeAt(0) )
        return "Il codice fiscale non e\' corretto: il codice di controllo non corrisponde.";
    return "";
}

function ControllaPIVA(pi)
{
    if ( pi == '00000000000' )  return 'La partita IVA non e\' valida.';
	if( pi == '' )  return '';
    if( pi.length != 11 )
        return "La lunghezza della partita IVA non e\' corretta: la partita IVA dovrebbe essere lunga esattamente 11 caratteri.";
    validi = "0123456789";
    for( i = 0; i < 11; i++ ){
        if( validi.indexOf( pi.charAt(i) ) == -1 )
            return "La partita IVA contiene un carattere non valido. I caratteri validi sono le cifre.";
    }
    s = 0;
    for( i = 0; i <= 9; i += 2 )
        s += pi.charCodeAt(i) - '0'.charCodeAt(0);
    for( i = 1; i <= 9; i += 2 ){
        c = 2*( pi.charCodeAt(i) - '0'.charCodeAt(0) );
        if( c > 9 )  c = c - 9;
        s += c;
    }
    if( ( 10 - s%10 )%10 != pi.charCodeAt(10) - '0'.charCodeAt(0) )
        return "La partita IVA non e\' valida: il codice di controllo non corrisponde.";
    return '';
}


function ControllaCF_PG( obj )
{
	var r = ControllaCF_PG_sub( obj.value )
	if ( r != '' )
	{
		AF_Alert( r );
		obj.value = '';
	}
}

function ControllaCF_PG_sub( pi )
{

    
    if( pi == '' )  return '';
    if( pi.length != 11 )
        return "La lunghezza del Codice Fiscale non e\' corretto: la sua lunghezza dovrebbe essere esattamente 11 caratteri.";
    validi = "0123456789";
    for( i = 0; i < 11; i++ ){
        if( validi.indexOf( pi.charAt(i) ) == -1 )
            return "IL Codice Fiscale contiene un carattere non valido. I caratteri validi sono le cifre.";
    }
    s = 0;
    for( i = 0; i <= 9; i += 2 )
        s += pi.charCodeAt(i) - '0'.charCodeAt(0);
    for( i = 1; i <= 9; i += 2 ){
        c = 2*( pi.charCodeAt(i) - '0'.charCodeAt(0) );
        if( c > 9 )  c = c - 9;
        s += c;
    }
    if( ( 10 - s%10 )%10 != pi.charCodeAt(10) - '0'.charCodeAt(0) )
        return "Il Codice Fiscale non e\' valido: il codice di controllo non corrisponde.";
    return '';
}
 //il modello di espressione regolare segnalato da \D corrisponde a qualunque carattere  che non corrisponda alle cifre numeriche da 0 a 9        
function ValidateNumber ( Expression , obj )
{
 
    var controllo=obj.value;   

    if (controllo.search(Expression)!= -1) 
   {
    
	//DMessageBox( '../' , 'Errore_SoloNumeri' , 'Attenzione' , 1 , 400 , 300 );
	AF_Alert( 'Errore_SoloNumeri' );
	//obj.focus();
	setTimeout(function() { document.getElementById(obj.id).focus(); }, 10);
	obj.value='';
	 
	
   }		 
}

function verifyEmail( obj )
{
	var status = false;     
	var emailRegEx = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,20}$/i;
	var email=obj.value;

	try
	{
		if ( email !== '') 
		{
		
			//Se ci sono N email
			if ( email.indexOf(";") > -1 )
			{
				var emails = email.split(";");
				for (var i = 0, length = emails.length; i < length; i++) 
				{
					var mail = emails[i];
					
					//Facciamo la trim delle singole email. (non uso la .trim() perchè funziona da IE9+)
					mail = mail.replace(/^\s+|\s+$/g, ''); 
					
					if (mail.search(emailRegEx) == -1) 
					{
						AF_Alert("Inserire un indirizzo Mail valido.");
						obj.value = '';
						return status;
					}
				}
			}
			else
			{
				if (email.search(emailRegEx) == -1) 
				{
					AF_Alert("Inserire un indirizzo Mail valido.");
					obj.value = '';
				}
			}
			
		}
	}
	catch(e)
	{
	}
	
    return status;
}



function DownloadCertificato()
{
	var idDoc;
	idDoc = document.getElementById('IDDOC').value;
	ExecFunctionCenter('../../pdf.aspx?mode=DOWNLOAD_CERTIFICATO&IDDOC=' + idDoc + '#download#500,500');
}

function openAzi()
{
	var nIdAzienda;
	nIdAzienda= document.getElementById('IdAzi').value;
	
	var const_width;
	const_width=780;
	
	var const_height;
	const_height=500;
	
	var sinistra;
	sinistra=(screen.width-const_width)/2;
	
	var alto;
	alto=(screen.height-const_height)/2;
	
	window.open('../../customdoc/VisualizzaAzienda.asp?IdPfu=&strFlag=OK&idAzi=' + nIdAzienda + '&IDMP=&intTab=0&strNomeCampo=-1&Provenienza=1','Run_Dati_AziendaLinked','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
	
}

function checkPIVA_ext( path, codStato , piva, eu_EXT )
{
	ajax = GetXMLHttpRequest(); 

	if(ajax)
	{

		if (eu_EXT == undefined)
			eu_EXT = 'NO';
		
		if ( piva.length < 3 )
			return "0#Inserire la Partita Iva";

		/*
		'-- Parametri di input : 
		'--		* STATO = Codice di 2 cifre per indicare il paese di provenienza
		'--		* PIVA  = Partita iva ( Inizia con le 2 cifre dello stato )
				
		'-- Output :  ( esempi )
		'--		* 0#Tutto ok
		'--		* 1#Messaggio di warning. La codifica non corrisponde con lo stato
		'--		* 2#Errore. Partita iva non valida
		*/
		var nocache = new Date().getTime();
		
		ajax.open("GET", path + 'CTL_Library/functions/verificaPIVA.asp?PIVA=' + escape( piva ) + '&STATO=' + escape( codStato ) + '&EXT=' + eu_EXT + '&nocache=' + nocache , false);
		ajax.send(null);

		if(ajax.readyState == 4) 
		{
			if(ajax.status == 200)
			{
				return ajax.responseText;
			}
			else
			{
				return "2#Server error";	
			}
		}
		else
		{
			return "2#Server error";
		}

	}
	else
	{
		return "2#Server error";
	}
	
	return "";

}

function checkCountry(path, codStato , descStato)
{
	/* 
		Pagina atta alla verifica della presenza di uno Stato nella domini gerarchici con associata
		una descrizione in lingua
	*/
	
	ajax = GetXMLHttpRequest(); 

	if(ajax)
	{
			//Meglio encodeURIComponent o escape ?
			ajax.open("GET", path + 'CTL_Library/functions/checkStato.asp?DESC=' + escape( descStato ) + '&STATO=' + escape( codStato ), false);
			 
			ajax.send(null);
			
			if(ajax.readyState == 4) 
			{
				if(ajax.status == 200)
				{
					return ajax.responseText;
				}
				else
				{
					return "2#Server error";	
				}
			}
			else
			{
				return "2#Server error";
			}

	}
	else
	{
		return "2#Server error";
	}
	
	return "";

}

function validateField( regExp, obj, blockAlert )
{
	var str = obj.value;
	var ret = true;
	
	//Se il parametro opzionale blockAlert non è stato passato, metto false come default
	if (blockAlert === undefined) blockAlert = false;
	
	if ( str != '' )
	{
		var patt = new RegExp( convertRegExp(regExp) );
		
		str = ReplaceExtended(str,'.',',');
		
		if (patt.test(str) == false)
		{
			ret = false;
			if ( !blockAlert )	AF_Alert("Valore non ammesso");
			obj.value = '';
			//DMessageBox( '../' , 'Errore_SoloNumeri' , 'Attenzione' , 1 , 400 , 300 );
		}
	}
	
	return ret;
}

function convertRegExp(regExp)
{
	return regExp
}


//LocalitaRapLeg2, ProvinciaRapLeg2, impostaLocalita
//openGEO('LocalitaRapLeg2','ProvinciaRapLeg2','RapLeg','impostaLocalita')
function openGEO(comune,provincia,fieldname, jsFunc, path, key_help, Format)
{
	codApertura = 'M-1-11-ITA';
	
	var tmp = getObj(comune).value;
	if ( !path )
	{
		path = '../../';
	}
	if ( tmp !== '' )
	{
		codApertura = tmp;
	}
	else
	{
		var tmp = getObj(provincia).value;
		
		if ( tmp !== '' )
			codApertura = tmp;
	}
	
	//Se il parametro key_help non viene passato uso un default
	if (key_help === undefined || !key_help){
		key_help = 'help_geo_ente';
	}
	
	var strQS = 'lo=content&portale=no&fieldname=' + escape(fieldname) + '&path_filtra=GEO&caption=Dominio GEO&help=' + key_help + '&path_start=GEO&lvl_sel=,3,6,7,&lvl_max=7&cod=' + codApertura + '&js=' + escape(jsFunc);
	
	//Inserito il campo format per poter estrarre i dati in maniera dinamica 02/02/2022
	if (Format !== undefined && Format.trim()!=="") 
	{
		strQS = strQS +'&Format=' + Format.trim();
	}
		
	if ( isSingleWin() ) {
		//ExecFunction(  '../../Ctl_Library/gerarchici.asp?lo=content&portale=no&fieldname=' + escape(fieldname) + '&path_filtra=GEO&caption=Dominio GEO&help=' + key_help + '&path_start=GEO&lvl_sel=,3,6,7,&lvl_max=7&cod=' + codApertura + '&js=' + escape(jsFunc) , 'DOMINIO_GEO' , ',width=700,height=750' );
		ExecFunction(  '../../Ctl_Library/gerarchici.asp?' + strQS , 'DOMINIO_GEO' , ',width=700,height=750' );
	} else {
		//ExecFunction(  path + 'Ctl_Library/gerarchici.asp?lo=content&portale=no&fieldname=' + escape(fieldname) + '&path_filtra=GEO&caption=Dominio GEO&help=' + key_help + '&path_start=GEO&lvl_sel=,3,6,7,&lvl_max=7&cod=' + codApertura + '&js=' + escape(jsFunc) , 'DOMINIO_GEO' , ',width=700,height=750' );
		ExecFunction(  path + 'Ctl_Library/gerarchici.asp?' + strQS , 'DOMINIO_GEO' , ',width=700,height=750' );
	}
}



function enableDisableAziGeo(comune,provincia,stato,geo,bool,regione)
{
	try 
	{
		statoDoc = getObjValue('StatoDoc');
	}
	catch(e)
	{
		statoDoc='';
	}
	
	getObj(comune).readOnly = bool;
	getObj(provincia).readOnly = bool;
	getObj(stato).readOnly = bool;
	
	if (regione !== undefined) getObj(regione).readOnly = bool;
	
	/* Se si sta mettendo readonly i field geografici aggiunto un evento per non permettere l'input,
		in particolare per evitare che con IE usando il 'backspace' il browser effettui un 'indietro' */
	try
	{
		if ( bool ) 
		{
			getObj(stato).onkeydown =  function(event){return false;};
			getObj(provincia).onkeydown =  function(event){return false;};
			getObj(comune).onkeydown =  function(event){return false;};		
			if (regione !== undefined) getObj(regione).onkeydown =  function(event){return false;};		
		}
		else
		{
			getObj(stato).onkeydown = '';
			getObj(provincia).onkeydown = '';
			getObj(comune).onkeydown = '';
			if (regione !== undefined) getObj(regione).onkeydown = '';
		}
	}
	catch(e){}

	try 
	{
		Not_Editable = getObjValue('Not_Editable');
	}
	catch(e)
	{
		Not_Editable='';
	}
	
	if ( ( statoDoc != 'Saved' && statoDoc != '' ) || ( Not_Editable.indexOf(comune+' ') > 0 && Not_Editable.indexOf(provincia+' ') > 0 && Not_Editable.indexOf(stato+' ') > 0 ) )
	{
		getObj(geo + '_link').setAttribute("onclick", "return false;" );
		getObj(geo).className = "";
		getObj(geo + '_link').style.cursor="default";
	}
}

function disableGeoField(idField, bool)
{
	getObj(idField).readOnly = bool;

	if ( bool ) 
	{
		getObj(idField).onkeydown =  function(event){return false;};
	}
	else
	{
		getObj(idField).onkeydown = '';
	}
}

function isMyCF(path, nome , cognome, cf)
{
	/* 
		Funzione che controlla la coerenza di nome e cognome con codice fiscale di una persona fisica
	*/
	
	ajax = GetXMLHttpRequest(); 
	
	var ajaxRes = '';
	var res = true;

	if(ajax)
	{
		ajax.open("GET", path + 'ctl_library/functions/checkcf.asp?NOME=' + encodeURIComponent(nome) + '&COGNOME=' + encodeURIComponent(cognome) + '&CF=' + encodeURIComponent(cf), false);
		ajax.send(null);

		if(ajax.readyState == 4) 
		{
			if(ajax.status == 200)
			{
				ajaxRes = ajax.responseText;
				
				//Se i dati sono giusti
				if ( ajaxRes == '1#1' )
				{
					res = true;
				}
				
				//Se il cf non è della persona passata
				if ( ajaxRes == '1#0' )
				{
					res = false;
				}
				
				//Se c'è stato un errore server gestito
				if ( ajaxRes.substring(0, 2) == '0#' )
				{
					AF_Alert(ajaxRes.substring(3, str.length));
					res = false;
				}
			}
			else
			{
				AF_Alert('Errore server checkcf');
				res = true;
			}
		}
		else
		{
			AF_Alert('Errore server checkcf');
			res = true;
		}

	}
	else
	{
			AF_Alert('Errore server checkcf');
			res = true;
	}
	
	return res;
}
function TextreadOnly(objName,b)
{
  try{ getObj(objName).readOnly=b; } catch( e ){};	
  if ( b == true )
     getObj(objName).className =  getObj(objName).className + ' readonly';
  if ( b == false )
   getObj(objName).className = ReplaceExtended(getObj(objName).className,' readonly','')
   
}

function verifyCap( idFieldCodiceGEO, objCap )
{
	/* 
		idFieldCodiceGEO : id del campo contenente il codice del comune (o del livello più basso di un insieme di dati GEO). 
		cap 	 		 : oggetto 'this' su cui è scattato l'onChange o su cui si vuole valire il cap		
	*/

	var ret = true;
	
	try
	{
		var codStato = '';
		codStato = getObj(idFieldCodiceGEO).value;

		if ( codStato !== '' )
		{
			codStato = codStato.substring(0, 10);
		}

		//Se il cap è diverso da stringa vuota e lo stato è Italia
		if ( objCap.value !== '' && codStato == 'M-1-11-ITA' )
		{
			ret = validateField('^[\\d]{5,5}$',objCap, true);

			if ( !ret )
				AF_Alert('CAP immesso non corretto');

		}
	}
	catch(e)
	{
	}

	return ret;
}


function Handle_Omocodia( Cf_In ){
	
	//rimpiazzo le lettere nelle posizioni riservate ai numeri
	//7-8-10-11-13-14-15
	//PNNNRC71T23C361L
	//0 = L   |   1 = M   |   2 = N   |   3 = P   |   4 = Q
	//5 = R  |    6 = S   |   7 = T   |   8 = U   |   9 = V
	var tempChar ='';
	var i;

	for( i = 6; i < 15; i++ )
	{
				
		tempChar = Cf_In.substring(i, i+1);
		
		//alert('prima=' + tempChar);
		
		tempChar = tempChar.replace('L','0');	
		tempChar = tempChar.replace('M','1');	
		tempChar = tempChar.replace('N','2');	
		tempChar = tempChar.replace('P','3');	
		tempChar = tempChar.replace('Q','4');	
		tempChar = tempChar.replace('R','5');	
		tempChar = tempChar.replace('S','6');	
		tempChar = tempChar.replace('T','7');	
		tempChar = tempChar.replace('U','8');	
		tempChar = tempChar.replace('V','9');	
		
		//alert('dopo=' +tempChar);
		
		Cf_In = Cf_In.substring(0, i) + tempChar + Cf_In.substring(i+1, 16 ) ;
		
		//alert(cf);
		
		if ( i == 7)
			i = 9;
		
		if ( i == 10)
			i = 12;	
		
    }
 	
	return (Cf_In);
	//alert(cf);
		
}

//serve a mettere in un afrase ogni parola con la prima lettera maiuscola
//usata per i campi Cognome e Nome
function Input_Upper_First_Letter( obj )
{
	
	//richiama la funzione generica presente in main.js
	obj.value = Upper_First_Letter( obj.value );
	
}