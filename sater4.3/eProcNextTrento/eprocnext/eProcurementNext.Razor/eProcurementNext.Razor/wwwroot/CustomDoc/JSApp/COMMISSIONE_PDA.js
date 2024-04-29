window.onload = setdocument;

function setdocument()
{
  
	var jumpcheck = getObjValue('JumpCheck');

	//nel caso criterio nn sia Offerta economicamente più vantaggiosa e non sia costo fisso nascondo i dati della seconda griglia
	/*
	if ( getObjValue('CriterioAggiudicazioneGara') != '15532' && getObjValue('CriterioAggiudicazioneGara') != '25532' )
	{

		//se per i nuovi bandi conformita =no oppure per i bandi generici monolotto nascondo le info della commissione tecnica
		if ( getObjValue('Conformita').toUpperCase() == 'NO' || getObjValue('Conformita') == '' ) 
		{
			if ( getObj('TESTATA1') )
				getObj('TESTATA1').style.display ='none';

			if ( getObj('ATTIG') )
				getObj('ATTIG').style.display ='none';
			
			if ( getObj('GIUDICATRICE') ) 
				getObj('GIUDICATRICE').style.display ='none';
		}

	}
	*/
	
	SetCampiNotEditCommissioni('');

}



function OpenBando(param)
{
if ( getObjValue('JumpCheck') == 'BANDO_GARA' || getObjValue('JumpCheck') == 'BANDO_SEMPLIFICATO' )
	ShowDocumentFromAttrib('BANDO_GARA,' + param);
else if (getObjValue('JumpCheck') == 'BANDO_CONCORSO')
	ShowDocumentFromAttrib('BANDO_CONCORSO,' + param);
else
	OpenDocGen(param);
}



function RefreshContent()
{
  //alert(getObj('PrevDoc').value);
  if ( getObj('PrevDoc').value !='')
    RefreshDocument('./');
  //parent.RefreshContent();
 
}

//----------RIPORTARE SU PUGLIA

function GetInfoAziendaFromCF( obj ){
    
    var strNameCtl = obj.name;
  
    

    var aInfo = strNameCtl.split('_');



    var nIndRrow = aInfo[1];

    var strCF = obj.value;

    var Grid = aInfo[0].substr(1, aInfo[0].length);
    
    
    if (strCF.length == 16) {
        
        var r = ControllaCF( strCF )
        
      	if ( r != '' )
      	{
      		AF_Alert( r );
      		obj.value = '';
      		return;
      	}
        
        r=CheckCoerenzaCF(obj);
        
        //if  ( bIsUnique ){

        //provo a ricercare le info azienda
        ajax = GetXMLHttpRequest();
	      
        var nocache = new Date().getTime();
	      
        if (ajax) {
            ajax.open("GET", '../../ctl_library/functions/InfoUserFromCF.asp?CodiceFiscale=' + encodeURIComponent(strCF) + '&nocache=' + nocache  , false);

            ajax.send(null);

            if (ajax.readyState == 4) {
                //alert(ajax.status);
                if (ajax.status == 200) {
                    //alert(ajax.responseText);
                    if (ajax.responseText != '' && ajax.responseText.indexOf('#', 0) > 0) {

                        //alert(ajax.responseText);    
                        obj.style.color = 'black';
                        var strresult = ajax.responseText;

                        //alert(strresult);
                        SetInfoAziendaRow(Grid, nIndRrow, strresult);
                        
                        

                    } else {

                        if (ajax.responseText != '')
                            LocDMessageBox('../', ajax.responseText, 'Attenzione', 1, 400, 300);

                        //setto i caratteri in rosso
                        obj.style.color = 'red';

                        //svuoto i campi
                        SetInfoAziendaRow(Grid, nIndRrow, '######'+strCF+'#');


                    }
                }
            }

        }
        //}else{

        //svuoto il campo del CF che non è univoco
        //  this.value='';
        //  SetInfoAziendaRow( Grid , nIndRrow ,'#####' );
        //}
    } else {
        //setto i caratteri in rosso
        obj.style.color = 'red';

        //svuoto i campi
        SetInfoAziendaRow(Grid, nIndRrow, '#######');
    }


}



