var Ambito_Old;
var cambio_ambito='si';
var Tipo_Modello_Convenzione_Scelta_Old;
var PresenzaListinoOrdini_Old;

function MySaveDoc()
{
    /*
    var TipoOrdine = 'S';
    try{ TipoOrdine = getObjValue( 'TipoOrdine' );   } catch ( e ) {TipoOrdine = 'S';};
    if( TipoOrdine == 'B' )
    {
            DisableObj(  'RicPropBozza' ,false );
            getObj('RicPropBozza').value = '0';

            DisableObj(  'RicPreventivo' ,false );
            getObj('RicPreventivo').value = '1';
    }
    */
    
    SaveDoc();
}


function OnChange_TipoOrdine( obj )
{
    ShowCol_TipoOrdine();
}

function ShowCol_TipoOrdine()
{
        /*
        var TipoOrdine = 'S';
        try{ TipoOrdine = getObjValue( 'TipoOrdine' );   } catch ( e ) {TipoOrdine = 'S';};
    
        if( TipoOrdine == 'S' )
        {

            //ShowCol( 'PRODOTTI' , 'Codice' , '' );
            ShowCol( 'PRODOTTI' , 'QtMin' , '' );

            ShowCol( 'PRODOTTI' , 'CostoComplessivo' , 'none' );
            ShowCol( 'PRODOTTI' , 'CoefCorr' , 'none' );
            ShowCol( 'PRODOTTI' , 'PercSconto' , 'none' );

            ShowCol( 'PRODOTTI' , 'ImportoCompenso' , 'none' );
            ShowCol( 'PRODOTTI' , 'RicPropBozza' , '' );
            try
            {
                DisableObj(  'RicPropBozza' ,false );
                DisableObj(  'RicPreventivo' ,false );
            }
            catch( e ) {}
            
        
        }
        
        if( TipoOrdine == 'P' )
        {
        
            //ShowCol( 'PRODOTTI' , 'Codice' , 'none' );
            ShowCol( 'PRODOTTI' , 'QtMin' , 'none' );
            ShowCol( 'PRODOTTI' , 'CostoComplessivo' , 'none' );
            ShowCol( 'PRODOTTI' , 'CoefCorr' , 'none' );
        
            ShowCol( 'PRODOTTI' , 'PercSconto' , '' );
            ShowCol( 'PRODOTTI' , 'RicPropBozza' , '' );
            ShowCol( 'PRODOTTI' , 'ImportoCompenso' , 'none' );
            try
            {
                DisableObj(  'RicPropBozza' ,false );
                DisableObj(  'RicPreventivo' ,false );
            }
            catch( e ) {}
            
        
        }

        if( TipoOrdine == 'C' )
        {
        
            //ShowCol( 'PRODOTTI' , 'Codice' , '' );
            ShowCol( 'PRODOTTI' , 'QtMin' , '' );
            ShowCol( 'PRODOTTI' , 'CostoComplessivo' , '' );
            ShowCol( 'PRODOTTI' , 'CoefCorr' , '' );
        
            ShowCol( 'PRODOTTI' , 'PercSconto' , 'none' );
            ShowCol( 'PRODOTTI' , 'ImportoCompenso' , 'none' );
            ShowCol( 'PRODOTTI' , 'RicPropBozza' , '' );

            try
            {
                DisableObj(  'RicPropBozza' ,false );
                DisableObj(  'RicPreventivo' ,false );
            }
            catch( e ) {}
        
        }
        
        if( TipoOrdine == 'B' )
        {
        
            //ShowCol( 'PRODOTTI' , 'Codice' , 'none' );
            ShowCol( 'PRODOTTI' , 'QtMin' , 'none' );
            ShowCol( 'PRODOTTI' , 'CostoComplessivo' , 'none' );
            ShowCol( 'PRODOTTI' , 'CoefCorr' , 'none' );
        
            ShowCol( 'PRODOTTI' , 'PercSconto' , '' );
            ShowCol( 'PRODOTTI' , 'ImportoCompenso' , '' );
            ShowCol( 'PRODOTTI' , 'RicPropBozza' , 'none' );
            
            getObj( 'IVA' ).value = '0';
            try
            {
                DisableObj(  'RicPropBozza' ,true );
                DisableObj(  'RicPreventivo' ,true );
            }
            catch( e ) {}
        
        }
        
        */
        
}


function PRODOTTI_AFTER_COMMAND( com )
{
    OnChangeTipoConvenzione(getObj('TipoConvenzione'));
    ShowCol_TipoOrdine( );
    SetFilterArticoliPrimari();
    ricercaEntiAccordoConvenzioni()
}

function PRODOTTI_OnLoad()
{
    ShowCol_TipoOrdine();
	
	var DOCUMENT_READONLY = '0';
	
	try
	{
		DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	}
	catch(e)
	{
		
	}
	
	//Se il documento è editabile
	if (DOCUMENT_READONLY == '0')
	{

		SetFilterArticoliPrimari();
		
	}
	
}

function OpenQuota(objGrid , Row , c)
{
var idRow;
var parametri;
idRow = getObj( 'R' + Row + '_id').value;
parametri='QUOTA#QUOTA#800,600'


var cod;
	var nq;
	var altro;
	var altroDOC = '';
	var s;
	var strURL = 'document.asp?';

	//alert( idRow );
	
	var vet;
	var documento;
	var docfrom;

	vet = parametri.split( '#' );
	documento = vet[0];
	docfrom = vet[1];

	
	
	try{
		s = docfrom.split( ',' );
		if(  s.length > 1 ) 
		{
			docfrom = s[0];
			idRow = s[1];
		}
	}
	catch( e ) {
	

	}

	if( idRow == '' )
	{
		DMessageBox( '../' , 'E\' necessario prima il documento' , 'Attenzione' , 1 , 400 , 300 );
		//alert( "E' necessario prima il documento" );
		return;
	}

	
	var nq;

	
	var w;
	var h;
	var Left;
	var Top;
    
	w = screen.availWidth * 0.9;
	h = screen.availHeight  * 0.9;
	Left= (screen.availWidth - w) / 2;
	Top= (screen.availHeight - h ) / 2;
 
     if( vet.length < 3  )
    {
	}
	else    
	{
		var d;
		d = vet[2].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		
		if( vet.length > 3 )
		{
			altro = vet[3];
		}

		if( vet.length > 4 )
		{
			altroDOC = vet[4];
		}
		
		if( vet.length > 5 )
		{
			strURL = vet[5];
		}


	}

 
  
	//var strDoc;
	//strDoc = getObj('IDDOC').value;

	var Target = documento + '_DOC_createfrom' ;// strDoc + '_DOC_' + cod;

	try{
		if( eval( 'BrowseInPage' ) == 1 )
		{
			Target = 'Content';
		}
	}	catch(e){		}

	var url;
	
	strURL = 'ctl_library/document/' + strURL + 'JScript=' + documento + '&DOCUMENT=' + documento + '&MODE=CREATEFROM&PARAM=' + docfrom + ',' + idRow +  altroDOC;

	url = encodeURIComponent(strURL  + '&lo=base');
	if ( isSingleWin() == false )
		pathRoot = '../../';
	ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document' , '' , '' );

}





function Seleziona_Fornitore  ( objGrid , Row , c )
 {
 
 
 var cod;
 var text;
 
	//-- recupero il codice della riga passata
	cod  = GetIdRow( objGrid , Row , 'self' );
	text = getObjGrid('R' + Row + '_aziRagioneSociale').value
	
	//parent.self.opener.getObj('AZI_Dest').value=cod;
	parent.self.opener.FldExtSetValue ('AZI_Dest', text, cod );
	
	
	var objHide = parent.self.opener.getObj('AZI_Dest');
		var objT = parent.self.opener.getObj('AZI_Dest_edit'); 
		var objT1 = parent.self.opener.getObj('AZI_Dest_edit1');
		
		var oldValue = objHide.value;
		objHide.value = cod;
		objT.value = text; 
		objT1.value = text; 
	//parent.opener.SaveDoc();
	parent.close();
    
 
 }


