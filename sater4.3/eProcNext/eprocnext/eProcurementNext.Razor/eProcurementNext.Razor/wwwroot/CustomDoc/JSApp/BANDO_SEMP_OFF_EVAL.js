var flag=0;

var CONST_CAG_OEPV = '15532';
var CONST_CAG_COSTO_FISSO = '25532';
var CONST_CAG_PPB = '15531';
var CONST_CAG_PPA = '16291';

var CONST_CFO_Prezzo = '15536';
var CONST_CFO_Percentuale = '15537';

var Concessione = 'no';

var gModAttribPunteggio = '';

function flagmodifica()
{
	flag=1;
}

window.onload = OnLoadPage; 

function roundTo(X , decimalpositions)
{
    var i = X * Math.pow(10,decimalpositions);
    i = Math.round(i);
    return i / Math.pow(10,decimalpositions);
}

function OnLoadPage()
{
	var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;

	try { Concessione = getObjValue('Concessione') ; } catch( e ){}
    if ( Concessione == '' )
        Concessione = 'no'

    if ( DOCUMENT_READONLY == '0' )
    {
    	if( Concessione == 'no')
        {
            FilterDom( 'CriterioAggiudicazioneGara' , 'CriterioAggiudicazioneGara' , getObjValue('CriterioAggiudicazioneGara') ,   'SQL_WHERE= DMV_COD <> \'16291\' ' , ''  , 'OnChangeCriterioAggiudicazioneGara( this );' , '' );
        }
    }
    
	
	try
	{
		OnChangeCriterioAggiudicazioneGara();
	}
	catch(e)
	{
	}

	OnChange_Riparametrazione();

	OnChangeFormula(); 

	//Se il documento è editabile
	if ( DOCUMENT_READONLY == '0' )
	{
		FilterDominioEco(this);
	}
	
	
    SetCostoFisso( '0' );
    
    ShowOpenQuizAQ();

	
	//-- conservo il valore iniziale del criterio attribuzione punteggio per controllare cosa aveva nel caso in cui dovesse cambiare
	gModAttribPunteggio = getObjValue('ModAttribPunteggio') 
	
	onChange_Visualizzazione_Offerta_Tecnica();
	
	
	//nascondo TipoAggiudicazione in Funzione di GeneraConvenzione
	if ( getObjValue('GeneraConvenzione') != '1' )
	{
		if ( DOCUMENT_READONLY == '0' )
				getObj('TipoAggiudicazione').value = 'monofornitore';
			
		$("#cap_TipoAggiudicazione").parents("table:first").css({"display": "none"});
	}
	else
	{
		$("#cap_TipoAggiudicazione").parents("table:first").css({"display": ""});
	}
	
}
function onChange_Visualizzazione_Offerta_Tecnica()
{
	if ( getObjValue('Visualizzazione_Offerta_Tecnica')  != 'due_fasi' )
	{
		ShowCol( 'CRITERI' , 'Allegati_da_oscurare' , 'none' );
	}
	else
	{
		ShowCol( 'CRITERI' , 'Allegati_da_oscurare' , '' );
	}
	
}
function RefreshContent()
{
	
	RefreshDocument('');

    //--opener.ExecDocCommand( 'SEDUTE#RELOAD' );
	//--opener.ShowLoading( 'SEDUTE' );

    
}

function OnChangeCriterioAggiudicazioneGara( obj )
{
	
	var strVersione;
	var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;
    
	try 
	{
        strVersione = getObjValue('Versione');
    }
    catch (e) 
    {
        strVersione = '';
    }


	if( getObjValue( 'Versione' ) > '1' )
	{
		getObj( 'BANDO_SEMP_OFF_EVAL_CRITERI_ECO').rows[2].style.display = 'none';
		getObj( 'BANDO_SEMP_OFF_EVAL_CRITERI_ECO').rows[3].style.display = 'none';
		getObj( 'BANDO_SEMP_OFF_EVAL_CRITERI_ECO').rows[4].style.display = 'none';
	}


    var CriterioAggiudicazioneGara = getObjValue( 'CriterioAggiudicazioneGara' ) ;
	if( CriterioAggiudicazioneGara == CONST_CAG_PPB || CriterioAggiudicazioneGara == CONST_CAG_PPA ) //--prezzo più basso o più alto
	{
		
		try
		{
			//getObj('ModAttribPunteggio').disabled = true;
		}
		catch(e){}
		
        $("#cap_Conformita").parents("table:first").css({"display": ""})	        

        
        $("#cap_PunteggioEconomico").parents("table:first").css({"display": ""})	        
        $("#cap_PunteggioTecMin").parents("table:first").css({"display": "none"})	        
        $("#cap_PunteggioTecnico").parents("table:first").css({"display": "none"})	        

		//getObj( 'CRITERI_ECO' ).style.display = 'none';
		//getObj( 'CRITERI_ECO_LOTTO' ).style.display = 'none';
		//getObj( 'CRITERI_ECO_TESTATA' ).style.display = 'none';
		//getObj( 'CRITERI_ECO_RIGHE' ).style.display = 'none';	
        
		setVisibility(getObj('AQ_EREDITA_TEC'), 'none');
        setVisibility(getObj('CRITERI_AQ_EREDITA_TEC'), 'none');
        
        
		getObj( 'CRITERI_ECO' ).style.display = '';
		getObj( 'CRITERI_ECO_LOTTO' ).style.display = 'none';
											 
		
        getObj( 'CRITERI' ).style.display = 'none';
		
		getObj( 'CRITERI_ECO_TESTATA' ).style.display = '';
		getObj( 'CRITERI_ECO_RIGHE' ).style.display = '';		
	

        try{
            getObj('BANDO_SEMP_OFF_EVAL_CRITERI_ECO').rows[1].style.display = 'none';
            getObj('BANDO_SEMP_OFF_EVAL_CRITERI_ECO').rows[5].style.display = 'none';
            getObj('BANDO_SEMP_OFF_EVAL_CRITERI_ECO').rows[6].style.display = 'none';
            getObj('BANDO_SEMP_OFF_EVAL_CRITERI_ECO').rows[7].style.display = 'none';
            getObj('BANDO_SEMP_OFF_EVAL_CRITERI_ECO').rows[8].style.display = 'none';
        }catch(e){};
		
		//Se il documento è editabile
		if ( DOCUMENT_READONLY == '0' )
		{
			FilterDom( 'OffAnomale' , 'OffAnomale' , getObjValue('OffAnomale') , '' , ''  , '');
            
			SetNumericValue('PunteggioEconomico', 100);
			SetNumericValue('PunteggioTecnico', 0);
			SetNumericValue('PunteggioTecMin', 0);
			NumberreadOnly( 'PunteggioEconomico' , true );
            
		}
		
	}
	else       // COSTO FISSO O OEV
	{
		//getObj( 'cap_PunteggioEconomico' ).parentElement.parentElement.parentElement.style.display = '';

		try
		{
			//getObj('ModAttribPunteggio').disabled = false;
		}
		catch(e){}
	 
        $("#cap_Conformita").parents("table:first").css({"display": "none"})	        

        $("#cap_PunteggioEconomico").parents("table:first").css({"display": ""})	        
        $("#cap_PunteggioTecMin").parents("table:first").css({"display": ""})	        
        $("#cap_PunteggioTecnico").parents("table:first").css({"display": ""})	        
		
		
		try{
			getObj( 'Conformita' ).value = 'No';
		}
		catch(e){}
		
		getObj( 'CRITERI_ECO' ).style.display = '';
		getObj( 'CRITERI_ECO_LOTTO' ).style.display = '';
		getObj( 'CRITERI' ).style.display = '';

		getObj( 'CRITERI_ECO_TESTATA' ).style.display = '';
		getObj( 'CRITERI_ECO_RIGHE' ).style.display = '';
		


        try{
            getObj('BANDO_SEMP_OFF_EVAL_CRITERI_ECO').rows[1].style.display = '';
            getObj('BANDO_SEMP_OFF_EVAL_CRITERI_ECO').rows[5].style.display = '';
            getObj('BANDO_SEMP_OFF_EVAL_CRITERI_ECO').rows[6].style.display = '';
            getObj('BANDO_SEMP_OFF_EVAL_CRITERI_ECO').rows[7].style.display = '';
            getObj('BANDO_SEMP_OFF_EVAL_CRITERI_ECO').rows[8].style.display = '';
        }catch(e){};
				 
																			 
   		
     
    	//Se il documento è editabile
    	if ( DOCUMENT_READONLY == '0' )
    	{
            var filter='';
            if ( getObjValue('CriterioFormulazioneOfferte') == CONST_CFO_Percentuale )
            {
            	filter ='SQL_WHERE= CategorieUSO like \'%,sconto,%\' ' ;
            }
            if ( getObjValue('CriterioFormulazioneOfferte') == CONST_CFO_Prezzo )
            {
            	filter ='SQL_WHERE= CategorieUSO like \'%,prezzo,%\' ' ;
            }
    	  
    		FilterDom( 'FormulaEcoSDA' , 'FormulaEcoSDA' , getObjValue('FormulaEcoSDA') , filter , ''  , 'OnChangeFormula( this );flagmodifica();');
    		FilterDom( 'OffAnomale' , 'OffAnomale' , getObjValue('OffAnomale') , 'SQL_WHERE= tdrcodice = \'16310\' ' , ''  , '');	

			
			NumberreadOnly( 'PunteggioEconomico' , false );
			NumberreadOnly( 'PunteggioTecnico' , false );
			//NumberreadOnly( 'PunteggioTecMin' , false);
            
            // se il documento è editabile ed ho impostato il costo fisso posso solo mettere i criteri tecnici
			if( CriterioAggiudicazioneGara == CONST_CAG_COSTO_FISSO ) //Costo Fisso 
            {
                SetNumericValue('PunteggioEconomico', 0);
			    SetNumericValue('PunteggioTecnico', 100);
			    NumberreadOnly( 'PunteggioEconomico' , true );
            }
             

    	}
        
        //SetCostoFisso('1');
        SetCostoFisso('0');
		
		setVisibility(getObj('AQ_EREDITA_TEC'), '');
        setVisibility(getObj('CRITERI_AQ_EREDITA_TEC'), '');
    }	   

	//per il costo fisso oppure prezzo più alto blocco a no calcolo soglia anomalia
	if ( DOCUMENT_READONLY == '0' )
    {
        if( CriterioAggiudicazioneGara == '25532' || CriterioAggiudicazioneGara == '16291' ) 
        {
            FilterDom( 'CalcoloAnomalia' ,  'CalcoloAnomalia' , '0' , 'SQL_WHERE=tdrcodice = \'0\' ' , '' , 'onChangeCalcoloSoglia( this );'); //-- solo no
            SelectreadOnly( 'CalcoloAnomalia' , true );
            SelectreadOnly('OffAnomale',true);
        }
        else
        {
            FilterDom( 'CalcoloAnomalia' ,  'CalcoloAnomalia' , getObj('CalcoloAnomalia').value , '' , '' , 'onChangeCalcoloSoglia( this );'); 
            SelectreadOnly( 'CalcoloAnomalia' , false );
            SelectreadOnly('OffAnomale',false );            
        }
    }
	
	 
	if (strVersione < '2') 	
    {
		try 
		{
			setVisibility(getObj('CRITERI_ECO_TESTATA'), 'none');
		} catch (e) {}

		try 
		{
			setVisibility(getObj('CRITERI_ECO_RIGHE'), 'none');
		} catch (e) {}
	}
	 
	onChangeCalcoloSoglia();
	
	//se parametro in input è non definito è la chiamata dalla loadpage
	//if (obj == undefined)
		SetCostoFisso( '0' );
	//else
	//	SetCostoFisso( '1' );
        
	
	//-- se la gara non è un accordo quadro vanno nascoste le aree per l'ereditarietà dei punteggi
    var TipoSceltaContraente = '';
    var AQ_RILANCIO_COMPETITVO = '';

    try { TipoSceltaContraente = getObj('TipoSceltaContraente').value  }  catch( e) {}
    try { AQ_RILANCIO_COMPETITVO = getObjValue( 'AQ_RILANCIO_COMPETITVO') } catch( e ){};
	
	if ( TipoSceltaContraente != 'ACCORDOQUADRO' && AQ_RILANCIO_COMPETITVO != 'yes' ) 
    {
        try {
            setVisibility(getObj('AQ_EREDITA_TEC'), 'none');
            ShowCol( 'CRITERI' , 'Eredita' , 'none' );
        } catch (e) {};
    }

	if( AQ_RILANCIO_COMPETITVO != 'yes' )
    {
        try {
            setVisibility(getObj('CRITERI_AQ_EREDITA_TEC'), 'none');
			$("#cap_PunteggioTecPercEredit").parents("table:first").css({"display": "none"});
        } catch (e) {};
    }
    else
    {
        ShowCol( 'CRITERI' , 'Eredita' , 'none' );
    }
	
}




