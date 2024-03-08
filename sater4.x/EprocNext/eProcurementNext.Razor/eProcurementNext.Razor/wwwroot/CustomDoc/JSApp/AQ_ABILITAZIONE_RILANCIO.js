window.onload = DISPLAY_FIRMA_OnLoad;

function DISPLAY_FIRMA_OnLoad()
{
	var Stato ='';


		Stato = getObj('StatoDoc').value;
	
		if ((getObjValue('SIGN_LOCK') =='0' || getObjValue('SIGN_LOCK') =='')   && (Stato=='Saved' || Stato==""))
		{
			document.getElementById('generapdf').disabled = false; 
			document.getElementById('generapdf').className ="generapdf";
		}
		else
		{
			document.getElementById('generapdf').disabled = true; 
			document.getElementById('generapdf').className ="generapdfdisabled";
		}	
		if ( getObjValue('SIGN_LOCK') != '0'   && (Stato=='Saved') )
		{
			document.getElementById('editistanza').disabled = false; 
			document.getElementById('editistanza').className ="attachpdf";
		}
		else
		{
			document.getElementById('editistanza').disabled = true; 
			document.getElementById('editistanza').className ="attachpdfdisabled";
		} 
		if (getObjValue('SIGN_ATTACH') ==''  &&  (Stato=='Saved') && getObjValue('SIGN_LOCK') != '0'   )
		{
			document.getElementById('attachpdf').disabled = false; 
			document.getElementById('attachpdf').className ="editistanza";
		}
		else
		{
			document.getElementById('attachpdf').disabled = true; 
			document.getElementById('attachpdf').className ="editistanzadisabled";
		}
		
}



function GeneraPDF()
{

	
    scroll(0,0);
	ExecDocProcess('FITTIZIO:-1:CHECKOBBLIG,DOCUMENT,,NO_MSG');	
	
}
function afterProcess(param) 
{
	if (param == 'FITTIZIO:-1:CHECKOBBLIG') 
	{
		PrintPdfSign('TABLE_SIGN=CTL_DOC&lo=print&PROCESS=&PDF_NAME=Abilitazione_rilancio&URL=/report/prn_AQ_ABILITAZIONE_RILANCIO.asp?SIGN=YES');
	}
}

function TogliFirma () 
{
	DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
	ExecDocProcess( 'SIGN_ERASE,FirmaDigitale,,NO_MSG');
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

function RefreshContent()
{
	RefreshDocument('');	
}


function trim(str)
{
   return str.replace(/^\s+|\s+$/g,"");
}