//mi permette di selezionare gli articoli principali di una riga prodotto accessorio o richiesto
function SelezionaPrincipali ( objGrid , Row , c )
{
  
  var TipoProdotto=getObj('R' + Row + '_TipoProdotto').value;
  
  if ( TipoProdotto != 'principale' && TipoProdotto != '' ){
    
      var bSave;
      var bSave=false;
      
      //se il documento non è salvato alert per fare il salva e mi fermo
      var IDDOC = getObj('IDDOC').value ;
      
      if ( IDDOC.length > 3 )
        if ( IDDOC.substr(0,3) == 'new' )
          bSave=true;
      
      
      //se la riga non è stata salvata alert per fare il salva e mi fermo
      var IDROW = getObjGrid('R' + Row + '_idRow').value;
      
      if ( IDROW == '')
        bSave=true;
        
        
      if ( ! bSave ){
        
          //alert(IDROW);
          
          var w;
          var h;
          var Left;
          var Top;
          var altro;
          
          w = screen.availWidth * 0.5;
          h = screen.availHeight  * 0.4;
          Left= (screen.availWidth - w) / 2;
          Top= (screen.availHeight - h ) / 2;
          
          
          var Descrizione = replace_special_charset ( getObj('R' + Row + '_Descrizione').value );
          var Descrizione = escape ( Descrizione );
          
          if ( Descrizione == '' ){
            DMessageBox( '../' , 'inserire codice e descrizione del prodotto' , 'Attenzione' , 1 , 400 , 300 );
            return;
          }
          
          //apro la lista  dei principali della convenzione
          var strURL='../../DASHBOARD/Viewer.asp?CaptionNoML=YES&EDITABLE=yes&TOOLBAR=&Table=CONVENZIONE_PRODOTTIPRINCIPALI&JSCRIPT=&IDENTITY=IdRow&DOCUMENT=CONVENZIONE.ADDFROM.CONVENZIONE&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=Selezione%20Prodotti Principali per il prodotto:' + Descrizione + '&Height=0,100*,210&numRowForPag=20&Sort=&SortOrder=&Exit=si&FilterHide=IdHeader=' + IDDOC + ' and idRow=' + IDROW ;
          ExecFunction(  strURL , 'ListaPrincipali'  , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
          
      }else{
        
        //DMessageBox( '../' , 'E\' necessario prima salvare il documento' , 'Attenzione' , 1 , 400 , 300 );
        
        if( confirm(  CNV( '../../','necessario il salva, si vuole salvare?')) )
        {
             SaveDoc();
        }
        
		    return;
		    
      }
        
        
  
  }
  

}



//effettua l'associazione prodotto-principale e restituisce html per la cella "Articoli Principali Collegati"
function SetPrincipaleProdottoConvenzione ( obj , trysave ) {
  
  
  //recupero indice diriga
  var strRow = obj.id.split( '_' )[0];
  
  //-- recupero il codice della riga passata
	var idRow;
	idRow = getObjGrid( strRow + '_idRow').value
	//idRow = getObj( strRow + '_IdRow').value;
	
	
	var IdConvenzione = getObj('IDDOC').value ;
	
  if ( IdConvenzione.length > 3 )
      if ( IdConvenzione.substr(0,3) == 'new' )
	       return;
  
  if ( idRow != '' ) {
  
  	var TipoProdotto;
  	//TipoProdotto = getObjGrid( 'val_' + strRow + '_TipoProdotto').value;
  	TipoProdotto =  GetProperty( getObjGrid( 'val_' + strRow + '_TipoProdotto') , 'value' );
  	
  	//se non ho cambiato tipoprodotto oppure è la prima selezione esco senza fare nulla
  	var CurrentTipoProdotto=getObj( strRow + '_TipoProdotto' ).options[getObj( strRow + '_TipoProdotto' ).selectedIndex].value;
  	//alert('precedente:'+TipoProdotto+'--corrente:'+CurrentTipoProdotto);
  	if ( (CurrentTipoProdotto==TipoProdotto) || TipoProdotto=='' )
  	     return;     
  	
  	
  	var objNameArticoliCollegati;
  	objNameArticoliCollegati = strRow + '_ArticoliCollegati';
  	
  	//se cambio da principale a altro elimino tutti i collegamenti a questo principale
  	var OPERATION;
    if (TipoProdotto=='principale')
      OPERATION='DELETEPRINCIPALE';
    else
      OPERATION='DELETEROW' ;
      
    //chiamata AJAX per eliminare le associazioni con questo principale ed aggiornare "Articoli Principali Collegati" per i prodotti coinvolti
  	ajax = GetXMLHttpRequest(); 
    
    if(ajax){
  		
      var strParam;		 
  		strParam = 'OPERATION=' + OPERATION + '&IDHEADER=' + IdConvenzione + '&IDROWPRINCIPALE=' + idRow ;
  		
      ajax.open("GET", '../../customDoc/SetPrincipaleProdottoConvenzione.asp?'+ strParam , false);
  	 
      ajax.send(null);
      //alert(ajax.readyState);
      if(ajax.readyState == 4) {
        //alert(ajax.status);
  	    if(ajax.status == 200)
  	    {
  		    result =  ajax.responseText;
  		    
  		    
  		    //svuoto tutte le celle "Articoli Principali Collegati"
  		    //numRow = eval('PRODOTTIGrid_NumRow') ;
  		    numRow = GetProperty( getObj('PRODOTTIGrid') , 'numrow');
  		    
  		    for( i = 0; i <= numRow ; i++ ){
  		      
  		      objNameArticoliCollegati =  'R' + i +  '_ArticoliCollegati';
  		      self.SetTAValue( objNameArticoliCollegati , '' ) ;
  		      
  		    }
  		    
          //aggiorno il campo "Articoli Principali Collegati" delle righe che hanno i collegamenti
  		    //alert(result);
          ainfo = result.split('###');
  		    numCell = ainfo.length;
  		    
          for( j = 0; j < numCell ; j++ ){
  		      
  		      
  		      ainfocell = ainfo[j].split('@@@');
  		      
  		      posRow = GetLocalPositionRow('PRODOTTIGrid' , ainfocell[0] );
  		      
  		      //alert(posRow);
  		      
            objNameArticoliCollegati =  'R' + posRow +  '_ArticoliCollegati';
  		      
            self.SetTAValue( objNameArticoliCollegati , ainfocell[1]  ) ;
  		    
  		    }
  		    
  		    
  	    }
      }
    }
    
    
    if ( trysave == 1){
       if( confirm(  CNV( '../../','necessario il salva, si vuole salvare?')) )
       {
           SaveDoc();
       }
    }
    
 }
 //alert(strRow + '_TipoProdotto');
 
 //getObj( strRow + '_TipoProdotto').selectedIndex
 //getObj('TassoAggiuntivo').options[getObj('TassoAggiuntivo').selectedIndex].value
  	
  
  return;

}

function MYDettagliDel ( objGrid , Row , c ){

  
   SetPrincipaleProdottoConvenzione( getObj( 'R' + Row + '_ArticoliCollegati') , 0 );
   
   var  idRow = getObjGrid( 'R' + Row + '_idRow').value;
    
   DettagliDel ( objGrid , Row , c );
    
   if (idRow != '' )
     if( confirm(  CNV( '../../','necessario il salva, si vuole salvare?')) )
     {
       SaveDoc();
     }

}


function GetLocalPositionRow( grid , idRow  )
{
  var i;
  var numRow = eval( grid + '_NumRow') ;
  
	
  for( i = 0; i <= numRow ; i++ ){
	  if ( getObj( 'R' + i + '_IdRow').value ==  idRow )
		return i;
	}
	
	return -1 ;

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
      }
     
    return  nuovo_testo;
  
  }
  
