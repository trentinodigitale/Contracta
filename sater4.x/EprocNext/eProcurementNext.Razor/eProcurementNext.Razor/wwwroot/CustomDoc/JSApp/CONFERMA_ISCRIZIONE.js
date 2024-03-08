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
	
	//ToPrint(param);
	
	PrintPdf( '/report/CONFERMA_ISCRIZIONE_INAPPROVE.asp?');


	/*try { 
		var v = getObj( 'ClasseIscriz' ).value;
	
		//trasformo la forma tecnica
		getObj( 'ClasseIscriz' ).value= ReplaceExtended(v,'###','#');
		v=getObj( 'ClasseIscriz' ).value;
	}catch(e){};
	*/  

}

window.onload = hideclasseiscrizione;

function hideclasseiscrizione()
{
	
	try
	{
		if ( getObj( 'JumpCheck' ).value.substring(0,16).toUpperCase() == 'ISTANZA_ALBOPROF' ) 
		{
			try{setVisibility(getObj('ClasseIscriz'), 'none');}catch(e){}
			try{setVisibility(getObj('Cap_ClasseIscriz'), 'none');}catch(e){}
			try{setVisibility(getObj('Cell_ClasseIscriz'), 'none');}catch(e){}
			try{setVisibility(getObj('Cell_ClasseIscriz').parentNode.parentNode.parentNode, 'none');}catch(e){}
			try{setVisibility(getObj('ClasseIscriz_edit'), 'none');}catch(e){}
			try{setVisibility(getObj('ClasseIscriz_button'), 'none');}catch(e){}
			try{setVisibility(getObj('cap_ClasseIscriz'), 'none');}catch(e){}
			try{setVisibility(getObj('ClasseIscriz_edit_new'), 'none');}catch(e){}
			
			//Filtro_Attivita_Professioni();	
			
		}
		else
		{
			try{setVisibility(getObj('AttivitaProfessionale'), 'none');}catch(e){}
			try{setVisibility(getObj('Cap_AttivitaProfessionale'), 'none');}catch(e){}
			try{setVisibility(getObj('Cell_AttivitaProfessionale'), 'none');}catch(e){}
			try{setVisibility(getObj('Cell_AttivitaProfessionale').parentNode.parentNode.parentNode, 'none');}catch(e){}
			try{setVisibility(getObj('AttivitaProfessionale_edit'), 'none');}catch(e){}
			try{setVisibility(getObj('AttivitaProfessionale_button'), 'none');}catch(e){}
			try{setVisibility(getObj('cap_AttivitaProfessionale'), 'none');}catch(e){}
			try{setVisibility(getObj('AttivitaProfessionale_edit_new'), 'none');}catch(e){}
		}
		
	}
	catch(e){}
	


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
	
	Filtro_Classe_Iscrizione();
	
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

function Filtro_Classe_Iscrizione()
{
	
	var str_Scelta_Classi_Libera = getObj('Scelta_Classi_Libera').value;
	
	
	
	var str_ClassiBando = getObj('ClassiBando').value;
	
	var str_Classi_Filter = '';
	
	var str_Filter =''
	
	//alert(str_ClassiBando);
	
	//per ALBO GESTIONE ME, ALBO FORNITURE E SERVIZI
	if( ( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' ) && ( getObj( 'JumpCheck' ).value.substring(0,16).toUpperCase() != 'ISTANZA_ALBOPROF' ) )		
	{
		
		var class_istanza = getObj('ClasseIscriz').value;
		var filter = '';
		
		
		filter =  GetProperty ( getObj('ClasseIscriz'),'filter') ;				
		
		if ( filter == '' || filter == undefined || filter == null )
		{					
			
			//se la configurazione non lo indica applico il filtro solo sulle selezioni fatte
			//altrimenti sulle classi indicate sul bando se presenti
			if ( str_Scelta_Classi_Libera == 'no' )
			{
				str_Classi_Filter = class_istanza ; 
			}
			else
			{
				if ( str_ClassiBando != '')
						str_Classi_Filter = str_ClassiBando ;
					
			}
			
			//se presente applico il filtro
			if ( str_Classi_Filter != '')
				str_Filter =  'SQL_WHERE= dmv_cod in (  select top 1000000  B.dmv_cod  from ClasseIscriz a  INNER JOIN ClasseIscriz B ON a.dmv_father = left( b.dmv_father , len ( a.dmv_father ) )  or  b.dmv_father = \'000.\'  or b.dmv_father = left( a.dmv_father , len ( b.dmv_father ) )     where  \'' + str_Classi_Filter + '\' like \'%###\' + A.DMV_COD + \'###%\'    )';
			SetProperty( getObj('ClasseIscriz'),'filter',str_Filter);
			
		}			
	}

	//per ALBO PROFESSIONISTI
	if( ( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' ) && ( getObj( 'JumpCheck' ).value.substring(0,16).toUpperCase() == 'ISTANZA_ALBOPROF' ) )	
	{
		var class_istanza_albo_prof = getObj('AttivitaProfessionaleIstanza').value;
		var filter = '';
		
		
		filter =  GetProperty ( getObj('AttivitaProfessionale'),'filter') ;				
		
		if ( filter == '' || filter == undefined || filter == null )
		{					
			
			
			//se la configurazione lo indica applico il filtro solo sulle selezioni fatte
			if ( str_Scelta_Classi_Libera == 'no' )
			{
				str_Classi_Filter = class_istanza_albo_prof;
			}
			else
			{
				if ( str_ClassiBando != '')
						str_Classi_Filter = str_ClassiBando ;
					
			}
			//se presente applico il filtro
			if ( str_Classi_Filter != '')
				str_Filter =  'SQL_WHERE= DMV_COD in (  select top 1000000  DMV_COD  from  GESTIONE_DOMINIO_TipologiaIncarico_ML_LNG   where ML_LNG = \'I\' and  \'' + str_Classi_Filter + '\' like \'%###\' + DMV_COD + \'###%\'    )'
			
			SetProperty( getObj('AttivitaProfessionale'),'filter',str_Filter);
			
			
		}	
		
	}
	
}


