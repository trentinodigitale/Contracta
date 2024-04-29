//Variabile di appoggio per contenere l'idpfu dell'utente collegato e gestire l'applicazione sia se accessibile sia no
var tmp_idpfuUtenteCollegato;

window.onload = Init_ANNULLA_ORDINATIVO;


function Init_ANNULLA_ORDINATIVO(){
  
  
  //inizializzo il genera pdf
  Init_Firma_ODC();
  
}




function Init_Firma_ODC()
{
  
  var StatoFunzionale ='';
  
  StatoFunzionale = getObjValue('StatoFunzionale');
  
  //if ( idpfuUtenteCollegato == undefined )
  //	var idpfuUtenteCollegato = getObjValue('IdpfuInCharge');

	if ( typeof idpfuUtenteCollegato === 'undefined' )
		tmp_idpfuUtenteCollegato = getObjValue('IdpfuInCharge');
	else
		tmp_idpfuUtenteCollegato = 	 idpfuUtenteCollegato;
	
    	
  	if ( (getObjValue('SIGN_LOCK') =='0' || getObjValue('SIGN_LOCK') =='')   && StatoFunzionale=='InLavorazione' &&  getObj('IdpfuInCharge').value == tmp_idpfuUtenteCollegato )
    {
  		document.getElementById('generapdf').disabled = false; 
  		document.getElementById('generapdf').className ="generapdf";
  	}
  	else
  	{
  		document.getElementById('generapdf').disabled = true; 
  		document.getElementById('generapdf').className ="generapdfdisabled";
  	}	
  	
  	if ( getObjValue('SIGN_LOCK') != '0'   && StatoFunzionale=='InLavorazione' &&  getObj('IdpfuInCharge').value == tmp_idpfuUtenteCollegato )
    {
  		document.getElementById('editistanza').disabled = false; 
  		document.getElementById('editistanza').className ="attachpdf";
  	}
  	else
  	{
  		document.getElementById('editistanza').disabled = true; 
  		document.getElementById('editistanza').className ="attachpdfdisabled";
  	} 
  	
  	if ( getObjValue('SIGN_ATTACH') == ''  &&  StatoFunzionale=='InLavorazione' &&  getObjValue('SIGN_LOCK') != '0' &&  getObj('IdpfuInCharge').value == tmp_idpfuUtenteCollegato )
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



function GeneraPDF ()
{

  //controllo che ho inserito le motivazioni che sono obbligatorie
  
  if( trim(getObjValue( 'Note' )) == '' )
	{
	  
	  TxtErr( 'Note' );  
	  DMessageBox( '../' , 'Inserire le motivazioni di annulla ordinativo' , 'Attenzione' , 1 , 400 , 300 );
		return;
	}
	
  
  //ToPrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=Annulla Ordinativo&lo=print&NO_SECTION_PRINT=FIRMA,APPROVAL');  
  scroll(0,0);  	
  PrintPdfSign('TABLE_SIGN=CTL_DOC&lo=print&PROCESS=&PDF_NAME=Annulla Ordinativo&URL=/report/prn_ANNULLA_ORDINATIVO.asp?SIGN=YES');
  
}


function TogliFirma () 
{
	DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );	
	ExecDocProcess( 'SIGN_ERASE,ANNULLA_ORDINATIVO');  
}

 function TxtErr( field )
{
    
		try{ getObj(field ).style.backgroundColor='#FFBE7D'; }catch(e){}; // F80

		try{ getObj(field + '_V' ).style.backgroundColor='#FFBE7D'; }catch(e){}; //FFC


		try{ getObj(field + '_edit' ).style.backgroundColor='#FFBE7D'; }catch(e){};
		try{ getObj(field + '_edit' ).style.backgroundColor='#FFBE7D'; }catch(e){};
	
		try{ getObj( field  + '_edit_new' ).style.borderColor='#FFBE7D'; }catch(e){};
		try{ getObj(field + '_edit_new' ).style.backgroundColor='#FFBE7D'; }catch(e){};
 		if ( getObj(field  ).type == 'checkbox' )
 		{
   		try{ getObj(field  ).offsetParent.style.backgroundColor='#FFBE7D'; }catch(e){};
    		
   	}
   
   
} 

function trim(str){
    return str.replace(/^\s+|\s+$/g,"");
}