//quando cambio il fornitore recupero il referente
  function onchangeFornitore(obj)
{
	
	 
	 UpdateFieldVisual(getObj('Mandataria'),'DATI_NUOVO_REFERENTE_CONVENZIONE','DATI_NUOVO_REFERENTE_CONVENZIONE','no','=','parent','OnchangeReferenteFornitore(1)');
	  
	 
}
//quando cambio il referente
function OnchangeReferenteFornitore1()
{
	
	
	if ( getObjValue('NotEditable').indexOf(' ReferenteFornitore ') < 0 )
	{	
	
		var azi_dest='';
		azi_dest = getObj('AZI_Dest').value;
		if ( azi_dest == '' )
		{
			alert('Prima di selezionare il Referente scegliere il fornitore');
			return -1;
		}
		else
		{
			
			
			UpdateFieldVisual(getObj('ReferenteFornitore'),'DATI_NUOVO_REFERENTE_FORNITORE','DATI_NUOVO_REFERENTE_FORNITORE','no','=','parent','');
			//dopo mezzo secondo invoco un save 
			setTimeout( SaveFittizio , 500 );
		}
	}
	
}

//aggiunto parametro nMakeSaveFittizio per far capire se deve fare un salvataggio con un processo fittizio

function OnchangeReferenteFornitore( nMakeSaveFittizio )
{
	
	//se il campo ReferenteFornitore è una combo procedo altrimenti no
	//vuol dire che è non editabile
	if ( getObj('ReferenteFornitore').type == 'select-one' ) 
	{	
	
		var iddoc = getObj('IDDOC').value; 
		
		var azi_dest = getObj('AZI_Dest').value;
			//var filter =  'SQL_WHERE= idpfu in ( select idpfu  from profiliUtente where pfuidazi = \'' + azi_dest +  '\'  and  substring (pfufunzionalita, 325, 1) = \'1\' and  substring (pfufunzionalita, 324, 1) = \'1\' and  substring (pfufunzionalita, 255, 1) = \'1\')';
		var filter =  'SQL_WHERE= idpfu in ( select idpfu  from profiliUtente with (nolock) where pfudeleted=0 and pfuidazi = \'' + azi_dest +  '\'  )';

		
		if ( getObjValue('NotEditable').indexOf('AZI_Dest') < 0 )
		{	
			
			try
			{
				if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' || iddoc.substr(0,3) == 'new'  )
				{
					
					
					FilterDom( 'ReferenteFornitore' , 'ReferenteFornitore' , getObjValue('ReferenteFornitoreHide') , filter ,'', 'OnchangeReferenteFornitore1();');
					
					//SetProperty(getObj('ReferenteFornitore'), 'filter', filter );
					
				}
			}catch( e ) {};
		}
		
		//se documento in lavorazione 
		//if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' || iddoc.substr(0,3) == 'new'  ){
		var DOCUMENT_READONLY = '0';
		
		try
		{
			DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
		}
		catch(e)
		{
			
		}
		
		//se il documento è editabile e azi_dest bloccato comunque devo aggiornare ReferenteFornitore perchè sul modello non è caricato nulla
		if ( DOCUMENT_READONLY == '0' )	
		{
			//se attributo non editabile richiedo il filtro non editabile
			if ( getObjValue('NotEditable').indexOf('AZI_Dest') > 0 )
			{
				var filter =  'SQL_WHERE= idpfu in ( select idpfu  from profiliUtente with (nolock) where  pfuidazi = \'' + azi_dest +  '\'  )';
				FilterDom( 'ReferenteFornitore' , 'ReferenteFornitore' , getObjValue('ReferenteFornitoreHide') , filter ,'', 'OnchangeReferenteFornitore1();', '', '', 'no');
			}
		}
		
		//se richiesto effettuo il salvataggio con un processo fittizzio
		if ( nMakeSaveFittizio == 1)
			ExecDocProcess( 'FITTIZIO3,DOCUMENT,,NO_MSG');
	}
}

function OnchangeAmbitoDelMerc()
{
	var iddoc = getObj('IDDOC').value; 	
	var strMsg = 'Attenzione proseguendo con l\'operazione si sta per rimuovere il Modello Convenzione Completa e si svuota l\'elelenco dei prodotti. Sei sicuro?';
	
	
	
	if ( getObjValue('Tipo_Modello_Convenzione_Scelta') != '' )
	{
		//vedo se presente listino ordini per cambiare messaggio
		
		var idDocListinoOrdini = getObj('idDocListinoOrdini').value ;
		
		if ( idDocListinoOrdini != 0 )
			strMsg = 'Attenzione proseguendo con l\'operazione si sta per rimuovere il Modello Convenzione Completa e si svuota l\'elelenco dei prodotti e viene annullato il listino ordini. Sei sicuro?'
		
		if( confirm(CNV( '../../', strMsg )) ) 
		{
			cambio_ambito='si';			
			ExecDocProcess( 'RIPULISCI_PRODOTTI,CONVENZIONE');
			Ambito_Old=getObj('Ambito').value;
			
			if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione'  )
			{		
				SetProperty( getObj('Merceologia'),'value','');
				SetProperty( getObj('Merceologia_edit_new'),'value','');		
			}
			
		}
		else
		{
			//SetProperty( getObj('Ambito'),'value',Ambito_Old);
			getObj('Ambito').value=Ambito_Old;
			cambio_ambito='no';
		}
		
	}
}


function OnchangeAmbito()
{
	var iddoc = getObj('IDDOC').value;	
	
	//aggiungo il fatto che ambito deve essere editabile
	if ( getObjValue('NotEditable').indexOf(' Ambito ') < 0 )
	{	
	
		if(  getObjValue( 'StatoFunzionale' ) == 'InLavorazione'  && cambio_ambito == 'si'  )
		{
			
			var Ambito = getObj('Ambito').value;
			var filter = '';
			filter =  GetProperty ( getObj('Merceologia'),'filter') ;				
			filter = filter.replace('SQL_WHERE=LEFT(DMV_CodExt,1) like \'[a-z]\'','');
			filter = filter.replace('SQL_WHERE=LEFT(DMV_CodExt,1) like \'[^a-z]\'','');
			filter = filter.replace(' and LEFT(DMV_CodExt,1) like \'[a-z]\'','');
			filter = filter.replace(' and LEFT(DMV_CodExt,1) like \'[^a-z]\'','');
			if ( Ambito != '1') // farmaci
			{
			
				if ( Ambito == '2' ) // presidi sanitari
				{
					
					if ( filter == '' || filter == undefined || filter == null )
					{
						
						SetProperty( getObj('Merceologia'),'filter','SQL_WHERE=LEFT(DMV_CodExt,1) like \'[a-z]\'');
					}
					else
					{
						if ( filter.indexOf('LEFT(DMV_CodExt,1) like \'[a-z]\'') < 0 )
							SetProperty( getObj('Merceologia'),'filter',filter + ' and LEFT(DMV_CodExt,1) like \'[a-z]\'');
					}
				}
				if ( Ambito == '3' || Ambito == '4'  ) // Altri beni o servizi
				{
									
					if ( filter == '' || filter == undefined || filter == null )
					{
						SetProperty( getObj('Merceologia'),'filter','SQL_WHERE=LEFT(DMV_CodExt,1) like \'[^a-z]\'');
					}
					else
					{
						if ( filter.indexOf('LEFT(DMV_CodExt,1) like \'[^a-z]\'') < 0 )
						SetProperty( getObj('Merceologia'),'filter',filter + ' and LEFT(DMV_CodExt,1) like \'[^a-z]\'');
					}		
				}		
			}
			else
			{
				SetProperty( getObj('Merceologia'),'filter','');
			}

			if ( getObjValue('NotEditable').indexOf('Tipo_Modello_Convenzione_Scelta') < 0 && getObjValue('StatoListino') != 'Inviato' && getObjValue('StatoListino') != 'Confermato'  && getObjValue('StatoListinoOrdini') == '' )
			{
				//filtro il dominio dei modelli in base alla scelte dell'ambito				
				var filter =  'SQL_WHERE= JumpCheck in (\'CONVENZIONI\' ) and C1.Value =\'' + Ambito +  '\'  ';
				
				//considero nel filtro il campo ConAccessori per considerare i modelli con valore accessorio
				var ConAccessori = getObjValue('ConAccessori');
				if ( ConAccessori == 'si')
				   filter = filter + ' and isnull(C2.Value,\'\') <>\'\' ';
				
				//alert(filter);
				try
				{
					
					FilterDom( 'Tipo_Modello_Convenzione_Scelta' , 'Tipo_Modello_Convenzione_Scelta' , getObjValue('Tipo_Modello_Convenzione_Scelta') , filter , ''  , 'OnChangeModello();');
					
				}catch( e ) {};
			}
			
			
			
		}
		
	}
}


