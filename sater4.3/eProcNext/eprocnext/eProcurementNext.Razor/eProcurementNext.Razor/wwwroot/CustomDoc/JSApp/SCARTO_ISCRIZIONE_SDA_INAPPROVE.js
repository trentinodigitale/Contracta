window.onload = onloadFirma;

function MySaveDoc()
{
	SaveDoc();
}

function onloadFirma()
{
	try
	{
		var statoFunzionale = '';
		Stato = getObj('StatoDoc').value;
		
		try
		{
			statoFunzionale = getObjValue('StatoFunzionale');

			if ( statoFunzionale == '' || statoFunzionale == undefined )
			{
				statoFunzionale = getObjValue('val_StatoFunzionale');
			}
		}
		catch(e)
		{
			statoFunzionale = getObjValue('val_StatoFunzionale');
		}
		
		if ( statoFunzionale != 'Valutato' )
		{
			document.getElementById('generapdf').disabled = true; 
			document.getElementById('generapdf').className ="generapdfdisabled";
			document.getElementById('editistanza').disabled = true; 
			document.getElementById('editistanza').className ="attachpdfdisabled";
			document.getElementById('attachpdf').disabled = true; 
			document.getElementById('attachpdf').className ="editistanzadisabled";
		}
		else
		{
			
			if ((getObjValue('SIGN_LOCK') =='0' || getObjValue('SIGN_LOCK') =='') ) // && statoFunzionale != 'Valutato' )
			{
				document.getElementById('generapdf').disabled = false; 
				document.getElementById('generapdf').className ="generapdf";
			}
			else
			{
				document.getElementById('generapdf').disabled = true; 
				document.getElementById('generapdf').className ="generapdfdisabled";
			}	
			if ( getObjValue('SIGN_LOCK') != '0' ) // && statoFunzionale != 'Valutato' )
			{
				document.getElementById('editistanza').disabled = false; 
				document.getElementById('editistanza').className ="attachpdf";
			}
			else
			{
				document.getElementById('editistanza').disabled = true; 
				document.getElementById('editistanza').className ="attachpdfdisabled";
			}
			if (getObjValue('SIGN_ATTACH') == '' && getObjValue('SIGN_LOCK') != '0' ) //&& statoFunzionale != 'Valutato' )
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
	}
	catch(e)
	{
	}		
	
	/* Se l'utente collegato non coincide con il responsabile del procedimento disabilito i pulsanti di firma */
	try
	{
		var responsabileProcedimento;
		
		responsabileProcedimento = getObj('ResponsabileProcedimento').value;
		
		if ( idpfuUtenteCollegato != responsabileProcedimento )
		{
			document.getElementById('generapdf').disabled = true; 
			document.getElementById('generapdf').className ="generapdfdisabled";
			
			document.getElementById('editistanza').disabled = true; 
			document.getElementById('editistanza').className ="attachpdfdisabled";
			
			document.getElementById('attachpdf').disabled = true; 
			document.getElementById('attachpdf').className ="editistanzadisabled";			
		}
	}
	catch(e){}
	
}

function GeneraPDF()
{
	var statoDoc;
	statoDoc = getObj('DOCUMENT_READONLY').value;

    if( statoDoc == '' ) 
    {
		DMessageBox( '../' , 'Compilare il documento in tutti i suoi campi obbligatori, successivamente effettuare nuovamente il comando genera pdf.' , 'Attenzione' , 1 , 400 , 300 );
        SaveDoc();
        return;
    }

    scroll(0,0);  

	//ToPrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=Conferma_Iscrizione&lo=print&NO_SECTION_PRINT=FIRMA&PROCESS=DOCUMENT%40%40%40PROTOCOLLA');
	PrintPdfSign('PROCESS=DOCUMENT%40%40%40PROTOCOLLA&PDF_NAME=Scarto_iscrizione&URL=/report/SCARTO_ISCRIZIONE_SDA_INAPPROVE.asp?SIGN=YES');
}

function TogliFirma() 
{
	DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
	ExecDocProcess( 'SIGN_ERASE,FirmaDigitale');
}

function RefreshContent()
{
	RefreshDocument('');
}
