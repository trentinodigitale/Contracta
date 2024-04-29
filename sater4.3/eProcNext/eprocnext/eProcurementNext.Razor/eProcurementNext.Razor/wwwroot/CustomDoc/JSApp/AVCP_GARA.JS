
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
window.onload=view_differenze;


function LOTTI_OnLoad()
{
	    
   //if ( getObj('StatoFunzionale').value == 'InLavorazione'  )
   //if ( getObj('IDDOC').value.substring(0,3) == 'new' )
   //{
		LOTTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=DOCUMENT_AVCP_GARA_LOTTI_TOOLBAR&MODGriglia=DOCUMENT_AVCP_GARA_LOTTI&Table=VIEW_DOCUMENT_AVCP_GARA_LOTTI&JSCRIPT=AVCP_GARA&IDENTITY=idheader&DOCUMENT=AVCP_GARA&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=0,100*,0&numRowForPag=15&Sort=id&ActiveSel=1&SortOrder=desc&Exit=no&ShowExit=0&FilterHide=LinkedDoc =' + getObj('Versione').value +'&ROWCONDITION=ANNULLATO,StatoFunzionale=Annullato~&';	
   //}
  
}
function view_differenze()
{
	try{ShowEvidenza( 'Body' , '1px solid red' );}catch(e){}
	sostituisce_chiudi();
}


function RefreshContent()
{
    if ( getObj('StatoFunzionale').value  != 'InLavorazione' )
	{
		parent.parent.RefreshDocument('');   
	}
	
	RefreshDocument('');      
}



function Cancella_Lotto (grid , r , c)
{
var idRow;
var param;
	
	//-- recupero il codice della riga passata
	idRow = GetIdRow( grid , r , 'self' );	
	
	param = 'DELETE,DOCUMENT_AVCP_LOTTO&CAPTION=Cancellazione Gara Semplice&TABLE=CTL_DOC&KEY=Id&FIELD=Protocollo'	 
	parent.Viewer_Command.location =  'ViewerCommand.asp?IDLISTA=' + idRow +'&PROCESS_PARAM=' + param ;
	
	

}




function Cancella_Lotto (grid , r , c)
{
	var idRow;
	var param;
	
	//-- recupero il codice della riga passata
	idRow = GetIdRow( grid , r , 'self' );
	
	var Statofunzionale = '';
	
	try	{ 	Statofunzionale = getObj( 'R' + r + '_StatoFunzionale').value;	}catch( e ) {};
	
	if ( Statofunzionale == '' || Statofunzionale == undefined )
	{
		try	{ 	Statofunzionale = getObj( 'R' + r + '_StatoFunzionale')[0].value; }catch( e ) {};
	}
	

	if ( Statofunzionale == 'Pubblicato' )
	{
	
		param = 'DELETE,DOCUMENT_AVCP_LOTTO&CAPTION=Cancellazione Gara Semplice&TABLE=CTL_DOC&KEY=Id&FIELD=Protocollo'	 
		parent.Viewer_Command.location =  'ViewerCommand.asp?IDLISTA=' + idRow +'&PROCESS_PARAM=' + param ;
		
	}
	if ( Statofunzionale == 'Annullato' )
	{
		param = 'RIPRISTINO,DOCUMENT_AVCP_LOTTO&CAPTION=Ripristino Gara Semplice&TABLE=CTL_DOC&KEY=Id&FIELD=Protocollo'	 
		parent.Viewer_Command.location =  'ViewerCommand.asp?IDLISTA=' + idRow +'&PROCESS_PARAM=' + param ;
	}

}





