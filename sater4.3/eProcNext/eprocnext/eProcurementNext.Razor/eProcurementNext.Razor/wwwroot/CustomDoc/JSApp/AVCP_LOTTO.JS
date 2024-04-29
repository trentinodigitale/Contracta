
function sostituisce_chiudi()
{
	   try
	   {
		   var onc = $(".Caption_Exit").attr("onclick");  
		   var elemHTML = $(".Caption_Exit").parent().html();  
		   var finalElement = elemHTML.replace(onc, "mychiudi();");  
		   $(".Caption_Exit").parent().html(finalElement);  
		}catch(e){}	
}
 
function mychiudi()
{
	
	if ( getObj('StatoFunzionale').value  == 'InLavorazione'  )
	{
		if( confirm(CNV( '../','Eventuali modifiche fatte al documento andranno perse. Sei sicuro di voler terminare?')) ) 
		{
			
			RemoveMessageFromMem();	
			self.close();
		}	  
	}
	else
	{
		RemoveMessageFromMem();	
		self.close();
	}
}

function PARTECIPANTI_OnLoad()
{
	//PARTECIPANTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=DOCUMENT_AVCP_LOTTO_PARTECIPANTI_TOOLBAR&MODGriglia=DOCUMENT_AVCP_GARA_PARTECIPANTI&Table=DASHBOARD_VIEW_AVCP_ELENCO_PARTECIPANTI&JSCRIPT=AVCP_LOTTO&IDENTITY=idheader&DOCUMENT=AVCP_LOTTO&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=0,100*,0&numRowForPag=15&Sort=Aggiudicatario&ActiveSel=1&SortOrder=desc&Exit=no&ShowExit=0&FilterHide=LinkedDoc =' + getObj('Versione').value ;	

}


function Importo ( obj )
{
	
	var valore;
	var totale;
	totale=0
	valore=0
	try{
     var i = 0;
	 var numRow = GetProperty( getObj('IMPORTIGrid') , 'numrow');
	 
		for( i=0; i <= numRow ; i++ )
			{
			
				//valore=getObj('R' + i + '_Importo_V').value;
				valore=getObj('R' + i + '_Importo').value;
				valore=valore.replace(",",".");
				valore=isNaN(parseFloat(valore)) ? 0 : parseFloat(valore);				
				
				//alert(valore);
				
				totale+=valore;
				
			}		
		}catch(e){}	
	SetNumericValue('ImportoSommeLiquidate',totale);
	
}


/*function onchange()
{
 try{
     var i = 0;
		for( i=0; i < IMPORTIGrid_EndRow + 1 ; i++ )
			{
			
				getObj('RIMPORTIGrid_' + i + '_DataInizio').onchange=Data_Inizio;
				getObj('RIMPORTIGrid_' + i + '_DataFine').onchange=Data_Fine;
				
			}
			
		
	}catch(e){}


}
function Data_Inizio ()
{
	alert ('MANCA LA FUNZIONE');
}


function Data_Fine ()
{
	alert ('MANCA LA FUNZIONE');
}


window.onload = onchange;*/
window.onload=view_differenze;
function view_differenze()
{
	
	try{ShowEvidenza( 'Body' , '1px solid red' );}catch(e){}
	sostituisce_chiudi();
}

function IMPORTI_AFTER_COMMAND( p )
{    
	Importo('');
}



function RefreshContent()
{
    
	if ( getObj('StatoFunzionale').value  != 'InLavorazione' )
	{
		parent.parent.RefreshDocument('');   
	}
	RefreshDocument('');      
}

function Cancella_Operatore (grid , r , c)
{
var idRow;
var param;
	
	//-- recupero il codice della riga passata
	idRow = GetIdRow( grid , r , 'self' );
	
	//if (  parent.parent.getObj('StatoFunzionale').value  == 'Pubblicato' )
	//{
	
		param = 'DELETE,DOCUMENT_AVCP_OE&CAPTION=Cancellazione Operatore Economico&TABLE=CTL_DOC&KEY=Id&FIELD=Protocollo'	 
		parent.Viewer_Command.location =  'ViewerCommand.asp?IDLISTA=' + idRow +'&PROCESS_PARAM=' + param ;
		
	//}
	/*else
	{
		DMessageBox( '../ctl_library/' , 'Eliminazione non consentita per lo stato del documento' , 'Attenzione' , 1 , 400 , 300 ); 
		return false;		
	}*/

}