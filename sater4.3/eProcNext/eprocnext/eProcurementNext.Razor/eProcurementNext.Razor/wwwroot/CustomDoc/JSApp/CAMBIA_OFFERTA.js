function afterProcess( param )
{

	if ( param == 'CONFERMA' )
	{
		
		ExecDocCommandInMem( 'PDA_VALUTA_LOTTO_TEC#RELOAD', getObjValue( 'idDoc' ) , 'PDA_VALUTA_LOTTO_TEC');
		
	}
	
}

window.onload = loadpage;


function loadpage()
{
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
		  for (i = 0; i < VALORI_PRODOTTIGrid_EndRow + 1; i++) 
		  {
			
			 try{numeroLotto=getObjValue('R' + i + '_NumeroLotto');}catch(e){numeroLotto='';}
			 bFound = false;
			 
			 //VERIFICA SE PER QUEL LOTTO ESISTE IL CRITERIO SPECIALIZZATO
			 for ( r = 0 ; r <  nA && numeroLotto != '' ;  r++ )
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
					if ( getObj( 'R' + i + '_' + Attributo )  && ( type == 'select-one'  || type == 'text' ) )
					{
						Valori =  LstAttrib_DOMINI_CRITERI.ATTRIBUTI[r].Valori;
						CRITERIO_Domain (getObj( 'R' + i + '_' + Attributo ),Valori);	
					}
						
				 }
				 
				 if ( bFound == true && Contesto ==  numeroLotto)
				 {
					Attributo =  LstAttrib_DOMINI_CRITERI.ATTRIBUTI[r].Attributo;
					try{ type = getObj( 'R' + i + '_' + Attributo ).type;}catch(e){type='';}
					//VERIFICO SE ATTRIBUTO ESISTE e NON SIA READONLY
					if ( getObj( 'R' + i + '_' + Attributo )  && ( type == 'select-one'  || type == 'text' ) )
					{
						Valori =  LstAttrib_DOMINI_CRITERI.ATTRIBUTI[r].Valori;	   
						CRITERIO_Domain (getObj( 'R' + i + '_' + Attributo ),Valori);	
					}									
				 }
			  }	  
		  		  
		    } 
       }
 }  
 