//setta le info di una azienda su una riga di una griglia
function SetInfoAziendaRow(strFullNameArea, nIndRrow, strresult) {


    var nPos;
    var ainfoAzi = strresult.split('#');

    var strRagSoc = ainfoAzi[0];

    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagioneSociale').value = strRagSoc;
    //getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagioneSociale_V').innerHTML = strRagSoc;
    
    
    var strNome = ainfoAzi[1];
    //alert(strNome);
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_Nome').value = strNome;
    

    var strCognome = ainfoAzi[2];
    //alert(strCognome);
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_Cognome').value = strCognome;

    var strRuolo = ainfoAzi[3];
    //alert(strRuolo);
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RuoloUtente').value = strRuolo;
    
	 var email = ainfoAzi[5];
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_EMAIL').value = email;
	
	 var cf = ainfoAzi[6];
     getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value = cf;
  
    var strIdPfu = ainfoAzi[4];
	
	//se valorizzato vuol dire che utente è nel sistema ma su altro ente
	var strUtentePresente = ainfoAzi[7];
	
	//setto utente nella prima colonna degli utenti codificati
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_UtentePresente').value =  strUtentePresente ; 
	
	
    var nIsInDomain;
    nIsInDomain=0;
    
	/*
    if (strIdPfu != '')
	{
      
		  //faccio una chiamata ajax per vedere se utente presente nel dominio
		   
		   var strFilter='SQL_WHERE=idpfu in ( select a.idpfu from profiliutente a inner join profiliutente b on a.pfuidazi = b.pfuidazi  where b.idpfu = <ID_USER>  ) and dmv_cod=' + strIdPfu ;
		   //var strFilter='SQL_WHERE=dmv_cod=' + strIdPfu ;
			
		   ajax = GetXMLHttpRequest();
		   var nocache = new Date().getTime();
		   
			 if (ajax) {
		  
				ajax.open("GET", '../../ctl_library/GetDomValue.asp?DESC=' + encodeURIComponent(strNome.toUpperCase()) + '&DOMAIN=UtenteCPN&FILTER=' + strFilter + '&nocache=' + nocache , false);
				//alert('../../ctl_library/GetDomValue.asp?DESC=' + encodeURIComponent(strNome.toUpperCase()) + 'DOMAIN=UtenteCPN&FILTER=' + strFilter );
				ajax.send(null);

				if (ajax.readyState == 4) {
					//alert(ajax.status);
					if (ajax.status == 200) {
						//alert(ajax.responseText);

							if ( ajax.responseText != '')    
							  nIsInDomain = 1 ;
					}
				}

		  }        
     }     
     */

	 //se utente è censito e non sta in altro ente allora sta nel dominio
     if ( strIdPfu != '' && strUtentePresente == '')
		 nIsInDomain = 1 ;
	 
     if (nIsInDomain == 1)
	 {
      
        //setto utente nella prima colonna degli utenti codificati
        getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_UtenteCommissione').value =  strIdPfu ; 
      
        //setto la parte visuale
        getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_UtenteCommissione_edit_new').value =  strNome.toUpperCase() + ' ' + strCognome.toUpperCase() ; 
		
		document.getElementById( 'R' + strFullNameArea + '_' + nIndRrow + '_Registra').disabled=true;
		
     }
	 else
	 {
     
        getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_UtenteCommissione').value =  '' ; 
        //setto la parte visuale
        getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_UtenteCommissione_edit_new').value =  '' ; 
		
		document.getElementById( 'R' + strFullNameArea + '_' + nIndRrow + '_Registra').disabled=false;
		
     }
    
    
	//blocco i campi se utente del dominio oppure utente presente nel sistema in un altro ente
    if (strIdPfu != '' || strUtentePresente != '' )
	{
		TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale', true );
		TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_RagioneSociale', true );
		TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_Nome', true );
		TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_Cognome', true );
		TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_RuoloUtente', true );
		TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_EMAIL', true );
	}
	else
	{
		TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale', false );
		TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_RagioneSociale', false );
		TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_Nome', false );
		TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_Cognome', false );
		TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_RuoloUtente', false );
		TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_EMAIL', false );
	}
	
	

}

function CheckCoerenzaCF( obj ){
    
    
    var strNameCtl = obj.name;
    var aInfo = strNameCtl.split('_');
    var nIndRrow = aInfo[1];
    var Grid = aInfo[0].substr(1, aInfo[0].length);
    
    
    //recupero nome,cognome,cf e faccio controllo    
    var strNome = getObjGrid('R' + Grid + '_' + nIndRrow + '_Nome').value ;
    var strCognome = getObjGrid('R' + Grid + '_' + nIndRrow + '_Cognome').value ;
    var strCF = getObjGrid('R' + Grid + '_' + nIndRrow + '_codicefiscale').value ;
    
    //alert(strNome + '-' + strCognome + '-' + strCF);
    
    if ( strNome != '' && strCognome != '' && strCF != '' ){
    
      var r = isMyCF('../../', strNome , strCognome, strCF );
      //alert(r);
      if ( !r ){
        AF_Alert( 'Codice fiscale non coerente con nome e cognome' );
      }
    } 
    return;
    
}

