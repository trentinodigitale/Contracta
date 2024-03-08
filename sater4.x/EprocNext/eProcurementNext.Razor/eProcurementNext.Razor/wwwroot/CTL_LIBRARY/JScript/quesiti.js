
function getObj(strId) {
	if (document.all != null)
		return document.all(strId)
	else{
		return document.getElementById(strId)
	}
}

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
		//alert(XHR);
		return XHR;
  };



  ajax = GetXMLHttpRequest();   
  
  
//visualizza il dettaglio di un documento dalla area ULTIMI BANDI del portale
function PrintDocument( cod )
{
	var cod;
	var nq;
	
	var w;
	var h;
	var Left;
	var Top;
    
	var strDoc='';
	try { 
		//strDoc = getObj('DOCUMENT').value; 
            	strDoc=getObj('DOCUMENT').value;
	} catch( e ) {};
	
	try
	{
		refer = '';
		refer = document.referrer;
	
		if  ( ( refer.toUpperCase().indexOf('SAVEDOC.ASP') != -1 && refer.toUpperCase().indexOf('STRCOMMANDPAR=SEND') != -1 ) ||  refer.toUpperCase().indexOf('SENDDOC.ASP') != -1 )
		{
			refer = 'Provenienza=SaveDoc&';
		}
		else
		{
			refer = '';
		}
		
	}
	catch(e)
	{
		refer = '';
	}
	
	//passata quando vengo dalla lista ATV per i nuovi Documenti
	var strProvenienza='';
	try { 
		strProvenienza=getObj('Provenienza').value;
	} catch( e ) {};
	
	
	if ( strDoc != '')
		//si tratta dei nuovi documenti
		strURL = '../report/' + strDoc + '.asp?PORTALE=1&IDDOC=' + cod + '&TYPEDOC=' + strDoc + '&Provenienza=' + strProvenienza;
	else
		//documento generico
		strURL = '../Aflcommon/FolderGeneric/PrintDoc.asp?' + refer + 'FileTemplate=Portale&lIdmpPar=1&StrCommandPar=PRINT&ProvenienzaPortale=1&lIdMsgPar=' + cod  ;	
		
  
	//Recupero Path e descrizione folder per comporre "Ti trovi in:" nei DETTAGLI		
	 var DESCPROVENIENZA;
	 try {
     DESCPROVENIENZA = escape(getObj('descfolder').innerHTML);
     strURL =  strURL + '&DESCPROVENIENZA=' + DESCPROVENIENZA;
	  }catch(e){
      }
	if(ajax){
	    
			ajax.open("GET",  getObj('URL_APP').value + 'backoffice/loginportale.asp?URL=' + escape ( strURL )  , false);
			ajax.send(null);
			
			if(ajax.readyState == 4) {
			   
				if(ajax.status == 200 || ajax.status == 404 || ajax.status == 500)
				{
					try{
					   document.getElementById( 'coldx' ).style.display='none';
					}catch(e){}
          
          try{
             document.getElementById( 'colcx' ).innerHTML =  ajax.responseText;
					   //alert(document.getElementById( 'colcx' ).getAttribute('class')) ;
					   //if ( document.getElementById( 'colcx' ).getAttribute('class') != 'largeview')
					   document.getElementById( 'colcx' ).setAttribute('class','large');
					   //document.getElementById( 'colcx' ).style.width='78%';
				  }catch(e){}
          
					try{
             document.getElementById( 'footer' ).setAttribute('class','large');
            //document.getElementById( 'footer' ).style.marginRight='0px';
            //document.getElementById( 'footer' ).style.marginLeft='19.3%';
            
          }catch(e){}
					
					try{
            Forms.init();
          }catch(e){}
          
          
          //inizializzo oggetti suggerimento
          window.addEvent('domready',function(){
            $$('div.tipscontent').each(function(div){
                tipsfx[div.id] = new Fx.Slide(div.id);
                });
          
          $$('div.tipsbar').addEvent('click',function(ev){
          ev = new Event(ev).preventDefault();
          var target = $(ev.target);
          if(target.getTag() =='a'){
          var id = target.href.substring(target.href.indexOf('#')+1);
          tipsfx[id].toggle();
          if(target.hasClass('suggest')) target.getPrevious().setStyle('display','inline');
          else  target.getNext().setStyle('display','inline');
          target.setStyle('display','none'); 
          }
          });
          
          
          if(window.ie6){
              ieMinWidthFix();
            window.onresizeend = ieMinWidthFix;	    	    
          }    
          
          });
          
				}
			}
      
      //recupero le proroghe del bando 
      try {
        PARAMPROROGA= getObj('PARAM_PROROGA').value ;
        ShowListaProroghe( PARAMPROROGA ) ;		
      }catch(e){
      }
      
      InsertQuesiti();
		
	 }
	
}


