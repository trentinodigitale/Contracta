var Old_Filter_Convenzione='';

var idRowTooltipAperto;


function Integrativo_Sec_Dettagli_AddRow(objGrid , Row , c){
  
  //alert('aggiungi articolo da ODC');
  
  Articoli_Sec_Dettagli_AddRow( objGrid , Row , c , 'ODC' )
  
}

function AggiungiIntegrativo(  ){

  AggiungiArticoloMultiplo( 'ODC' );

}


function AggiungiCarrello(  ){

  AggiungiArticoloMultiplo( 'CARRELLO' );
}


function Carrello_Sec_Dettagli_AddRow( objGrid , Row , c  ){
  
  Articoli_Sec_Dettagli_AddRow( objGrid , Row , c , 'CARRELLO' )
}

function Articoli_Sec_Dettagli_AddRow( objGrid , Row , c , Contesto )
{
	var cod;
	var nq;
	var strCommand;
	var testo;
	var result;
  
  //recupero dalla querystring il doc ODC da aggiornare nel contesto ODC
	var IDDOC_TO_UPDATE = getQSParam('doc_to_upd');
	var IDDOC_RIDOTTO   = getQSParam('doc_ridotto');
  
	//alert(IDDOC_TO_UPDATE);
	
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
		
	//recupero la qt imputata
	var QtImputata = getObjValue( 'R' + Row + '_QTDisp');
	//recupero prezzo
	var PrezzoUnitario = getObjValue( 'R' + Row + '_PrezzoUnitario');
	//recupero valoreaccessorio
	var ValoreAccessorio = getObjValue( 'R' + Row + '_ValoreAccessorioTecnico');
  
	//Se NON sto lavorando il carrello di una riduzione ordinativo
	if ( !IDDOC_RIDOTTO || IDDOC_RIDOTTO == '' || IDDOC_RIDOTTO == '0' )
	{
		if ( parseFloat(QtImputata) <= 0 )
		{
			DMessageBox( '../' , 'Quantita deve essere maggiore di 0' , 'Info' , 1 , 400 , 300 );
			return;
		}
		
		/* commentato perche lo lasciamo solo lato server per att. 584004 - Convenzioni con importi negativi
		if ( parseFloat(PrezzoUnitario) <= 0 ){
			DMessageBox( '../' , 'Prezzo deve essere maggiore di 0' , 'Info' , 1 , 400 , 300 );
			return;
		}
		
			  
		if ( parseFloat(ValoreAccessorio) < 0 ){
			DMessageBox( '../' , 'ValoreAccessorio deve essere maggiore o uguale a 0' , 'Info' , 1 , 400 , 300 );
			return;
		}
		*/
	}
	/*
	else
	{
		if ( parseFloat(QtImputata) >= 0 )
		{
			DMessageBox( '../' , 'La quantita deve essere minore di 0' , 'Info' , 1 , 400 , 300 );
			return;
		}
		
		if ( parseFloat(PrezzoUnitario) >= 0 ){
			DMessageBox( '../' , 'Il prezzo deve essere minore di 0' , 'Info' , 1 , 400 , 300 );
			return;
		}
		
		if ( parseFloat(ValoreAccessorio) < 0 ){
			DMessageBox( '../' , 'Il valoreAccessorio deve essere minore o uguale a 0' , 'Info' , 1 , 400 , 300 );
			return;
		}
		
	}*/
	

  
  
  //recupero not_editable
  var not_editable = getObjValue( 'R' + Row + '_Not_Editable');
  
    
  ajax = GetXMLHttpRequest(); 
  
  if(ajax){
		
    var strParam;		 
		strParam = 'OPERATION=ADDROW&ID=' + cod + '&QT=' + QtImputata + '&PrezzoUnitario=' + PrezzoUnitario + '&ValoreAccessorio=' + ValoreAccessorio + '&not_editable=' + not_editable;
		
		var nocache = new Date().getTime();
		
		var strUrlOperation = '../customDoc/OperationCarrello.asp?'+ strParam + '&nocache=' + nocache ;
		
		if ( Contesto == 'ODC'){
		  strParam = strParam + '&IDDOC_TO_UPDATE=' + IDDOC_TO_UPDATE + '&IDDOC_RIDOTTO=' + IDDOC_RIDOTTO;
		  strUrlOperation = '../customDoc/Operation_Articoli_ODC.asp?'+ strParam + '&nocache=' + nocache ;
		}
		
		//alert(strUrlOperation);
		
    ajax.open("GET", strUrlOperation , false);
	 
    ajax.send(null);
    
    if(ajax.readyState == 4) {
      //alert(ajax.status);
	    if(ajax.status == 200)
	    {
	      result =  ajax.responseText;
	      if (result == ''){
	        
	        if ( Contesto == 'CARRELLO'){
	         //aggiorno numero di righe del carrello
           SetRowCarrello();
          
           //aggiorno il doc carrello in memoria
           ExecDocCommandInMem( 'PRODOTTI#RELOAD', idpfuUtenteCollegato, 'CARRELLO');
          
           //visualizzo messaggio operazione ok
           DMessageBox( '../' , 'Articolo aggiunto al carrello' , 'Info' , 1 , 400 , 300 );
           
	        }else{
            
            //siamo nel contesto ODC e ricarico in memoria la sezione prodotti dell'ODC
            //ExecDocCommandInMem( 'PRODOTTI#RELOAD', IDDOC_TO_UPDATE, 'ODC');
            ReloadDocFromDB ( IDDOC_TO_UPDATE ,'ODC');
            
            ShowWorkInProgress(false);
            
            //visualizzo messaggio operazione ok
            DMessageBox( '../' , 'Articolo aggiunto ODC' , 'Info' , 1 , 400 , 300 );
            
          }
	        
	      }
		    else{
		      
		      if ( Contesto == 'CARRELLO'){
  		      
            //aggiorno numero di righe del carrello
  		      SetRowCarrello();
  		      
  		      //aggiorno il doc carrello in memoria
  		      ExecDocCommandInMem( 'PRODOTTI#RELOAD', idpfuUtenteCollegato, 'CARRELLO');
  		      
          }else{
            
            //aggiorno il doc ODC in memoria
  		      ExecDocCommandInMem( 'PRODOTTI#RELOAD', IDDOC_TO_UPDATE, 'ODC');
  		      
          }
          
          //visualizzo messaggio operazione non consentita
          DMessageBox( '../' , result , 'Attenzione' , 2 , 400 , 300 );  
          
          
		    }
	    }
    }
  }

}


