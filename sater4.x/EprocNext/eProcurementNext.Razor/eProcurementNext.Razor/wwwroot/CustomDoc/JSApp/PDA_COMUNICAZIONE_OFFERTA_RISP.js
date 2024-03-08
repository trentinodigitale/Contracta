
function OpenCollegati( )
{
  
	var Fascicolo = '';
	try	{ 	Fascicolo = getObjValue( 'Fascicolo')	}catch( e ) {};

	
	var URL = '../dashboard/mainView.asp?A=A&FOLDER_GROUP=LINKED_ISCRIZIONE_ALBO&FilterHide= Fascicolo = \'' + Fascicolo + '\' ';
	
	
	parent.parent.parent.DocumentiCollegati( URL );

}
function GeneraPDF()
{		
	ExecDocProcess( 'CONTROLLO_PRODOTTI,PDA_COMUNICAZIONE_OFFERTA_RISP,,NO_MSG');
}


function afterProcess( param )
{

	var value='';
	if ( param == 'CONTROLLO_PRODOTTI' )
    {
		value=controlloEsitoRiga('');
	
			if (value == -1)
			{
				alert( CNV( '../','Sono presenti righe con anomalie.'));
				return ;
			} 	
			
		PrintPdf('/report/prn_PDA_COMUNICAZIONE_OFFERTA_RISP.asp?BUSTA=BUSTA_ECONOMICA%26&PAGEORIENTATION=landscape&TO_SIGN=YES&TABLE_SIGN=CTL_DOC&IDENTITY_SIGN=id&PDF_NAME=Offerta_Migliorativa&AREA_SIGN=');
	return;	
	}
}
function controlloEsitoRiga()
{
	var numeroRighe = GetProperty( getObj('OFFERTAGrid') , 'numrow');
	for( i = 0 ; i <= numeroRighe ; i++ )
	 {
		try
		{
			if ( getObj('ROFFERTAGrid_' + i + '_EsitoRiga').value.indexOf('State_ERR.gif') > 0 )
			{
				return -1;
			}
		
		}catch(e)	  {	  }
	}

}
function TogliFirma () 
{
	DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );	
	ExecDocProcess( 'SIGN_ERASE,FirmaDigitale');  
}

window.onload = FIRMA_OnLoad;


function FIRMA_OnLoad()
{
   
	var Stato ='';
	Stato = getObjValue('StatoFunzionale');
	
	
	 try
	 {
		if ((getObjValue('SIGN_LOCK') =='0' || getObjValue('SIGN_LOCK') =='')   && (Stato!='Inviato' ) )
		{
			document.getElementById('generapdf').disabled = false; 
			document.getElementById('generapdf').className ="generapdf";
		}
		else
		{
			document.getElementById('generapdf').disabled = true; 
			document.getElementById('generapdf').className ="generapdfdisabled";
		}
		
		if ( getObjValue('SIGN_LOCK') != '0'   && (Stato!='Inviato' ) )
		{
			document.getElementById('editistanza').disabled = false; 
			document.getElementById('editistanza').className ="attachpdf";
		}
		else
	   {
			document.getElementById('editistanza').disabled = true; 
			document.getElementById('editistanza').className ="attachpdfdisabled";
	   }
		
		
		if ( getObjValue('SIGN_ATTACH') == ''  &&  (Stato!='Inviato') && getObjValue('SIGN_LOCK') != '0'   )
		{
			document.getElementById('attachpdf').disabled = false; 
			document.getElementById('attachpdf').className ="editistanza";
		}
		else
	   {
			document.getElementById('attachpdf').disabled = true; 
			document.getElementById('attachpdf').className ="editistanzadisabled";
	   }
		
		
	  }catch( e ) {}
	  
	  try{ ShowCol( 'OFFERTA' , 'FNZ_DEL' , 'none' ); } catch( e ) {}
	  
	//se documento non editabile non invoca la funzione LOAD_DominiCriteri
	try
	{
		if (  getObjValue('DOCUMENT_READONLY') == '0' ) 
		{
			LOAD_DominiCriteri();
		}
	}
	catch(e){}
	
}



function LOAD_DominiCriteri()
{
	
	var i;
	var r;
	var nA
	var type
   //RECUPERO OGGETTO JSON
   try{ var LstAttrib_DOMINI_CRITERI=JSON.parse( getObjValue( 'LstAttrib_DOMINI_CRITERI' ) );}catch(e){}
   
   //RECUPERO NUMERO ATTRIBUTI
   try{  nA = LstAttrib_DOMINI_CRITERI.ATTRIBUTI.length;}catch(e){nA=0;}
   
   //CONTROLLA SE CI SONO DOMINI NEI CRITERI TECNICI
   if ( nA > 0 )
   {
		  //CICLA SU TUTTE LE RIGHE DI PRODOTTI	  
		  for (i = 0; i < OFFERTAGrid_EndRow + 1; i++) 
		  {
			
			 numeroLotto=getObjValue('ROFFERTAGrid_' + i + '_NumeroLotto');
			 bFound = false;
			 
			 //VERIFICA SE PER QUEL LOTTO ESISTE IL CRITERIO SPECIALIZZATO
			 for ( r = 0 ; r <  nA ;  r++ )
		     {
				 if ( LstAttrib_DOMINI_CRITERI.ATTRIBUTI[r].Contesto == numeroLotto )
				 {
					 bFound = true;
				 }				
			 }
			 
			 //CICLA NUOVAMENTE SUI CRITERI PER COSTRUIRE IL DOMINIO
			 for ( r = 0 ; r <  nA ;  r++ )
		     {
				 
				 Contesto =  LstAttrib_DOMINI_CRITERI.ATTRIBUTI[r].Contesto;
				 
				 
				 //caso di  criterio non specializzato per numeroLotto
				 if ( bFound == false && Contesto == 'B' )
				 {
					Attributo =  LstAttrib_DOMINI_CRITERI.ATTRIBUTI[r].Attributo;
					try{ type = getObj( 'R' + i + '_' + Attributo ).type;}catch(e){type='';}
					//VERIFICO SE ATTRIBUTO ESISTE e NON SIA READONLY
					//if ( getObj( 'R' + i + '_' + Attributo )  && ( getObj( 'R' + i + '_' + Attributo ).type == 'select-one'  || getObj( 'R' + i + '_' + Attributo ).type == 'text' ) )
					if ( getObj( 'ROFFERTAGrid_' + i + '_' + Attributo )  && ( type == 'select-one'  || type == 'text' ) )
					{
						Valori =  LstAttrib_DOMINI_CRITERI.ATTRIBUTI[r].Valori;
						CRITERIO_Domain (getObj( 'ROFFERTAGrid_' + i + '_' + Attributo ),Valori);	
					}
						
				 }
				 
				 if ( bFound == true && Contesto ==  numeroLotto)
				 {
					Attributo =  LstAttrib_DOMINI_CRITERI.ATTRIBUTI[r].Attributo;
					try{ type = getObj( 'R' + i + '_' + Attributo ).type;}catch(e){type='';}
					//VERIFICO SE ATTRIBUTO ESISTE e NON SIA READONLY
					if ( getObj( 'ROFFERTAGrid_' + i + '_' + Attributo )  && ( type == 'select-one'  || type == 'text' ) )
					{
						Valori =  LstAttrib_DOMINI_CRITERI.ATTRIBUTI[r].Valori;	   
						CRITERIO_Domain (getObj( 'ROFFERTAGrid_' + i + '_' + Attributo ),Valori);	
					}									
				 }
			  }	  
		  		  
		    } 
       }
 }  

