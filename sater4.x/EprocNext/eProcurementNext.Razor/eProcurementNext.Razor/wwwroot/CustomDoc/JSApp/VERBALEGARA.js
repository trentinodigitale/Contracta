function ChangeMode( elem ){


  //recupero riga corrente
  var strNome=elem.name;
  
  var nPos = strNome.indexOf('R');
  
  var nPos1 = strNome.indexOf('_Edit');
  
  var Row = strNome.substring(nPos+1,nPos1-nPos);
  
  //allineo il valore dei campi nascosti
  CloseRTE();
  
  //recupero valore della descrizioneestesa
  var strValue ;
  if ( elem.checked ) 
    strValue = getObjGrid('R' + Row + '_DescrizioneEstesa_V').innerHTML;
  else
    strValue = getObjGrid('R' + Row + '_DescrizioneEstesa').value;

  
  //recupero versione diversa da quella corrente del controllo
  /*
  var strURL ;
  //strURL = '../GetFilteredField.asp?STYLE=RTE&FORMAT=H&FIELD=DescrizioneEstesa&ROW=' + Row + '&VALUE=' + escape(strValue);
  strURL = '../GetFilteredField.asp?STYLE=RTE&FORMAT=H&FIELD=DescrizioneEstesa&ROW=' + Row + '&VALUE=' ;

  
  if ( elem.checked ) {
    
    //recupero versione editabile del controllo
    strURL = strURL + '&EDITABLE=yes';
  }else{
    
    //recupero versione NON editabile del controllo
    strURL = strURL + '&EDITABLE=no';
  }

  //recupero struttura attributo textarea
  var strHTML = SUB_AJAX(strURL);
  //alert(strHTML);
  */
  
  if ( elem.checked ) {
    //costruisco textarea editabile completa
    strHTML = '<textarea rows=6 id="' + 'R' + Row + '_DescrizioneEstesa" name="' + 'R' + Row + '_DescrizioneEstesa" class="RTE" onkeypress="TA_MaxValue(this,200);" onblur="TA_MaxValue(this,200);" >' ; 
    strHTML= strHTML + strValue + "</textarea>" ;
    
  }else{
    //costruisco label non editabile e textarea nascosta 
    strHTML = '<label id="' + 'R' + Row + '_DescrizioneEstesa_V" name=' + 'R' + Row + '_DescrizioneEstesa_V" >' + strValue + '</label>' ;
    strHTML = strHTML + '<textarea style="display:none;" width="100%" rows=6 id="' + 'R' + Row + '_DescrizioneEstesa" name="' + 'R' + Row + '_DescrizioneEstesa" >' ; 
    strHTML= strHTML + strValue + "</textarea>" ;
  }
  
  getObj('DETTAGLIGrid_r' +  Row + '_c4').innerHTML = strHTML;
  
  //setto il valore nell'attributo
  //SetTAValue( 'R' + Row + '_DescrizioneEstesa', strValue );
  
  //sostituisco la nuova versione a quella corrente
  
  //se la nuova versione è editabile applico la versione RTE al controllo editabile
  if ( elem.checked ) {
  
  try{
      
      $('#R' + Row + '_DescrizioneEstesa').rte("", "../images/toolbar/");
      
  }catch(e){};
  
  }
  
}


function afterProcess( param )
{
    if ( param == 'CHIUDI_LAVORAZIONE' )
    {
        var IdConvenzione = getObjValue( 'LinkedDoc' );
        
        //-- aggiorna il documento chiamante
        ExecDocCommandInMem( 'TESTATA#RELOAD', IdConvenzione, 'DOCUMENT');     
        ExecDocCommandInMem( 'TESTATA#RELOAD', IdConvenzione, 'TESTATA');     
        
        //-- chiude il documento corrente
        breadCrumbPop();    
    }
	
	if ( ( param == 'ARCHIVIA' || param == 'ANNULLA' ) && getObjValue('JumpCheck') == 'CONTRATTO_GARA' )
    {
        var IdContratto = getObjValue( 'LinkedDoc' );
        
        //-- aggiorna il documento chiamante
        ExecDocCommandInMem( 'DOCUMENTAZIONE#RELOAD', IdContratto, 'CONTRATTO_GARA');     
        //ExecDocCommandInMem( 'CRONOLOGIA#RELOAD', IdContratto, 'CONTRATTO_GARA');   
        
        //-- chiude il documento corrente
        breadCrumbPop();    
    }

}

function ChiudiLAvorazione( param )
{	
	
	
	if (getObjValue('SIGN_ATTACH') == ""  )
	{
		DMessageBox( '../' , 'Prima di effettuare "Chiudi Lavorazione" allegare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
		return;
	}
	if (getObjValue('SIGN_ATTACH') != "" )
	{
		
		ExecDocProcess( 'CHIUDI_LAVORAZIONE,VERBALEGARA');
		
	}
	
}


function GeneraPDF ()
{
	var Stato = getObjValue('StatoDoc');
	var JumpCheck = getObjValue('JumpCheck');
    
    if( Stato == '' ) 
    {
        //alert( 'Per effettuare la stampa si richiede prima un salvataggio. Verra\' effettuato in automatico, successivamente effettuare nuovamente il comando di stampa');
		DMessageBox( '../' , 'Compilare il Documento in tutti i suoi campi obbligatori, successivamente effettuare nuovamente il comando genera pdf.' , 'Attenzione' , 1 , 400 , 300 );
        SaveDoc();
        return;
    }
	
	if ( JumpCheck == 'CONTRATTO' ) 
	{
        PrintPdfSign('URL=/report/StampaVerbaleGara.ASP?SIGN=YES&PDF_NAME=CONTRATTO');
    }
    
	if ( JumpCheck == 'CLAUSOLA' ) 
	{
        PrintPdfSign('URL=/report/StampaVerbaleGara.ASP?SIGN=YES&PDF_NAME=CLAUSOLEVESSATORIE&SAVE_ATTACH=YES');
    }
		
}


function TogliFirma () 
{
	DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );
	ExecDocProcess( 'SIGN_ERASE,FirmaDigitale');
	
	
}

function FIRMA_OnLoad()
{
   
	var Stato ='';
	Stato = getObjValue('StatoDoc');
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
	try
	{ 
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
    catch(e){}	

}
window.onload = FIRMA_OnLoad;