function SvuotaCarrello(){
  
  var result;
  ajax = GetXMLHttpRequest(); 
  
  if(ajax){
		
    var strParam;		 
		strParam = 'OPERATION=DELETE_ALL' ;
		
    var nocache = new Date().getTime();
		//alert('../customDoc/OperationCarrello.asp?'+ strParam + '&nocache=' + nocache);
    ajax.open("GET", '../customDoc/OperationCarrello.asp?'+ strParam + '&nocache=' + nocache , false);
	 
    ajax.send(null);
    
    if(ajax.readyState == 4) {
      //alert(ajax.status);
	    if(ajax.status == 200)
	    {
	      result =  ajax.responseText;
	      if (result == ''){
	        
	        //aggiorno numero di righe del carrello
          //SetRowCarrello;
          getObj('catalogo_toolbar_visualizzacarrello').innerHTML = CNV( '../','Visualizza il carrello') + ' (0)' ;
          
          //aggiorno il doc carrello in memoria
          ExecDocCommandInMem( 'PRODOTTI#RELOAD', idpfuUtenteCollegato, 'CARRELLO');
          
          //visualizzo messaggio operazione ok
          DMessageBox( '../' , 'Carrello svuotato correttamente' , 'Info' , 1 , 400 , 300 );
	        
	      }
		    else
		    
          DMessageBox( '../' , result , 'Attenzione' , 2 , 400 , 300 );  
		    
	    }
    }
  }
  

}




//window.onload = SetRowCarrello;
window.onload = function(){

	//-- ripristino il filtro sul dominio gerarchico convenzione lotto
	SetFiltroConvenzione();
	
	SetRowCarrello();

	
};

	


