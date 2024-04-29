window.onload = DISPLAY_FIRMA_OnLoad;
//Variabile di appoggio per contenere l'idpfu dell'utente collegato e gestire l'applicazione sia se accessibile sia no
var tmp_idpfuUtenteCollegato;
//array con i campi obbligatori sul documento
var LstAttrib = [ 

'NomeRapLeg',
'CognomeRapLeg',
'StatoRapLeg',
'LocalitaRapLeg',
'ProvinciaRapLeg',
'DataRapLeg',
//'CFRapLeg',
//'TelefonoRapLeg',
//'CellulareRapLeg',
'ResidenzaRapLeg',
'StatoResidenzaRapLeg',
'ProvResidenzaRapLeg',
'IndResidenzaRapLeg',
'CapResidenzaRapLeg',
//'PIVA',
//'EmailRapLeg',
//'TitoloProfessionale_albo_prof_3',
'AttivitaProfessionaleIstanza',
'carica_sociale',
'STATOLOCALITALEG',
'PROVINCIALEG',
'LOCALITALEG',
'NUMTEL',
'CAPLEG',
'INDIRIZZOLEG'
];

var NumControlli = LstAttrib.length;


function trim(str){
    return str.replace(/^\s+|\s+$/g,"");
}
function MySaveDoc(){
  SaveDoc();  
}

