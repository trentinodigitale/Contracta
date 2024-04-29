window.onload = Onload_Process;

function Onload_Process(){
	
	
	//se il documento è stato confermato apro l'applicazione
	var DOCUMENT_READONLY = '0';
	
	try
	{		
		if ( getObjValue('val_StatoFunzionale') != 'InLavorazione')
		{
			DOCUMENT_READONLY='1';
		}
		else
		{
			DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
		}
		
		
		
	}
	catch(e)
	{
	}
	
	try {
		
		if (getObj('val_StatoFunzionale').value=='Pubblicato')
			ShowCol( 'DOCUMENTAZIONE_RICHIESTA' , 'FNZ_OPEN' , 'none' );
		//alert('ok');
		
	}catch(e){
	}
	
	SetCampiVariazione();
	
	if (DOCUMENT_READONLY == '0' ) 
	{
		//set_Complex();
		//set_Criteri();
		
		ActiveDrag();	
		
	}else
	{
		HideColDrag();
	}	
	
		
}


function LISTA_DOCUMENTI_OnLoad()
{
	    
    if (getObj('IDDOC').value.substring(0,3) == 'new' )
	{
		LISTA_DOCUMENTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=&Table=BANDO_ALBO_LISTA_DOCUMENTI&JSCRIPT=BANDO&IDENTITY=Id&DOCUMENT=BANDO&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=200,100*,0&numRowForPag=15&Sort=data&ActiveSel=2&SortOrder=asc&Exit=no&ShowExit=0&AreaFiltroWin=close&FilterHide=IdDoc = 0 ';
	}
	else
	{
		LISTA_DOCUMENTI.location = '../../DASHBOARD/Viewer.asp?TOOLBAR=&Table=BANDO_ALBO_LISTA_DOCUMENTI&JSCRIPT=BANDO&IDENTITY=Id&DOCUMENT=BANDO&PATHTOOLBAR=../customdoc/&AreaAdd=no&Caption=&Height=200,100*,0&numRowForPag=15&Sort=data&ActiveSel=2&SortOrder=asc&Exit=no&ShowExit=0&AreaFiltroWin=close&FilterHide=LinkedDoc =' + getObj('IDDOC').value ;;	
	}
}





function ClickDown( grid , r , c )
{

		
		
		move( 'LineaDocumentazione' , r  , 1 );
		move( 'TipoInterventoDocumentazione' , r  , 1 );
		move( 'DescrizioneRichiesta' , r  , 1 );
		move( 'AllegatoRichiesto' , r  , 1 );
		move( 'Obbligatorio' , r  , 1 );
		move( 'TipoFile' , r  , 1 );
		move( 'AnagDoc' , r  , 1 );
		move( 'NotEditable' , r  , 1 );
		move( 'AreaValutazione' , r  , 1 );
		move( 'Peso' , r  , 1 );
		
		
	

}

function ClickUp( grid , r , c )
{

	
	
		move( 'LineaDocumentazione' , r  , -1 );
		move( 'TipoInterventoDocumentazione' , r  , -1 );
		move( 'DescrizioneRichiesta' , r  , -1 );
		move( 'AllegatoRichiesto' , r  , -1 );
		move( 'Obbligatorio' , r  , -1 );
		move( 'TipoFile' , r  , -1 );
		move( 'AnagDoc' , r  , -1 );
		move( 'NotEditable' , r  , -1 );
		move( 'AreaValutazione' , r  , -1 );
		move( 'Peso' , r  , -1 );

		
	
}

