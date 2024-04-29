
var idRowTooltipAperto;

window.onload = InitCarrelloInMem;


function InitCarrelloInMem()
{
	
  
  //aggiorno la griglia del carrello in memoria
  
	try
	{
		ExecDocCommandInMem( 'PRODOTTI#RELOAD', getObj('IDDOC').value, 'CARRELLO');
	}
	catch(e)
	{
	}
	
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
							
							//R1_FNZ_OPEN
							idRiga = element.parents("table:first").attr('id');
							idRiga = ReplaceExtended(idRiga,'_FNZ_OPEN','');
							numeroDiRiga = ReplaceExtended(idRiga,'R','');
							
							//R0_Id_Product
							var cod = getObjValue('R' + numeroDiRiga + '_Id_Product');
							
							if ( isSingleWin() == false )
								pathRoot = '../../';
							
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

  
}

/*
function CreaOrdinativo(  )
{
	var Grid = getObj( 'PRODOTTIGrid');
	//numRow=parseInt( Grid.numrow );	
	//alert(numRow);
	if ( GetProperty( Grid, 'numrow' )  == '-1' )  
	{
	    //alert( CNV( '../' , 'Per creare l\'ordine e\' necessario almeno un prodotto' ) )
	    DMessageBox( '../' , 'Per creare l\'ordine e\' necessario almeno un prodotto' , 'Attenzione' , 2 , 400 , 300 );  
	    //return 0;
	}

  
  ExecDocProcess('CREA_ORDINATIVO,CARRELLO&SHOW_MSG_INFO=no');
    
}
*/



function CreaPreventivo( param )
{


	var Grid = getObj( 'PRODOTTIGrid');
	numRow=parseInt( Grid.numrow );	
	if ( GetProperty( Grid, 'numrow' )  == '-1' )  
	{
	    alert( CNV( '../' , 'Per creare il Preventivo e\' necessario almeno un prodotto' ) )
	    return 0;
	}

    //-- effettuare il controllo di coerenza per verificare che gli articoli siano relativi al Business Travel
    try{
        if( getObj( 'R0_TipoOrdine' ).value != 'B' )
        {
            if( getObj( 'R0_RicPreventivo' ).value != '1' )
            {
                //DMessageBox( '../../CTL_Library/' , 'Non e\' possibile creare un preventivo per articoli di convenzioni che non siano di Business Travel' , 'Attenzione' , 2 , 400 , 300 );
                DMessageBox( '../../CTL_Library/' , 'Non e\' possibile creare un preventivo per articoli di convenzioni che non lo prevedono' , 'Attenzione' , 2 , 400 , 300 );
                return ;
            }
        }
    }
    catch(e){};


    DOC_NewDocumentFrom( param  );

}


function MYDettagliDelCarrello( objGrid , Row , c  ) {

  /*
  var TipoProdotto;
  TipoProdotto = getObjGrid( 'R' + Row + '_TipoProdotto').value;
  
  //se è un accessorio cancello la riga
  if ( TipoProdotto == 'accessorio' )
  */
  
  
  DettagliDel ( objGrid , Row , c  );
    
  //se è uno richiesto no posso cancellare
  /*
  if ( TipoProdotto == 'richiesto' ){
    DMessageBox( '../../CTL_Library/' , 'prodotto selezionato obbligatorio' , 'Attenzione' , 2 , 400 , 300 );
	  return ;
	}
	
	//se si tratta di un principale setto un flag a 1 per indicare ad un processo DELPRINCIPALE su quale riga stò lavorando
	if ( TipoProdotto == 'principale' ){
	   
	   getObjGrid( 'R' + Row + '_ToDelete').value = 1 ;
	   
	   //invoco un processo sul documento che si preoccupa di cancellare il principale 
	   //e i suoi collegati se possibile (nn ci deve essere un altro princiapale acui sono collegati)
	   ExecDocProcess ('DELETEPRINCIPALE,CARRELLO');
	   
  }  
  */
}



//chiamata dopo il successo di un processo
function afterProcess(){
  
  var Command=getQSParam('COMMAND');
  var Process_Param=getQSParam('PROCESS_PARAM');
 
  //se ho cliccato su crea oprdinativo innesco il makedocfrom
  if (Command == 'PROCESS' && Process_Param == 'CREA_ORDINATIVO,CARRELLO')
  {
      //creo ordinativo
      MakeDocFrom( 'ODC#900,800#CARRELLO#' + getObj('IDDOC').value );
  }
  //ExecDocCommandInMem( 'OFFERTE#RELOAD', IdDocPDA, 'PDA_MICROLOTTI');
} 

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
function RefreshContent()
{
	
}