function SetRowCarrello(){

  ajax = GetXMLHttpRequest(); 
  
  if(ajax){
		
    var strParam;		 
		strParam = 'OPERATION=COUNTER_ROWS' ;
		
    var nocache = new Date().getTime();
    //alert('../customDoc/OperationCarrello.asp?'+ strParam + '&nocache=' + nocache);
    ajax.open("GET", '../customDoc/OperationCarrello.asp?'+ strParam + '&nocache=' + nocache , false);
	 
    ajax.send(null);
    
    if(ajax.readyState == 4) {
      //alert(ajax.status);
	    if(ajax.status == 200)
	    {
	      result =  ajax.responseText;
	      //alert( ajax.responseText );
	      if ( ! isNaN(parseInt(result)) ){
	        
	        //aggiorno numero di righe del carrello
          //alert(getObj('catalogo_toolbar_visualizzacarrello').innerHTML);
	        getObj('catalogo_toolbar_visualizzacarrello').innerHTML = CNV( '../','Visualizza il carrello') + ' (' + result + ')' ;
	        
	      }
		    else{
		      DMessageBox( '../' , result , 'Attenzione' , 2 , 400 , 300 );  
		    }
         
	    }
    }
  }
  
  
  

}


function VisualizzaCarrello(){
  /*
  ExecDocCommandInMem( 'PRODOTTI#RELOAD', idpfuUtenteCollegato, 'CARRELLO');
  ShowDocument('CARRELLO' , idpfuUtenteCollegato );
*/

  ExecDocCommandInMem( 'PRODOTTI#RELOAD', '<ID_USER>', 'CARRELLO');
  ShowDocument('CARRELLO' ,'<ID_USER>' );

}




