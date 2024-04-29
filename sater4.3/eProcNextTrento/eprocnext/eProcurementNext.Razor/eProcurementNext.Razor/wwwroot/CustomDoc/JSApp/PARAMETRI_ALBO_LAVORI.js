
function ALLEGA_PATTO_OnLoad()
{
   
	var Stato ='';
	Stato = getObjValue('StatoDoc');
	if (Stato != 'Sent' )
    {
		document.getElementById('attachpdf').disabled = false; 
		document.getElementById('attachpdf').className ="generapdf";
	}
	else
	{
		document.getElementById('attachpdf').disabled = true; 
		document.getElementById('attachpdf').className ="generapdfdisabled";
	}
		
	Controllo_Sospensione();
	
}
window.onload = ALLEGA_PATTO_OnLoad;

function AllegaPDF ()
{
	var StatoDoc ='';
	StatoDoc = getObjValue('StatoDoc');
	
	 if( StatoDoc  == '' ) 
    {
        
		DMessageBox( '../' , 'Prima di caricare il file il documento deve essere salvato, successivamente effettuare nuovamente il comando allega pdf.' , 'Attenzione' , 1 , 400 , 300 );
        SaveDoc();
        return;
    }
    scroll(0,0);
	ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=ctl_doc&amp;IDDOC=' + getObjValue('IDDOC') + '&amp;OPERATION=INSERTSIGN&amp;IDENTITY=Id&amp;AREA=&amp;SAVE_HASH=YES&amp;DOMAIN=FileExtention&amp;FORMAT=#AllegaFirma#600,400');
}

function Controllo_Sospensione()
{
	/*
	var b='';
	//se non è checked disabilito i campi relativi alla sospensione
	try{ b=getObj('RABILITAZIONI_MODEL_Attiva_Sospensione_V').checked;}catch( e ){b=getObj('RABILITAZIONI_MODEL_Attiva_Sospensione').checked;};
	if ( b == false )
	{
		
		try{getObj( 'RABILITAZIONI_MODEL_NumMesiScadenza').value='';} catch( e ){};
		$( "#cap_NumMesiScadenza" ).parents("table:first").css({"display":"none"});
		try{getObj( 'RABILITAZIONI_MODEL_Sollecito').value='';} catch( e ){};
		$( "#cap_Sollecito" ).parents("table:first").css({"display":"none"});
		try{getObj( 'RABILITAZIONI_MODEL_NumPeriodiFreqPrimaria').value='';} catch( e ){};
		$( "#cap_NumPeriodiFreqPrimaria" ).parents("table:first").css({"display":"none"});
		try{getObj( 'RABILITAZIONI_MODEL_FreqPrimaria').value='';} catch( e ){};
		$( "#cap_FreqPrimaria" ).parents("table:first").css({"display":"none"});
		try{getObj( 'RABILITAZIONI_MODEL_FreqSecondaria').value='';} catch( e ){};
		$( "#cap_FreqSecondaria" ).parents("table:first").css({"display":"none"});
		
		
		
	}
	//se è checked abilito i campi relativi alla sospensione
	if ( b == true )
	{
	
		$( "#cap_NumMesiScadenza" ).parents("table:first").css({"display":""});
		$( "#cap_Sollecito" ).parents("table:first").css({"display":""});
		$( "#cap_NumPeriodiFreqPrimaria" ).parents("table:first").css({"display":""});
		$( "#cap_FreqPrimaria" ).parents("table:first").css({"display":""});
		$( "#cap_FreqSecondaria" ).parents("table:first").css({"display":""});
		
	}
	*/
}