//window.onload = OnLoadPage; 
$( document ).ready(function() {
    OnLoadPage();
});

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
	
	//se il documento è editabile faccio i settaggi 
	if ( DOCUMENT_READONLY == '0' )
	{
	
		//cambia la tooltip della matita per Aprire il dettaglio del modello	
		var tmpMlg = '';

		try
		{
			tmpMlg = CNV( pathRoot ,'Modifica Modello Gara');
			getObj('FNZ_UPD_link').firstChild.alt= tmpMlg;
			getObj('FNZ_UPD_link').firstChild.title=tmpMlg;
		}
		catch(e)
		{
		}

		try{
			
			getObj( 'STRUTTURA' ).style.display='none';
		}catch(e){};
		
		if ( getObj('JumpCheck').value != 'INTEGRAZIONE' )
		{
		  try{
			  OnChangeTipoScadenzaOrdinativo ( getObj('TipoScadenzaOrdinativo') );
			}catch(e){};
		}
		
		
		
		OnchangeReferenteFornitore( 0 );
		OnchangeAmbito();
		Pulisco_Tipo_Modello_convenzione();
		Change_Allega_file();
		
		Ambito_Old = getObj('Ambito').value;
		Tipo_Modello_Convenzione_Scelta_Old =  getObj('Tipo_Modello_Convenzione_Scelta').value ;
		
		PresenzaListinoOrdini_Old = getObj('PresenzaListinoOrdini').value ;
		
		if ( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' && getObj('JumpCheck').value != 'INTEGRAZIONE' )
		{
			//setto onblur sul campo 
			getObj('DataScadenzaOrdinativo_V').onblur = OnBlurDataScadenzaOrdinativo_V;
		}
		
		
		OnChangeTipoConvenzione(getObj('TipoConvenzione'));
		
		//innesco funzione per settare filtro su dominio ArticoliPrimari per tutte le righe
		SetFilterArticoliPrimari();
		
		
		
	
	}
	
	
	//Azione per recuperare il modello selezionato solo se il documento editabile
	//se TipoBandoScelta è vuoto
	//se TipoBando valorizzato allora deduco TipoBandoScelta da TipoBando
	if (DOCUMENT_READONLY == '0' ) 
	{
		
		var strValueTipoBandoScelta ='';
		//var strTipoBando = getObjValue('TipoBando');
		
		//var Titolo = '';
		
		//try
		//{
			//  Titolo = getObj('Titolo').value;
		//}catch(e){};
		
		
		strValueTipoBandoScelta = getObjValue('TipoBandoSceltaHide');
		
		//getObj('val_Appalto_Verde').innerHTML=getObj('val_RTESTATA_PRODOTTI_MODEL_TipoBandoScelta').innerHTML;
		
		//if ( strTipoBando != '' )
		//{
			//strValueTipoBandoScelta = ReplaceExtended(strTipoBando, '_' + getObj('IDDOC').value , '');

			
			if ( getObjValue('Tipo_Modello_Convenzione_Scelta') == '' && strValueTipoBandoScelta != '' ) 			
			{ 
					
				//SetTextValue( 'RTESTATA_PRODOTTI_MODEL_TipoBandoScelta', strValueTipoBandoScelta );
				SetDomValue( 'Tipo_Modello_Convenzione_Scelta', strValueTipoBandoScelta );
				
				//se cmq vuoto messaggio "il modello precedentemente selezionato non risulta più valido".
				//effettuare di nuovo la selezione sulla sezione Prodotti nel campo 
				if ( getObjValue('Tipo_Modello_Convenzione_Scelta') == '' )
						
					DMessageBox('../', 'il modello precedentemente selezionato non risulta valido.riselezionare nei prodotti_Convenzione', 'Attenzione', 1, 400, 300);

           
			}
		//}
		
		PLANT_OnLoad();
	}
	
	
	
	//sulla griglia delle quote se statofunzionale = invioincorso tolgo la lentina per fare modifica quota
	Init_Quote_Grid();
	
	/*Richiamo la on chenge del campo merceologia per precaricare il campo Cetegoria merceologica */
	onChangeMerceologia(this);
	
	
	//se documento EDITABILE verifico se il campo PresenzaListinoOrdini è Editabile oppure no 
	//a seconda dell'utente collegato
	if (DOCUMENT_READONLY == '0' ) 
	{ 
		HandlePresenzaListinoOrdini( this , 0 );
		
		//filtro i riferimenti se ci sono referenti tecnici
		try{
			FilterRiferimenti();
			
		}catch(e){}
		
	}

	ricercaEntiAccordoConvenzioni()

	// SetFilterIniziative_FromRup()
}   

function ricercaEntiAccordoConvenzioni()
{
	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	var GestioneQuote = getObj('GestioneQuote');
	var numrow = GetProperty( getObj('PLANTGrid') , 'numrow');

	if (DOCUMENT_READONLY == '0' ) 
	{ 
		if (GestioneQuote.value == 'senzaquote')
		{	
			for( i = 0 ; i <= numrow ; i++ )
			{	
				SetProperty(getObj('R'+ i +'_AZI_Ente'), 'filter', 'SQL_WHERE= idazi in ( select idazi from ACCORDO_CREA_CONVENZIONI_VIEW where Azienda = ' + idaziAziendaCollegata + ') ');
			}
		}
	}
}

function Change_Allega_file()
{

	//if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione')
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
		
		try{ getObj('F2_SIGN_ATTACH_V_BTN').setAttribute("onclick", "ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=CTL_DOC_SIGN&NO_REFRESH_PARENT=YES&IDDOC=' + getObjValue('IDDOC') + '&OPERATION=INSERTSIGN&PATH=../../&SAVE_HASH=YES&IDENTITY=IdHeader&AREA=F2&DOMAIN=FileExtention&FORMAT=#AllegaFirma#600,400');" );}catch( e ) {};
		try{ getObj('F1_SIGN_ATTACH_V_BTN').setAttribute("onclick", "ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=CTL_DOC_SIGN&NO_REFRESH_PARENT=YES&IDDOC=' + getObjValue('IDDOC') + '&OPERATION=INSERTSIGN&PATH=../../&SAVE_HASH=YES&IDENTITY=IdHeader&AREA=F1&DOMAIN=FileExtention&FORMAT=#AllegaFirma#600,400');" );}catch( e ) {};
	}

}


function Pulisco_Tipo_Modello_convenzione()
{
	var DOCUMENT_READONLY = '0';
	
	try
	{
		DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	}
	catch(e)
	{
		
	}

	//Se il documento è editabile
	if (DOCUMENT_READONLY == '0')
	{

		var iddoc = getObj('IDDOC').value;

		if ( getObj('Ambito').value == '' )
		{
			//filtro il dominio dei modelli in base alla scelte dell'ambito				
				var filter =  'SQL_WHERE= C1.Value =\'NON_DEVE_USCIRE_NULLA\'  ';
				
				try
				{
					
					FilterDom( 'Tipo_Modello_Convenzione_Scelta' , 'Tipo_Modello_Convenzione_Scelta' , getObjValue('Tipo_Modello_Convenzione_Scelta') , filter , ''  , 'OnChangeModello();');
					
				}catch( e ) {};
		}

	}
}
//-- associo il nuovo modello al documento 
function OnChangeModello()
{   
  
	//se ci sono righe di prodotti nella convenzione o ci sono righe nel listino ordini 
	//presento messaggio di warning
	
	var nNumRowProdotti = GetProperty( getObj('PRODOTTIGrid') , 'numrow');
	var PresenzaRigheListinoOrdini = getObj('PresenzaRigheListinoOrdini').value ;
	
	var strMsg = 'Attenzione proseguendo con l\'operazione si sta per rimuovere il Modello Convenzione Completa e si svuota l\'elelenco dei prodotti. Sei sicuro?';
	
	if ( PresenzaRigheListinoOrdini == '1' )
		strMsg = 'Attenzione proseguendo con l\'operazione si sta per rimuovere il Modello Convenzione Completa e si svuota l\'elelenco dei prodotti e viene annullato il listino ordini. Sei sicuro?' ; 
	
	if ( nNumRowProdotti != '-1' || PresenzaRigheListinoOrdini == '1' )
	{	

		//chiedo conferma
		if( confirm(CNV( '../../', strMsg )) ) 
		{
			
			OnChangeModello_OK();
	
		}
		else
		{
			//ripristino la precedente selezione
			getObj('Tipo_Modello_Convenzione_Scelta').value = Tipo_Modello_Convenzione_Scelta_Old;
		}
		
	}
	else
		OnChangeModello_OK();	
	
	
	
	//ExecDocProcess( 'SELECT_MODELLO_CONVENZIONE,CONVENZIONE');

} 

