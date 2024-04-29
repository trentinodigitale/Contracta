/*<script language="javascript">*/
/*-----------------------------------------------------------------------------------------*/
	//@bfunc Public | setBackgroundImage | void | questa funzione setta il background di una 
	// cella di una tabella

	//@bparm target | string | sarebbe l'id della cella
	//@bparm imageBack | string | l'imagine che si caricare

	function setBackgroundImage(target, imageBack){
	if (document.all != null) //  controllo il browser in uso
	target.background = imageBack.src;//explorer
	else {
		tempImage = "background-Image: url(" + imageBack.src + ");"//netscape
		target.setAttribute("style", tempImage) 
	}
}

	/*-----------------------------------------------------------------------------------------*/
	//@bfunc Public | setStyleById | void | questa funzione setta una proprieta di una classe

	//@bparm id_element | long | sarebbe l'id del elemento a cui appartiene la classe
	//@bparm s_class | string | classe di cui vogliamo cambiare una proprieta
	//@bparm s_property | string | proprieta da settare
	//@bparm s_value_property | string | valore della proprieta

	function setStyleById(id_element,s_property,s_value_property){
	var ie = (document.all) ? true : false;
	var elements;
	// '*' not supported by IE/Win 5.5 and below
	element = (ie) ? document.all(id_element) : document.getElementById(id_element);

	var node = element;
	eval('node.style.' + s_property + " = '" +s_value_property + "'" );
	
}
	/*-----------------------------------------------------------------------------------------*/
	//@bfunc Public | setStyleByObject | void | questa funzione setta una proprieta di una classe

	//@bparm objTarget | object | oggetto di cui vogliamo cambiare una propriet
	//@bparm s_property | string | proprieta da settare
	//@bparm s_value_property | string | valore della proprieta

	function setStyleByObject(objTarget,s_property,s_value_property){

	try {
		var ie = (document.all) ? true : false;
	var node = objTarget;
	eval('node.style.' + s_property + " = '" +s_value_property + "'" );
	} catch (e) {

		alert('setStyleByObject error');
	}
	
	
}



	/*-----------------------------------------------------------------------------------------*/
	//@bfunc Public | setStyleByClass | void | questa funzione setta una proprieta di una classe a partire da una classe

	//@bparm t | long | sarebbe l'id del elemento a cui appartiene la classe
	//@bparm c | string | classe di cui vogliamo cambiare una proprieta
	//@bparm p | string | proprieta da settare
	//@bparm v | string | valore della proprieta

	function setStyleByClass(t,c,p,v){
	var elements;
	var ie = (document.all) ? true : false;
	// '*' not supported by IE/Win 5.5 and below
	elements = (ie) ? document.all : document.getElementsByTagName(t);

	for(var i = 0; i < elements.length; i++){
		var node = elements.item(i);
	if(node.tagName.toUpperCase()==t.toUpperCase() && node.className.toUpperCase()==c.toUpperCase()) {
		eval('node.style.' + p + " = '" + v + "'");
		}
	}
}



	function setBgColor(target, colorBack){
	if (document.all != null) //  controllo il browser in uso
	target.background = colorBack;//explorer
	else {
		tempImage = "background-Color: colorBack;"//netscape
		target.setAttribute("style", tempImage) 
	}
}

	/*-----------------------------------------------------------------------------------------*/
	//@bfunc Public | setVisibility | void | questa funzione setta la visibilita di una div
	//@bparm target | string | sarebbe l'id della cella
	//@bparm imageBack | string | l'imagine che si caricare

	function setVisibility(target, objState){
		/*
		if(target != null)
			{
				if (document.all != null) //  controllo il browser in uso
					target.style.display= objState//explorer
				else {
					tempState="display:"+objState+";"//netscape
					target.setAttribute("style", tempState) 
				}
			}
		*/

		target.style.display = objState ;
}



	/*-----------------------------------------------------------------------------------------*/
	//@bfunc Public | setTop | void | questa funzione setta la visibilita di una div
	//@bparm target | string | sarebbe l'id della cella
	//@bparm imageBack | string | l'imagine che si caricare

	function setTop(target, strTop){

	if (document.all != null) //  controllo il browser in uso
	target.style.top= strTop//explorer
	else {
		tempState = "top:" + strTop + ";"//netscape
		target.setAttribute("style", tempState) 
	}
}

	//@bfunc Public | getObj | object | questa funzione a fronte di un id
	// recupera l'oggetto ad esso associato
	//@bparm strId | string | sarebbe l'id dell'elemento

	function getObj(strId) {
	
	//document.all!= null ? return document.all(strObject) : return document.getElementById(strObject))
	if (document.all != null)
	return document.all(strId)
	else{
		return document.getElementById(strId)
		}
}


	function getObjPage( strId, docPage)
	{
	if( docPage	 == '' )
	{
		docPage = 'self';
	}



	try{
		mydocument = eval(docPage + '.document');
	}catch(e){
		return getObj(strId);
	}

	if ( mydocument == undefined )
	return getObj(strId);

	if (mydocument.all != null)
	{
		
		return mydocument.all(strId);
	}
	else
	{
		
		return mydocument.getElementById(strId);
	}
}

	//@bfunc Public | setClassName | void | questa funzione a fronte di un id
	// cambia la classe associata all'oggetto
	//@bparm target | string | l'oggetto
	//@bparm clsName | string | nuova classe da caricare

	function setClassName(target, clsName){
	if (document.all != null)
	target.className=clsName;
	else {
		target.setAttribute("className", clsName)
	}
}

	function setClassName1(target, clsName){
	if (document.all != null)
	target.className=clsName;
	else {
		target.setAttribute("class", clsName)
	}
}

	// How Use GetProperty(getObj("Id1"), "Property")
	function GetProperty(objTarget, NameProperty)  {

	return objTarget.getAttribute(NameProperty);


}

	// How Use SetProperty(getObj("Id1"), "Property" ,'')
	function SetProperty(objTarget, NameProperty, ValueProperty)  {

	if (objTarget != null)
	objTarget.setAttribute(NameProperty, ValueProperty);

}



	//@bfunc Public | getObjDoc | object | questa funzione dato un documento e un id,
	// recupera l'oggetto ad esso associato
	//Carmine Vella 19/03/2003
	//@bparm strId | object | Documento sul quale recuperare l'oggetto											
	//@bparm strId | string | sarebbe l'id dell'elemento

	function getObjDoc(objdocument,strId) {
	
	if (objdocument.all != null)
	return objdocument.all(strId)
	else
	return objdocument.getElementById(strId)
}

	//Carmine Vella
	//Scritto perchè mi serve l'istruzione document.all 
	//che per Netscape si traduce in document.layers
	function GetAll(objdocument) {
	
	if (objdocument.all != null)
	return objdocument.all
	else
	return objdocument.layer
}

	function unDec(number){
		var value;
	if (number==0) value='0';
	else if (number==1) value='1';
	else if (number==2) value='2';
	else if (number==3) value='3';
	else if (number==4) value='4';
	else if (number==5) value='5';
	else if (number==6) value='6';
	else if (number==7) value='7';
	else if (number==8) value='8';
	else if (number==9) value='9';
	else if (number==10) value='A';
	else if (number==11) value='B';
	else if (number==12) value='C';
	else if (number==13) value='D';
	else if (number==14) value='E';
	else if (number==15) value='F';
	else value='';
	return value;
}

	function hexize(rgbvalue){


		number = rgbvalue;
	s_value="";
	do {
		s_value = s_value + unDec(number - Math.floor(number / 16) * 16);
	number = Math.floor(number/16);
	
	} while (number>=16)
	s_value = s_value + unDec(number);
	tempValue='';
	for(i=s_value.length-1;i>=0;i--)
	tempValue=tempValue+s_value.charAt(i);

	return tempValue;
}

	//sotituisce nella stringa strToken tutte le occorrenze di nChar
	//con due occorrenze di nChar
	function CharReplace(strToken,nChar)
	{
	var cnt1;
	var objStr = new String(strToken);
	var objTmpStr = new String('');
	var LenStr = objStr.length;
	for (cnt1=0; cnt1 < LenStr; cnt1++)
	{
		if ((objStr.charAt(cnt1)) == nChar)
	objTmpStr=objTmpStr+(objStr.charAt(cnt1))+nChar;
	else
	objTmpStr=objTmpStr+(objStr.charAt(cnt1));
	}
	return objTmpStr;
}
	function replace_special_charset(testo){

		//@comm questa funzione provvede a rimpiazzare i caratteri speciali che presentano
		//@comm problemi nel recupero mediante il request form da una pagina creata dinamicamente
		//@comm in javascript.
		//@comm Prende in input il testo da pulire e restituisce il testo pulito.

		//@comm creo l'array dei caratteri speciali:
		//@comm array[0][x] --> carattere speciale
		//@comm array[1][x] --> carattere sostitutivo
		//effettuo il cast sul testo; conversione a string
		testo = testo.toString();
	var check = false; //@comm indica se è stato effettuato un rinmpiazzo.
	var array_charset = new Array(2);
	var lunghezza = testo.length;
	var nuovo_testo = '';
	for(r=0;r<2;r++)
	{
		array_charset[r] = new Array(10);
	}

	array_charset[0][0] = "è";
	array_charset[1][0] = "e'";
	array_charset[0][1] = "é";
	array_charset[1][1] = "e'";
	array_charset[0][2] = "£";
	array_charset[1][2] = "L";
	array_charset[0][3] = "ì";
	array_charset[1][3] = "i'";
	array_charset[0][4] = "ò";
	array_charset[1][4] = "o'";
	array_charset[0][5] = "ç";
	array_charset[1][5] = "c";
	array_charset[0][6] = "à";
	array_charset[1][6] = "a'";
	array_charset[0][7] = "°";
	array_charset[1][7] = "^";
	array_charset[0][8] = "ù";
	array_charset[1][8] = "u'";
	array_charset[0][9] = "§";
	array_charset[1][9] = "$";


	//@comm comincio il replace.
	for (rt=0;rt<=lunghezza;rt++)
	{
    		for (pu=0;pu<=array_charset[0].length;pu++)
	{
    			if (unescape(testo.charAt(rt))==unescape(array_charset[0][pu]))
	{

		nuovo_testo = nuovo_testo + array_charset[1][pu];
	check = true;
	break;
    			  }
    			
    		 }
	if (check == false)
	{
		nuovo_testo = nuovo_testo + unescape(testo.charAt(rt));
    		    }
	check = false;
    }

	return  nuovo_testo;
  
  }


	/*-----------------ReplaceExtended---------------------------------------------
	DESCRIZIONE: effettua la replace di tutte le occorrenze di una stringa
	input:
	  strExpression= la stringa in vui fare la replace
	  strFind=la stringa da cercare
	  strReplace=la stringa da sostituire
			
	output: la nuova stringa
	*/
	function ReplaceExtended(strExpression,strFind,strReplace){

  while (strExpression.indexOf(strFind)>=0)
	strExpression=strExpression.replace(strFind,strReplace);

	return strExpression;
}

	//Restituisce oggetto per chiamata ajax
	function GetXMLHttpRequest() {
	var
	XHR = null,
	browserUtente = navigator.userAgent.toUpperCase();

	if(typeof(XMLHttpRequest) === "function" || typeof(XMLHttpRequest) === "object")
	XHR = new XMLHttpRequest();
	else if(window.ActiveXObject && browserUtente.indexOf("MSIE 4") < 0) {
			if(browserUtente.indexOf("MSIE 5") < 0)
	XHR = new ActiveXObject("Msxml2.XMLHTTP");
	else
	XHR = new ActiveXObject("Microsoft.XMLHTTP");
		}
	return XHR;
};




