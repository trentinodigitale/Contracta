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
'CFRapLeg',
'TelefonoRapLeg',
'CellulareRapLeg',
'ResidenzaRapLeg',
'StatoResidenzaRapLeg',
'ProvResidenzaRapLeg',
'IndResidenzaRapLeg',
'CapResidenzaRapLeg',
//'PIVA',
//'EmailRapLeg',
'CittaEntrate',
'OrdineProfessionale',
'ProvinciaOrdProfessionale',
'NumeroOrdProfessionale',
'TitoloProfessionale',
'AttivitaProfessionaleIstanza'
];
var LstAttrib_associati = [ 
'aziRagioneSociale',
'NaGi',
'Sede',
'NumeroCivico',
//'aziLocalitaLeg',
'aziCAPLeg',
//'aziProvinciaLeg',
'NUMTEL',
//'NUMFAX',
//'EmailAssociato',
'CFRapLegassociato',
'PIVAassociato',
'SedeCCIAA',
'IscrCCIAA',
'DataCCIAA',
'STATOLOCALITALEG',
'LOCALITALEG',
'PROVINCIALEG'

]

var NumControlli = LstAttrib.length;
var NumControlli_associati = LstAttrib_associati.length;

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
    
    PrintPdfSign('URL=/report/prn_' + getObj('TYPEDOC').value + '.ASP?SIGN=YES&PROCESS=ISTANZA@@@VERIFICHE_PRE_PDF&VIEW_FOOTER_HEADER=ISTANZA_AlboProf_BIM_HF_Stampe');
	
	
	
}

function controllo_attivita_send(grid , r , c)
{
	
	
	var NRFATTURATO_Grid = GetProperty( getObj('POSIZIONI_FATTURARO_INCARICHIGrid') , 'numrow');
	
	var err = 0;
	
	if(  Number( NRFATTURATO_Grid ) >= 0 )
    {
		
    	 for( i = 0 ; i <= NRFATTURATO_Grid ; i++ )
    	 {
			 try
			 {
					if( getObjValue( 'RPOSIZIONI_FATTURARO_INCARICHIGrid_' + i + '_Importo' ) == '' )
					{
						 err = 1;
						 TxtErr( 'RPOSIZIONI_FATTURARO_INCARICHIGrid_' + i + '_Importo' );
					}
					else
					{
						 
						 TxtOK( 'RPOSIZIONI_FATTURARO_INCARICHIGrid_' + i + '_Importo' );
					}
					
			}catch(e){};
		 }	
	
	}
	
	
	if(  err > 0 )
	{
		DMessageBox( '../' , 'Per proseguire e\' necessaria la compilazione di tutti i campi evidenziati' , 'Attenzione' , 1 , 400 , 300 );
		return -1;
	}
	
	return 0;
	
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
	for( i = 0 ; i < NumControlli_associati ; i++ )
	{
		TxtOK( LstAttrib_associati[i] );
	}
} 

function Iscrizione_Previdenza() 
{
	try
	{
		if( document.getElementsByName('cassaprevidenza')[0].checked == true )
			{
			
				if( GetProperty( getObj('PREVIDENZAGrid') , 'numrow') > -1) 
				  {
				   //alert(getObj('cassaprevidenza'));
					 //getObj('cassaprevidenza').checked = false;
					 document.FORMDOCUMENT.cassaprevidenza[0].checked=false;
					 document.FORMDOCUMENT.cassaprevidenza[1].checked=true;
			 DMessageBox( '../' , 'Prima di cambiare la selezione eliminare le righe dalla griglia sottostante' , 'Attenzione' , 1 , 400 , 300 );
					 
					 return;			 
				  }

				document.getElementById('TOOLBAR_PREVIDENZA_ADDNEW').style.display = "none";	   
			  
			}

			if( document.getElementsByName('cassaprevidenza')[1].checked == true )
				{
					document.getElementById('TOOLBAR_PREVIDENZA_ADDNEW').style.display = "";		
					if( GetProperty( getObj('PREVIDENZAGrid') , 'numrow')==-1)
						ExecDocCommand( 'PREVIDENZA#AddNew#');
				}
			

			//if( document.getElementsByName('cassaprevidenza')[0].checked == false && document.getElementsByName('cassaprevidenza')[1].checked == false )	
			if ( document.FORMDOCUMENT.cassaprevidenza[0].checked == false &&  document.FORMDOCUMENT.cassaprevidenza[1].checked == false )
			{
				document.getElementById('TOOLBAR_PREVIDENZA_ADDNEW').style.display = "none";	   
			}
	}catch(e){};
}