function OnChangeModello_OK()
{ 
	//GESTIONE FATTA PER EVITARE DI LASCIARE VALORI ERRATI IN TipoBandoScelta quando il conferma del modello va in eccezione
	 try 
	 {
		
		SetTextValue( 'TipoBandoSceltaHide',getObjValue('Tipo_Modello_Convenzione_Scelta') );
		
		SetTextValue( 'Tipo_Modello_Convenzione_Scelta',getObjValue('TipoBandoSceltaOLD') );
		
	 } catch (e) {};
	 
	//-- aggiorna il modello da usare per la sezione prodotti
	ExecDocProcess( 'SELECT_MODELLO_BANDO,BANDO');
}

function EsportaListino( param )
{

    var Tipomod = getObjValue( 'Tipo_Modello_Convenzione' );
	var iddoc = getObj('IDDOC').value;
	var filtroEffettuato;
	var URL;
	
    
    if ( Tipomod == '' )
    {
      alert( CNV( '../','E\' necessario selezionare prima il modello'));
      return ;
    }
	  
    var Model = 'MODELLO_BASE_CONVENZIONI_' + Tipomod + '_MOD_Convenzione' ;
    
	filtroEffettuato = 'IdConvenzione=' + iddoc ;
	URL = 'STORED=0&filter=' + encodeURIComponent( filtroEffettuato ) ;
	

	if ( param != '' )
	{
		URL = URL.replace( param , '' );
	}
	
	ExecFunction(pathRoot + 'CTL_Library/accessBarrier.asp?goto=../report/esporta_xlsx_listini.aspx&' + URL, '_blank', '');

}


function OnClickProdotti( obj )
{
     var Tipomod = getObjValue( 'Tipo_Modello_Convenzione' );
    
    if ( Tipomod == '' )
    {
      //alert( CNV( '../','E\' necessario selezionare prima il modello'));
      DMessageBox( '../' , 'E\' necessario selezionare prima il modello' , 'Attenzione' , 1 , 400 , 300 );
      return ;
    }

    var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;
	  var MSGTEXT = getObj( 'MSGTEXT' ).value;
    
    if ( DOCUMENT_READONLY == "1" || MSGTEXT == 'NON_CARICARE' )
        DMessageBox( '../' , 'Documento in sola lettura' , 'Attenzione' , 1 , 400 , 300 );
    else
        ImportExcel( 'CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,CONVENZIONE&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#600,450');
}



function CreaApriContratto( param )
{
    StatoContratto = getObjValue( 'StatoContratto' );
    if ( StatoContratto == 'Rifiutato' || StatoContratto == '' )
    {
        if ( param == 'CONTRATTO_PDF##CONVENZIONE')
        { 
            ExecDocProcess( 'SAVE_CONTRATTO:-1:CHECKOBBLIG,CONVENZIONE' );
        }
        else
        { 
            ExecDocProcess( 'SAVE_CLAUSOLE:-1:CHECKOBBLIG,CONVENZIONE' );
        }
    }
    else
    {
        MakeDocFrom ( param );
    }

}

function afterProcess( param )
{
    
	if ( param == 'SAVE_DOC' )
	{
		ElabAIC();  
	}
	
	if ( param == 'SAVE_CONTRATTO:-1:CHECKOBBLIG' )
    {
        MakeDocFrom ( 'CONTRATTO_PDF##CONVENZIONE' );    
    }
    if ( param == 'SAVE_CLAUSOLE:-1:CHECKOBBLIG' )
    {
        MakeDocFrom ( 'CLAUSOLE_PDF##CONVENZIONE' );    
    }
	if ( param == 'RIPULISCI_PRODOTTI' )
    {
		OnchangeAmbito();
	}
	if ( param == 'ONCHANGE_GESTIONE_QUOTE' )
	{
		getObj('GestioneQuote').focus();
	}
	if ( param == 'SELECT_MODELLO_BANDO' )
	{
		getObj('Tipo_Modello_Convenzione_Scelta').focus();
	}
	if ( param == 'FITTIZIO' )
    {
		var cod=getObjValue( 'id_modello' );
		ShowDocumentPath( 'CONFIG_MODELLI' , cod ,'../');
	}
	
	if ( param == 'FITTIZIO2' )
    {
		DMessageBox( '../' , 'allegato correttamente salvato e Documento Salvato' , 'Attenzione' , 1 , 400 , 300 );
	}
	
	if ( param == 'SAVE_DOC_DM' )
	{
		Elab_DM();  
	}
	
}




function DetailMakeTotal( strSection , objField )
{
	var Totale = 0;
	var i;
	var r;
	var nameField='';
	//debugger;
	
	var numRow = 0;
	
	//-- recupero il numero delle righe presenti sulla griglia
	var Grid = getObj( strSection + 'Grid');
	numRow=Number( GetProperty(Grid,'numrow') );
	
	
	//-- sommo tutte le righe
	try
	{ 
		for( i = 0; i <= numRow ; i++ )
		{
			Totale +=  Number( getObjValue(  'RCAPIENZA_LOTTIGrid_' + i + '_Importo' ));
		}
	} catch( e ) {}; 
	
	
	
	//-- aggiorna il campo con il totale
	try
	{  
		
		SetNumericValue( getObj( strSection + '_TOTAL_FIELD').value ,Totale );
	} catch( e ) {}; 

	
}

function OnchangeGestioneQuote()
{
	ExecDocProcess( 'ONCHANGE_GESTIONE_QUOTE,CONVENZIONE,,NO_MSG');
}


function OnChangeTipoScadenzaOrdinativo ( obj ) {

  //alert(obj.value);
  
  NumberreadOnly( 'NumeroMesi' , false );
  DatareadOnly( 'DataScadenzaOrdinativo' , false );
    
  if ( obj.value == 'immediatamenteesecutivo'){
    
    //svuoto i campi e li rendo non editabili
    getObj('DataScadenzaOrdinativo_V').value='';
    getObj('DataScadenzaOrdinativo').value='';
    DatareadOnly( 'DataScadenzaOrdinativo' , true );
    
    getObj('NumeroMesi_V').value='';
    getObj('NumeroMesi').value='';
    NumberreadOnly( 'NumeroMesi' , true );
    
  }
  
  if ( obj.value == 'duratafissata'){
    
    
    //caption campo data di base
    getObj('cap_DataScadenzaOrdinativo').innerHTML=CNV( '../../','data');
    
    //svuoto il campo data 
    getObj('DataScadenzaOrdinativo_V').value='';
    getObj('DataScadenzaOrdinativo').value='';
    
    //lo rendo non editabile
    DatareadOnly( 'DataScadenzaOrdinativo' , true );
    
  }
  
  if ( obj.value == 'scadenzafissata' || obj.value == 'datamassimadivalidita' ){
    
    
    //svuoto il campo numeromesi 
    getObj('NumeroMesi_V').value='';
    getObj('NumeroMesi').value='';
    
    //lo rendo non editabile
    NumberreadOnly( 'NumeroMesi' , true );
    
    //setto la cation a seconda del valore
    if ( obj.value == 'datamassimadivalidita')
      getObj('cap_DataScadenzaOrdinativo').innerHTML = CNV( '../../','data massima scadenza');
    else
      getObj('cap_DataScadenzaOrdinativo').innerHTML=CNV( '../../','data scadenza fissata');
    
  }
  

}