function AggiungiArticoloMultiplo( Contesto ){
  
  var idRow;
	var vet;
	var altro;
	var i;
	var NumRow;
	var QtImputata;
	var Row;
	var strParam;		 
	var nocache;
	var resultglobale;
	var resultFaseII;
	var codice;
	var PrezzoUnitario;
	var ValoreAccessorio;
	var not_editable;
	//debugger;
  
  var IDDOC_TO_UPDATE = getQSParam('doc_to_upd'); 
  var IDDOC_RIDOTTO   = getQSParam('doc_ridotto');
  
	resultglobale='<html><head>';
  resultglobale= resultglobale + '<link rel=stylesheet href="../CTL_Library/Themes/caption.css" type="text/css"/>';
  resultglobale= resultglobale + '<link rel=stylesheet href="../CTL_Library/Themes/griddocument.css" type="text/css"/>';
  resultglobale= resultglobale + '<link rel=stylesheet href="../CTL_Library/Themes/field.css" type="text/css"/>';
  
  if ( Contesto == 'CARRELLO')
   resultglobale= resultglobale + '<title>' + CNV ('../' , 'Esito Aggiungi articoli Carrello' ) + '</title></head><body>';
  else
   resultglobale= resultglobale + '<title>' + CNV ('../' , 'Esito Aggiungi articoli ODC' ) + '</title></head><body>'; 
  
  resultglobale= resultglobale + '<table><tr><td><table height="30px" width="100%" ><tr  ><td width="100%" height="30px"><table width="100%" class="Caption"  border="0" cellspacing="0" cellpadding="0">';
  
  if ( Contesto == 'CARRELLO')
    resultglobale= resultglobale + '<tr><td >' + CNV ('../' , 'Esito Aggiungi articoli Carrello' ) + '</td></tr></table></td></tr>';
  else
    resultglobale= resultglobale + '<tr><td >' + CNV ('../' , 'Esito Aggiungi articoli ODC' ) + '</td></tr></table></td></tr>';
    
  resultglobale= resultglobale + '<tr><td><table class="Grid"  cellpadding=0 cellspacing=0><tr><td class="Grid_RowCaption">Codice</td><td class="Grid_RowCaption"></td><td class="Grid_RowCaption">Esito</td></tr>';
	
	ShowWorkInProgress(true);

	resultFaseII = `<div><table class="Grid"  cellpadding=0 cellspacing=0><tr><td class="Grid_RowCaption">Codice</td><td class="Grid_RowCaption"></td><td class="Grid_RowCaption">Esito</td></tr>`;

	//-- recupera il codice della riga selezionata
	//idRow = GetIdSelectedRow( 'GridViewer' , 'RadioSel' , 'this' );
	idRow = Grid_GetIdSelectedRow( 'GridViewer' );
	//alert(idRow);
	if( idRow == '' )
	{
	  ShowWorkInProgress(false);
		DMessageBox( '../' , 'E\' necessario selezionare prima una riga' , 'Attenzione' , 2 , 400 , 300 );  
	}
	else
	{
		
		//innesco addrow su ogni riga
		vet = idRow.split('~~~');
		NumRow = vet.length;
		//alert(NumRow);
		
    ajax = GetXMLHttpRequest(); 
		
		
		
		for ( i = 0 ; i < NumRow ; i++ ){
      
      
      //recupero row riga selezionata
      Row = GetPositionRow('GridViewer',vet[i],'self');
     
      //recupero qt imputata
      //recupero la qt imputata
      //QtImputata = '1';
      QtImputata = getObjValue( 'R' + Row + '_QTDisp');  
      
      //recupero prezzo
      PrezzoUnitario = getObjValue( 'R' + Row + '_PrezzoUnitario');
      
      //recupero valoreaccessorio
      ValoreAccessorio = getObjValue( 'R' + Row + '_ValoreAccessorioTecnico');
      
  
      //recupero codice
      codice = getObjValue( 'R' + Row + '_Codice');  
      
      //recupero not_editable
      not_editable = getObjValue( 'R' + Row + '_Not_Editable');
      
      
		  //strParam = 'OPERATION=ADDROW&ID=' + vet[i] + '&QT=' + QtImputata ;
		  strParam = 'OPERATION=ADDROW&ID=' + vet[i] + '&QT=' + QtImputata + '&PrezzoUnitario=' + PrezzoUnitario + '&ValoreAccessorio=' + ValoreAccessorio + '&not_editable=' + not_editable;
		  
		  nocache = new Date().getTime();
		  
		  var strUrlOperation = '../customDoc/OperationCarrello.asp?'+ strParam + '&nocache=' + nocache
		
		  if ( Contesto == 'ODC'){
		    strParam = strParam + '&IDDOC_TO_UPDATE=' + IDDOC_TO_UPDATE + '&IDDOC_RIDOTTO=' + IDDOC_RIDOTTO;
		    strUrlOperation = '../customDoc/Operation_Articoli_ODC.asp?'+ strParam + '&nocache=' + nocache ;
		  }
		  //alert(strUrlOperation);
      ajax.open("GET", strUrlOperation , false);
	 
      ajax.send(null);
      
      if(ajax.readyState == 4) {
      //alert(ajax.status);
  	    if(ajax.status == 200)
  	    {
  	      result =  ajax.responseText;
  	      //alert(result);
  	      if (result == ''){
  	        
            //visualizzo messaggio operazione ok
            //DMessageBox( '../' , 'Articolo aggiunto al carrello' , 'Info' , 1 , 400 , 300 );
  	        resultglobale = resultglobale + '<tr><td class="GR0_Text"><span class="Text" >' + codice + ' </span></td><td ><img alt="" src="../CTL_Library/images/Domain/State_ok.gif"></td><td>'
  	        
			resultFaseII = resultFaseII + '<tr><td class="GR0_Text"><span class="Text" >' + codice + ' </span></td><td ><img alt="" src="../CTL_Library/images/Domain/State_ok.gif"></td><td>'
			resultFaseII = resultFaseII + `${Contesto == 'CARRELLO' ? CNV('../' , 'Articolo aggiunto al carrello' ) : CNV ('../' , 'Articolo aggiunto ODC' )}`
			resultFaseII = resultFaseII + '</td></tr>';

			if (Contesto == 'CARRELLO')
  	         resultglobale = resultglobale + CNV ('../' , 'Articolo aggiunto al carrello' );
  	        else
  	         resultglobale = resultglobale + CNV ('../' , 'Articolo aggiunto ODC' );
  	        
            resultglobale = resultglobale + '</td></tr>';
  	        
  	      }
  		    else{
  		      
  		      //visualizzo messaggio operazione non consentita
            //DMessageBox( '../' , result , 'Attenzione' , 2 , 400 , 300 ); 
            resultglobale = resultglobale + '<tr><td class="GR0_Text"><span class="Text" >' + codice + ' </span></td><td><img alt="" src="../CTL_Library/images/Domain/State_Err.gif"></td><td>' 
			resultFaseII = resultFaseII + '<tr><td class="GR0_Text"><span class="Text" >' + codice + ' </span></td><td><img alt="" src="../CTL_Library/images/Domain/State_Err.gif"></td><td>' 
            
				  if (result.length > 8) {
					  if (result.substring(0, 8) == 'NO_ML###') {
						  resultglobale = resultglobale + result.substring(8, result.length);
						  resultFaseII = resultFaseII + result.substring(8, result.length);
					  } else {
						  resultglobale = resultglobale + CNV('../', result);
						  resultFaseII = resultFaseII + CNV('../', result);
					  }
				  } else {

					resultglobale = resultglobale + CNV ('../' , result ) ;
					  resultFaseII = resultFaseII + CNV ('../' , result ) ;
				  }
              
				resultglobale = resultglobale + '</td></tr>';
				resultFaseII = resultFaseII + '</td></tr>';
            
  		    }
  	    }
      }
      
  }
  
  
  if ( Contesto == 'CARRELLO'){
    //aggiorno numero di righe del carrello
    SetRowCarrello();
    
    //aggiorno il doc carrello in memoria
    ExecDocCommandInMem( 'PRODOTTI#RELOAD', idpfuUtenteCollegato, 'CARRELLO');
    
  }else{
  
    //aggiorno il doc ODC in memoria
  	//ExecDocCommandInMem( 'PRODOTTI#RELOAD', IDDOC_TO_UPDATE, 'ODC');
  	ReloadDocFromDB ( IDDOC_TO_UPDATE ,'ODC');
  	ShowWorkInProgress(false);
  }
    
  resultglobale = resultglobale + '</table></td></tr><tr><td height="100%">&nbsp;</td></tr></table></td></tr></table></body></html>'
  resultFaseII = resultFaseII + '</table></div>'
  
	
	
	var const_width=450;
	var const_height=250;
	var sinistra=(screen.width-const_width)/2;
	var alto=(screen.height-const_height)/2;

		if (typeof isFaseII !== 'undefined' && isFaseII) {
			$(`${resultFaseII}`).dialog({
				title: `${Contesto == 'CARRELLO' ? CNV('../', 'Esito Aggiungi articoli Carrello') : CNV('../', 'Esito Aggiungi articoli ODC')}`,
				resizable: false,
				modal: true,
				maxHeight: $(window).height(),
				open: function () {
					$(this).dialog('option', 'maxHeight', $(window).height());
				},
				buttons: {
					"OK": function () {
						$(this).dialog("close");
					}
				}
			});
			ShowWorkInProgress(false);
			return;
		}


  //alert (resultglobale);
  var winSend=window.open('','EsitoAggiungiCarrello','toolbar=no,location=no,directories=no,status=no,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
	winSend.document.write(resultglobale);
  
  ShowWorkInProgress(false);
  
 }
 
}


function GetPositionRow( grid , idRow , Page )
{

	var objInd;
	var nInd; 
	var objGrid;
	var numRow;
	
	
	try
	{
		objGrid = getObjPage( grid , Page);
		//numRow = objGrid.numrow;
		
    numRow = GridViewer_NumRow;
		
		if(  numRow == undefined ) numRow = objGrid[0].numrow;
		
		for (nInd=0;nInd<=numRow;nInd++)
		{
			try
			{
				//-- prelevo il valore dell'identificativo
				objInd = getObjPage( grid + '_idRow_' + nInd , Page);
				
				if ( objInd.value == idRow )
				{
					return nInd;
				}
			}
			catch(e){}
		}
		
		return -1;
	}
	catch(  e ){ return -1; 	};

}


function SetFiltroConvenzione(){
  
	var NewFilter;

	//conservo il filtro originale attributo convenzione
	//if ( Old_Filter_Convenzione == '')
	//	Old_Filter_Convenzione = GetProperty( getObj('Convenzione_Lotto'),'filter');

	//alert(Old_Filter_Convenzione);

	//if (Old_Filter_Convenzione == '')
		NewFilter = 'SQL_WHERE=' ;
	//else
	//	NewFilter = Old_Filter_Convenzione + ' and ' ;

	//NewFilter =  NewFilter + ' IdentificativoIniziativa=\'' +  getObjValue('IdentificativoIniziativa')  + '\'' ;

	if ( getObjValue('IdentificativoIniziativa') != '' )
	{
		NewFilter =  NewFilter + ( ' IdentificativoIniziativa=\'' +  getObjValue('IdentificativoIniziativa')  + '\' and ' );
	}

	if ( getObjValue('Macro_Convenzione') != '' )
	{
		NewFilter =  NewFilter + ( ' \'' +  getObjValue('Macro_Convenzione')  + '\' like \'%###\' + Macro_Convenzione + \'###%\' and ' );
	}

	if (NewFilter.substring( NewFilter.length - 4 , NewFilter.length ) == 'and ' )
		NewFilter = NewFilter.substring( 0 , NewFilter.length - 4 );



	if ( getObjValue('IdentificativoIniziativa') == '' && getObjValue('Macro_Convenzione') == '')
		SetProperty( getObj('Convenzione_Lotto'),'filter', Old_Filter_Convenzione );
	else
		SetProperty( getObj('Convenzione_Lotto'),'filter', NewFilter );         

	//alert('SQL_WHERE= IdentificativoIniziativa=\'' +  getObjValue('IdentificativoIniziativa')  + '\'');
  
  
}

	//Pagina sotto customDoc, "tooltip_carrello.asp?RIGA="

	$(function() 
	{
		$( document ).tooltip({
			items: "img",
			content: function() 
			{
				var element = $( this );

				//Se ci troviamo sulla colonna 'Informazione' (il tooltip grafico deve scattare solo su questa colonna)
				if ( element.parents("table:first").hasClass( "TOOLTIP_CARRELLO_Tab" ) || element.parents("table:first").hasClass( "TOOLTIP_CARRELLO" ) )
				{
					var output;
					
					output = '';
					
					try
					{
						ajax = GetXMLHttpRequest();

						if(ajax)
						{
							var nocache = new Date().getTime();
							var numeroDiRiga;
							var idRiga;
							
							idRiga = element.parents("table:first").attr('id');
							idRiga = ReplaceExtended(idRiga,'_FNZ_OPEN','');
							numeroDiRiga = parseInt(ReplaceExtended(idRiga,'R',''));
												
							var cod = GetIdRow( 'GridViewer' , numeroDiRiga , 'self' );
							
							ajax.open("GET", pathRoot + 'CustomDoc/Tooltip_Carrello.asp?RIGA=' + encodeURIComponent(cod) + '&nocache=' + nocache , false);
							ajax.send(null);

							if(ajax.readyState == 4) 
							{
								
								if(ajax.status == 200 )
								{
									
									if (ajax.responseText != "-1" )
									{
										output=ajax.responseText;
									}
															
								}
							}		
						}
					}
					catch(e)
					{
						//alert(e.message);
					}
					
				
					return output;
				}
			}
		});
	});
	
	
	function openTooltip( grid , idRow , Page )
	{

		var objTooltip = 'R' + idRow + '_FNZ_OPEN';
		
		
		//$('#' + objTooltip).children().children().children().children().tooltip( 'open' );
		$('.img_label_alt').trigger('mouseout');
		
		if (idRow !== idRowTooltipAperto)
		{
			$('#' + objTooltip).children().children().children().children().trigger('mouseover');
			idRowTooltipAperto = idRow;
		}
		else
		{
			idRowTooltipAperto = -1;
		}

		
		
	}