function LocalPrintPdf( param )
{
    
    Stato = getObjValue('StatoDoc');
    param = '/report/prn_' + getObj('TYPEDOC').value + '.ASP?&VIEW_FOOTER_HEADER=ISTANZA_AlboProf_BIM_HF_Stampe'
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
	FormatAllegato();
	Iscrizione_Previdenza();
	Iscrizione_dipendentesino();
	toolbar_posizioni_elenco_prof();
	
	Stato ='';
	Stato = getObjValue('StatoDoc');
	IdpfuInCharge = getObjValue('IdpfuInCharge');
	
	/*if ( Stato != 'Saved' && Stato != '' )
	{
	 document.getElementById('DIV_FIRMA').style.display = "none";	
	}*/
	
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
window.onload = DISPLAY_FIRMA_OnLoad;


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
	
	if ( controllo_attivita_send('','','') == -1 )
	{
		err = 1;
		return-1;
	}

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
	if ( getObj('TitoloProfessionale').value != 1 )
	{
		for( k = 0 ; k < NumControlli_associati ; k++ )
		{
	  
			try{
				 if ( getObj(LstAttrib_associati[k]).type == 'text' || getObj(LstAttrib_associati[k]).type == 'hidden' 
					||  getObj(LstAttrib_associati[k]).type == 'select-one' ||  getObj(LstAttrib_associati[k]).type == 'textarea')
				  {
					if( trim(getObjValue( LstAttrib_associati[k] )) == '' )
					{
						err = 1;
						TxtErr( LstAttrib_associati[k] );
					}
				 }

				if ( getObj(LstAttrib_associati[k]).type == 'checkbox' )
				{
					if( getObj( LstAttrib_associati[k] ).checked == false )
					{
						err = 1;
						TxtErr( LstAttrib_associati[k] );
					}
				}

		  
		  }catch(e)
		  {
				alert( k + ' - ' +  LstAttrib_associati[k] );
		  }

		}
	}
	
	
	if( document.getElementsByName('cassaprevidenza')[0].checked == false  && document.getElementsByName('cassaprevidenza')[1].checked == false )
	{
		 TxtErr( 'cassaprevidenzali' );
		 err = 1;
	}
	else
	 {		 
		  TxtOK( 'cassaprevidenzali');
		 
	 }
	 
	 if( document.getElementsByName('dipendentesino')[0].checked == false  && document.getElementsByName('dipendentesino')[1].checked == false )
	{
		 TxtErr( 'dipendentesinoli' );
		 err = 1;
	}
	else
	 {		 
		  TxtOK( 'dipendentesinoli');
		 
	 }
	 
	
	
	
	
	var NRPREVIDENZAGrid = GetProperty( getObj('PREVIDENZAGrid') , 'numrow');
		
	
    if(  Number( NRPREVIDENZAGrid ) >= 0 )
    {
		
    	 for( i = 0 ; i <= NRPREVIDENZAGrid ; i++ )
    	 {
      		 try
      		 {
            	    if( getObjValue( 'RPREVIDENZAGrid_' + i + '_NumPREVIDENZA' ) == '' )
                  {
            			 err = 1;
            			 TxtErr( 'RPREVIDENZAGrid_' + i + '_NumPREVIDENZA' );
            		}
      			else
      			 {
            			 
            			 TxtOK( 'RPREVIDENZAGrid_' + i + '_NumPREVIDENZA' );
            		}
            	   
            	    if( getObjValue( 'RPREVIDENZAGrid_' + i + '_SedePREVIDENZA' ) == '' )
                  {
            			 err = 1;
            			 TxtErr( 'RPREVIDENZAGrid_' + i + '_SedePREVIDENZA' );
            		}
      			else
      			 {
            			 
            			 TxtOK( 'RPREVIDENZAGrid_' + i + '_SedePREVIDENZA' );
            		}
          
      	   }catch(e)	  {	  }
      	   
      	   //alert( getObjValue( 'RPREVIDENZAGrid_' + i + '_DenominazionePREVIDENZA' ));
      	   
      	   if( getObjValue( 'RPREVIDENZAGrid_' + i + '_DenominazionePREVIDENZA' ) == '' )  {
      	       err = 1;
            	 TxtErr( 'RPREVIDENZAGrid_' + i + '_DenominazionePREVIDENZA' );
           }else{
              TxtOK( 'RPREVIDENZAGrid_' + i + '_DenominazionePREVIDENZA' );
           }
    	   
    	   
        }
    }
	
	
	
	
	
	var NRPOSIZIONI_INPSGrid = GetProperty( getObj('POSIZIONI_INPSGrid') , 'numrow');
		
	
    if(  Number( NRPOSIZIONI_INPSGrid ) >= 0 )
    {
		
	 for( i = 0 ; i <= NRPOSIZIONI_INPSGrid ; i++ )
	 {
		try
		{
      	    if( getObjValue( 'RPOSIZIONI_INPSGrid_' + i + '_NumINPS' ) == '' )
            {
      			 err = 1;
      			 TxtErr( 'RPOSIZIONI_INPSGrid_' + i + '_NumINPS' );
      		}
			else
			 {
      			 
      			 TxtOK( 'RPOSIZIONI_INPSGrid_' + i + '_NumINPS' );
      		}
      	   
      	    if( getObjValue( 'RPOSIZIONI_INPSGrid_' + i + '_SedeINPS' ) == '' )
            {
      			 err = 1;
      			 TxtErr( 'RPOSIZIONI_INPSGrid_' + i + '_SedeINPS' );
      		}
			else
			 {
      			 
      			 TxtOK( 'RPOSIZIONI_INPSGrid_' + i + '_SedeINPS' );
      		}
    
	   }catch(e)	  {	  }
    }
    }
	
	
	
	
	var NRPOSIZIONI_INAILGrid = GetProperty( getObj('POSIZIONI_INAILGrid') , 'numrow');
		
	
    if(  Number( NRPOSIZIONI_INAILGrid ) >= 0 )
    {
		
	 for( i = 0 ; i <= NRPOSIZIONI_INAILGrid ; i++ )
	 {
		try
		{
      	    if( getObjValue( 'RPOSIZIONI_INAILGrid_' + i + '_NumINAIL' ) == '' )
            {
      			 err = 1;
      			 TxtErr( 'RPOSIZIONI_INAILGrid_' + i + '_NumINAIL' );
      		}
			else
			 {
      			 
      			 TxtOK( 'RPOSIZIONI_INAILGrid_' + i + '_NumINAIL' );
      		}
      	   
      	    if( getObjValue( 'RPOSIZIONI_INAILGrid_' + i + '_SedeINAIL' ) == '' )
            {
      			 err = 1;
      			 TxtErr( 'RPOSIZIONI_INAILGrid_' + i + '_SedeINAIL' );
      		}
			else
			 {
      			 
      			 TxtOK( 'RPOSIZIONI_INAILGrid_' + i + '_SedeINAIL' );
      		}
      	   
      	   
		
	   }catch(e)	  {	  }
    }
    }
	
	
	
		
	var NRPOSIZIONI_ELENCO_PROFGrid = GetProperty( getObj('POSIZIONI_ELENCO_PROFGrid') , 'numrow');
		
	
    if(  Number( NRPOSIZIONI_ELENCO_PROFGrid ) >= 0 )
    {
		
	 for( i = 0 ; i <= NRPOSIZIONI_ELENCO_PROFGrid ; i++ )
	 {
		try
		{
      	    if( getObjValue( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_NomeDirTec' ) == '' )
            {
      			 err = 1;
      			 TxtErr( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_NomeDirTec' );
      		}
			else
			 {
      			 
      			 TxtOK( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_NomeDirTec' );
      		}
      	   
      	     if( getObjValue( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_CognomeDirTec' ) == '' )
            {
      			 err = 1;
      			 TxtErr( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_CognomeDirTec' );
      		}
			else
			 {
      			 
      			 TxtOK( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_CognomeDirTec' );
      		}
			
			 if( getObjValue( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_LocalitaDirTec' ) == '' )
            {
      			 err = 1;
      			 TxtErr( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_LocalitaDirTec' );
      		}
			else
			 {
      			 
      			 TxtOK( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_LocalitaDirTec' );
      		}
			
			 if( getObjValue( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_DataDirTec' ) == '' )
            {
      			 err = 1;
      			 TxtErr( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_DataDirTec' );
      		}
			else
			 {
      			 
      			 TxtOK( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_DataDirTec' );
      		}
			
			 if( getObjValue( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_CFDirTec' ) == '' )
            {
      			 err = 1;
      			 TxtErr( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_CFDirTec' );
      		}
			else
			 {
      			 
      			 TxtOK( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_CFDirTec' );
      		}
			
			 if( getObjValue( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_Allegato' ) == '' )
            {
      			 err = 1;
      			 TxtErr( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_Allegato' );
      		}
			else
			 {
      			 
      			 TxtOK( 'RPOSIZIONI_ELENCO_PROFGrid_' + i + '_Allegato' );
      		}
      	   
      	   
		
	   }catch(e)	  {	  }
    }
    }
	
	
	/*RIMOSSO IN QUANTO NON PRESENTE NELLA VERSIONE EDITABLE
	
	var NRPOSIZIONI_FATTURARO_INCARICHIGrid = GetProperty( getObj('POSIZIONI_FATTURARO_INCARICHIGrid') , 'numrow');
	
	
		
	
    if(  Number( NRPOSIZIONI_FATTURARO_INCARICHIGrid ) >= 0 )
    {
		
	 for( i = 0 ; i <= NRPOSIZIONI_FATTURARO_INCARICHIGrid ; i++ )
	 {
		try
		{
      	    if( getObjValue( 'RPOSIZIONI_FATTURARO_INCARICHIGrid_' + i + '_TipologiaIncarico' ) == '' )
            {
      			 err = 1;
      			 TxtErr( 'RPOSIZIONI_FATTURARO_INCARICHIGrid_' + i + '_TipologiaIncarico' );
      		}
			else
			 {
      			 
      			 TxtOK( 'RPOSIZIONI_FATTURARO_INCARICHIGrid_' + i + '_TipologiaIncarico' );
      		}
      	   
      	    if( getObjValue( 'RPOSIZIONI_FATTURARO_INCARICHIGrid_' + i + '_Importo' ) == '' )
            {
      			 err = 1;
      			 TxtErr( 'RPOSIZIONI_FATTURARO_INCARICHIGrid_' + i + '_Importo' );
      		}
			else
			 {
      			 
      			 TxtOK( 'RPOSIZIONI_FATTURARO_INCARICHIGrid_' + i + '_Importo' );
      		}
      	   
      	   
		
	   }catch(e)	  {	  }
    }
    }
	
	*/
	var numrrowdoc = Number(GetProperty( getObj('DOCUMENTAZIONEGrid') , 'numrow') );
		if(   numrrowdoc  >= 0 )
        {
			 
			 var t=0;
			 for (t=0;t<numrrowdoc+1;t++)
			 {
				//if(getObj('RDOCUMENTAZIONEGrid_' + t + '_Obbligatorio').value == '1')
				//{
					if ( getObj('RDOCUMENTAZIONEGrid_' + t + '_Allegato').value == '')
					{
						err=1;
						TxtErr( 'RDOCUMENTAZIONEGrid_' + t + '_Allegato' );
					}
					else
					{
						TxtOK( 'RDOCUMENTAZIONEGrid_' + t + '_Allegato' );
					}
					
				//}
				
			 
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


function PREVIDENZA_AFTER_COMMAND ()
{
	//se non ci sono righe Previdenza setto a no la scelta della previdenza
	var NRPREVIDENZAGrid = GetProperty( getObj('PREVIDENZAGrid') , 'numrow');
	//alert(NRPREVIDENZAGrid)	;
	
  if(  Number( NRPREVIDENZAGrid ) == -1 ){
    document.FORMDOCUMENT.cassaprevidenza[0].checked=true;
		document.FORMDOCUMENT.cassaprevidenza[1].checked=false;
  }
  
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
	/*var val
	try{ val=getObj('NaGi').value; }catch(e){val=GetProperty(getObj('val_NaGi'), 'value');}
	
	if ( val == '845325' )*/
	if ( getObj('TitoloProfessionale').value == '1' )
	{
		document.getElementById('studioassociato').style.display = 'none';
	}
	else
	{
		document.getElementById('studioassociato').style.display = '';
	}
}
function ControlloTitoloProfessionale()
{
	
	var val
	try{ val=getObj('NaGi').value; }catch(e){val=GetProperty(getObj('val_NaGi'), 'value');}
	
	if ( val == '845325' )
	{
		if ( getObj('TitoloProfessionale').value != '1' )
		{
			getObj('TitoloProfessionale').value='';			
			DMessageBox( '../' , 'Essendo operatore economico registrato come "Persona Fisica" puo iscriversi unicamente come "Libero Professionista Singolo" ' , 'Attenzione' , 1 , 400 , 300 );
			return -1;
		}
	}
vis_studio_associato();
toolbar_posizioni_elenco_prof();
}
function toolbar_posizioni_elenco_prof()
{	
	var val
	try{ val=getObj('TitoloProfessionale').value; }catch(e){val=GetProperty(getObj('val_TitoloProfessionale'), 'value');}
	try
	{	
		if ( val == '1' )
		{
			document.getElementById('TOOLBAR_POSIZIONI_ELENCO_PROF_ADDNEW').style.display = "none";
		}
		else
		{
			document.getElementById('TOOLBAR_POSIZIONI_ELENCO_PROF_ADDNEW').style.display = "";
		}
	}catch(e){}
}   
function Iscrizione_dipendentesino()
{
	if( document.getElementsByName('dipendentesino').length  > 1 )
	{
		if( document.getElementsByName('dipendentesino')[0].checked == true )
		{
			document.getElementById('dipendentesi').style.display = 'none';
		}
		else
		{
			document.getElementById('dipendentesi').style.display = 'block';
		}
	}
	
	if( document.getElementsByName('dipendentesino').length == 1 )
	{
		if( getObj('dipendentesino').value == 'no' )
		{
			document.getElementById('dipendentesi').style.display = 'none';
		}
		else
		{
			document.getElementById('dipendentesi').style.display = 'block';
		}
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

function OnChange_AttivitaProfessionaleIstanza()
{
	
	ExecDocProcess( 'ON_CHANGE,ATTIVITAPROFESSIONALEISTANZA,,NO_MSG');
	
}