function move( field , row , verso ) 
{
    try
    {
        
		var iValue;
		
		iValue = 0;
		
		var f1 = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + row + '_' + field );
        var f2 = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + ( row + verso ) + '_' + field ) ;
        var app;
		var app1;
		var app2;
		
		/*		
		if (f1 == null)
		{
			f1 = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + row + '_' + field + '_V' );
			iValue = 1;
		}
		
		if (f2 == null)
		{
			f2 = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + ( row + verso ) + '_' + field + '_V') ;
			iValue = 1;
		}
		
		
		if (iValue == 0)
		{
			app = f1.value;
			f1.value = f2.value;
			f2.value = app;
		}
		else
		{
		*/
			//alert(field + ' - ' + f1.type);
			
			app = f1.value;
			
			if (f1.type == 'textarea')
			{
				SetTAValue( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + row + '_' + field , f2.value);
				SetTAValue( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + ( row + verso ) + '_' + field ,app );
			}
			else
			if (field == 'Obbligatorio')
			{
				app2=f1.checked;
				f1.checked=f2.checked;
				f2.checked=app2;
			}
			else
			if (field == 'Peso')
			{
				SetNumericValue( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + row + '_' + field , f2.value);
				SetNumericValue( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + ( row + verso ) + '_' + field ,app );
			}
			else
			if (field == 'TipoFile')
			{
				f1.value=f2.value;
				f2.value=app;
				
				app1= getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + row + '_' + field + '_edit').value;
				app2= getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + row + '_' + field + '_edit_new').value;
				
				getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + row + '_' + field + '_edit').value = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + ( row + verso ) + '_' + field + '_edit').value;
				getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + row + '_' + field + '_edit_new').value = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + ( row + verso ) + '_' + field + '_edit_new').value;
				
				getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + ( row + verso ) + '_' + field + '_edit').value=app1;
				getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + ( row + verso ) + '_' + field + '_edit_new').value=app2;
				
			}
			else			
			if (f1.type == 'hidden')
			{
				SetTextValue( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + row + '_' + field , f2.value);
				SetTextValue( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + ( row + verso ) + '_' + field ,app );
			}
			else
			if (f1.type == 'select-one')
			{
				f1.value=f2.value;
				f2.value=app;
			}
			
			
			
			
			//f1.textContent = f2.textContent;
			//f1.innerText=f2.textContent;
			
			//f2.textContent = app;
			//f2.innerText = app;
		//}
				
		
    
    }catch(e){}

}


function SetCampiVariazione(  ) 
{
	
	//alert(getObj('RGestione_Modifiche_MODEL_Sospendi_Iscrizioni').value);
	
	try {
        if (getObj('RGestione_Modifiche_MODEL_Sospendi_Iscrizioni').value == 'si') 
		{
            //getObj('RGestione_Modifiche_MODEL_Invia_Notifica_Sospensione').value = '';
            getObj('RGestione_Modifiche_MODEL_Invia_Notifica_Sospensione').disabled = false;
			
			getObj('RGestione_Modifiche_MODEL_Richiedi_Nuova_Istanza').disabled = false;
        }
		else
		{
			getObj('RGestione_Modifiche_MODEL_Invia_Notifica_Sospensione').value = '';
            getObj('RGestione_Modifiche_MODEL_Invia_Notifica_Sospensione').disabled = true;
			
			getObj('RGestione_Modifiche_MODEL_Richiedi_Nuova_Istanza').value = '';
            getObj('RGestione_Modifiche_MODEL_Richiedi_Nuova_Istanza').disabled = true;
			
			
			
		}

    } catch (e) {}
	
}


function ActiveDrag ()
{
	//attivo DRAG&DROP sulla griglia degli Atti
	//ActiveGridDrag (  'DOCUMENTAZIONEGrid' , MoveAllAtti );
	
	//attivo DRAG&DROP sulla griglia Busta Documentazione 
	ActiveGridDrag (  'DOCUMENTAZIONE_RICHIESTAGrid' , MoveAllDoc );
}


function HideColDrag ()
{
	//nascondo drag_drop quando non editabile
	//ShowCol( 'DOCUMENTAZIONE' , 'FNZ_DRAG' , 'none' );
	ShowCol( 'DOCUMENTAZIONE_RICHIESTA' , 'FNZ_DRAG' , 'none' );
	ShowCol( 'DOCUMENTAZIONE_RICHIESTA' , 'FNZ_ADD' , 'none' );
}

/*
function DOCUMENTAZIONE_RICHIESTA_AFTER_COMMAND( param )
{
	//attivo DRAG&DROP sulla griglia Atti
	ActiveGridDrag (  'DOCUMENTAZIONE_RICHIESTAGrid' , MoveAllDoc );
	
	
}
*/





//funzione che sposta tutti campi della griglia
function MoveAllDoc(  r , verso )
{

	
	
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'LineaDocumentazione' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'TipoInterventoDocumentazione' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'AllegatoRichiesto' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'AnagDoc' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'NotEditable' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'Obbligatorio' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'Peso' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'TipoFile' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'AreaValutazione' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'EMAS' , r  , verso );
	Move_Abstract( 'DOCUMENTAZIONE_RICHIESTAGrid', 'TipoValutazione' , r  , verso );
	
	move_Descrizione_Doc( 'DescrizioneRichiesta' , r  , verso );
	

}





