window.onload = OnLoadPage; 

function OnLoadPage()
{
    var crit = '';
    var conf = '';
	
	var Divisione_lotti = '';
	
	Divisione_lotti = getObjValue('Divisione_lotti');
	
	if ( Divisione_lotti == '0' )
	{
		getObj('LOTTO').style.display = 'none';
	}
	
	
    try{ crit = getObjValue( 'val_CriterioAggiudicazioneGara' ); }catch(e){ crit = ''; };
    try{ conf = getObjValue( 'Conformita' ); }catch(e){ conf = ''; };
    
    //-- se è privista la conformita Ex-Ante oppure è economicamente più vantaggiosa oppure COSTO FISSO si devono aprire i singoli lotti
    if( conf != 'Ex-Ante' && crit != '15532' &&  crit != '25532' )
    {   
        ShowCol( 'LISTA_BUSTE' , 'bRead' , 'none' );
    }
    
    //--se è al prezzo nasconodo colonne punteggio
    if ( crit == '15531' )
	{
		ShowCol( 'LISTA_BUSTE' , 'ValoreOfferta' , 'none' );
		ShowCol( 'LISTA_BUSTE' , 'PunteggioTecnico' , 'none' );
		ShowCol( 'LISTA_BUSTE' , 'PunteggioEconomico' , 'none' );
    }
    
	//se è al costo fisso nascondo  le colonne scheda valutazione,punteggio tecnico,punteggio economico
	if ( crit == '25532' )
	{
		ShowCol( 'LISTA_BUSTE' , 'FNZ_CONTROLLI' , 'none' );
		ShowCol( 'LISTA_BUSTE' , 'PunteggioTecnico' , 'none' );
		ShowCol( 'LISTA_BUSTE' , 'PunteggioEconomico' , 'none' );
	
	}
    
    //cambio caption attributo CriterioAggiudicazioneGara in funzione se ACCORDOQUADRO
  	var ValTipoSceltaContraente = '';
      
    try
	{ 
      ValTipoSceltaContraente = getObjValue( 'TipoSceltaContraente' ); 
    }
	catch(e)
	{ 
		ValTipoSceltaContraente = ''; 
	}
      
    //alert(ValTipoSceltaContraente);
      
    if( ValTipoSceltaContraente == 'ACCORDOQUADRO' )
	{
      getObj('cap_CriterioAggiudicazioneGara').innerHTML =  CNV( '../../','Criterio Valutazione');
    }

	//Nel caso in cui per il lotto la valutazione è al prezzo e NON è economicamente vantaggiosa E NON COSTO FISSO si nasconde la colonna per la valutazione
	if ( getObjValue('val_CriterioAggiudicazioneGara') != '15532' && getObjValue('val_CriterioAggiudicazioneGara') != '25532' )
	{
		ShowCol( 'LISTA_BUSTE' , 'FNZ_CONTROLLI' , 'none' );
	}
    
}