function OnchangeUtenteCommissione(obj)
{
	var strNameCtl = obj.name;
    var aInfo = strNameCtl.split('_');
    var nIndRrow = aInfo[1];
    var strutente = obj.value;
    var Grid = aInfo[0].substr(1, aInfo[0].length);
	var utenteidpfu=getObj('R'+ Grid + '_' + nIndRrow +'_UtenteCommissione').value;
	//alert(utenteidpfu);
	//vengono avvalorate tutte le celle prelevando i dati dell'utente selezionato, 
	//tutte le celle vengono rese non editabili tranne Ruolo e Curriculum, 
	//se svuotato si mettono le celle editabili e si svuotano i campi
	if ( utenteidpfu != '' ) 
	{
		//provo a ricercare le info per utente
        ajax = GetXMLHttpRequest();	      
        var nocache = new Date().getTime();
	     
        if (ajax) 
		{
            ajax.open("GET", '../../ctl_library/functions/InfoUserFromCF.asp?utenteidpfu=' + encodeURIComponent(utenteidpfu) + '&nocache=' + nocache  , false);

            ajax.send(null);

            if (ajax.readyState == 4) 
			{                
                if (ajax.status == 200) 
				{                    
                    if (ajax.responseText != '' && ajax.responseText.indexOf('#', 0) > 0) 
					{
                        obj.style.color = 'black';
                        var strresult = ajax.responseText;
                       //alert(strresult);
                        SetInfoAziendaRow(Grid, nIndRrow, strresult); 
                    } 
					else 
					{

                        if (ajax.responseText != '')
                            LocDMessageBox('../', ajax.responseText, 'Attenzione', 1, 400, 300);

                        //setto i caratteri in rosso
                        obj.style.color = 'red';

                        //svuoto i campi
                        SetInfoAziendaRow(Grid, nIndRrow, '########');


                    }
                }
            }

        }	
	}
	else
	{
		//setto i caratteri in rosso
        obj.style.color = 'red';
        //svuoto i campi
        SetInfoAziendaRow(Grid, nIndRrow, '########');
	
	}
}

function AGGIUDICATRICE_AFTER_COMMAND ()
{
	SetCampiNotEdit('AGGIUDICATRICE');
}
function GIUDICATRICE_AFTER_COMMAND ()
{
	SetCampiNotEdit('GIUDICATRICE');
}

function ECONOMICA_AFTER_COMMAND ()
{
	SetCampiNotEdit('ECONOMICA');
}



function SetCampiNotEdit( Sezione )
{
	
	
	
	var NumRow;
	var strFullNameArea;
	var strIdPfu;
	var strUtentePresente;
	
	griglia = Sezione + 'Grid' ;
	
	
	NumRow = GetProperty( getObj(griglia) , 'numrow' )
	strFullNameArea =griglia;
	strIdPfu=''

	for ( nIndRrow = 0 ; nIndRrow <= NumRow ; nIndRrow++ )
	{
		strIdPfu=getObj('R'+ strFullNameArea + '_' + nIndRrow +'_UtenteCommissione').value;
		
		strUtentePresente=getObj('R'+ strFullNameArea + '_' + nIndRrow +'_UtentePresente').value;
		
		//blocco il registra se utente nel dominio
		if (strIdPfu != '')
		{
			document.getElementById( 'R' + strFullNameArea + '_' + nIndRrow + '_Registra').disabled=true;
			
		}
		else
		{
			document.getElementById( 'R' + strFullNameArea + '_' + nIndRrow + '_Registra').disabled=false;
			
		}	
		
		//blocco gli altri campi se utente nel dominio o utente presente nel sistema su altro ente
		if ( strIdPfu != '' || strUtentePresente != '')
		{	
			TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale', true );
			TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_RagioneSociale', true );
			TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_Nome', true );
			TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_Cognome', true );
			TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_RuoloUtente', true );
			TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_EMAIL', true );
		}
		else
		{		
			TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale', false );
			TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_RagioneSociale', false );
			TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_Nome', false );
			TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_Cognome', false );
			TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_RuoloUtente', false );
			TextreadOnly( 'R' + strFullNameArea + '_' + nIndRrow + '_EMAIL', false );
		}
		
	}
	
	
	
	
	
	if (getObj('Anagrafica_Master').value != 'si')
	{
		ShowCol( Sezione , 'Registra' , 'none' );
		
	}
	
	

}




function SetCampiNotEditCommissioni(griglia)
{
	
	SetCampiNotEdit('AGGIUDICATRICE');
	try { SetCampiNotEdit('GIUDICATRICE'); } catch(e){}
	try { SetCampiNotEdit('ECONOMICA'); } catch(e){}
	
	
	
}