//innesesca processi nuovi in modalità AJAX dal client
//ritorna: -10 ajax non disponibile
//		    <retcod>###<caption>###<desc>###<ico> 	dove
		//			retcode 0 tutto ok
		//			retcod 1 errore
		//			retcode 2 tutto ok con scelta per continuare
		function ExecProcessAjax( IdMsg , PARAM ){

			ajax = GetXMLHttpRequest();

		if(ajax){


			ajax.open("GET", '<%=Application("strVirtualDirectory")%>/AflCommon/FolderGeneric/ExecdocProcessAjax.asp?IdMsg=' + IdMsg + '&PROCESS_PARAM=' + escape(PARAM), false);

		ajax.send(null);

		if(ajax.readyState == 4) {
  				//alert(ajax.status);
  				if(ajax.status == 200)
		{
  					//alert(ajax.responseText);
  					return ajax.responseText;
  				}
  			}
  
  	}
		return '-10###ExecProcessAjax###Funzione Non Disponibile###2';
}



		function SUB_AJAX( URL ){

			ajax = GetXMLHttpRequest();

		if(ajax){


			ajax.open("GET", URL, false);

		ajax.send(null);
		if(ajax.readyState == 4) {
				if(ajax.status == 200)
		{
					return ajax.responseText;
				}
			}

	}
		return '';
}

		function getQSParamFromString(strQueryString , ParamName) {

			// Memorizzo tutta la QueryString in una variabile
			QS = strQueryString ;
		// Posizione di inizio della variabile richiesta
		var indSta=QS.indexOf(ParamName + '=');
		// Se la variabile passata non esiste o il parametro vuoto, restituisco null
		if (indSta==-1 || ParamName=="") return null;
		// Posizione finale, determinata da una eventuale &amp; che serve per concatenare più variabili
		var indEnd=QS.indexOf('&',indSta);
		// Se non c'e una &amp;, il punto di fine e la fine della QueryString
		if (indEnd==-1) indEnd=QS.length;
		// Ottengo il solore valore del parametro, ripulito dalle sequenze di escape
		var valore = unescape(QS.substring(indSta+ParamName.length+1,indEnd));
		// Restituisco il valore associato al parametro 'ParamName'
		return valore; 
  }

		//apre un documento generico 
		function Open_GenericDocument( cod , path ){


	//var nq;



	//-- recupero il codice della riga passata
	//cod = GetIdRow( objGrid , Row , 'self' );
	
	var w;
		var h;
		var Left;
		var Top;

		w = 800;
		h = 600;
		Left= (screen.availWidth - 800) / 2;
		Top= (screen.availHeight - 600) / 2;;

	//var strDoc='';
	//try {strDoc = getObj('DOCUMENT').value; } catch( e ) { };

		ExecFunction(  path + 'OpenDoc.asp?lIdMsgPar=' + cod+ '&Name=&lIdmpPar=1&StrCommandPar=OPENDOC' , 'OPEN_GENERIC_DOC_' + cod , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );
  

} 
  
/*</script>*/