//visualizza il dettaglio di un documento dal VIEWER DEI BANDI DAL PORTALE
//function PrintDocumentFromViewer( objGrid , Row , c ,td)
function PrintDocumentFromListaPortale( objGrid , Row , c )

{
	var cod;
	var nq;
	
	var w;
	var h;
	var Left;
	var Top;
    
	var strDoc='';
	
	try { strDoc=getObj('R' + Row + '_DOCUMENT').value;}catch( e ) {};
	
	var cod='';
	//cod=prendiElementoDaId('GridViewer_idRow_' + Row).value;
	
	cod = GetIdRow( objGrid , Row , 'self' );
	//alert(cod);
	
	//objForm=prendiElementoDaId('formprint');
	//objForm.action=objForm.action + 'FileTemplate=Portale&lIdMsgPar=' + cod + '&Name=' + strDoc + '&lIdmpPar=1&StrCommandPar=OPENDOC&ProvenienzaPortale=1';
	
	//var strUrl= objForm.action + '&lIdMsgPar=' + cod + '&Name=' + strDoc + '&lIdmpPar=1&StrCommandPar=OPENDOC&ProvenienzaPortale=1';
	//prendiElementoDaId('lIdMsgPar').value=cod ;
	//prendiElementoDaId('Name').value=strDoc ;
	
	//objForm.submit();
	
		
	if ( strDoc != '')
		//si tratta dei nuovi documenti
		strURL = '../report/' + strDoc + '.asp?PORTALE=1&IDDOC=' + cod + '&TYPEDOC=' + strDoc ;
	else
		//documento generico
		strURL = '../Aflcommon/FolderGeneric/PrintDoc.asp?FileTemplate=Portale&lIdmpPar=1&StrCommandPar=PRINT&ProvenienzaPortale=1&lIdMsgPar=' + cod  ;	

    //Recupero Path e descrizione folder per comporre "Ti trovi in:" nei DETTAGLI		
	var DESCPROVENIENZA;
	try {
    DESCPROVENIENZA = escape(getObj('descfolder').innerHTML);
    strURL =  strURL + '&DESCPROVENIENZA=' + DESCPROVENIENZA;
	}catch( e
  ) {};
  
  
  
	if(ajax){
	    
			ajax.open("GET", getObj('URL_APP').value + '/backoffice/loginportale.asp?URL=' + escape ( strURL )  , false);
			ajax.send(null);
			if(ajax.readyState == 4) {
				if(ajax.status == 200 || ajax.status == 404  || ajax.status == 500 )
				{
				  //alert(ajax.responseText);
					document.getElementById( 'colcx' ).innerHTML =  ajax.responseText;
					document.getElementById( 'colcx' ).setAttribute('class','large');
					
					
				  try{
            Forms.init();
          }catch(e){}
          
					
					//inizializzo oggetti suggerimento
          window.addEvent('domready',function(){
          $$('div.tipscontent').each(function(div){
          tipsfx[div.id] = new Fx.Slide(div.id);
          });
          
          $$('div.tipsbar').addEvent('click',function(ev){
          ev = new Event(ev).preventDefault();
          var target = $(ev.target);
          if(target.getTag() =='a'){
          var id = target.href.substring(target.href.indexOf('#')+1);
          tipsfx[id].toggle();
          if(target.hasClass('suggest')) target.getPrevious().setStyle('display','inline');
          else  target.getNext().setStyle('display','inline');
          target.setStyle('display','none'); 
          }
          });
          
          
          if(window.ie6){
              ieMinWidthFix();
            window.onresizeend = ieMinWidthFix;	    	    
          }    
          
          });
          
				}
			}			
	
      
	    
      			  
			//recupero le proroghe del bando 
			try {
			  PARAMPROROGA= getObj('PARAM_PROROGA').value
			  ShowListaProroghe( PARAMPROROGA ) ;		
			}catch(e){
			}
			
			InsertQuesiti();
			
	}
	
}