function MySaveDoc(param)
{

    var CriterioAggiudicazioneGara = getObjValue( 'CriterioAggiudicazioneGara' ) ;
	var SommaPunteggiEreditati = 0.0;
    var AQ_RILANCIO_COMPETITVO = '';
    
    try { AQ_RILANCIO_COMPETITVO = getObjValue( 'AQ_RILANCIO_COMPETITVO') } catch( e ){};
    
    //commentato ed aggiunto ai vari singoli controlli ove necessario
	//if( getObjValue( 'CriterioAggiudicazioneGara' ) == CONST_CAG_OEPV  || getObjValue( 'CriterioAggiudicazioneGara' ) == CONST_CAG_COSTO_FISSO )
	{

		var PunteggioEconomico=parseFloat(getObjValue( 'PunteggioEconomico' ));
		var PunteggioTecnico=parseFloat(getObjValue( 'PunteggioTecnico' ));
			
		if( getObjValue( 'CriterioAggiudicazioneGara' ) == CONST_CAG_OEPV )
		{
			//if ( ( PunteggioTecnico == 0 || getObjValue( 'PunteggioTecnico_V' ) == '' )  && ( CriterioAggiudicazioneGara  == CONST_CAG_OEPV  || CriterioAggiudicazioneGara  == CONST_CAG_COSTO_FISSO ) ) 	
			if ( PunteggioEconomico == 0 || getObjValue( 'PunteggioEconomico_V' ) == '')	
			{
					
				getObj('AnomalieCompilazioneCriteri_V').innerHTML = '<img src="../images/Domain/State_ERR.gif"><br><br>' + CNV( '../','Digitare un punteggio Economico superiore a 0');
				DMessageBox( '../' , 'Digitare un punteggio Economico superiore a 0' , 'Attenzione' , 1 , 400 , 300 );
				//getObj('PunteggioEconomico_V').focus();
				return -1;
			}
		}
		
		
		if ( ( PunteggioTecnico == 0 || getObjValue( 'PunteggioTecnico_V' ) == '' )  && ( CriterioAggiudicazioneGara  == CONST_CAG_OEPV  || CriterioAggiudicazioneGara  == CONST_CAG_COSTO_FISSO ) ) 	
			{
				getObj('AnomalieCompilazioneCriteri_V').innerHTML = '<img src="../images/Domain/State_ERR.gif"><br><br>' + CNV( '../','Digitare un punteggio Tecnico superiore a 0');
				DMessageBox( '../' , 'Digitare un punteggio Tecnico superiore a 0' , 'Attenzione' , 1 , 400 , 300 );
				//getObj('PunteggioTecnico_V').focus();
				return -1;
			}	
		
		if ( PunteggioEconomico + PunteggioTecnico != 100 )	
			{
				getObj('AnomalieCompilazioneCriteri_V').innerHTML = '<img src="../images/Domain/State_ERR.gif"><br><br>' + CNV( '../','La somma del punteggio tecnico e del punteggio economico deve essere 100');
				DMessageBox( '../' , 'La somma del punteggio tecnico e del punteggio economico deve essere 100' , 'Attenzione' , 1 , 400 , 300 );
				//getObj('PunteggioEconomico_V').focus();
				return -1;
			}
		
		if ( getObjValue( 'PunteggioTecMin' ) != '' &&  getObjValue( 'PunteggioTecMin' ) > PunteggioTecnico )
			{
			  getObj('AnomalieCompilazioneCriteri_V').innerHTML = '<img src="../images/Domain/State_ERR.gif"><br><br>' + CNV( '../','La soglia minima del punteggio Tecnico non puo\' essere maggiore del punteggio tecnico');  
				DMessageBox( '../' , 'La soglia minima del punteggio Tecnico non puo\' essere maggiore del punteggio tecnico' , 'Attenzione' , 1 , 400 , 300 );
				//getObj('PunteggioTecMin_V').focus();
				return -1;
			}
		
		if ( getObjValue( 'FormulaEcoSDA' )== '' && getObjValue ( 'Versione') == '' )
		{
			getObj('AnomalieCompilazioneCriteri_V').innerHTML = '<img src="../images/Domain/State_ERR.gif"><br><br>' + CNV( '../','Nella sezione dei criteri per la valutazione della busta economica selezionare il "Criterio Economica"');  
			DMessageBox( '../' , 'Nella sezione dei criteri per la valutazione della busta economica selezionare il "Criterio Economica"' , 'Attenzione' , 1 , 400 , 300 );
			//getObj('FormulaEcoSDA').focus();
			return -1;
		}
		
		if( getObj('FormulaEcoSDA').value.indexOf( ' Coefficiente X ' ) >= 0 && getObjValue ( 'Versione') == '' )
		{
			if( getObjValue('Coefficiente_X') == '' )
			{
				getObj('AnomalieCompilazioneCriteri_V').innerHTML = '<img src="../images/Domain/State_ERR.gif"><br><br>' + CNV( '../','Nella sezione dei criteri per la valutazione della busta economica selezionare un valore per il campo "Coefficiente X"');  
				DMessageBox( '../' , 'Nella sezione dei criteri per la valutazione della busta economica selezionare un valore per il campo "Coefficiente X"' , 'Attenzione' , 1 , 400 , 300 );
				//getObj('Coefficiente_X').focus();
				return -1;
			}
				
		}
		
		
		//controlli sulla griglia
		if( GetProperty( getObj('CRITERIGrid') , 'numrow') == -1  && ( CriterioAggiudicazioneGara  == CONST_CAG_OEPV  || CriterioAggiudicazioneGara  == CONST_CAG_COSTO_FISSO ))
		{
			//DocShowFolder( 'FLD_CRITERI' );	   
			//tdoc();
			getObj('AnomalieCompilazioneCriteri_V').innerHTML = '<img src="../images/Domain/State_ERR.gif"><br><br>' + CNV( '../','Nella griglia Criteri di valutazione busta tecnica deve essere presente almeno una riga.');  
			DMessageBox( '../' , 'Nella griglia Criteri di valutazione busta tecnica deve essere presente almeno una riga.' , 'Attenzione' , 1 , 400 , 300 );
			return -1;
		
		}
		
		if( GetProperty( getObj('CRITERIGrid') , 'numrow') != -1 && ( CriterioAggiudicazioneGara  == CONST_CAG_OEPV  || CriterioAggiudicazioneGara  == CONST_CAG_COSTO_FISSO ) )
		{
			var numrighe=GetProperty( getObj('CRITERIGrid') , 'numrow');
			var i=0;
			var k=0;
			var totpunteggiorighe=0;
            SommaPunteggiEreditati = 0.0;

			//alert(numrighe);
			for( i = 0 ; i <= numrighe ; i++ )
			{		

                if(  getObj( 'R' + i + '_Eredita' ).checked  )
                {
				   SommaPunteggiEreditati += parseFloat(getObjValue('R'+i+'_PunteggioMax'));
                }
				
                if(getObjValue('R'+i+'_CriterioValutazione') == '')
				{
					//DocShowFolder( 'FLD_CRITERI' );	   
					//tdoc();
					getObj('AnomalieCompilazioneCriteri_V').innerHTML = '<img src="../images/Domain/State_ERR.gif"><br><br>' + CNV( '../','Sulla griglia Criteri di valutazione il "Criterio" su ogni riga.');  
					DMessageBox( '../' , 'Sulla griglia Criteri di valutazione il "Criterio" su ogni riga.' , 'Attenzione' , 1 , 400 , 300 );
					//getObj('R'+i+'_CriterioValutazione').focus();
					return -1;	
				}
                
				if ((isNaN(parseFloat(getObjValue('R'+i+'_PunteggioMax'))) ||  parseFloat(getObjValue('R'+i+'_PunteggioMax')) == 0 ) && getObjValue('R'+i+'_CriterioValutazione') != 'ereditato')
				{
					//DocShowFolder( 'FLD_CRITERI' );	   
					//tdoc();
					getObj('AnomalieCompilazioneCriteri_V').innerHTML = '<img src="../images/Domain/State_ERR.gif"><br><br>' + CNV( '../','Sulla griglia Criteri di valutazione il punteggio per ogni singola riga deve essere maggiore di zero.');  
					DMessageBox( '../' , 'Sulla griglia Criteri di valutazione il punteggio per ogni singola riga deve essere maggiore di zero.' , 'Attenzione' , 1 , 400 , 300 );
					//getObj('R'+i+'_PunteggioMax_V').focus();
					return -1;	
				}					
				
				totpunteggiorighe=totpunteggiorighe+parseFloat(getObjValue('R'+i+'_PunteggioMax'));
				
                if (getObjValue('R'+i+'_DescrizioneCriterio')=='')
				{
					//DocShowFolder( 'FLD_CRITERI' );	   
					//tdoc();
					getObj('AnomalieCompilazioneCriteri_V').innerHTML = '<img src="../images/Domain/State_ERR.gif"><br><br>' + CNV( '../','Sulla griglia Criteri di valutazione busta tecnica inserire una descrizione su ogni riga');  
					DMessageBox( '../' , 'Sulla griglia Criteri di valutazione busta tecnica inserire una descrizione su ogni riga' , 'Attenzione' , 1 , 400 , 300 );
					//getObj('R'+i+'_DescrizioneCriterio').focus();
					return -1;
				}
				
				if(getObjValue('R'+i+'_CriterioValutazione') == 'quiz')
				{
					if(getObjValue('R'+i+'_AttributoCriterio') == '')
					{
						//DocShowFolder( 'FLD_CRITERI' );	   
						//tdoc();
						getObj('AnomalieCompilazioneCriteri_V').innerHTML = '<img src="../images/Domain/State_ERR.gif"><br><br>' + CNV( '../','Sulla griglia Criteri di valutazione busta tecnica selezionare un valore per la colonna attributo se il criterio e\' quiz.');  
						DMessageBox( '../' , 'Sulla griglia Criteri di valutazione busta tecnica selezionare un valore per la colonna attributo se il criterio e\' quiz.' , 'Attenzione' , 1 , 400 , 300 );
						//getObj('R'+i+'_AttributoCriterio').focus();
						return -1;
					}
					else
					{
						for(k=0;k<i;k++)
						{
							if(getObjValue('R'+k+'_AttributoCriterio') == getObjValue('R'+i+'_AttributoCriterio') )
							{
							//DocShowFolder( 'FLD_CRITERI' );	   
							//tdoc();
							getObj('AnomalieCompilazioneCriteri_V').innerHTML = '<img src="../images/Domain/State_ERR.gif"><br><br>' + CNV( '../','Sulla griglia Criteri di valutazione busta tecnica l\'attributo deve essere univoco.');  
							DMessageBox( '../' , 'Sulla griglia Criteri di valutazione busta tecnica l\'attributo deve essere univoco.' , 'Attenzione' , 1 , 400 , 300 );
							//getObj('R'+i+'_AttributoCriterio').focus();
							return -1;	
							}
						}
					}
					
					/*
					TxtOK( 'R' + k + '_FNZ_OPEN' );
					
					if (getObjValue('R' + k + '_Formula') == '') {
						
						getObj('AnomalieCompilazioneCriteri_V').innerHTML = '<img src="../images/Domain/State_ERR.gif"><br><br>' + CNV( '../','Sulla griglia Criteri di valutazione busta tecnica compilare il criterio Oggettivo evidenziato');  
						DMessageBox('../', 'Sulla griglia Criteri di valutazione busta tecnica compilare il criterio Oggettivo evidenziato', 'Attenzione', 1, 400, 300);
						TxtErr( 'R' + k + '_FNZ_OPEN'  );
						return -1;
						
					}*/	
					
				}
			}
			
			if( roundTo( PunteggioTecnico , 2 ) != roundTo( totpunteggiorighe , 2 ) )
			{
				//DocShowFolder( 'FLD_CRITERI' );	   
				//tdoc();
				getObj('AnomalieCompilazioneCriteri_V').innerHTML = '<img src="../images/Domain/State_ERR.gif"><br><br>' + CNV( '../','Il Punteggio Tecnico deve essere uguale alla somma dei punteggi presenti sulle righe. ');  
				DMessageBox( '../' , 'Il Punteggio Tecnico deve essere uguale alla somma dei punteggi presenti sulle righe. ' , 'Attenzione' , 1 , 400 , 300 );
				return -1;
			}
			
		}
        
        //-- se siamo su un rilancio competitivo la somma dei punteggi da ereditare è presente nella sezione specifica
        if( AQ_RILANCIO_COMPETITVO == 'yes' )
        {

			var numrighe=GetProperty( getObj('CRITERI_AQ_EREDITA_TECGrid') , 'numrow');
			var i=0;
            SommaPunteggiEreditati = 0.0;

			//alert(numrighe);
			for( i = 0 ; i <= numrighe ; i++ )
			{		
                if(  getObj( 'RCRITERI_AQ_EREDITA_TECGrid_' + i + '_Eredita' ).checked || getObj( 'RCRITERI_AQ_EREDITA_TECGrid_' + i + '_Eredita_V' ).checked   )
                {
				   SommaPunteggiEreditati += parseFloat(getObjValue('RCRITERI_AQ_EREDITA_TECGrid_'+i+'_PunteggioMax'));
                }
            }
			
			PunteggioTecPercEredit = parseFloat( getObjValue('PunteggioTecPercEredit'));
                
			if( PunteggioTecPercEredit < 0  || PunteggioTecPercEredit >  100 || isNaN(PunteggioTecPercEredit) )
			{
				DMessageBox('../', 'La "\%Ereditata" deve essere un valore compreso fra 0 e 100 compresi', 'Attenzione', 1, 400, 300);
				return -1;
			}
			
                        
        }
        
		if( CriterioAggiudicazioneGara != CONST_CAG_COSTO_FISSO )  //CONST_CAG_OEPV )
		{
			//-- controlla le righe delle formule economiche
			if ( getObjValue( 'Versione' ) != '' )
			{
				var SommaPunteggiEco = 0.0 ;
				var MancaValore = 0 ;
				var n = 1000;
				var strFormulaEco = '';
				var descrCriterioEco = '';
				var punteggioMaxEco = '';
				
				//--almeno una riga deve esistere
				if( getObj( 'RCRITERI_ECO_RIGHEGrid_0_DescrizioneCriterio' ) == null )
				{	
					ShowError( 'Per il criterio di aggiudicazione gara "Offerta economicamente piu\' vantaggiosa" e\' necessario che ci sia almeno una riga nella griglia "Criteri di valutazione busta economica" ' );
					return -1;
				}			

				//-- tutti i campi devono essere avvalorati ( eccezione per la soglia)
				for( i = 0 ; i < n && getObj( 'RCRITERI_ECO_RIGHEGrid_' + i + '_DescrizioneCriterio' ) != null ; i++ )
				{
					MancaValore = 0;
						
					// Se "Valutazione soggettiva" non sono obbligatori i campi soliti ma solo la descrizione ed il punteggio

					strFormulaEco = getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_FormulaEcoSDA');
					descrCriterioEco = getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_DescrizioneCriterio');
					punteggioMaxEco = getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_PunteggioMax');

					if ( strFormulaEco == 'Valutazione soggettiva' )
					{
						if ( descrCriterioEco == '' || punteggioMaxEco == '' )
							MancaValore = 1;
					}
					else
					{

						if( strFormulaEco == '' ) MancaValore = 1;
						if( descrCriterioEco == '' ) MancaValore = 1;
						if( punteggioMaxEco == '' ) MancaValore = 1;
						//if( getObjValue( 'RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoBase' ) == '' ) MancaValore = 1;
						if( getObjValue( 'RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoValore' ) == '' ) MancaValore = 1;
						if( getObjValue( 'RCRITERI_ECO_RIGHEGrid_' + i + '_CriterioFormulazioneOfferte' ) == '' ) MancaValore = 1;
						if( strFormulaEco.indexOf( ' Coefficiente X ' ) >= 0 && getObjValue( 'RCRITERI_ECO_RIGHEGrid_' + i + '_Coefficiente_X' ) == '' ) MancaValore = 1;
						if( strFormulaEco.indexOf(' Alfa ') >= 0 && getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_Alfa') == '') MancaValore = 1;
						//-- l'attributo di confronto è necessario se la formula lo prevede
						if ( getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoBase') == '' 
                             &&
                             BaseAstaNecessaria( strFormulaEco , getObjValue( 'RCRITERI_ECO_RIGHEGrid_' + i + '_CriterioFormulazioneOfferte' ) )      
                            )
                        { 
                            MancaValore = 'RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoBase';
                        }
	
					}	
					
					if( MancaValore == 1 )
					{	
						ShowError( 'Per ogni riga nella griglia "Criteri di valutazione busta economica" e\' necessario compilare tutti i campi' );
						return -1;
					}

					SommaPunteggiEco += parseFloat( getObjValue( 'RCRITERI_ECO_RIGHEGrid_' + i + '_PunteggioMax' ));
                    
				}
				
				//--la somma dei punti deve essere uguale al valore di testata
				if( SommaPunteggiEco != parseFloat( getObjValue( 'PunteggioEconomico' ) ) )
				{			
					ShowError( 'Il Punteggio Economico deve essere uguale alla somma dei punteggi presenti sulle righe. ');  
					return -1;
				}						
			}
		}
        
        //-- se la gara  è un accordo quadro o un rilancio  
        try
        {
            if ( getObj('TipoSceltaContraente').value == 'ACCORDOQUADRO' || AQ_RILANCIO_COMPETITVO == 'yes'  ) 
            {
                PunteggioTecMinEredit = parseFloat( getObjValue('PunteggioTecMinEredit'));
                PunteggioTecMaxEredit = parseFloat( getObjValue('PunteggioTecMaxEredit'));
                PunteggioTecPercEredit = parseFloat( getObjValue('PunteggioTecPercEredit'));
                
                //-- minimo ereditabile   0 <= min <= max 
                //-- massimo ereditabile  min < max <= somma( punti ereditati )
                //-- % ereditabile        0 < % <= 100
                
				if ( isNaN(PunteggioTecMinEredit) || isNaN(PunteggioTecMaxEredit) )
				{
					DMessageBox('../', 'Minima percentuale ereditabile e Massima percentuale ereditabile devono essere un valore compreso fra 0 e 100 compresi', 'Attenzione', 1, 400, 300);
					return -1;
				}
				
                if( PunteggioTecMinEredit < 0  || PunteggioTecMinEredit  >  PunteggioTecMaxEredit )
			    {
					ShowError( 'IL "Minimo valore ereditabile" deve essere un valore compreso fra 0 ed il "Massimo valore ereditabile"' );
					return -1;
                }
                
               /* if( PunteggioTecPercEredit < 0  || PunteggioTecPercEredit >  100  || isNaN(PunteggioTecPercEredit) )
                {
					ShowError( 'La "\%Ereditata" deve essere un valore compreso fra 0 e 100 compresi' );
					return -1;
                }
				
				
			
                if( ( PunteggioTecMaxEredit <=  PunteggioTecMinEredit  || ( PunteggioTecMaxEredit > ( SommaPunteggiEreditati * ( PunteggioTecPercEredit / 100.0 )) ) ) && AQ_RILANCIO_COMPETITVO == 'yes'  &&  PunteggioTecPercEredit != 0   )
                {
					ShowError( 'IL "Massimo valore ereditabile" deve essere un valore compreso fra il "Minimo valore ereditabile" e la percentuale della somma dei punteggi ereditati' );
					return -1;
                }
            */
            }
        }
        catch( e){}
	
	}
  
  //controllo di coerenza anomalia
  
	if (  getObjValue( 'CalcoloAnomalia' ) == '1' ){
    
		if (getObj( 'OffAnomale').value == '' ){
		  getObj('AnomalieCompilazioneCriteri_V').innerHTML = '<img src="../images/Domain/State_ERR.gif"><br><br>' + CNV( '../','Effettuare una selezione per il campo Offerte Anomale');  
		  DMessageBox( '../' , 'Effettuare una selezione per il campo Offerte Anomale' , 'Attenzione' , 1 , 400 , 300 );
			return -1;
		}
	  
	}
	
	var tmpCalcoloAnomalia = getObjValue('CalcoloAnomalia');
	var tmpCriterioAggiudicazione = getObjValue('CriterioAggiudicazioneGara');

	try
	{
		
		
		/* se la gara è economicamente vantaggiosa e si è scelto "Calcolo Anomalia" = 'si' 
			ed i campi ModalitaAnomalia_TEC e ModalitaAnomalia_ECO sono presenti sul modello */
		if ( ( tmpCriterioAggiudicazione == '15532' || tmpCriterioAggiudicazione == '25532' ) && tmpCalcoloAnomalia == '1' )
		{
			if ( getObj('ModalitaAnomalia_TEC') )
			{
				if ( getObjValue('ModalitaAnomalia_TEC') == '' || getObjValue('ModalitaAnomalia_ECO') == '')
				{
					DMessageBox('../', 'Compilare i campi \'Modalita di calcolo PT\' e \'Modalita calcolo PE\'', 'Attenzione', 1, 400, 300);
					getObj('ModalitaAnomalia_TEC').focus();
					return -1;
				}
			}
		}
	}
	catch(e)
	{
	}
  
  
	//-- verifico una incompatibilità dei punteggi sulle righe dei criteri
	if ( CheckCriteriPunteggi() == -1 ){
		DMessageBox( '../' , 'Verificare i punteggi dei criteri oggettivi, sono presenti domini o range con valori superiori rispetto al punteggio del criterio' , 'Attenzione' , 1 , 400 , 300 );
		return -1;
	}
	  	
  	
	ExecDocProcess( param);	
}



function ShowError( err )
{
	getObj('AnomalieCompilazioneCriteri_V').innerHTML = '<img src="../images/Domain/State_ERR.gif"><br><br>' + CNV( '../',err );  
	DMessageBox( '../' , err  , 'Attenzione' , 1 , 400 , 300 );
}

function EditCriterio( objGrid , Row , c )
{
    if(  getObjValue( 'R' + Row + '_CriterioValutazione' ) == 'quiz'  )
    {
		var PunteggioMax = 1;
    
       //recupero TipoGiudizioTecnico
        var TipoGiudizioTecnico  ='';
        
		try {
            var TipoGiudizioTecnico = getObj('TipoGiudizioTecnico').value;

            if (document.getElementById('ModAttribPunteggio')) 
			{
                var criterio = getObjValue('ModAttribPunteggio');

                if (criterio != '' && criterio != 'giudizio') 
				{
                    TipoGiudizioTecnico = 'number';
					if (criterio == 'punteggio' ) 
						PunteggioMax = getObjValue('R' + Row + '_PunteggioMax')
                }
            }

        } catch (e) {}
        
       if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' )
        {
            Open_Quiz( '../' , 'R' + Row + '_Formula' , 'C' , getObjValue('R' + Row + '_DescrizioneCriterio') , TipoGiudizioTecnico, 'R' + Row + '_AttributoCriterio' , PunteggioMax);
        }
        else
        {
            Open_Quiz( '../' , 'R' + Row + '_Formula' , 'V' , getObjValue('R' + Row + '_DescrizioneCriterio') , TipoGiudizioTecnico, 'R' + Row + '_AttributoCriterio' , PunteggioMax );
        }
    }
}


function EditCriterioAQ( objGrid , Row , c )
{
    if(  getObjValue( 'RCRITERI_AQ_EREDITA_TECGrid_' + Row + '_CriterioValutazione' ) == 'quiz'  )
    {
    
       //recupero TipoGiudizioTecnico
        var TipoGiudizioTecnico  ='';
        
		try {
            var TipoGiudizioTecnico = getObj('TipoGiudizioTecnico').value;

            if (document.getElementById('ModAttribPunteggio')) 
			{
                var criterio = getObjValue('ModAttribPunteggio');

                if (criterio != '' && criterio != 'giudizio') 
				{
                    TipoGiudizioTecnico = 'number';
                }
            }

        } catch (e) {}
        
        Open_Quiz( '../' , 'RCRITERI_AQ_EREDITA_TECGrid_' + Row + '_Formula' , 'V' , getObjValue('R' + Row + '_DescrizioneCriterio') , TipoGiudizioTecnico, 'RCRITERI_AQ_EREDITA_TECGrid_' + Row + '_AttributoCriterio' );

    }
}

function CRITERI_OnLoad()
{

    FilterDominio();


}

function CRITERI_AFTER_COMMAND( param )
{
	try { TipoSceltaContraente = getObj('TipoSceltaContraente').value  }  catch( e) {}
	try { AQ_RILANCIO_COMPETITVO = getObjValue( 'AQ_RILANCIO_COMPETITVO') } catch( e ){};
	FilterDominio();
   	try 
	{ 
        if ( TipoSceltaContraente != 'ACCORDOQUADRO' && AQ_RILANCIO_COMPETITVO != 'yes' ) 
        {
            ShowCol( 'CRITERI' , 'Eredita' , 'none' );
        }
    } catch( e ){};
	
	OnChange_Riparametrazione( );
	
	onChange_Visualizzazione_Offerta_Tecnica();


}

function OnChangeCriterio( obj )
{
	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
    
	var i = obj.id.split('_');

    if( getObjValue(  i[0] + '_CriterioValutazione' ) == 'quiz' )
    {
		setVisibility( getObj(  i[0] + '_AttributoCriterio' ) , '' );
		setVisibility( getObj(  i[0] + '_FNZ_OPEN' ) , '' );
		setVisibility(getObj( i[0] + '_Allegati_da_oscurare_edit_new'), '');
		setVisibility(getObj( i[0] + '_Allegati_da_oscurare_button'), '');

        try{ 
            
            //disabilito il punteggio solo se la tipologia di giudizio è a dominio 
            var TipoGiudizioTecnico  ='';
            
            try{
              var TipoGiudizioTecnico  = getObj( 'TipoGiudizioTecnico').value;
            }catch(e){};
            
			/* 
				non va più disattivato con l'introduzione dei coefficienti
            if ( TipoGiudizioTecnico != 'domain')
              getObj(  i[0] + '_PunteggioMax_V' ).disabled = true; 
            
			*/
			
        }catch(e){};
        AggiornaCriteriTecnici(  i[0] + '_Formula' , '' , '' );
           
          //FilterDom(  i[0] + '_AttributoCriterio' , 'AttributoCriterio' , getObjValue( i[0] + '_CampoTesto_1' ), 'SQL_WHERE= TipoBando = \'' + getObjValue( 'TipoBando' ) + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type not in ( 18,4,5,8 )  ' , i[0].substring(1,3)  , '');
		//Se il documento è editabile
		if (DOCUMENT_READONLY == '0') 
		{
			FilterDom(  i[0] + '_AttributoCriterio' , 'AttributoCriterio' , getObjValue( i[0] + '_CampoTesto_1' ), 'SQL_WHERE= TipoBando = \'' + getObjValue( 'TipoBando' ) + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type not in ( 18,5,8 )  ' , i[0].substring(1,3)  , '');
			
			//SE SIAMO SULLE 2 fasifaccio il filtro sull'attributo altrimenti la colonna non è visibile
			if ( getObjValue('Visualizzazione_Offerta_Tecnica')  == 'due_fasi' )
			{										
				var filtro='';
				filtro= 'SQL_WHERE= TipoBando = \'' + getObjValue('TipoBando') + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type  in ( 18 )' ;								
				SetProperty( getObj(i[0] + '_Allegati_da_oscurare'),'filter',filtro);							

			}
		}
          
    }
    else
    {
          setVisibility( getObj( i[0] + '_AttributoCriterio' ) , 'none' );
          setVisibility( getObj( i[0] + '_FNZ_OPEN' ) , 'none' );
		  setVisibility( getObj( i[0] + '_Allegati_da_oscurare_edit_new'), 'none');
		  setVisibility( getObj( i[0] + '_Allegati_da_oscurare_button'), 'none');
		  getObj( i[0] + '_AttributoCriterio' ).value = '';
          try{ 
            getObj(  i[0] + '_PunteggioMax_V' ).disabled = false; 
            
          }catch(e){};
    }


	//FilterDominio();

}

function FilterDominio()
{
    	
	//-- per tutte le righe definisco il filtro sul dominio e la presenza del comando per aprire il dialogo
    var n = 100; //-- numero righe
    var i;
    try{
        for( i = 0 ; i < n ; i++ )
        {
       
            if( getObjValue( 'StatoFunzionale' ) == 'InLavorazione' && getObjValue( 'R' + i + '_CriterioValutazione' ) == 'quiz' ) 
            {
                //FilterDom(  'R' + i + '_AttributoCriterio' , 'AttributoCriterio' , getObjValue( 'R' + i + '_CampoTesto_1' ), 'SQL_WHERE= TipoBando = \'' + getObjValue( 'TipoBando' ) + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type not in ( 18,4,5,8 ) ' , i  , '')
                FilterDom(  'R' + i + '_AttributoCriterio' , 'AttributoCriterio' , getObjValue( 'R' + i + '_CampoTesto_1' ), 'SQL_WHERE= TipoBando = \'' + getObjValue( 'TipoBando' ) + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type not in ( 18,5,8 ) ' , i  , '')
				
				//SE SIAMO SULLE 2 fasifaccio il filtro sull'attributo altrimenti la colonna non è visibile
				if ( getObjValue('Visualizzazione_Offerta_Tecnica')  == 'due_fasi' )
				{										
					var filtro='';
					filtro= 'SQL_WHERE= TipoBando = \'' + getObjValue('TipoBando') + '\' and DZT_NAME = \'MOD_OffertaTec\' and DZT_Type  in ( 18 )' ;
					SetProperty( getObj('R' + i + '_Allegati_da_oscurare'),'filter',filtro);							

				}
            }
            if( getObjValue( 'R' + i + '_CriterioValutazione' ) == 'quiz' )
            {
                  try{ setVisibility( getObj( 'R' + i + '_AttributoCriterio' ) , '' ); }catch(e){};
                  setVisibility( getObj( 'R' + i + '_FNZ_OPEN' ) , '' );
				  try {setVisibility(getObj('R' + i + '_Allegati_da_oscurare_edit_new'), '');} catch (e) {};
				  try {setVisibility(getObj('R' + i + '_Allegati_da_oscurare_button'), '');} catch (e) {};
				  try {setVisibility(getObj('R' + i + '_Allegati_da_oscurare_label'), '');} catch (e) {};
                  
                  try{ 
                  
                  
                    var TipoGiudizioTecnico  ='';
                
                    try{
                      var TipoGiudizioTecnico  = getObj( 'TipoGiudizioTecnico').value;
                    }catch(e){};
                    
					
					/*
						if ( TipoGiudizioTecnico != 'domain')
							getObj(  'R' + i + '_PunteggioMax_V' ).disabled = true; 
                    */
					
                  }catch(e){};
                  
            }
            else
            {
                  try{ setVisibility( getObj( 'R' + i + '_AttributoCriterio' ) , 'none' ); }catch(e){};
                  setVisibility( getObj( 'R' + i + '_FNZ_OPEN' ) , 'none' );
				  try {setVisibility(getObj('R' + i + '_Allegati_da_oscurare_edit_new'), 'none');} catch (e) {};
				  try {setVisibility(getObj('R' + i + '_Allegati_da_oscurare_button'), 'none');} catch (e) {};
				  try {setVisibility(getObj('R' + i + '_Allegati_da_oscurare_label'), 'none');} catch (e) {};
            }
            
            if( getObjValue( 'R' + i + '_CriterioValutazione' ) == 'ereditato' )
            {
                  setVisibility( getObj( 'R' + i + '_FNZ_DEL' ) , 'none' );
                  setVisibility( getObj( 'R' + i + '_FNZ_COPY' ) , 'none' );
            }
            
        }
    }catch(e){};
}

function ShowOpenQuizAQ()
{
    //-- per tutte le righe definisco il filtro sul dominio e la presenza del comando per aprire il dialogo
    var n = 100; //-- numero righe
    var i;
    try{
        for( i = 0 ; i < n ; i++ )
        {
       
            if( getObjValue( 'RCRITERI_AQ_EREDITA_TECGrid_' + i + '_CriterioValutazione' ) != 'quiz' )
            {
                  try{ setVisibility( getObj( 'RCRITERI_AQ_EREDITA_TECGrid_' + i + '_AttributoCriterio' ) , 'none' ); }catch(e){};
                  setVisibility( getObj( 'RCRITERI_AQ_EREDITA_TECGrid_' + i + '_FNZ_OPEN' ) , 'none' );
            }
        }
    }catch(e){};
}




//-- determino il punteggio massimo del criterio oggettivo
function AggiornaCriteriTecnici( strField , p1 , p2 )
{
    var obj = getObj( strField );
    var R = strField.split( '_' );
    var M = 0;
    var i;
    try{    
        var v = obj.value.split( '#=#' )[2].split( '#~#' )
    var l = v.length;
        for( i = 3 ; i < l ; i += 4 )
        {
            if( Number( v[i] ) > M ) M = Number( v[i] ) ;
        }
    }catch(e){};
    
    //aggiorno il punteggio solo se tipogiudiziotecnico è edit
    var TipoGiudizioTecnico  ='';
    try{
      var TipoGiudizioTecnico  = getObj( 'TipoGiudizioTecnico').value;
    }catch(e){};
    
    if ( TipoGiudizioTecnico != 'domain')
      SetNumericValue( R[0] +  '_PunteggioMax' , M );


}

function OnChangeFormula( obj , Row )
{
    try
	{
		var strFormula = getObjValue(Row + 'FormulaEcoSDA');
		SetTextValue(Row + 'FormulaEconomica', strFormula);

		if ( strFormula == 'Valutazione soggettiva' )
		{
			//Se la formula economica selezionata è Valutazione soggettiva nascondiamo i campi non utili
			try { getObj(Row + 'Coefficiente_X').style.display = 'none'; } catch(e) {}
			try { getObj(Row + 'cap_Coefficiente_X').style.display = 'none'; } catch(e) {}
			try { getObj(Row + 'Alfa_V').style.display = 'none'; } catch(e) {}
			try { getObj(Row + 'AttributoBase').style.display = 'none'; } catch(e) {}
			try { getObj(Row + 'CriterioFormulazioneOfferte').style.display = 'none'; } catch(e) {}
			try { getObj(Row + 'AttributoValore').style.display = 'none'; } catch(e) {}

		}
		else
        {
			
			try { getObj(Row + 'Coefficiente_X').style.display = ''; } catch(e) {}
			try { getObj(Row + 'cap_Coefficiente_X').style.display = ''; } catch(e) {}
			try { getObj(Row + 'Alfa_V').style.display = ''; } catch(e) {}
			try { getObj(Row + 'AttributoBase').style.display = ''; } catch(e) {}
			try { getObj(Row + 'CriterioFormulazioneOfferte').style.display = ''; } catch(e) {}
			try { getObj(Row + 'AttributoValore').style.display = ''; } catch(e) {}
		
			//if ( getObjValue( 'Versione' ) == '' )
			{

				if( strFormula.indexOf( ' Coefficiente X ' ) >= 0 )
				{
					getObj(Row + 'Coefficiente_X').style.display='';
					try{ getObj('cap_Coefficiente_X').style.display='';}catch(e){}
					
				}
				else
				{
					
					getObj(Row + 'Coefficiente_X').style.display='none';
					try{getObj(Row + 'cap_Coefficiente_X').style.display='none';}catch(e){}
					getObj(Row + 'Coefficiente_X').value = '';
					
				}
				
				/* GESTIONE DELLA COSTANTE ALFA */
				if (strFormula.indexOf(' Alfa ') >= 0)
				{		
					getObj(Row + 'Alfa_V').style.display = '';
				}
				else 
				{
					getObj(Row + 'Alfa_V').style.display = 'none';
					getObj(Row + 'Alfa_V').value = '';
					getObj(Row + 'Alfa').value = '';
				}
				
			}
		}
		
	}
	catch( e ) 
	{
	}
	
  
}


//-- 0 -- no
//-- 1 -- Dopo la soglia di sbarramento
//-- 2 -- Prima della soglia di sbarramento
function OnChange_Riparametrazione( obj )
{
    try{
        if( getObjValue( 'PunteggioTEC_100' ) <= '0' )
        {
            //-- se non viene chiesta la riparametrazione si nasconde il criterio    
            //setVisibility( getObj( 'PunteggioTEC_TipoRip' ), 'none' );
            //setVisibility( getObj( 'cap_PunteggioTEC_TipoRip' ), 'none' );
			
			$("#cap_PunteggioTEC_TipoRip").parents("table:first").css({"display": "none"});
			
            ShowCol( 'CRITERI' , 'Riparametra' , 'none' );
        
        }
        else
        {
            //setVisibility( getObj( 'PunteggioTEC_TipoRip' ), '' );
            //setVisibility( getObj( 'cap_PunteggioTEC_TipoRip' ), '' );
			$("#cap_PunteggioTEC_TipoRip").parents("table:first").css({"display": ""});
			

            if( getObjValue( 'PunteggioTEC_TipoRip' ) < 1  )
            {
                getObj( 'PunteggioTEC_TipoRip' ).value = '1';
            }
			
			if ( getObj( 'PunteggioTEC_TipoRip' ).value == '1' )
				ShowCol( 'CRITERI' , 'Riparametra' , 'none' );
			else
				ShowCol( 'CRITERI' , 'Riparametra' , '' );			
			
        }
    }catch(e){};    
}

function OnChange_RiparametrazioneCriterio( obj )
{
    if( getObjValue( 'PunteggioTEC_TipoRip' ) < 1 )
    {
        getObj( 'PunteggioTEC_TipoRip' ).value = '1';
    }

	if ( getObj( 'PunteggioTEC_TipoRip' ).value == '1' )
		ShowCol( 'CRITERI' , 'Riparametra' , 'none' );
	else
		ShowCol( 'CRITERI' , 'Riparametra' , '' );	
	
}


function onChangeCalcoloSoglia(obj)
{
	try
	{
		if (  getObjValue( 'CalcoloAnomalia' ) != '1' )
		{
			//getObj( 'OffAnomale').value='';			
			//getObj( 'OffAnomale').disabled=true;
			SetDomValue( 'OffAnomale' , '' );
			SelectreadOnly('OffAnomale',true);
		}
		else
		{
			SelectreadOnly('OffAnomale',false);
			
		}
		
		verifyModalitaDiCalcoloAnomalia();
		
	}
	catch(e)
	{
	}
	
	
	
}

function FilterDominioEco( obj )
{
	try{
		
		var n = 1000;
		var filter;

		for( i = 0 ; i < n && getObj( 'RCRITERI_ECO_RIGHEGrid_' + i + '_DescrizioneCriterio' ) != null ; i++ )
		{
			FilterDom(  'RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoBase' , 'AttributoBase' , getObjValue( 'RCRITERI_ECO_RIGHEGrid_' + i + '_CampoTesto_1' ), 'SQL_WHERE= TipoBando = \'' + getObjValue( 'TipoBando' ) + '\' and DZT_NAME = \'MOD_BandoSempl\' and DZT_Type in ( 2 ) ' , 'CRITERI_ECO_RIGHEGrid_' + i  , '');
			FilterDom(  'RCRITERI_ECO_RIGHEGrid_' + i + '_AttributoValore' , 'AttributoValore' , getObjValue( 'RCRITERI_ECO_RIGHEGrid_' + i + '_CampoTesto_2' ), 'SQL_WHERE= TipoBando = \'' + getObjValue( 'TipoBando' ) + '\' and DZT_NAME = \'MOD_Offerta\' and DZT_Type in ( 2 ) ' , 'CRITERI_ECO_RIGHEGrid_' + i  , '');
						
			//if ( getObjValue('CriterioFormulazioneOfferte') == '15537' ){ filter ='SQL_WHERE= CategorieUSO like \'%,sconto,%\' '; }
			//if ( getObjValue('CriterioFormulazioneOfferte') == '15536' ){ filter ='SQL_WHERE= CategorieUSO like \'%,prezzo,%\' ';}
			
			SetCriterioFormulazioneOfferteRow( i );
			
			/*
			if ( getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_CriterioFormulazioneOfferte') == '15537' ){ filter ='SQL_WHERE= CategorieUSO like \'%,sconto,%\' '; }
			if ( getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_CriterioFormulazioneOfferte') == '15536' ){ filter ='SQL_WHERE= CategorieUSO like \'%,prezzo,%\' ';}			
			
			FilterDom( 'RCRITERI_ECO_RIGHEGrid_' + i + '_FormulaEcoSDA' , 'FormulaEcoSDA' , getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_FormulaEcoSDA') , filter , 'CRITERI_ECO_RIGHEGrid_' + i  , 'OnChangeFormula( this , \'RCRITERI_ECO_RIGHEGrid_' + i + '_\' );flagmodifica();');
			OnChangeFormula( this , 'RCRITERI_ECO_RIGHEGrid_' + i + '_' );
			*/
		}
		
	}
	catch(e)
	{ 
		alert( 'error ' + e);
	}	
}

/*
function SetCriterioFormulazioneOfferteRow( i )
{
	var filter;
	if ( getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_CriterioFormulazioneOfferte') == '15537' ){ filter ='SQL_WHERE= CategorieUSO like \'%,sconto,%\' '; }
	if ( getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_CriterioFormulazioneOfferte') == '15536' ){ filter ='SQL_WHERE= CategorieUSO like \'%,prezzo,%\' ';}			
	
	FilterDom( 'RCRITERI_ECO_RIGHEGrid_' + i + '_FormulaEcoSDA' , 'FormulaEcoSDA' , getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_FormulaEcoSDA') , filter , 'CRITERI_ECO_RIGHEGrid_' + i  , 'OnChangeFormula( this , \'RCRITERI_ECO_RIGHEGrid_' + i + '_\' );flagmodifica();');
	OnChangeFormula( this , 'RCRITERI_ECO_RIGHEGrid_' + i + '_' );
}
*/

function CRITERI_ECO_RIGHE_AFTER_COMMAND( param )
{
    FilterDominioEco();
}

function SetCriterioFormulazioneOfferteRow( i )
{
	var filter;
	var Concessione = 'no'

	var CVO = getObjValue('RCRITERI_ECO_RIGHEGrid_' + i +'_CriterioFormulazioneOfferte') ;
    
    try { Concessione = getObjValue('Concessione') ; } catch( e ){}
    if ( Concessione == '' )
        Concessione = 'no';

	if ( CVO == '15537') {
		filter = 'SQL_WHERE= CategorieUSO like \'%,sconto,%\' and CategorieUSO like \'%,Concessioni_' + Concessione + ',%\' ';
	}

	if ( CVO == '15536') {
		filter = 'SQL_WHERE= CategorieUSO like \'%,prezzo,%\' and CategorieUSO like \'%,Concessioni_' + Concessione + ',%\' ';
	}


	FilterDom('RCRITERI_ECO_RIGHEGrid_' + i + '_FormulaEcoSDA', 'FormulaEcoSDA', getObjValue('RCRITERI_ECO_RIGHEGrid_' + i + '_FormulaEcoSDA'), filter, 'CRITERI_ECO_RIGHEGrid_' + i, 'OnChangeFormula( this , \'RCRITERI_ECO_RIGHEGrid_' + i + '_\' );flagmodifica();');
	OnChangeFormula(this, 'RCRITERI_ECO_RIGHEGrid_' + i + '_');

}



function OnChangeCriterioFormulazioneOfferte( obj )
{
	var v = obj.name.split( '_' );
	SetCriterioFormulazioneOfferteRow( v[3] );
}

function verifyModalitaDiCalcoloAnomalia()
{

	//Gli attributi ModalitaAnomalia_TEC e ModalitaAnomalia_ECO, potrebbero non esserci , gestisco con try catch
	try
	{
		var CalcoloAnomalia = getObjValue('CalcoloAnomalia');
		var CriterioAggiudicazione = getObjValue('CriterioAggiudicazioneGara');
		
		/* se la gara è economicamente vantaggiosa e si è scelto "Calcolo Anomalia" = 'si' 
			visualizzo i campi ModalitaAnomalia_TEC e ModalitaAnomalia_ECO*/
		if ( ( CriterioAggiudicazione == '15532' || CriterioAggiudicazione == '25532' ) && CalcoloAnomalia == '1' )
		{
			getObj('cap_ModalitaAnomalia_TEC').style.display = '';
			getObj('ModalitaAnomalia_TEC').style.display = '';
			
			getObj('cap_ModalitaAnomalia_ECO').style.display = '';
			getObj('ModalitaAnomalia_ECO').style.display = '';
		}
		else
		{
			getObj('cap_ModalitaAnomalia_TEC').style.display = 'none';
			getObj('ModalitaAnomalia_TEC').style.display = 'none';
			getObj('ModalitaAnomalia_TEC').value = '';
			
			getObj('cap_ModalitaAnomalia_ECO').style.display = 'none';
			getObj('ModalitaAnomalia_ECO').style.display = 'none';
			getObj('ModalitaAnomalia_ECO').value = '';
		}
	}
	catch(e)
	{
	}

}


function OnChangePunteggio(obj)
{
	
	var idpunteggio = obj.id.replace('_V','');
	var idpunteggiomin = idpunteggio.replace('PunteggioMax','PunteggioMin');
	var idpunteggiomax = idpunteggio.replace('PunteggioMin','PunteggioMax');
	var punteggiomin = getObjValue(idpunteggiomin);
	var punteggiomax = getObjValue(idpunteggiomax);
	//controllo da fare solo se ho appena digitato Punteggio min
	if ( idpunteggio.indexOf('PunteggioMin') >= 0 )
	{
		if (parseFloat(punteggiomin) < 0) 
		{
			getObj(idpunteggiomin).value='';
			getObj(idpunteggiomin + '_V').value='';
			DMessageBox('../', 'Sulla griglia Criteri di valutazione Soglia Minima Punteggio per ogni singola riga non deve essere minore di zero.', 'Attenzione', 1, 400, 300);        
			return -1;
		}
	}
	if ( idpunteggio.indexOf('PunteggioMax') >= 0 )
	{
		if (isNaN(parseFloat(punteggiomax)) || parseFloat(punteggiomax) == 0 || parseFloat(punteggiomax) <= 0) 
		{
			getObj(idpunteggiomax).value='';
			getObj(idpunteggiomax + '_V').value='';
			DMessageBox('../', 'Sulla griglia Criteri di valutazione Punteggio per ogni singola riga deve essere maggiore di zero.', 'Attenzione', 1, 400, 300);        
			return -1;
		}
	}
	if ( idpunteggio.indexOf('PunteggioMin') >= 0 )
	{
		if ( parseFloat(punteggiomax) < parseFloat(punteggiomin) ) 
		{
			getObj(idpunteggiomin).value='';
			getObj(idpunteggiomin + '_V').value='';
			DMessageBox('../', 'Inserire una soglia minima minore o uguale al punteggio', 'Attenzione', 1, 400, 300);        
			return -1;
			
		}
	}
	if ( idpunteggio.indexOf('PunteggioMax') >= 0 )
	{
		if ( parseFloat(punteggiomax) < parseFloat(punteggiomin) ) 
		{
			getObj(idpunteggiomin).value=punteggiomax;
			getObj(idpunteggiomin + '_V').value=punteggiomax;
			return -1;
			
		}	
	}
}

//nResetCampi= 0/1 se =0 svuota i campi altrimenti no
function SetCostoFisso( nResetCampi )
{

	var DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	
	$("#cap_PunteggioEconomico").parents("table:first").css({"display": ""})		
	
	//if ( getObjValue('CriterioAggiudicazioneGara') == '25532' )
	if ( getObjValue('CriterioAggiudicazioneGara') == CONST_CAG_COSTO_FISSO )
		
	{
		 //nascondere 'PunteggioEconomico' e porre a zero, rendere readonly PunteggioTecnico e porlo a 100
		 if ( DOCUMENT_READONLY == '0' )
		  {
			
			if ( nResetCampi == '1' )
			{	
				SetNumericValue('PunteggioEconomico', 0);
				SetNumericValue('PunteggioTecnico', 100);
			}
			
			NumberreadOnly( 'PunteggioTecnico' , true );
		  }
		  $("#cap_PunteggioEconomico").parents("table:first").css({"display": "none"})		  
		  //vengono nascoste le sezioni dei criteri economici CRITERI_ECO_TESTATA e CRITERI_ECO_RIGHE
		  setVisibility(getObj('CRITERI_ECO_TESTATA'), 'none');
		  setVisibility(getObj('CRITERI_ECO_RIGHE'), 'none');
	 }
	 else
	 {	 
		if ( DOCUMENT_READONLY == '0' )
		 {
			if ( nResetCampi == '1' )
			{		
				SetNumericValue('PunteggioEconomico', 0);
				SetNumericValue('PunteggioTecnico', 0);
			}
			
			NumberreadOnly( 'PunteggioTecnico' , false );
		 }
		
		//$("#cap_PunteggioEconomico").parents("table:first").css({"display": ""})		
		//setVisibility(getObj('CRITERI_ECO_TESTATA'), '');
		//setVisibility(getObj('CRITERI_ECO_RIGHE'), '');
		
	 }
	
}



function OnChangeAlfa(obj) 
{
	var idAlfa = obj.id.replace('_V','');
	var alfa = getObjValue(idAlfa);

	if ( alfa != '' )
	{
		var numberAlfa = parseFloat(alfa);
			
		/* ACCETTO VALORI > DI 0 E <> DA 1 */
		if ( numberAlfa <= 0 || numberAlfa == 1 )
		{
			obj.value = '';
			getObj(idAlfa).value = '';
			DMessageBox( '../' , 'La costante alfa deve essere un valore maggiore di 0 e diverso da 1' , 'Attenzione' , 1 , 400 , 300 );
		}
		
		
	}
	
	
}



function CriterioDel( g , r , c )
{
    if ( getObjValue( 'R' + r + '_CriterioValutazione' ) == 'ereditato')
        return;
    else
        return DettagliDel(g , r , c)
}

function CriterioCopy ( g , r , c )
{
    if ( getObjValue( 'R' + r + '_CriterioValutazione' ) == 'ereditato')
        return;
    else
        return DettagliCopy( g , r , c )
}


function OnChangeMaxEreditato( obj )
{
    //-- sul rilancio competitivo se ? cambiato il massimo ereditabile lo riportiamo sulla riga del criterio ereditato
    if ( getObjValue( 'R0_CriterioValutazione' ) == 'ereditato' )
    {
        SetNumericValue( 'R0_PunteggioMax' , getObjValue( 'PunteggioTecMaxEredit' ) );
    }  
}



function Calc_Max_Ereditabile()
{
	var AQ_RILANCIO_COMPETITVO = '';
	var check;
    try { AQ_RILANCIO_COMPETITVO = getObjValue( 'AQ_RILANCIO_COMPETITVO') } catch( e ){};    
	
	try
	{

		if ( AQ_RILANCIO_COMPETITVO == 'yes' && getObj('DOCUMENT_READONLY').value == '0' ) 
		 {
			
			var numrighe = GetProperty(getObj('CRITERI_AQ_EREDITA_TECGrid'), 'numrow');
			
			PunteggioTecPercEredit = parseFloat( getObjValue('PunteggioTecPercEredit'));
			PunteggioTecMinEredit = parseFloat( getObjValue('PunteggioTecMinEredit'));
            PunteggioTecMaxEredit = parseFloat( getObjValue('PunteggioTecMaxEredit'));
			 //PunteggioTecMinEredit <= PunteggioTecPercEredit <= PunteggioTecMaxEredit
			if( PunteggioTecPercEredit < 0  || PunteggioTecPercEredit  >  PunteggioTecMaxEredit ||  PunteggioTecPercEredit < PunteggioTecMinEredit)
			{				
				DMessageBox('../', 'La "% Ereditata" deve essere un valore compreso fra la "Minima percentuale ereditabile" ed la "Massima percentuale ereditabile"', 'Attenzione', 1, 400, 300);
				return -1;
			}
            
			
			SommaMax_Ereditabile = 0.0;

			  for (i = 0; i <= numrighe; i++) 
			  {				   
				   try {
						check = getObj( 'RCRITERI_AQ_EREDITA_TECGrid_' + i + '_Eredita_V' ).checked;
					} catch (e) {
						check = getObj( 'RCRITERI_AQ_EREDITA_TECGrid_' + i + '_Eredita' ).checked;
					}
					
				   if (check)
					{
					   SommaMax_Ereditabile += parseFloat(getObjValue('RCRITERI_AQ_EREDITA_TECGrid_'+i+'_PunteggioMax'));
					}
			  }
			  
			 SommaMax_Ereditabile= roundTo(( SommaMax_Ereditabile * ( PunteggioTecPercEredit / 100.0 )),2);
			
			if ( isNaN(parseFloat(SommaMax_Ereditabile)) )
			{
				SommaMax_Ereditabile=0.0;
			}	
			//-- sul rilancio competitivo se è cambiato il massimo ereditabile lo riportiamo sulla riga del criterio ereditato
			if ( getObjValue( 'R0_CriterioValutazione' ) == 'ereditato' )
			{
				SetNumericValue( 'R0_PunteggioMax' , SommaMax_Ereditabile );
			}
		 }			
	} catch(e){};
}


//--seleziono PREZZO - 15536
//--------------------------
//-- uno dei seguenti dati è calcolati ed ha bisogno della base asta
//--------------------------
var BaseAstaPrezzo  = [
' Sconto Corrente ',
' Massimo Sconto Offerto ',
' Sconto Offerto ',
' Sconto Migliore ',
' Sconto Peggiore ',
' Media Sconti Offerti ',
' Ribasso Corrente ',
' Massimo Ribasso Offerto ',
' Ribasso Offerto ',
' Ribasso Migliore ',
' Ribasso Peggiore ',
' Media Ribassi Offerti ',
' Valore Base Asta ',
' Percentuale Corrente ',
' Massima Percentuale Offerta ',
' Percentuale Offerta ',
' Percentuale Migliore ',
' Percentuale Peggiore ',
' Media Percentuali Offerte '
]


//--seleziono PERCENTUALE - 15537
//--------------------------
//-- uno dei seguenti dati è calcolati ed ha bisogno della base asta
//--------------------------
var BaseAstaPercentuale  =[
' Media Valori Offerti ' ,
' Massimo Valore Offerta ',
' Minimo Valore Offerta ',
' Offerta Migliore ',
' Offerta Corrente ',
' Valore Offerta ',
' Ribasso Corrente ',
' Massimo Ribasso Offerto ',
' Ribasso Offerto ',
' Ribasso Migliore ',
' Ribasso Peggiore ',
' Media Ribassi Offerti ',
' Valore Base Asta '
]

//-- se all'interno della formula trova una delle parole chiavi indicate significa che la formula ha bisogno della base asta per il calcolo
function BaseAstaNecessaria( strFormulaEco , CriterioFormulazioneOfferte )
{
    var vet ;

    if ( CriterioFormulazioneOfferte == '15536' )
    {
         vet = BaseAstaPrezzo;
    }
    else
    {
         vet = BaseAstaPercentuale;
    }

	var i = 0;
    var NumControlli = vet.length;
	for( i = 0 ; i < NumControlli ; i++ )
	{
		if ( strFormulaEco.indexOf( vet[i] ) >= 0 )
            return true;
    }
    return false;
}





function OnChangeModAttribPunteggio(obj)
{
	var ModAttribPunteggio = getObjValue('ModAttribPunteggio');
	
	//-- rettifico eventuali selezioni
	
	
	if ( ModAttribPunteggio ==  '' ) ModAttribPunteggio = 'coefficiente';
	if ( gModAttribPunteggio ==  '' ) gModAttribPunteggio = 'coefficiente';
	
	if ( gModAttribPunteggio ==  'giudizio' ) gModAttribPunteggio = 'coefficiente';
	
	//-- nel caso non sia necessaria una conversione esco
	if ( ModAttribPunteggio == gModAttribPunteggio)
	{
		return;
	}

	
	gModAttribPunteggio = ModAttribPunteggio;


	//-- verifico la presenza di criteri di valutazione tecnica oggettivi che siano per range o dominio, in tal caso rettifico ed informo l'utente
	if (GetProperty(getObj('CRITERIGrid'), 'numrow') != -1) 
	{
		
		
		var bFound = false;
		
		
		var numrighe = GetProperty(getObj('CRITERIGrid'), 'numrow');
		i = 0;
		var k = 0;
		
		for (i = 0; i <= numrighe; i++) 
		{
				
			if ( getObjValue('R' + i + '_CriterioValutazione') == 'quiz' )
			{
				
				var Formula = getObjValue('R' + i + '_Formula');
				var vet = Formula.split( '#=#' );

				if ( vet[1] == 'dominio' || vet[1] == 'range' )
				{
					bFound = true;
					var PunteggioMax = getObjValue('R' + i + '_PunteggioMax');
					var vetG = vet[2].split( '#~#' );
					var l =  vetG.length  / 4;
					var V;
					var Newformula = vet[0] + '#=#' + vet[1] + '#=#';
					
					for( j = 0 ; j < l ; j++ )
					{
						if ( j > 0 )
							Newformula = Newformula + '#~#';
						
						V = Number( vetG[j*4+3] );
						
						//-- trasformo il valore
						if ( ModAttribPunteggio == 'coefficiente' )
						{
							if ( PunteggioMax == 0 )
								vetG[j*4+3] = 0;
							else
								vetG[j*4+3] = V / PunteggioMax;
						}

						if ( ModAttribPunteggio == 'punteggio' ) 						
						{
							vetG[j*4+3] = V * PunteggioMax;
						}

						
						Newformula = Newformula + vetG[j*4+0] + '#~#' + vetG[j*4+1] + '#~#' + vetG[j*4+2] + '#~#' + vetG[j*4+3] ;

					}
					
					//-- ricompongo la formula
					getObj('R' + i + '_Formula').value = Newformula;
				}
	
			}
		}
		
		if ( bFound == true )
		{
            DMessageBox('../', 'Il cambio di \"Modalita Attribuzione Punteggio\" comporta una modifica ai criteri di valutazione tecnica oggettivi. la modifica dei punteggi inseriti è stata eseguita in automatico, si prega di verificare che il contenuto sia corretto.', 'Attenzione', 1, 400, 300);
		}
		
	}
	
}



function CheckCriteriPunteggi()
{
	var ModAttribPunteggio = getObjValue('ModAttribPunteggio');
	if( ModAttribPunteggio == '' ) ModAttribPunteggio = 'coefficiente';

	//-- verifico la presenza di criteri di valutazione tecnica oggettivi che siano per range o dominio con punteggi non corretti
	if (GetProperty(getObj('CRITERIGrid'), 'numrow') != -1) 
	{
		
		
		var numrighe = GetProperty(getObj('CRITERIGrid'), 'numrow');
		i = 0;
		var k = 0;
		
		for (i = 0; i <= numrighe; i++) 
		{
				
			if ( getObjValue('R' + i + '_CriterioValutazione') == 'quiz' )
			{
				
				var Formula = getObjValue('R' + i + '_Formula');
				var vet = Formula.split( '#=#' );

				if ( vet[1] == 'dominio' || vet[1] == 'range' )
				{
					bFound = true;
					var PunteggioMax = getObjValue('R' + i + '_PunteggioMax');
					var vetG = vet[2].split( '#~#' );
					var l =  vetG.length  / 4;
					
					for( j = 0 ; j < l ; j++ )
					{
						
						
						if ( ModAttribPunteggio == 'coefficiente' )
						{
							if ( Number( vetG[j*4+3] )  > 1 )
								return -1
						}

						if ( ModAttribPunteggio == 'punteggio' ) 						
						{
							if ( PunteggioMax < Number( vetG[j*4+3] ) )
								return -1
						}

						

					}
					
				}
	
			}
		}
		
		
	}
	return 0;
	
}