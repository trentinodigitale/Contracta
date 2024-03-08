function MyExecDocProcess(param){	

	ExecDocProcess(param);
}
function MyExecDocProcessValuta(param){	
 
	ExecDocProcess(param);
}

function MySaveDoc(){
 
  SaveDoc();
  
}

function MyToPrint(param){
	
  	//try{ ReplaceSepClasseIscriz(); } catch(e){};
	ToPrint(param);


	/*try { 
		var v = getObj( 'ClasseIscriz' ).value;
	
		//trasformo la forma tecnica
		getObj( 'ClasseIscriz' ).value= ReplaceExtended(v,'###','#');
		v=getObj( 'ClasseIscriz' ).value;
	}catch(e){};*/
	    

}

window.onload = hideclasseiscrizione;

function hideclasseiscrizione()
{

	try
	{
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
	catch(e)
	{
	}
	
	
	/*
	//SE NON SONO PRESENTI CATEGORIE NASCONDO LA SEZIONE
	var numeroRighe0 = GetProperty( getObj('CATEGORIEGrid') , 'numrow');	
	if(  Number( numeroRighe0 ) < 0 )
	{
		document.getElementById('CATEGORIEGrid').style.display = "none";
		document.getElementById('CATEGORIEGrid_Caption').style.display = "none";
		
	}
	
	if( getObj('Richiesta_Info').value == '0')
	{
		ShowCol( 'CATEGORIE' , 'AllegatoRichiesto' , 'none' );
	}
	*/
	
	Filtro_Classi();
	
	
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

	ToPrintPdfSign('TABLE_SIGN=CTL_DOC&PDF_NAME=Conferma_Iscrizione&lo=print&NO_SECTION_PRINT=FIRMA&PROCESS=DOCUMENT%40%40%40PROTOCOLLA');

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




function Filtro_Classi()
{
	
	
	if( getObj('Richiesta_Info').value == '0')
	{
		ShowCol( 'CATEGORIE' , 'AllegatoRichiesto' , 'none' );
	}
	
	//SE NON SONO PRESENTI CATEGORIE NASCONDO LA SEZIONE
	var numeroRighe0 = GetProperty( getObj('CATEGORIEGrid') , 'numrow');	
	if(  Number( numeroRighe0 ) < 0 )
	{
		document.getElementById('CATEGORIEGrid').style.display = "none";
		document.getElementById('CATEGORIEGrid_Caption').style.display = "none";
		return;
	}
	
	
	
	
	var str_Scelta_Classi_Libera = getObj('Scelta_Classi_Libera').value;
	
	//alert(str_Scelta_Classi_Libera);
	
	
	//se la scelta non libera non faccio nulla e nascondo attributo per la selezione
	//delle Categorie_Merceologiche 
	if ( str_Scelta_Classi_Libera == 'no' ) 
	{
		
		try{setVisibility(getObj('CLASSI'), 'none');}catch(e){}
		
		return;
		
	}

		
	//alert(str_ClassiBando);
	
	//per ALBO GESTIONE ME, ALBO FORNITURE E SERVIZI
	if( ( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' ) )		
	{
		
		var str_ClassiBando = getObj('ClassiBando').value;
		//alert(str_ClassiBando);
		
		var str_Classi_Filter = '';
	
		var str_Filter =''
		
		
		if (  str_ClassiBando != '' || ( getObjValue( 'Elenco_Categorie_Merceologiche' ) != ''  && getObjValue( 'Livello_Categorie_Merceologiche' ) != '' && Get_CTL_PARAMETRI('SDA','EMPTY_IS_ALL','DefaultValue','true','-1') == 'true' ) )   
		{
			var id_sda = getObjValue( 'IdDocBando' );
			var filtro='';
			
			if  ( str_ClassiBando != '' )
			{
				filtro= 'SQL_WHERE= dmv_cod in ( select dmv_cod from SDA_Categorie_Merceologiche_SELECTED where idheader = ' + id_sda + ' ) ';
			}
			else
			{
				filtro= 'SQL_WHERE= DMV_DM_ID = \'' + getObjValue( 'Elenco_Categorie_Merceologiche' ) + '\' and DMV_LEVEL <= ' + getObjValue( 'Livello_Categorie_Merceologiche' ) 
			}
				
			SetProperty( getObj('Categorie_Merceologiche'),'filter',filtro);

					
		}
	   
	 	
	}

	
	
}


function Onchange_Categorie_Merceologiche()
{  

	
	ExecDocProcess( 'ON_CHANGE,CATEGORIE_MERCEOLOGICHE_CONFERMA,,NO_MSG');
	

}
