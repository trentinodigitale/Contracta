
window.onload = Init;


function Init()
{
	

 //inizializzo il genera pdf
  DOC_SignInitButton();
  
  try {
		if (getObjValue('RichiestaFirma') == 'no') {
	
				document.getElementById('FIRMA').style.display = "none";
			}
	} catch (e) {                      }
  
}


function GeneraPDF ()
{

  //controllo che ho inserito le motivazioni che sono obbligatorie
  
  if( trim(getObjValue( 'Body' )) == '' )
	{
	  
	  TxtErr( 'Body' );  	  
	  DMessageBox( '../' , 'Inserire le motivazioni per il ritiro della Risposta Concorso' , 'Attenzione' , 1 , 400 , 300 );
	  return -1;
	  
	}
	
  
  //ToPrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=Annulla Ordinativo&lo=print&NO_SECTION_PRINT=FIRMA,APPROVAL');  
  scroll(0,0);  	
  PrintPdfSign('TABLE_SIGN=CTL_DOC&lo=print&PROCESS=&PDF_NAME=Ritira Risposta Concorso&URL=/report/prn_Ritira_Risposta_Concorso.asp?SIGN=YES');
  
}



function trim(str)
{
    return str.replace(/^\s+|\s+$/g,"");
}


function LocalPrintPdf( param )
{
    
  
    param = '/report/prn_' + getObj('TYPEDOC').value + '.ASP?'  
    
    PrintPdf( param );

}