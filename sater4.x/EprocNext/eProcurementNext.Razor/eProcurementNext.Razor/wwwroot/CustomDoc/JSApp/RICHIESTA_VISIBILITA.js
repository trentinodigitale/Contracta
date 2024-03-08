
window.onload = Init_RICHIESTA_VISIBILITA;

function Init_RICHIESTA_VISIBILITA(){
  

  
  
  //inizializzo il genera pdf
  Init_Firma();
  try
	{
		statoFunzionale = getObjValue('StatoFunzionale');
		
		if ( statoFunzionale == 'InLavorazione' )
		{
			getObj('Note').disabled = true;
			getObj('Note').readOnly = true;
			getObj('Note').style.backgroundColor='#ECECEC';
		}
	}
	catch(e)
	{
	}
   
}




function Init_Firma()
{
  
  var StatoFunzionale = '';
  
  StatoFunzionale = getObj('StatoFunzionale').value ;
  
	if ( (getObjValue('SIGN_LOCK') =='0' || getObjValue('SIGN_LOCK') =='')   && StatoFunzionale=='InLavorazione' )
  {
		document.getElementById('generapdf').disabled = false; 
		document.getElementById('generapdf').className ="generapdf";
	}
	else
	{
		document.getElementById('generapdf').disabled = true; 
		document.getElementById('generapdf').className ="generapdfdisabled";
	}	
	
	if ( getObjValue('SIGN_LOCK') != '0'   && StatoFunzionale=='InLavorazione' )
  {
		document.getElementById('editistanza').disabled = false; 
		document.getElementById('editistanza').className ="attachpdf";
	}
	else
	{
		document.getElementById('editistanza').disabled = true; 
		document.getElementById('editistanza').className ="attachpdfdisabled";
	} 
	
	if ( getObjValue('SIGN_ATTACH') == ''  &&  StatoFunzionale=='InLavorazione' &&  getObjValue('SIGN_LOCK') != '0'  )
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
  
  //controllo che ho compilato motivazioni e  DataTermineVisibilita
  
  var value2=controlli('');
	if (value2 == -1)
		return;  
  
  ToPrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=Richiesta Visibilita Temporanea&lo=print&NO_SECTION_PRINT=FIRMA,APPROVAL');
  
}


function TogliFirma () 
{
	DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );	
	ExecDocProcess( 'SIGN_ERASE,RICHIESTA_VISIBILITA');  
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



function controlli (param)
{
	
  var err=0;
  
  //-- controllo i dati della richiesta
  if ( getObj('DataTermineVisibilita').value == ''  )
	{
		
		TxtErr('DataTermineVisibilita');
		err=1;
    
	}
	//alert(getObj('Body').value);
	if ( getObj('Body').value == '' )
	{
		TxtErr('Body');
    err=1;
	}
	

	if  ( err == 1){
    DMessageBox( '../' , 'Per proseguire e\' necessaria la compilazione di tutti i campi evidenziati' , 'Attenzione' , 1 , 400 , 300 );
    return -1;
  }
	 
   
}