//inverte il campo descrizione di due righe
//contemplando anche i casi in cui su una riga il campo è editabile e su un'altra no
function move_Descrizione_Doc( field , row , verso ) 
{
				
	try
    {
        var f1 = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + row + '_' + field );
        var f2 = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + ( row + verso ) + '_' + field ) ;
        var app;
		
		var f1_edit =0 ;
		var f2_edit =0 ;
		
		
		
		f1_V = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + row + '_' + field + '_V');
			
		if ( f1_V == null ){
			
			f1_edit = 1 ; 
		}
		
		f2_V = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + ( row + verso ) + '_' + field + '_V') ;
		
		
		if ( f2_V == null ){
			
			f2_edit = 1 ;
		}
		
		//alert(f1_edit + '---' + f2_edit);
		//sorgente non editabile e destinazione editabile
		if ( f1_edit != f2_edit )
		{
			if ( f1_edit == 0)
			{	
				
				//alert( Descrizione_Doc_NotEditable ( ( row + verso )  , f1_V.innerHTML  ));
				//la destinazione diventa non editabile con il valore di f1
				f2.parentNode.innerHTML = Descrizione_Doc_NotEditable ( ( row + verso )  , f1_V.innerHTML );
				
				//alert(Descrizione_Doc_Editable (    row  , f2.value ))
				//la sorgente diventa editabile con il valore di f2
				f1_V.parentNode.innerHTML =  Descrizione_Doc_Editable (    row  , f2.value );
				
			}
			else
			{	
				
				
				//la destinazione diventa  editabile con il valore di f1
				f2_V.parentNode.innerHTML = Descrizione_Doc_Editable ( ( row + verso )  , f1.value );
				
				
				//la sorgente diventa non editabile con il valore di f2
				f1.parentNode.innerHTML =  Descrizione_Doc_NotEditable (    row  , f2_V.innerHTML );
				
			}
			
		}
		else
		{
			//inverte i valori dei campi (visuali/nascosti) se entrambi editabili oppure no
			
			app = f1.value;
			f1.value = f2.value;
			f2.value = app;
			
			
			f1 = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + row + '_' + field + '_V');
			f2 = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + ( row + verso ) + '_' + field + '_V') ;


			app = f1.value;
			
			f1.value = f2.value;
			f2.value = app
			
			if ( app == undefined )
			{
				try{
					app = f1.innerHTML;
					
					f1.innerHTML = f2.innerHTML;
					f2.innerHTML = app;
					
				}catch(e){}
			}
		}
		
	}
	catch(e)
	{
	}
}

function Descrizione_Doc_NotEditable ( rowRiga , strValue )
{
	var StrHtml =''
	StrHtml = '<span class="TextArea_NotEditable" id="RDOCUMENTAZIONE_RICHIESTAGrid_' + rowRiga + '_DescrizioneRichiesta_V">' +  strValue + '</span>';
	StrHtml = StrHtml  + '<textarea class="display_none attrib_base" name="RDOCUMENTAZIONE_RICHIESTAGrid_' +  rowRiga  + '_DescrizioneRichiesta" id="RDOCUMENTAZIONE_RICHIESTAGrid_' +  rowRiga  + '_DescrizioneRichiesta">' + strValue + '</textarea>';
	return StrHtml;
}	

function Descrizione_Doc_Editable ( rowRiga , strValue )
{
	var StrHtml =''
	
	//<textarea width="100%" cols="20" rows="0" name="RDOCUMENTAZIONE_RICHIESTAGrid_2_DescrizioneRichiesta" id="RDOCUMENTAZIONE_RICHIESTAGrid_2_DescrizioneRichiesta" class="TextArea width_100_percent" onkeypress="TA_MaxLen(this,250 );" onblur="TA_MaxLen(this,250 );">terza</textarea>
	
	StrHtml = '<textarea width="100%" cols="20" rows="0" name="RDOCUMENTAZIONE_RICHIESTAGrid_' +  rowRiga  + '_DescrizioneRichiesta" id="RDOCUMENTAZIONE_RICHIESTAGrid_' +  rowRiga  + '_DescrizioneRichiesta" class="TextArea width_100_percent" onkeypress="TA_MaxLen(this,250 );" onblur="TA_MaxLen(this,250 );">' + strValue + '</textarea>';
	return StrHtml;
}	