//per aprire i risultati di gara dal VIEWER DEI BANDI DAL PORTALE
function OpenRisultatoDiGara1( objGrid , Row , c )
{
	var cod;
	var nq;
	var protbando;
	
	//-- recupero il codice della riga passata
	//cod = GetIdRow( objGrid , Row , 'self' );
	
	
	cod = prendiElementoDaId('R'+ Row + '_idDocR').value;		
  
  //se non presente nessun risultato di gara esco senza fare niente	
	if (cod == '0')	
	 return;
	 
	protbando = prendiElementoDaId('R'+ Row + '_ProtocolloBando').value;		
	
	
	var CONTESTO;
	var CONTESTO = 'BANDITRADIZIONALI';
	try { 
		CONTESTO = prendiElementoDaId('R'+ Row + '_CONTESTO').value;		
	} catch( e ) {};
	
	
	
	//alert(CONTESTO);
	strURL = '../report/RisultatoDiGara.asp?CONTESTO=' + CONTESTO + '&PROTOCOLLOBANDO='+ escape(protbando) + '&TYPEDOC=RISULTATODIGARA&MODE=OPEN&IDDOC=' + cod 
	var DESCPROVENIENZA;
  DESCPROVENIENZA = escape(getObj('descfolder').innerHTML);
  strURL =  strURL + '&DESCPROVENIENZA=' + DESCPROVENIENZA;
  var URLPROVENIENZA = escape(self.location);
  strURL =  strURL + '&URLPROVENIENZA=' + URLPROVENIENZA;
	if(ajax){
	    
			ajax.open("GET", getObj('URL_APP').value + '/backoffice/loginportale.asp?URL=' + escape ( strURL )  , false);
			ajax.send(null);
			
			
			
			if(ajax.readyState == 4) {
				if(ajax.status == 200 || ajax.status == 404 || ajax.status == 500)
				{
					//alert(ajax.responseText);
					document.getElementById( 'colcx' ).innerHTML =  ajax.responseText;
					document.getElementById( 'colcx' ).setAttribute('class','large');
					Forms.init();
				}
			}			
		
	}
	

}

//per aprire la modale per fare iscriviti quando clicco su un comando sul detttaglio (ad esempio partecipa)
function Partecipa( targetname ){
	target= getObj(targetname);
	Modal.init();
  Modal.show(target);
}


//recupero la griglia dei quesiti con le risposte se esistono
function ShowListaQuesitiGD( PARAM ){
      
  ajax = GetXMLHttpRequest(); 
  if(ajax){
    
    strURL = '../report/grigliaquesitiGD.asp?PARAM=' + PARAM ;
    
    ajax.open("GET",  getObj('URL_APP').value + '/backoffice/loginportale.asp?URL=' + escape ( strURL ) , false);
    ajax.send(null);
	if(ajax.readyState == 4) {
		
		if(ajax.status == 200 || ajax.status == 404 || ajax.status == 500)
		{
		 	document.getElementById( 'grigliaquesiti' ).innerHTML =  ajax.responseText;
		}
	}	  
  }
}


//effettua la ricerca di un quesito
//PARAM=GUID@SUBTYPE_ORIGIN
function CercaQuesito(){
    
  var PARAM=getObj('PARAM_QUESITINEW').value;
  
  var ainfo=PARAM.split('@');
    
  var GUID_DOC = ainfo[0];
  var SUBTYPE_ORIGIN ;
	try {
	  SUBTYPE_ORIGIN = ainfo[1];
	}catch(e){
	  SUBTYPE_ORIGIN='' ; 
	}
            
    
  
  
  var Filtro=getObj('FiltroQuesito').value;
	
	var backoffice='YES';
  try{
    backoffice=getObj('backoffice').value;
  }catch(e){
  }
  var DOCUMENT;
  
	//è valorizzato solo in caso di nuovo documento
	try {
	  DOCUMENT=getObj('DOCUMENT')[0].value ;  
	}catch(e){

		try{
		 DOCUMENT=getObj('DOCUMENT').value ;  
		}catch(e){

		DOCUMENT='' ; 
		}

	}
	
  var strURL = getObj('URL_APP').value + 'quesiti/grigliaquesiti.asp?backoffice=' + backoffice + '&Filtro=' + escape(Filtro) + '&GUID_DOC=' + GUID_DOC + '&SUBTYPE_ORIGIN=' + SUBTYPE_ORIGIN + '&DOCUMENT=' + DOCUMENT  ;
  //alert(strURL);
	//impostare CONTESTO=S dall'interno
	
  ajax = GetXMLHttpRequest(); 
	if(ajax){
	
			ajax.open("GET", strURL  , false);
      
			ajax.send(null);
			
			if(ajax.readyState == 4) {
			   //alert(strURL);
			  //alert(ajax.status);
				if(ajax.status == 200 || ajax.status == 404 || ajax.status == 500)
				{
			   	var strTemp=ajax.responseText;
				
			   	var ainfo=strTemp.split('###');
         	document.getElementById( 'grigliaquesiti' ).innerHTML =  ainfo[1];
				}
				
        //se nn ci sono chiarimenti nascondo area di ricerca
        if ( ainfo[0] == 0 )
				   document.getElementById( 'arearicercaquesiti' ).style.display='none';
				
			}			
	}
}