function OnChangeTipoConvenzione( obj ) {

  
  if ( obj.value != 'miste'){
    
    //per download CSV devo usare un modello con il suffisso _SACQ
    //per import CSV devo usare un modello con il suffisso _SACQ
    
    //nascondo la colonna TipoAcquisto sui prodotti
    try{
      ShowCol( 'PRODOTTI' , 'TipoAcquisto' , 'none' );
    }catch(e){}
  
  }else{
    
    //visualizzo la colonna TipoAcquisto sui prodotti
    try{
      ShowCol( 'PRODOTTI' , 'TipoAcquisto' , '' );
    }catch(e){}
  
  }

}


function OnBlurDataScadenzaOrdinativo_V(){
  
  //alert('myonblur');
  //controllo formale
  ck_VD( getObj('DataScadenzaOrdinativo_V') );
  
  //controllo se < oggi o minore della data inizio convenzione
  var strVal =  getObj('DataScadenzaOrdinativo').value ;
  var strVal1 = getObj('DataInizio').value ;
  
  if ( strVal <= strVal1 ){
      alert( CNV( '../../','data scadenza ordinativo minore data inizio convenzione') ) ; 
      getObj('DataScadenzaOrdinativo_V').value='';
      getObj('DataScadenzaOrdinativo').value=''; 
      return;
  }
  
  //recupero data server attuale
  var strVal2 = GetDataServer('../../','');
  //alert(strVal2);
  
  if ( strVal <= strVal2 ){
      alert( CNV( '../../','data scadenza ordinativo minore di data server') ) ; 
      getObj('DataScadenzaOrdinativo_V').value='';
      getObj('DataScadenzaOrdinativo').value=''; 
      return;
  }
  
  var strVal3 = getObj('DataFine').value ;
  if ( strVal < strVal1 ){
      alert( CNV( '../../','data scadenza ordinativo minore data scadenza convenzione') ) ; 
      return;
  }
}

//setta il filtro sul dominio ArticoliPrimari per considerare solo gli articoli della convenzione corrente
function SetFilterArticoliPrimari()
{
  
  
  
  //numRow = eval('PRODOTTIGrid_NumRow') ;
  var numRow = GetProperty( getObj('PRODOTTIGrid') , 'numrow');
  
  for( i = 0; i <= numRow ; i++ ){
    
    SetProperty( getObj('RPRODOTTIGrid_' + i + '_ArticoliPrimari'),'filter','SQL_WHERE= c.id=' + getObj('IDDOC').value );
    
  }
  
  

}
function RIEPILOGO_ALLEGATI_FIRMATI_OnLoad()
{
	if ( getObj('JumpCheck').value == 'INTEGRAZIONE' )
	{
		getObj('div_RIEPILOGO_ALLEGATI_FIRMATIGrid').style.display='none';
		
	}
}


 function ADD_Enti( obj)
 {
	 ExecDocProcess( 'ADD_ENTI,CONVENZIONE,,NO_MSG' );
 }
 
 function ActiveSelStruttura()
 {
	 getObj( 'TIPO_AMM_ER_button' ).onclick();
	//openHierarchyPopup('TIPO_AMM_ER','./LoadExtendedAttrib.asp?MultiValue=0&titoloFinestra=Struttura&TypeAttrib=5&IdDomain=TIPO%5FAMM%5FER&Attrib=TIPO%5FAMM%5FER&Format=AR&Editable=True&Suffix=&Filter=&SelectOnlyChild=0&SelectNoRoot=0&PathImage=%2E%2E%2FCTL%5FLibrary%2Fimages%2FDomain%2F&Value=', 'dialog-iframe-TIPO_AMM_ER');
 }
 
function UpdateModelloBando()
{
	var TipoBando = getObjValue( 'Tipo_Modello_Convenzione' );
	var cod=getObjValue( 'id_modello' );
	var docReadonly = getObjValue( 'DOCUMENT_READONLY' );

    if ( TipoBando == '' || cod == '' )
    {
		DMessageBox( '../' , 'E\' necessario selezionare prima il modello' , 'Attenzione' , 1 , 400 , 300 );
		return;
    }

	//Se il documento non è readonly l'apertura del documento CONFIG_MODELLI la posticipiamo al reload del documento, nell'after process
	if ( docReadonly == '1' )
		ShowDocumentPath( 'CONFIG_MODELLI' , cod ,'../');
	else
		ExecDocProcess( 'FITTIZIO,DOCUMENT,,NO_MSG');

}
function RefreshContent(tipo,param)
{
	if ( tipo == 'ViewerExecProcess' && param == 'DELETE,LISTA_DOCUMENTI' )
	{
		ExecDocCommand( 'LISTA_DOCUMENTI#Reload#' );
	}
}



function F1_SIGN_ATTACH_OnChange(){
		
	//alert('Save F1');
	ExecDocProcess( 'FITTIZIO2,DOCUMENT,,NO_MSG');
		
}

function STIPULA_FORMA_PUB_OnChange(){
		
	//alert('Save F1');
	ExecDocProcess( 'FITTIZIO3,DOCUMENT,,NO_MSG');
		
}


function F2_SIGN_ATTACH_OnChange(){
	ExecDocProcess( 'FITTIZIO2,DOCUMENT,,NO_MSG');
}


function DownLoadCSV( param )
{

    var Tipomod = getObjValue( 'Tipo_Modello_Convenzione' );
	var iddoc = getObj('IDDOC').value;
	var filtroEffettuato;
	var URL;
	
    
    if ( Tipomod == '' )
    {
      alert( CNV( '../','E\' necessario selezionare prima il modello'));
      return ;
    }
	  
    var Model = 'MODELLO_BASE_CONVENZIONI_' + Tipomod + '_MOD_Convenzione' ;
    
    //se tipoconvenzione diverso da miste allora condiero il modello senza la colonna TipoAcquisto
    if ( getObj('TipoConvenzione').value != 'miste' ) 
      //Model = Model + '_SACQ';
	{     
		//ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + iddoc + '&TIPODOC=CONVENZIONE&HIDECOL=TipoDoc,StatoRiga,TipoAcquisto&MODEL=' + Model  , '_blank' ,'');
		URL = '../../Report/CSV_LOTTI.asp?IDDOC=' + iddoc + '&TIPODOC=CONVENZIONE&HIDECOL=TipoDoc,StatoRiga,TipoAcquisto,ESITORIGA&MODEL=' + Model ;
				
    }
	else
	{
		//ExecFunction('../../Report/CSV_LOTTI.asp?IDDOC=' + iddoc + '&TIPODOC=CONVENZIONE&HIDECOL=TipoDoc,StatoRiga&MODEL=' + Model  , '_blank' ,'');
		URL = '../../Report/CSV_LOTTI.asp?IDDOC=' + iddoc + '&TIPODOC=CONVENZIONE&HIDECOL=TipoDoc,StatoRiga,ESITORIGA&MODEL=' + Model;
		
	}
	if ( param != '' )
	{
		URL = URL.replace( param , '' );
		
	}
	
	ExecFunction( URL , '_blank' ,'');
}



function GetDatiAIC()
{
	ExecDocProcess('SAVE_DOC,AIC,,NO_MSG');
}


function ElabAIC()
{
	// IdOfferta
	var IDDOC = getObjValue('IDDOC');
	
	
	
	if ( isSingleWin() )
	{
		var url;
		
		url = encodeURIComponent( 'CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=CONVENZIONE&lo=base' );
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunctionCenter('../../CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=CONVENZIONE' );
	}  
	
	
	
	//alert(IDDOC);
}