function InvioIstanza( param )
{


	if ( getObjValue('RichiestaFirma') == 'no')
	{
		var value=controlli(param);
	 
		if (value == -1)
			return;
		   
		 ExecDocProcess( 'SEND,ISTANZA_AlboOperaEco');
	 }
	 
	if (getObjValue('Attach') == "" && getObjValue('RichiestaFirma') != 'no' )
	{
		DMessageBox( '../' , 'Prima di Inviare il documento allegare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
		return;
	}
	if (getObjValue('Attach') != "" )
	{
		ExecDocProcess( 'PRE_SEND,ISTANZA_AlboOperaEco');

	}

}

function GeneraPDF ()
{

   var value2=controlli('');
   if (value2 == -1)
	    return;
    Stato = getObjValue('StatoDoc');
    
    if( Stato == '' ) 
    {
        //alert( 'Per effettuare la stampa si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di stampa');
		DMessageBox( '../' , 'Compilare l\'istanza in tutti i suoi campi obbligatori, successivamente effettuare nuovamente il comando genera pdf.' , 'Attenzione' , 1 , 400 , 300 );
        SaveDoc();
        return;
    }
    scroll(0,0);
    
    PrintPdfSign('URL=/report/prn_' + getObj('TYPEDOC').value + '.ASP?SIGN=YES&PROCESS=ISTANZA@@@VERIFICHE_PRE_PDF');
	
	
	
}

	

function TogliFirma () 
{

 if ( confirm(CNV('../../', 'Si sta per eliminare il file firmato.')) ) { 
 
   //DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
   ExecDocProcess( 'SIGN_ERASE,FirmaDigitale');
  }
  
}

function SetInitField()
{
   
   
	var i = 0;
	for( i = 0 ; i < NumControlli ; i++ )
	{
		TxtOK( LstAttrib[i] );
	}
	
} 




function LocalPrintPdf( param )
{
    
    Stato = getObjValue('StatoDoc');
    param = '/report/prn_' + getObj('TYPEDOC').value + '.ASP?'
    if( Stato == '' ) 
    {
        //alert( 'Per effettuare la stampa si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di stampa');
		DMessageBox( '../' , 'Per effettuare la stampa si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di stampa.' , 'Attenzione' , 1 , 400 , 300 );
        SaveDoc();
        return;
    }
  
    
    PrintPdf( param );

}

function DISPLAY_FIRMA_OnLoad()
{
    
	
	vis_studio_associato();	
	HideCestinodoc();
	HideCestino_SOTTOSCRITTI();
	HideCestinodoc_GEIE();
	FormatAllegato();	
	enable_disable_aggregazione_rete();
	SetOnChangeOnCodiceFiscale('GEIE_GRIDGrid');	
	Stato ='';
	Stato = getObjValue('StatoDoc');
	IdpfuInCharge = getObjValue('IdpfuInCharge');
	
	
	if ( typeof idpfuUtenteCollegato == 'undefined' )
		tmp_idpfuUtenteCollegato = getObjValue('IdpfuInCharge');
	else
		tmp_idpfuUtenteCollegato = idpfuUtenteCollegato;
	
	if ( getObjValue('RichiestaFirma') == 'no')
	 {
	  document.getElementById('DIV_FIRMA').style.display = "none";	
	}
	

	if (( getObjValue('SIGN_LOCK') =='0' || getObjValue('SIGN_LOCK') =='' )   && (Stato=='Saved' || Stato=="") && IdpfuInCharge == tmp_idpfuUtenteCollegato )
		{
		document.getElementById('generapdf').disabled = false; 
		document.getElementById('generapdf').className ="generapdf";
		}
	else
	   {
	   document.getElementById('generapdf').disabled = true; 
	   document.getElementById('generapdf').className ="generapdfdisabled";
	   }
	  	 
	if ( getObjValue('SIGN_LOCK') != '0'   && (Stato=='Saved') && IdpfuInCharge == tmp_idpfuUtenteCollegato )
		{
		document.getElementById('editistanza').disabled = false; 
		document.getElementById('editistanza').className ="attachpdf";
		}
	else
	   {
	   document.getElementById('editistanza').disabled = true; 
	   document.getElementById('editistanza').className ="attachpdfdisabled";
	   } 
	if ( getObjValue('SIGN_ATTACH') == ''  &&  (Stato=='Saved') && getObjValue('SIGN_LOCK') != '0'  && IdpfuInCharge == tmp_idpfuUtenteCollegato  )
		{
		document.getElementById('attachpdf').disabled = false; 
		document.getElementById('attachpdf').className ="editistanza";
		}
	else
	   {
	   document.getElementById('attachpdf').disabled = true; 
	   document.getElementById('attachpdf').className ="editistanzadisabled";
	   }
		
	
	if (  IdpfuInCharge != tmp_idpfuUtenteCollegato )
	{
		getObj('apriGEO' + '_link').setAttribute("onclick", "return false;" );
		getObj('apriGEO').className = "";
		getObj('apriGEO' + '_link').style.cursor="default";
		
		getObj('apriGEO2' + '_link').setAttribute("onclick", "return false;" );
		getObj('apriGEO2').className = "";
		getObj('apriGEO2' + '_link').style.cursor="default";
		
		getObj('apriGEO3' + '_link').setAttribute("onclick", "return false;" );
		getObj('apriGEO3').className = "";
		getObj('apriGEO3' + '_link').style.cursor="default";
		
		
	}
	initAziEnte();

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
    var err = 0;
	
	

	for( i = 0 ; i < NumControlli ; i++ )
	{
  
		try{
			 if ( getObj(LstAttrib[i]).type == 'text' || getObj(LstAttrib[i]).type == 'hidden' 
				||  getObj(LstAttrib[i]).type == 'select-one' ||  getObj(LstAttrib[i]).type == 'textarea')
			  {
				if( trim(getObjValue( LstAttrib[i] )) == ''  || trim(getObjValue( LstAttrib[i] )) == '###' )
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
    
   
    
	//se non sono un libero professionista singolo
	if ( getObj('carica_sociale').value != 1  )
	{
		var NRELENCO_PROFGrid = GetProperty( getObj('ELENCO_PROFGrid') , 'numrow');		
		//alert(NRELENCO_PROFGrid);
		if  ( Number( NRELENCO_PROFGrid ) < 0 )
		{
			DMessageBox( '../' , 'Per proseguire e\' necessaria la compilazione di almeno una riga per la tabella "I sottoscritti"' , 'Attenzione' , 1 , 400 , 300 );
			return -1;
		}
		
		
		
		
		if(  Number( NRELENCO_PROFGrid ) >= 0 )
		{
			
			 for( i = 0 ; i <= NRELENCO_PROFGrid ; i++ )
			 {
				 try
				 {
					if( getObjValue( 'RELENCO_PROFGrid_' + i + '_NomeDirTec' ) == '' )
					{
						err = 1;
						TxtErr( 'RELENCO_PROFGrid_' + i + '_NomeDirTec' );
					}
					else
					{							 
						TxtOK( 'RELENCO_PROFGrid_' + i + '_NomeDirTec' );
					}

					if( getObjValue( 'RELENCO_PROFGrid_' + i + '_CognomeDirTec' ) == '' )
					{
						err = 1;
						TxtErr( 'RELENCO_PROFGrid_' + i + '_CognomeDirTec' );
					}
					else
					{							 
						TxtOK( 'RELENCO_PROFGrid_' + i + '_CognomeDirTec' );
					}								
					
					if( getObjValue( 'RELENCO_PROFGrid_' + i + '_LocalitaDirTec' ) == '' )
					{
						err = 1;
						TxtErr( 'RELENCO_PROFGrid_' + i + '_LocalitaDirTec' );
					}
					else
					{							 
						TxtOK( 'RELENCO_PROFGrid_' + i + '_LocalitaDirTec' );
					}		

					if( getObjValue( 'RELENCO_PROFGrid_' + i + '_DataDirTec' ) == '' )
					{
						err = 1;
						TxtErr( 'RELENCO_PROFGrid_' + i + '_DataDirTec' );
					}
					else
					{							 
						TxtOK( 'RELENCO_PROFGrid_' + i + '_DataDirTec' );
					}								
					
					if( getObjValue( 'RELENCO_PROFGrid_' + i + '_CFDirTec' ) == '' )
					{
						err = 1;
						TxtErr( 'RELENCO_PROFGrid_' + i + '_CFDirTec' );
					}
					else
					{							 
						TxtOK( 'RELENCO_PROFGrid_' + i + '_CFDirTec' );
					}								
					
					if( getObjValue( 'RELENCO_PROFGrid_' + i + '_RuoloUtente' ) == '' )
					{
						err = 1;
						TxtErr( 'RELENCO_PROFGrid_' + i + '_RuoloUtente' );
					}
					else
					{							 
						TxtOK( 'RELENCO_PROFGrid_' + i + '_RuoloUtente' );
					}								
					
					if( getObjValue( 'RELENCO_PROFGrid_' + i + '_ordine_associato' ) == '' )
					{
						err = 1;
						TxtErr( 'RELENCO_PROFGrid_' + i + '_ordine_associato' );
					}
					else
					{							 
						TxtOK( 'RELENCO_PROFGrid_' + i + '_ordine_associato' );
					}
					
					if( getObjValue( 'RELENCO_PROFGrid_' + i + '_ordine_associato_PIVA_CF' ) == '' )
					{
						err = 1;
						TxtErr( 'RELENCO_PROFGrid_' + i + '_ordine_associato_PIVA_CF' );
					}
					else
					{							 
						TxtOK( 'RELENCO_PROFGrid_' + i + '_ordine_associato_PIVA_CF' );
					}
			     }catch(e){} 			  
			 }
		}
	}
	
	var numrrowGEIE = Number(GetProperty( getObj('GEIE_GRIDGrid') , 'numrow') );
	if(   numrrowGEIE  >= 0 )
	{
		 
		 var t=0;
		 for (t=0;t<numrrowGEIE+1;t++)
		 {
					
				if ( getObj('RGEIE_GRIDGrid_' + t + '_codicefiscale').value == '')
				{
					err=1;
					TxtErr( 'RGEIE_GRIDGrid_' + t + '_codicefiscale' );
				}
				else
				{
					TxtOK( 'RGEIE_GRIDGrid_' + t + '_codicefiscale' );
				}
				
				/*
				if ( getObj('RGEIE_GRIDGrid_' + t + '_Ruolo_Impresa').value == '')
				{
					err=1;
					TxtErr( 'RGEIE_GRIDGrid_' + t + '_Ruolo_Impresa' );
				}
				else
				{
					TxtOK( 'RGEIE_GRIDGrid_' + t + '_Ruolo_Impresa' );
				}
				*/
				
				if ( getObj('RGEIE_GRIDGrid_' + t + '_Allegato').value == '')
				{
					err=1;
					TxtErr( 'RGEIE_GRIDGrid_' + t + '_Allegato' );
				}
				else
				{
					TxtOK( 'RGEIE_GRIDGrid_' + t + '_Allegato' );
				}
				
				if ( getObj('RGEIE_GRIDGrid_' + t + '_AllegatoDGUE').value == '')
				{
					err=1;
					TxtErr( 'RGEIE_GRIDGrid_' + t + '_AllegatoDGUE' );
				}
				else
				{
					TxtOK( 'RGEIE_GRIDGrid_' + t + '_AllegatoDGUE' );
				}
				
			
		 
		 }
		
	}		
		
		
		var numrrowdoc = Number(GetProperty( getObj('DOCUMENTAZIONEGrid') , 'numrow') );
		if(   numrrowdoc  >= 0 )
        {
			 
			 var t=0;
			 for (t=0;t<numrrowdoc+1;t++)
			 {
								
					if ( getObj('RDOCUMENTAZIONEGrid_' + t + '_Allegato').value == '')
					{
						err=1;
						TxtErr( 'RDOCUMENTAZIONEGrid_' + t + '_Allegato' );
					}
					else
					{
						TxtOK( 'RDOCUMENTAZIONEGrid_' + t + '_Allegato' );
					}
				
			 
			 }
			
		}
		
	if ( getObj('check_1').checked == false && 	getObj('check_2').checked == false &&
		 getObj('check_3').checked == false && getObj('check_4').checked == false &&
		 getObj('check_5').checked == false && getObj('check_6').checked == false &&
		 getObj('check_7').checked == false && getObj('check_8').checked == false &&
		 getObj('check_9').checked == false && getObj('check_10').checked == false 
		)
	{
		err=1;
		TxtErr( 'check_1' );TxtErr( 'check_2' );TxtErr( 'check_3' );TxtErr( 'check_4' );
		TxtErr( 'check_5' );TxtErr( 'check_6' );TxtErr( 'check_7' );TxtErr( 'check_8' );
		TxtErr( 'check_9' );TxtErr( 'check_10' );
			
	}
	else
	{
		TxtOK( 'check_1' );TxtOK( 'check_2' );TxtOK( 'check_3' );TxtOK( 'check_4' );
		TxtOK( 'check_5' );TxtOK( 'check_6' );TxtOK( 'check_7' );TxtOK( 'check_8' );
		TxtOK( 'check_9' );TxtOK( 'check_10' );
	}	
	  
	if ( getObj('check_9').checked == true )
	{
		if ( getObj('check_9_1').checked == false && getObj('check_9_2').checked == false && getObj('check_9_3').checked == false )
		{
			err=1;
			TxtErr( 'check_9_1' );TxtErr( 'check_9_2' );TxtErr( 'check_9_3' );
		}
		else
		{
			TxtOK( 'check_9_1' );TxtOK( 'check_9_2' );TxtOK( 'check_9_3' );
		}
	}
	
    if(  err > 0 )
	{
		
		DMessageBox( '../' , 'Per proseguire e\' necessaria la compilazione di tutti i campi evidenziati' , 'Attenzione' , 1 , 400 , 300 );
        return -1;
	}
}

function MyExecDocProcess(param){
	
 
	ExecDocProcess(param);
}




function Doc_DettagliDel( grid , r , c )
{
	var v = '0';
	try
	{
		v = getObj( 'RDOCUMENTAZIONEGrid_' + r + '_Obbligatorio' ).value ;
	}catch(e){};
	
    if( v == '1' )
    {
        //DMessageBox( '../' , 'La documentazione è obbligatoria' , 'Attenzione' , 1 , 400 , 300 );
    }
    else
    {
        DettagliDel( grid , r , c );
    }
}


function DOCUMENTAZIONE_AFTER_COMMAND ()
{
	HideCestinodoc();	
	FormatAllegato();
}
function ELENCO_PROF_AFTER_COMMAND ()
{
	HideCestino_SOTTOSCRITTI();		
}
function GEIE_GRID_AFTER_COMMAND()
{
	HideCestinodoc_GEIE();
	SetOnChangeOnCodiceFiscale('GEIE_GRIDGrid');	
	//aggiorno il campo denominazioneATI
    UpgradeDenominazioneRTI();
}


function HideCestinodoc()
{
    try{
        var i = 0;
		
		
		if ((getObj('StatoDoc').value== 'Saved' || getObj('StatoDoc').value == '' ) && (getObj('SIGN_LOCK').value == '0') )
		{
			for( i=0; i < DOCUMENTAZIONEGrid_EndRow+1 ; i++ )
			{
				if( getObj( 'RDOCUMENTAZIONEGrid_' + i + '_Obbligatorio' ) . value == '1' )
				{
					
					getObj( 'DOCUMENTAZIONEGrid_r' + i + '_c0' ).innerHTML = '&nbsp;';
				}
			}
		}
   }catch(e){}
  
}

function HideCestino_SOTTOSCRITTI()
{
    try{
        var i = 0;
		
		
		if ((getObj('StatoDoc').value== 'Saved' || getObj('StatoDoc').value == '' ) && (getObj('SIGN_LOCK').value == '0') )
		{		
					
			getObj( 'ELENCO_PROFGrid_r' + i + '_c0' ).innerHTML = '&nbsp;';				
			
		}
   }catch(e){}
  
}


function HideCestinodoc_GEIE()
{
    try{
        var i = 0;
		
		
		if ((getObj('StatoDoc').value== 'Saved' || getObj('StatoDoc').value == '' ) && (getObj('SIGN_LOCK').value == '0') )
		{			
			getObj( 'GEIE_GRIDGrid_r' + i + '_c1' ).innerHTML = '&nbsp;';	
			TextreadOnly( 'RGEIE_GRIDGrid_0_codicefiscale' ,true);
		}
   }catch(e){}
  
}
//funzione per inserire nella sezione documentazione i tipi allegati consentiti scelti in creazione del BANDO
function FormatAllegato()
{
	var numDocu = GetProperty( getObj('DOCUMENTAZIONEGrid') , 'numrow');
	var tipofile;
	var richiestaFirma;
	var onclick;
	var obj;
	
	
	
	for( i = 0 ; i <= numDocu ; i++ )
	{
		try
		{
			tipofile=getObj('RDOCUMENTAZIONEGrid_' + i + '_TipoFile').value;
			
			try
			{
				richiestaFirma=getObj('RDOCUMENTAZIONEGrid_' + i + '_RichiediFirma').value;
			}
			catch(e)
			{
				richiestaFirma='';
			}

			if ( tipofile != '' )
			{
				tipofile=ReplaceExtended(tipofile,'###',',');
				tipofile='EXT:'+tipofile.substring(1,tipofile.lenghth);
				tipofile=tipofile.substring(0, tipofile.length-1)+'-';
				tipofile='FORMAT=INTV'+tipofile;
				
				if ( richiestaFirma == '1' )
				{
					tipofile = tipofile + 'INTVB'; //format per forzare la verifica di firma bloccante in caso di mancata firma o file corrotto
				}
				
				obj=getObj('RDOCUMENTAZIONEGrid_' + i + '_Allegato_V_BTN' ).parentElement;	//errore
				onclick=obj.innerHTML;
				onclick=onclick.replace(/FORMAT=INTV/g,tipofile);
				onclick=onclick.replace(/FORMAT=INT/g,tipofile);
				obj.innerHTML = onclick;
			}
			//se per qualche motivo tolta INTV nasconde img della pennina
			
			try
			{
				if ( onclick.indexOf('FORMAT=INTV') < 0 )
				{
					$('#RDOCUMENTAZIONEGrid_' + i + '_Allegato_V_N').siblings('.IMG_SIGNINFO').hide();					
				}
			}
			catch(e)
			{		
			}
			

		}
		catch(e)
		{
		}
	}

	
}


function RefreshContent()
{
    RefreshDocument('');      
}




function IsNumeric2(sText)
{
   var ValidChars = '0123456789.';
   var IsNumber=true;
   var Char;
 
   for (i = 0; i < sText.length && IsNumber == true; i++) 
      { 
      Char = sText.charAt(i);
      if (ValidChars.indexOf(Char) == -1) 
         {
         IsNumber = false;
         }
      }
   return IsNumber;
   
   }


function roundTo(X , decimalpositions)
{
    var i = X * Math.pow(10,decimalpositions);
    i = Math.round(i);
    return i / Math.pow(10,decimalpositions);
}

function ControllaCF(cf)
{
    var validi, i, s, set1, set2, setpari, setdisp;
    if( cf == '' )  return '';
    cf = cf.toUpperCase();
    if( cf.length != 16 )
        return "La lunghezza del codice fiscale non e'\n"
        +"corretta: il codice fiscale dovrebbe essere lungo\n"
        +"esattamente 16 caratteri.";
    validi = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    for( i = 0; i < 16; i++ ){
        if( validi.indexOf( cf.charAt(i) ) == -1 )
            return "Il codice fiscale contiene un carattere non valido \'" +
                cf.charAt(i) +
                "\'.\nI caratteri validi sono le lettere e le cifre.";
    }
    set1 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    set2 = "ABCDEFGHIJABCDEFGHIJKLMNOPQRSTUVWXYZ";
    setpari = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    setdisp = "BAKPLCQDREVOSFTGUHMINJWZYX";
    s = 0;
    for( i = 1; i <= 13; i += 2 )
        s += setpari.indexOf( set2.charAt( set1.indexOf( cf.charAt(i) )));
    for( i = 0; i <= 14; i += 2 )
        s += setdisp.indexOf( set2.charAt( set1.indexOf( cf.charAt(i) )));
    if( s%26 != cf.charCodeAt(15)-'A'.charCodeAt(0) )
        return "Il codice fiscale non e\' corretto:\n"+
            "il codice di controllo non corrisponde.";
    return "";
}

function ControllaPIVA(pi)
{
    if( pi == '' )  return '';
    if( pi.length != 11 )
        return "La lunghezza della partita IVA non e\'\n" +
            "corretta: la partita IVA dovrebbe essere lunga\n" +
            "esattamente 11 caratteri.";
    validi = "0123456789";
    for( i = 0; i < 11; i++ ){
        if( validi.indexOf( pi.charAt(i) ) == -1 )
            return "La partita IVA contiene un carattere non valido \'" +
                pi.charAt(i) + "'.\nI caratteri validi sono le cifre.";
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
        return "La partita IVA non e\' valida:\n" +
            "il codice di controllo non corrisponde.";
    return '';
}
function vis_studio_associato()
{
	
	if ( getObjValue('carica_sociale') == '1' )
	{
		try{document.getElementById('div_ELENCO_PROFGrid').style.display = 'none';}catch(e){}
		try{document.getElementById('TOOLBAR_ELENCO_PROF_ADDNEW').style.display = "none";}catch(e){}
	}
	else
	{
		try{document.getElementById('div_ELENCO_PROFGrid').style.display = '';}catch(e){}
		try{document.getElementById('TOOLBAR_ELENCO_PROF_ADDNEW').style.display = "";}catch(e){}
	}
}



//GESTIONE DEI CAMPI LOCALITA PROVINCIA E STATO
function initAziEnte()
{
	enableDisableAziGeo('LocalitaRapLeg','ProvinciaRapLeg','StatoRapLeg','apriGEO',true);
	enableDisableAziGeo('ResidenzaRapLeg','ProvResidenzaRapLeg','StatoResidenzaRapLeg','apriGEO2',true);
	enableDisableAziGeo('LOCALITALEG','PROVINCIALEG','STATOLOCALITALEG','apriGEO3',true);
}


function impostaLocalita(cod,fieldname)
{
	ajax = GetXMLHttpRequest(); 
	
	var comuneTec;
	var provinciaTec;
	var statoTec;
	var comuneDesc; 
	var provinciaDesc;
	var statoDesc;
	
	if ( fieldname == 'RapLeg' )
	{
		comuneTec='LocalitaRapLeg2';
		provinciaTec='ProvinciaRapLeg2';
		statoTec='StatoRapLeg2';
		comuneDesc='LocalitaRapLeg';
		provinciaDesc='ProvinciaRapLeg';
		statoDesc='StatoRapLeg';
		geo='apriGEO'
	}
	if ( fieldname == 'ResidenzaRapLeg' )
	{
		comuneTec='ResidenzaRapLeg2';
		provinciaTec='ProvResidenzaRapLeg2';
		statoTec='StatoResidenzaRapLeg2';
		comuneDesc='ResidenzaRapLeg';
		provinciaDesc='ProvResidenzaRapLeg';
		statoDesc='StatoResidenzaRapLeg';
		geo='apriGEO2'
	}
	if ( fieldname == 'LOCALITALEG' )
	{
		comuneTec='LOCALITALEG2';
		provinciaTec='PROVINCIALEG2';
		statoTec='STATOLOCALITALEG2';
		comuneDesc='LOCALITALEG';
		provinciaDesc='PROVINCIALEG';
		statoDesc='STATOLOCALITALEG';
		geo='apriGEO3'
	}
	

	if(ajax)
	{
		ajax.open("GET", '../../ctl_library/functions/infoNodoGeo.asp?fldname=localita&cod=' + escape(cod), false);
		//output nella forma : COD-COMUNE#@#DESC-COMUNE#@#COD-PROVINCIA#@#DESC-PROVINCIA#@#COD-STATO#@#DESC-STATO
		ajax.send(null);

		if(ajax.readyState == 4) 
		{
			//Se non ci sono stati errori di runtime
			if(ajax.status == 200)
			{
				if ( ajax.responseText != '' ) 
				{
					var res = ajax.responseText;
					
					//Se l'esito della chiamata è stato positivo
					if ( res.substring(0, 2) == '1#' ) 
					{
						try
						{
							var vet = res.substring(4).split( '#@#' );
							
							var codLoc;
							var descLoc;
							var codProv;
							var descProv;
							var codStato;
							var descStato;

							codLoc = vet[0];
							descLoc = vet[1];
							codProv = vet[2];
							descProv = vet[3];
							codStato = vet[4];
							descStato = vet[5];

							getObj(comuneTec).value = codLoc;
							getObj(comuneDesc).value = descLoc;

							if ( codLoc == '' || codLoc.substring( codLoc.length-3, codLoc.length ) == 'XXX' )
								disableGeoField( comuneDesc, false);
							else
								disableGeoField( comuneDesc, true);

							getObj(provinciaTec).value = codProv;
							getObj(provinciaDesc).value = descProv;

							if ( codProv == '' || codProv.substring( codProv.length-3, codProv.length ) == 'XXX' )
								disableGeoField( provinciaDesc, false);
							else
								disableGeoField( provinciaDesc, true);

							getObj(statoTec).value = codStato;
							getObj(statoDesc).value = descStato;

							if ( codStato == ''  || codStato.substring( codStato.length-3, codStato.length ) == 'XXX' )
								disableGeoField( statoDesc, false);
							else
								disableGeoField( statoDesc, true);
								
						}
						catch(e)
						{
							alert('Errore:' + e.message);
							
						}
					}
					else
					{
						alert('errore.msg:' + res.substring(2));
						enableDisableAziGeo(comuneDesc,provinciaDesc,statoDesc,geo,false);
					}
				}
			}
			else
			{
				alert('errore.status:' + ajax.status);
				enableDisableAziGeo(comuneDesc,provinciaDesc,statoDesc,geo,false);
				
			}
		}
		else
		{
			alert('errore in impostaLocalita');
			enableDisableAziGeo(comuneDesc,provinciaDesc,statoDesc,geo,false);
		}
	}
}
function OnChangeCheck(obj)
{
	var name=obj.name;
	var valore=obj.value;
	
	getObj('check_1').checked = false;
	getObj('check_2').checked = false;	
	getObj('check_3').checked = false;
	getObj('check_4').checked = false;
	getObj('check_5').checked = false;
	getObj('check_6').checked = false;
	getObj('check_7').checked = false;
	getObj('check_8').checked = false;
	if ( name != 'check_9_1' && name != 'check_9_2' && name != 'check_9_3')
	{
		getObj('check_9').checked = false;
	}
	getObj('check_9_1').checked = false;
	getObj('check_9_2').checked = false;
	getObj('check_9_3').checked = false;
	getObj('check_10').checked = false;
	
	if ( valore == '1' )
	{
		getObj(name).checked=true;
	}
	else
	{
		getObj(name).checked=false;
	}
	
	enable_disable_aggregazione_rete();
	
}
function enable_disable_aggregazione_rete()
{
	if ( getObj('check_9').checked == false )
	{
		getObj('check_9_1').disabled = true;
		getObj('check_9_2').disabled = true;
		getObj('check_9_3').disabled = true;	
		
	}
	else
	{
		getObj('check_9_1').disabled = false;
		getObj('check_9_2').disabled = false;
		getObj('check_9_3').disabled = false;
	}
}



//SETTO EVENTO ON CHANGE SULLA COLONNA CODICE FISCALE DELLE GRIGLIE RTI
function SetOnChangeOnCodiceFiscale(strFullNameArea) {

    var nNumRow = GetProperty(getObj(strFullNameArea), 'numrow');
    var nIndRrow;
    for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

        if (nIndRrow == 0 && strFullNameArea == 'GEIE_GRIDGrid') {

            //disabilito onkeyup su codice fiscale
            getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').onkeyup = '';

        } else {
            getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').onkeyup = GetInfoAziendaFromCF;
            
        }

    }

}


//a partire dal codice fiscale ritorna le info di azienda
function GetInfoAziendaFromCF() {

   
	
	var IDDOC = getObjValue('IDDOC');
	//RRTIGRIDGrid_0_codicefiscale
    var strNameCtl = this.name;
	//alert(strNameCtl);
    var aInfo = strNameCtl.split('_');
	

    var nIndRrow = aInfo[2];

    var strCF = this.value;

    var Grid = aInfo[0].substr(1, aInfo[0].length);
	
	Grid=Grid + '_GRIDGrid';
	
	var bIsUnique_blocco=false;
	
	

    
    
    if (strCF.length >= 7) {

        //if  ( bIsUnique ){

        //provo a ricercare le info azienda
        ajax = GetXMLHttpRequest();
	
        if (ajax) {
            ajax.open("GET", '../../ctl_library/functions/InfoAziFromCF.asp?AZIPROFILO=S&CodiceFiscale=' + encodeURIComponent(strCF) + '&IDDOC=' + IDDOC + '&Grid=' + encodeURIComponent(Grid), false);

            ajax.send(null);

            if (ajax.readyState == 4) {
                //alert(ajax.status);
                if (ajax.status == 200) {
                    //alert(ajax.responseText);
                    if (ajax.responseText != '' && ajax.responseText.indexOf('#', 0) > 0) 
					{

                        //alert(ajax.responseText);    
                        this.style.color = 'black';
                        var strresult = ajax.responseText;
						
						
						
						if ( bIsUnique_blocco != true )
						{
							SetInfoAziendaRow(Grid, nIndRrow, strresult);

							//faccio alert se azienda presente in altra griglia
							var bIsUnique = AziIsUnique(Grid, nIndRrow, strCF);
						}
						

                    } 
					else 
					{

						if (ajax.responseText != '')
							LocDMessageBox('../', ajax.responseText, 'Attenzione', 1, 400, 300);

						//setto i caratteri in rosso
						this.style.color = 'red';

						//svuoto i campi
						SetInfoAziendaRow(Grid, nIndRrow, '#######');


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
        this.style.color = 'red';

        //svuoto i campi
        SetInfoAziendaRow(Grid, nIndRrow, '#######');
    }

    //aggiorno campo denominazione
    UpgradeDenominazioneRTI();
}



//setta le info di una azienda su una riga di una griglia
function SetInfoAziendaRow(strFullNameArea, nIndRrow, strresult) 
{
    var nPos;
    var ainfoAzi = strresult.split('#');

    var strRagSoc = ainfoAzi[0];
	
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc').value = strRagSoc;
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc_V').innerHTML = strRagSoc;


    /*
    if (strFullNameArea == 'DOCUMENTAZIONE_ATIgriglia' && nIndRrow==0){
      var strCodicefiscale = ainfoAzi[4];
      getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value=strCodicefiscale;
    }*/

    var strIndLeg = ainfoAzi[1];
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_INDIRIZZOLEG').value = strIndLeg;
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_INDIRIZZOLEG_V').innerHTML = strIndLeg;

    var strLocLeg = ainfoAzi[2];
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_LOCALITALEG').value = strLocLeg;
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_LOCALITALEG_V').innerHTML = strLocLeg;


    var strProvLeg = ainfoAzi[3];
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_PROVINCIALEG').value = strProvLeg;
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_PROVINCIALEG_V').innerHTML = strProvLeg;



    var strIdazi = ainfoAzi[5];
    getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_IdAzi').value = strIdazi;

	
}



//controlla che questo codice fiscale non sia già presente
function AziIsUnique(strNameAreaCurrent, nRowCurrent, strCF ) {

    var bIsUnique = true;

    //griglia RTI
    var nIndRrow;
    var strFullNameArea = 'GEIE_GRIDGrid';

    var nNumRow = -1;
	
	try
	{
		nNumRow=Number(GetProperty(getObj(strFullNameArea), 'numrow'));
	}
	catch(e)
	{
	}
	
    for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

        if( strFullNameArea != strNameAreaCurrent || (strFullNameArea == strNameAreaCurrent && Number(nIndRrow) != Number(nRowCurrent)) ) 
		{

            if (getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_codicefiscale').value.toUpperCase() == strCF.toUpperCase()) 
			{
                //alert( CNV ('../../' , 'azienda gia inserita nella griglia RTI') );
                LocDMessageBox('../', 'azienda gia inserita nella griglia GEIE', 'Attenzione', 1, 400, 300);				
                bIsUnique = false;
                return bIsUnique;
				
            }
        }
    }





    return bIsUnique;

}
function LocDMessageBox(path, Text, Title, ICO, w, h) {
    //alert(CNV('../../', Text));
	ML_text = Text
	Title = 'Informazione';					
	ICO = 1;
	page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);

	ExecFunctionModale( page, null , 200 , 420 , null  );
	
}



//ricostruisce il campo denominazione
function UpgradeDenominazioneRTI() {
	
	//se doc non editabile non faccio nulla
	if (  getObjValue('DOCUMENT_READONLY') != '0' ) 
		return;
	
    var strTempValue;
    //aggiorno campo nascosto con la denominazione
    var objDenominazioneATI = getObj('DenominazioneATI');
    objDenominazioneATI.value = '';

    var nIndRrow;
    var strFullNameArea;
    var nNumRow;
	
	
   

        strFullNameArea = 'GEIE_GRIDGrid';
		nNumRow = -1;
		
		try
		{
			nNumRow = Number(GetProperty(getObj(strFullNameArea), 'numrow'));
		}
		catch(e)
		{
		}
		
        if (nNumRow >= 0 && getObjGrid('R' + strFullNameArea + '_0_RagSoc').value != '') {

            objDenominazioneATI.value = 'Raggruppamento ';

            for (nIndRrow = 0; nIndRrow <= nNumRow; nIndRrow++) {

                strTempValue = getObjGrid('R' + strFullNameArea + '_' + nIndRrow + '_RagSoc').value;

                if (strTempValue != '') {
                    if (nIndRrow == 0)
                        objDenominazioneATI.value = objDenominazioneATI.value + strTempValue;
                    else
                        objDenominazioneATI.value = objDenominazioneATI.value + ' - ' + strTempValue;
                }

            }
        }
    

	
	

    //se il campo DenominazioneATI è vuoto setto la ragione sociale del fornitore che ha fatto l'offerta
    
    if (objDenominazioneATI.value == '') 
	{

        ajax = GetXMLHttpRequest();

        if (ajax) {

            ajax.open("GET", '../../ctl_library/functions/InfoAziFromCF.asp?IdAzi=' + getObj('Azienda').value, false);

            ajax.send(null);

            if (ajax.readyState == 4) {

                if (ajax.status == 200) {
                    if (ajax.responseText != '') {

                        //alert(ajax.responseText);
                        var strTempValue = ajax.responseText;
                        var ainfo = strTempValue.split('#');
                        objDenominazioneATI.value = ainfo[0];

                    }
                }
            }

        }


    }

    
    //aggiorno il campo visuale
	  getObj('DenominazioneATI_V').innerHTML = objDenominazioneATI.value;	 
	  
    
}
function Esporta_Classi_Selezionate()  
{
	ExecDownloadSelf( pathRoot + 'CTL_Library/accessBarrier.asp?goto=../Report/CSV_LOTTI.asp&IDDOC=' + getObjValue('IDDOC') + '&TIPODOC=ISTANZA_AlboProf_3&TitoloFile=Elenco_Classi_Selezionate&MODEL=ISTANZA_AlboProf_3_XLS_ESTRACT&VIEW=VIEW_ISTANZA_AlboProf_3_XLS_ESTRACT&Sort=id');
}