function SetUserCurrentInvioQuesito(){

  ajax = GetXMLHttpRequest(); 
	
  if(ajax){
	
  		ajax.open("GET", getObj('URL_APP').value + 'ctl_library/functions/infoCurrentUser.asp', false);

			ajax.send(null);
			
			if(ajax.readyState == 4) {
				
				if(ajax.status == 200 || ajax.status == 404 || ajax.status == 500)
				{
					//alert(ajax.responseText);
					var Infouser=ajax.responseText;
					var ainfo = Infouser.split('#');
					
					try{
					   getObj('OperatoreEconomico').value = ainfo[0]  ;
					   if (getObj('OperatoreEconomico').value != '')
                getObj('OperatoreEconomico').disabled=true;
					   getObj('Telefono').value = ainfo[1]  ;
					   //getObj('Telefono').disabled=true;
					   getObj('Fax').value = ainfo[2]  ;
					   //getObj('Fax').disabled=true;
					   getObj('EMail').value = ainfo[3]  ;
					   if (getObj('EMail').value != '')
					     getObj('EMail').disabled=true;
					   getObj('backoffice').value = 'no'  ;
					   
					}catch(e){
					  //il form nn è presente ma soloil campo backoffice per fare correttamente le query diricerca e visualizzazione dei quesiti
				    getObj('backoffice').value = 'no' ;
          }
				}
				
        //ricarico i quesiti per prendere anche i miei evasi
				CercaQuesito();
			}			
  		
	}
}

 
 //recupero le proroghe associate se esistono
 function ShowListaProroghe( FIELDIDDOC ){
   
    
   ajax = GetXMLHttpRequest(); 
   if(ajax){
  			
        strURL = '../report/proroga.asp?IDMSGBANDOIA=' + FIELDIDDOC ;
    
        ajax.open("GET",  getObj('URL_APP').value + '/backoffice/loginportale.asp?URL=' + escape ( strURL ) , false);
        
  			ajax.send(null);
  			if(ajax.readyState == 4) {
  				if(ajax.status == 200 || ajax.status == 404 || ajax.status == 500)
  				{
  					
  					strListMsg=ajax.responseText;
  					if ( strListMsg != '' ){
  				    var listIdmsg=new Array();
  					  var listIdmsg= strListMsg.split(',') ;
  					 
              for ( iLoop=0; iLoop < listIdmsg.length; iLoop++ ){
                
				var tmpVirtualDir;
				tmpVirtualDir = '/Application';

				if ( isSingleWin() )
					tmpVirtualDir = urlPortale;
				
                ajax.open("GET", tmpVirtualDir + '/report/DisplayProroga.asp?lIdmpPar=1&ProvenienzaPortale=1&lIdMsgPar=' + listIdmsg[iLoop]   , false);        
                ajax.send(null);
                if(ajax.readyState == 4) {
                  if(ajax.status == 200 || ajax.status == 404 || ajax.status == 500)
                  {
                    document.getElementById( 'proroga' ).innerHTML =  document.getElementById( 'proroga' ).innerHTML + ajax.responseText ;
                  } 
                }
              }
                   
            }else
            
  					 document.getElementById( 'proroga' ).innerHTML =  ajax.responseText;
  					
  				}
  			}			
  	}
}