function Init_Quote_Grid()
{
	numRow = GetProperty( getObj('QUOTEGrid') , 'numrow');
  		    
	for( i = 0; i <= numRow ; i++ ){
	  //val_R0_StatoFunzionale_extraAttrib
	  strStatoFunz  = getExtraAttrib (  'val_R' + i +  '_StatoFunzionale' , 'value');  //getObjValue ( 'R' + i +  '_StatoFunzionale' );
		
	  if ( strStatoFunz == 'InvioInCorso')
	  {  
		//tolgo la lentina per fare modifica quota
		getObj ( 'QUOTEGrid_r' +  i + '_c6').innerHTML='';
		
	  }  
	}
}


function onChangeMerceologia( obj )
{

    //Se il documento è editabile
    if (getObj('DOCUMENT_READONLY').value == '0') 
	{

		try
		{
			//- se il campo è visualizzato filtriamo il contenuto in funzione della merceologia
			if ( getObj( 'cap_CATEGORIE_MERC' ) !== null )
			{
				var filter = 'SQL_WHERE=  DMV_Father like \'' + getObjValue( 'Merceologia' ) + '-%\' ';
				
                FilterDom('CATEGORIE_MERC', 'CATEGORIE_MERC', getObjValue('CATEGORIE_MERC'), filter, '', '');
			}
			
			
		}catch(e)
		{}	
	}
	
	
}




function MyInviaListino()
{
    
	var value=controlli('');
 
	if (value == -1)
	    return;
	
	//ExecDocProcess( 'INVIA_LISTINO,CONVENZIONE');
	//Messo con kpf 530301 se invia prima il listino su invio contratto resta con i campi obblig non editabili
	ExecDocProcess( 'INVIA_LISTINO:-1:CHECKOBBLIG,CONVENZIONE' );
	
	
}
function MyPubblica(param)
{
    
	var value=controlli_pubblica('');
 
	if (value == -1)
	    return;
	
	ExecDocProcess(param);
	
}



var LstAttrib = [ 

'Titolo',
'Mandataria',
'ReferenteFornitore'
];


var NumControlli = LstAttrib.length;

var LstAttrib_pubblica = [ 

'DescrizioneEstesa',
'IdentificativoIniziativa',
'Appalto_Verde',
'Acquisto_Sociale',
'GestioneQuote',
'TipoConvenzione',
'ConAccessori',
'Valuta',
'TipoImporto',
'DataFine',
'TipoScadenzaOrdinativo'
];


var NumControlli_pubblica = LstAttrib_pubblica.length;

function SetInitField()
{
   
   
	var i = 0;
	for( i = 0 ; i < NumControlli ; i++ )
	{
		if ( getObjValue('NotEditable').indexOf(LstAttrib[i]) < 0 )
		{
			TxtOK( LstAttrib[i] );
		}
	}
	
	
} 

function SetInitField_pubblica()
{
   
   
	var i = 0;
	for( i = 0 ; i < NumControlli_pubblica ; i++ )
	{
		if ( getObjValue('NotEditable').indexOf(LstAttrib_pubblica[i]) < 0 )
		{
			TxtOK( LstAttrib_pubblica[i] );
		}
	}
	
	
} 

function trim(str){
    return str.replace(/^\s+|\s+$/g,"");
}

function controlli (param)
{

	
	var err = 0;
    var	cod = getObj( "IDDOC" ).value;

	 
    var strRet = CNV( '../' , 'ok' );


  
	SetInitField();
	
	
	//-- effettuare tutti i controlli



    //-- controllo i dati della richiesta
    var i = 0;
   	
	
	for( i = 0 ; i < NumControlli ; i++ )
	{
  
		if ( getObjValue('NotEditable').indexOf(LstAttrib[i]) < 0 )
		{
			try{
				 if ( getObj(LstAttrib[i]).type == 'text' || getObj(LstAttrib[i]).type == 'hidden' 
					||  getObj(LstAttrib[i]).type == 'select-one' ||  getObj(LstAttrib[i]).type == 'textarea')
				  {
					if( trim(getObjValue( LstAttrib[i] )) == '' )
					{
						err = 1;
						//alert(LstAttrib[i]);
						TxtErr( LstAttrib[i] );
					}
				 }

				if ( getObj(LstAttrib[i]).type == 'checkbox' )
				{
					if( getObj( LstAttrib[i] ).checked == false )
					{
						//alert(LstAttrib[i]);
						err = 1;
						TxtErr( LstAttrib[i] );
					}
				}

		  
		  }catch(e)
		  {
				alert( i + ' - ' +  LstAttrib[i] );
		  }
		}
    }
    
   
    
	
	  
    if(  err > 0 )
	{
		DocShowFolder( 'FLD_TESTATA' );
		DMessageBox( '../' , 'Per inviare il listino e\' necessaria la compilazione di tutti i campi evidenziati' , 'Attenzione' , 1 , 400 , 300 );
        return -1;
	}
	


}

function controlli_pubblica (param)
{

	
	var err = 0;
    var	cod = getObj( "IDDOC" ).value;

	 
    var strRet = CNV( '../' , 'ok' );


  
	SetInitField_pubblica();
	
	
	//-- effettuare tutti i controlli



    //-- controllo i dati della richiesta
    var i = 0;
   	
	
	for( i = 0 ; i < NumControlli_pubblica ; i++ )
	{
  
		if ( getObjValue('NotEditable').indexOf(LstAttrib_pubblica[i]) < 0 )
		{
			try{
				 if ( getObj(LstAttrib_pubblica[i]).type == 'text' || getObj(LstAttrib_pubblica[i]).type == 'hidden' 
					||  getObj(LstAttrib_pubblica[i]).type == 'select-one' ||  getObj(LstAttrib_pubblica[i]).type == 'textarea')
				  {
					if( trim(getObjValue( LstAttrib_pubblica[i] )) == '' )
					{
						err = 1;
						//alert(LstAttrib[i]);
						TxtErr( LstAttrib_pubblica[i] );
					}
				 }

				if ( getObj(LstAttrib_pubblica[i]).type == 'checkbox' )
				{
					if( getObj( LstAttrib_pubblica[i] ).checked == false )
					{
						//alert(LstAttrib[i]);
						err = 1;
						TxtErr( LstAttrib_pubblica[i] );
					}
				}

		  
		  }catch(e)
		  {
				alert( i + ' - ' +  LstAttrib_pubblica[i] );
		  }
		}
    }
    
   
    
	
	  
    if(  err > 0 )
	{
		DocShowFolder( 'FLD_TESTATA' );
		DMessageBox( '../' , 'Per pubblicare la convenzione e\' necessaria la compilazione di tutti i campi evidenziati' , 'Attenzione' , 1 , 400 , 300 );
        return -1;
	}
	


}

function SaveFittizio()
{
	ExecDocProcess( 'FITTIZIO3,DOCUMENT,,NO_MSG');
}


function SetFilterPlant( obj , nSvuota)
{
	//R0_AZI_Ente_edit
	//alert(obj.name);
	
	var NameAttrib = '';
	var NamePlant_Row = '';
	
	NameAttrib = obj.name;
	
	//ricavo il prefisso della riga
	var vetInfoRow = NameAttrib.split( '_' );
	var NameRowPlant = ''; 
	var filter = '';
	
	var objBtn_Plant = getObj( vetInfoRow[0] + '_Plant_button') ;
	
	//se il campo Plant è visivbile allora esiste il bottone per la selezione
	if ( objBtn_Plant != null )
	{
		
		//se ho un ente selezionato applico il filtro sulla struttura aziendale
		NamePlant_Row = vetInfoRow[0] + '_Plant_extraAttrib';
		
		if ( getObj( vetInfoRow[0] + '_AZI_Ente').value != '' )
		{
		//strformat#=#M#@#filter#=##@#multivalue#=#1
			filter = 'SQL_WHERE= idaz in ( ' + getObj( vetInfoRow[0] + '_AZI_Ente').value + ' )' ;
			
		}
		
		getObj( NamePlant_Row ).value= 'strformat#=#M#@#filter#=#' + filter + '#@#multivalue#=#1';
		
		//svuoto il campo
		if ( nSvuota == 1)
		{	
			getObj( vetInfoRow[0] + '_Plant').value = '';
			getObj( vetInfoRow[0] + '_Plant_edit_new').value = '0 Selezionati';
		}
			
	}
}




function PLANT_OnLoad()
{
  
	
	
	
	var DOCUMENT_READONLY = '0';
	
	try
	{
		DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	}
	catch(e){}
	
	
	//Attivo il meccanismo se doc EDITABILE e GestioneQuote senzaquote
	
	//Se il documento è editabile
	if (DOCUMENT_READONLY == '0')
	{
		//numRow = eval('PRODOTTIGrid_NumRow') ;
		var numRow = GetProperty( getObj('PLANTGrid') , 'numrow');
		
		for( i = 0; i <= numRow ; i++ )
		{
			
			SetFilterPlant( getObj('R' + i + '_AZI_Ente') , 0 );
			
    
		}
		
		
		
	}
	
}


function PLANT_AFTER_COMMAND( com )
{
    PLANT_OnLoad();
	ricercaEntiAccordoConvenzioni()
	
}



function HandlePresenzaListinoOrdini( obj, nMakeSave )
{
	
	//se non passato vuol dire che devo fare il salva se cambio lo stato al controllo
	if ( nMakeSave == undefined )
		nMakeSave = 1;
	
	//continuo se il campo è visbile (è una select-one)
	//altrimenti esco subito
	
	//variabile per indicare lo stato iniziale del controllo
	var Prima_ListinoOrdini_Bloccato ;
	var PresListinoOrdini_Bloccato = true ;
	
	
	if ( getObj('PresenzaListinoOrdini').type == 'select-one' ) 
	{
		
		//recupero classi di stile associato al controllo; se presente la classe readonly allora il controllo è bloccato
		strClassiStile = getObj('PresenzaListinoOrdini').className ;
		if ( strClassiStile.indexOf( 'readonly') < 0 )
			Prima_ListinoOrdini_Bloccato = false;
		
		
		//Il campo PresenzaListinoOrdini sarà editabile se l'utente collegato è il compilatore
		//oppure l'utente collegato è presnete nei riferimenti tecnici nel tab riferimenti
		
		//vede se utentecollegato è il compilatore
		if ( idpfuUtenteCollegato  == getExtraAttrib (  'val_IdPfu' , 'value') )
		{	
			PresListinoOrdini_Bloccato = false ;
		}
		
		//se il campo è ancora bloccato allora controllo se l'utente è nei riferimenti tecnici
		if ( PresListinoOrdini_Bloccato )
		{
			PresListinoOrdini_Bloccato = UtenteIsReferenteTecnico();
		}
		
		
		//alert (PresListinoOrdini_Bloccato);
		
		SelectreadOnly('PresenzaListinoOrdini',PresListinoOrdini_Bloccato); 
		
		//se ho cambiato stato al controllo innesco un processo fittizio
		//se richiesto per aggiornare anche i comandi della toolbar del documento "Listino Ordini"
		if ( Prima_ListinoOrdini_Bloccato != PresListinoOrdini_Bloccato && nMakeSave != 0 )
		{
			SaveFittizio();
		}
		
	}
	
	
}


function UtenteIsReferenteTecnico()
{
  //ciclo sulla griglia e vedo se l'utente è nei riferimenti tecnici
  //in tal caso il campo sarà sbloccato altrimenti bloccato
  
  var bCheck = true ; 
  var ruolo ; 
  var idpfu ; 
  
  if (GetProperty(getObj('RIFERIMENTIGrid'), 'numrow') >= 0) 
  {
	var numeroRighe = parseFloat(GetProperty(getObj('RIFERIMENTIGrid'), 'numrow')) + 1;
	
	for (var r = 0; r < numeroRighe; r++) 
	{
		
		
	   
		ruolo = getObjValue( 'RRIFERIMENTIGrid_' + r + '_RuoloRiferimenti' );
		idpfu = getObjValue( 'RRIFERIMENTIGrid_' + r + '_IdPfu' );
		
		if ( ruolo == 'ReferenteTecnico') {
			
			if ( idpfuUtenteCollegato == idpfu ) 
			{
				bCheck = false ; 
				break;
			}
		}
	}
  }
  
  return bCheck ;
}



function RIFERIMENTI_AFTER_COMMAND( param )
{
  FilterRiferimenti();
  HandlePresenzaListinoOrdini ( this , 0 ) ;
  ricercaEntiAccordoConvenzioni()
}



function FilterRiferimenti(){
	
	
	var filterUser = '';	
	var i;
	var numrighe=GetProperty( getObj('RIFERIMENTIGrid') , 'numrow');
	
	//filterUser = 'SQL_WHERE= idpfu in ( select idpfu from RiferimentiForBando where DOC_ID = \'BANDO_GARA\'  and  OWNER = <ID_USER> )';
	
	
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
					FilterDom(  'RRIFERIMENTIGrid_' + i + '_IdPfu' , 'IdPfu' , getObjValue( 'val_RRIFERIMENTIGrid_' + i + '_IdPfu' ), filterUser , 'RIFERIMENTIGrid_' + i  , 'HandlePresenzaListinoOrdini(this)')
				}
				/*
				else
				{				
					filterUser = 'SQL_WHERE= idpfu in ( select idpfu from RiferimentiForBando where DOC_ID = \'BANDO_GARA\'  and  OWNER = <ID_USER> )';
				}
				*/
				
			}
			catch(e)
			{
			}

		}
		
	}catch(e){};

}




function ApriListinoOrdini()
{
    
	
	//var value=controlli('');
 
	//if (value == -1)
	//    return;
	
	
	//controllo se è selezionato il modello nella testata prodotti per procedere
	if ( getObjValue('Tipo_Modello_Convenzione_Scelta') == '' )
	{
		DMessageBox('../', 'Per aprire il Listino ordini necessario selezionare il Modello Convenzione completa', 'Attenzione', 1, 400, 300);		
		DocShowFolder( 'FLD_PRODOTTI' );
		return;
	}
	
	MakeDocFrom ( 'LISTINO_ORDINI##CONVENZIONE' );   
	
}


function OnchangePresenzaListinoOrdini()
{
	var PresenzaRigheListinoOrdini = getObj('PresenzaRigheListinoOrdini').value ;
	
	if ( PresenzaRigheListinoOrdini == '1' )
	{	
		strMsg = 'Attenzione proseguendo con l\'operazione viene annullato il listino ordini. Sei sicuro?' ; 

		if( confirm(CNV( '../../', strMsg )) ) 
		{
			
			ExecDocProcess( 'CANCELLA_LISTINO_ORDINI,CONVENZIONE,,NO_MSG');

		}
		else
		{
			//ripristino la precedente selezione
			getObj('PresenzaListinoOrdini').value = PresenzaListinoOrdini_Old;
		}
	
	}
	else
		ExecDocProcess( 'CANCELLA_LISTINO_ORDINI,CONVENZIONE,,NO_MSG');
	
}



function GetDatiDM()
{
	ExecDocProcess('SAVE_DOC_DM,DM,,NO_MSG');
}




function Elab_DM()
{
	// IdOfferta
	var IDDOC = getObjValue('IDDOC');
	
	
	
	if ( isSingleWin() )
	{
		var url;
		
		url = encodeURIComponent( 'CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=CONVENZIONE&lo=base' );
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunctionCenter('../../CustomDoc/DM_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=CONVENZIONE' );
	}  
	
	
	
	//alert(IDDOC);
}


// function SetFilterIniziative_FromRup()
// {	
	
	// //solo se il doc editabile e attivo il modulo PROGRAMMAZIONE_INIZIATIVE
	// if(getObjValue('isActive_GROUP_PROGRAMMAZIONE_INIZIATIVA') == 'yes')
	// {

		// var strFilter = 'SQL_WHERE= dmv_cod in ( select ID_Iniziativa from Rup_Programmazione_Iniziative where UserRUP = \'' + getObjValue ('UserRUP') + '\' )';

		// SetProperty(getObj('IdentificativoIniziativa'), 'filter', strFilter );
	// }
// }