//effettua la chiamta ajax inviando i dati di un form
function xmlhttpPost(strURL,formname,responsediv,responsemsg) {

    var xmlHttpReq = false;

    var self = this;

    // Xhr per Mozilla/Safari/Ie7

    if (window.XMLHttpRequest) {

        self.xmlHttpReq = new XMLHttpRequest();

    }

    // per tutte le altre versioni di IE

    else if (window.ActiveXObject) {

        self.xmlHttpReq = new ActiveXObject("Microsoft.XMLHTTP");

    }

    self.xmlHttpReq.open('POST', strURL, true);

    self.xmlHttpReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    self.xmlHttpReq.onreadystatechange = function() {

        if (self.xmlHttpReq.readyState == 4) {

			// Quando pronta, visualizzo la risposta del form

            updatepage(self.xmlHttpReq.responseText,responsediv);

        }

		else{

			// In attesa della risposta del form visualizzo il msg di attesa
      if (responsemsg != '')
			 updatepage(responsemsg,responsediv);



		}

    }
    
    
    self.xmlHttpReq.send(getquerystring(formname));

}



function getquerystring(formname) {

    var form = document.forms[formname];

	var qstr = "";



    function GetElemValue(name, value) {
        
        value = replace_special_charset(value);
        
        qstr += (qstr.length > 0 ? "&" : "")

            + escape(name).replace(/\+/g, "%2B") + "="

            + escape(value ? value : "").replace(/\+/g, "%2B");

			//+ escape(value ? value : "").replace(/\n/g, "%0D");
          
    }

	

	var elemArray = form.elements;

    for (var i = 0; i < elemArray.length; i++) {

        var element = elemArray[i];
        
        try {
            var elemType = element.type.toUpperCase();
    
            var elemName = element.name;
    
            if (elemName) {
    
                if (elemType == "TEXT"
    
                        || elemType == "TEXTAREA"
    
                        || elemType == "PASSWORD"
    
    					          || elemType == "BUTTON"
    
    					          || elemType == "RESET"
    
    					          || elemType == "SUBMIT"
    
    					          || elemType == "FILE"
    
    					          || elemType == "IMAGE"
    
                        || elemType == "HIDDEN")
    
                    GetElemValue(elemName, element.value);
    
                else if (elemType == "CHECKBOX" && element.checked)
    
                    GetElemValue(elemName, 
    
                        element.value ? element.value : "On");
    
                else if (elemType == "RADIO" && element.checked)
    
                    GetElemValue(elemName, element.value);
    
                else if (elemType.indexOf("SELECT") != -1)
    
                    for (var j = 0; j < element.options.length; j++) {
    
                        var option = element.options[j];
    
                        if (option.selected)
    
                            GetElemValue(elemName,
    
                                option.value ? option.value : option.text);
    
                    }
    
            }
        }catch(e){
        }
    }

    return qstr;

}

function updatepage(str,responsediv){

    document.getElementById(responsediv).innerHTML = str;

}




function HideFormInvioQuesito(){
  
  if ( getObj('statoform_invioquesito').value  == '0' ) {
    document.getElementById('campi_invio_quesito').style.display='';
    document.getElementById('statoform_invioquesito').value='1';
  }else{
    document.getElementById('campi_invio_quesito').style.display='none';
    document.getElementById('statoform_invioquesito').value='0';
  }
  
  
  try{    
    document.getElementById('errormsg').style.display='none';
  }catch(e){
    //alert('diverrore');
  }
  
}



//inserisce i quesiti sul dettaglio del documento
function InsertQuesiti(){
      
      var RichiestaQuesito='YES';
      var CodificaRichiestaQuesito;
      var MessaggioPrivato = -1 ;
      var EXPIRYDATE;
      var IDDOC_GUID;
	    var DOCUMENT;
	    var PROTOCOLLOBANDO;
	    var SUBTYPE_ORIGIN;
	    var strQuesitoAnonimo;
	    var ContestoPrivato = 1;
	    
      //IdmsgPrivato viene valorizatto solo all'interno quando il messaggio è privato
      try {
        MessaggioPrivato = IdmsgPrivato;
      }catch(e){
        ContestoPrivato = 0 ;
      }
      
      
      
      try {
	  
        CodificaRichiestaQuesito =  getObj('RichiestaQuesito').value ;
        //1=SI,2=NO,3=solo per invitati
        if (CodificaRichiestaQuesito == '2' || CodificaRichiestaQuesito == '3' )
          RichiestaQuesito='NO';
          
        //se stiamo su un messaggio invito e RichiestaQuesito= solo per invitati allora visualizzo solo dall'interno i quesiti sugli inviti
        if (CodificaRichiestaQuesito == '3' && Number(MessaggioPrivato) > 0 )
          RichiestaQuesito='YES'; 
          
      }catch(e){
      }
      
      
      if ( RichiestaQuesito == 'YES') {
        
        //recupero html dei quesiti
        try{
            
            //recupero scadenza per inserire quesiti
            try {
              EXPIRYDATE=getObj('TermineRichiestaQuesiti').value
              if ( EXPIRYDATE =='')
                EXPIRYDATE=getObj('EXPIRYDATE').value ; 
            }catch(e){
              EXPIRYDATE=getObj('EXPIRYDATE').value ; 
            }
			
			      
      			//è valorizzato solo in caso di nuovo documento
      			try {
      			  DOCUMENT=getObj('DOCUMENT')[0].value ;  
            }catch(e){
              
              try{
                 DOCUMENT=getObj('DOCUMENT').value ;  
              }catch(e){
                
                DOCUMENT='' ; 
              }
              
            }
          
            //identificativo del documento 
            try {
                IDDOC_GUID = getObj('IDDOC_GUID').value ;
            }catch(e){
                IDDOC_GUID='' ; 
            }
       
            try {
              PROTOCOLLOBANDO = getObj('PROTOCOLLOBANDO').value ;
            }catch(e){
              PROTOCOLLOBANDO='' ; 
            }
            
            try {
              SUBTYPE_ORIGIN = getObj('SUBTYPE_ORIGIN').value ;
            }catch(e){
              SUBTYPE_ORIGIN='' ; 
            }
            
            try {
              strQuesitoAnonimo = getObj('QuesitoAnonimo').value ;
            }catch(e){
              strQuesitoAnonimo='1' ; 
            }
            
            //se sono lato interno metto sempre l'area per inserire il quesito
            if ( ContestoPrivato == 1 )
              strQuesitoAnonimo='1' ; 
            
            var FASCICOLO = getObj('FASCICOLO').value ;
            
            var strURL = getObj('URL_APP').value + 'quesiti/GetHtmlQuesiti.asp?EXPIRYDATE=' + EXPIRYDATE + '&DOCUMENT=' + DOCUMENT + '&IDDOC_GUID=' + IDDOC_GUID + '&PROTOCOLLOBANDO=' + PROTOCOLLOBANDO + '&SUBTYPE_ORIGIN=' + SUBTYPE_ORIGIN + '&FASCICOLO=' + FASCICOLO + '&QUESITOANONIMO=' + strQuesitoAnonimo ;
            
            ajax.open("GET",  strURL  , false);
            ajax.send(null);
            
    			  if(ajax.readyState == 4) {
				      
    				  if(ajax.status == 200 || ajax.status == 404 || ajax.status == 500)
    				  {
    				      getObj('CHIARIMENTI' ).innerHTML = ajax.responseText;
      			  }
    				}
           
            
            //visualizzo l'area di inserimento quesito se rischiesto
            var insertQuesito;
            insertQuesito='YES';
            try {
              insertQuesito =  getObj('SYS_INSERISCIQUESITIDALPORTALE').value ;
            }catch(e){
            }
            
            if ( insertQuesito == 'NO'){
                try {   
                  getObj('AreaInsertQuesito' ).style.display='none';
                }catch(e){
                }
            }
            
            //provo a recuperare la griglia dei quesiti con le risposte se esistono
            try {
              CercaQuesito();
              HideFormInvioQuesito();    
            }catch(e){
            }
        }catch(e){}
        
        
         
      }else{
      
        //nascondo area di cerca e area lista quesiti
        //document.getElementById( 'CHIARIMENTI' ).style.display='none';
        getObj('CHIARIMENTI' ).style.display='none';
      }	  
}


function ShowRisultatoDiGara( objGrid , Row , c )
{
	var cod;
	var nq;
	var protbando;
	
	//-- recupero il codice della riga passata
	//cod = GetIdRow( objGrid , Row , 'self' );
	
	//alert("ris")
	cod = prendiElementoDaId('R'+ Row + '_idDocR').value;		
	
	protbando = prendiElementoDaId('R'+ Row + '_ProtocolloBando').value;		
	
	var w;
	var h;
	var Left;
	var Top;
    
	w = screen.availWidth;
	h = screen.availHeight;
	Left=0;
	Top=0;
  
	//var strDoc;
	//strDoc = getObj('DOCUMENT').value;
	//alert(cod);
	
	//alert(getObj('descfolder').innerHTML);
	
	var DESCPROVENIENZA;
  DESCPROVENIENZA = escape(getObj('descfolder').innerHTML);
  
	if (cod != '0')	{
		strURL = getObj('URL_APP').value + 'report/RisultatoDiGara.asp?PROTOCOLLOBANDO='+ escape(protbando) +'&CONTESTO=BANDITRADIZIONALI&BACKOFFICE=yes&TYPEDOC=RISULTATODIGARA&MODE=OPEN&IDDOC=' + cod ;
		strURL =  strURL + '&DESCPROVENIENZA=' + DESCPROVENIENZA;
	}else
		return;
	
	if(ajax){
	    
			ajax.open("GET", strURL  , false);
			ajax.send(null);
			if(ajax.readyState == 4) {
			   
				if(ajax.status == 200 || ajax.status == 404 || ajax.status == 500)
				{
				  //alert(ajax.responseText);
					document.getElementById( 'colcx' ).innerHTML =  ajax.responseText;
					document.getElementById( 'colcx' ).setAttribute('class','large');
					
					
				  try{
            Forms.init();
          }catch(e){}
					
		  //inizializzo oggetti suggerimento
          window.addEvent('domready',function(){
          $$('div.tipscontent').each(function(div){
          tipsfx[div.id] = new Fx.Slide(div.id);
          });
          
          $$('div.tipsbar').addEvent('click',function(ev){
          ev = new Event(ev).preventDefault();
          var target = $(ev.target);
          if(target.getTag() =='a'){
          var id = target.href.substring(target.href.indexOf('#')+1);
          tipsfx[id].toggle();
          if(target.hasClass('suggest')) target.getPrevious().setStyle('display','inline');
          else  target.getNext().setStyle('display','inline');
          target.setStyle('display','none'); 
          }
          });
          
          
          if(window.ie6){
              ieMinWidthFix();
            window.onresizeend = ieMinWidthFix;	    	    
          }    
          
          });
          
				}
			}			
	
  }
	
}


	function replace_special_charset(testo)
  {
	
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
				
				nuovo_testo = nuovo_testo +  array_charset[1][pu];
			    check = true;
			    break;
			}
			
		}
		if (check == false)
		{
		  	nuovo_testo = nuovo_testo +  unescape(testo.charAt(rt));
		}
		check = false;
	}
     
    return  nuovo_testo;
  
  }
	
	function RefreshImageCatcha(valImageId) {
	var objImage = document.images[valImageId];
	if (objImage == undefined) {
		return;
	}
	var now = new Date();
	objImage.src = objImage.src.split('?')[0] + '?x=' + now.toUTCString();
}

function test_captcha( path , val )
{
	ajax = GetXMLHttpRequest();

	if(ajax){
													 
		try
		{			
			ajax.open("GET", path + 'CTL_Library/functions/checkCaptcha.asp?captchacode=' + escape( val ), false);
			ajax.send(null);
												
			if(ajax.readyState == 4) 
			{
				if(ajax.status == 200)
				{
					if (ajax.responseText == '1')
					{
						
						return true;
					}
					else
					{
						RefreshImageCatcha('imgCaptcha');
						
						var form = $("FormInsQuesito");
						var fields = form.elements;
						var msgerror = new Element('div').setProperty('id','errormsg').injectBefore(fields[fields.length-1].form);
						msgerror.setHTML('<p><strong>Attenzione:</strong> Captcha inserito non corretto!</p>');

						return false;
					}	
				}
			}
		}
		catch( err )
		{
			alert('Javascript error test_captcha()');
			return true;
		}

	}

	return true;
}


//per far scaricare gli allegati di un documento
function ScaricaAllegati( param  ){
  
  //alert(param);
  strUrl= getObj('URL_APP').value + 'CTL_LIBRARY/DOCUMENT/DownloadAttach.asp?' + param
  
  ExecFunction( strUrl  , 'ScaricaAllegati' , '');
  
  
}
