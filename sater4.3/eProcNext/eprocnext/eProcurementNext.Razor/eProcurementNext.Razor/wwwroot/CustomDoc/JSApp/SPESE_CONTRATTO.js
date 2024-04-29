var OnLoad = 0;

function DETTAGLI_OnLoad()
{
	var versato = 0.0;
	var Corrispettivo = 0.0;
	//alert( 'ok' );
	var i;
	for ( i = 0 ; i <= DETTAGLIGrid_NumRow  ; i++ )
	{
		setClassName( DETTAGLIGrid.rows[i+1].cells[0] , 'SIMPLE');
	
		for( x = 1 ; x < 8 ; x++ )
		{
			setClassName( DETTAGLIGrid.rows[i+1].cells[x] , 'SIMPLER');
		}
		
	}
	//alert( getObj( 'TYPEDOC' ).value  );

	
	if ( getObj( 'TYPEDOC' ).value == 'CHIUSURA_CONTO' )
	{
		versato = Number(opener.getObj( 'Importo' ).value);
		Corrispettivo = Number(opener.getObj( 'Corrispettivo' ).value);
	}

	
	
	if ( getObj( 'TYPEDOC' ).value == 'SPESE_CONTRATTO' )
	{
		versato = Number(opener.getObj( 'ImportoDaVersare' ).value);
		Corrispettivo = Number(opener.getObj( 'Corrispettivo' ).value);
	}
	

    
    SetTextValue(  'R0_Conto' , opener.getObj( 'Conto' ).value);
	setClassName( DETTAGLIGrid.rows[1].cells[7] , 'SIMPLEB');
    
	var onorario = 0.0;
	
	//-- calcolo il diritto di rogito
	if ( Corrispettivo > 0   &&    Corrispettivo <= 51.65 )
	{
		onorario = 6.20; //-- =(E11-B12)*C12+D12
	}
	
	if ( Corrispettivo > 51.65   &&    Corrispettivo <= 1032.91 )
	{
		onorario = ((( Corrispettivo - 51.65 ) * 2.5 ) / 100 ) + 6.2; //--=(F11-B13)*C13+D12
	}

	if ( Corrispettivo > 1032.91   &&    Corrispettivo <=  5164.57 )
	{
		onorario = ((( Corrispettivo - 1032.91 ) * 1.3 ) / 100 ) + 30.73; //-- =(G11-B14)*C14+D13
	}

	if ( Corrispettivo > 5164.57   &&    Corrispettivo <= 30987.41 )
	{
		onorario = ((( Corrispettivo - 5164.57 ) * 0.8 ) / 100 ) + 84.44; //-- =(H11-B15)*C15+D14
	}

	if ( Corrispettivo > 30987.41   &&    Corrispettivo <= 154937.07 )
	{
		onorario = ((( Corrispettivo - 30987.41 ) * 0.6 ) / 100 ) + 291.02; //-- =(I11-B16)*C16+D15
	}

	if ( Corrispettivo > 154937.07   &&    Corrispettivo <= 516456.90 )
	{
		onorario = ((( Corrispettivo - 154937.0 ) * 0.3 ) / 100 ) + 1034.72; //-- =(J11-B17)*C17+D16
	}

	if ( Corrispettivo > 516456.90    )
	{
		onorario = ((( Corrispettivo - 516456.90 ) * 0.15 ) / 100 ) + 2119.28; //-- =(K11-B18)*C18+D17
	}

	onorario = Math.round( onorario * 100.0 ) / 100.0;

	//opener.SetNumericValue( 'DirittiRogito' , onorario );
	
	SetNumericValue( 'R0_Versato' , versato );

    if ( getObj('R24_Dovute').value == '' )
    {
	    SetNumericValue( 'R24_Dovute' , onorario );
	}

    OnLoad = 1;
	CalcolaSpese( this );
    OnLoad = 0;

}

var Dovute_24 = 0;
var Dovute_25 = 0;
var Dovute_26 = 0;
var Dovute_29 = 0;


function CalcolaSpese( field )
{


    //-- per alcuni campi si tiene traccia se l'utente ha fatto una modifica esplicita 
    //-- della variabile, per evitare che venga sovrascritta dai calcoli
    if ( field.name  == 'R24_Dovute_V' ) 
        Dovute_24 = 1; 
    if ( field.name  == 'R25_Dovute_V' ) 
        Dovute_25 = 1; 
    if ( field.name  == 'R26_Dovute_V' ) 
        Dovute_26 = 1;
    if ( field.name  == 'R29_Dovute_V' ) 
        Dovute_29 = 1;


	var valore = 0;

	valore = Number(getObj( 'R2_Ruoli' ).value ) +  Number(getObj( 'R8_Ruoli' ).value );
	valore = Math.round( valore * 100.0 ) / 100.0;
	SetNumericValue( 'R3_Ruoli' , valore );
	
	valore = 0;
	
	//-- calcolo la colonna marche
	for( r = 1 ; r < 17 ; r++ )
	{
		if( r != 7 && r != 10 && r != 8 && r != 9 && r != 2 && r!= 1 && r!=11 && r!= 12 )
		{

			valore = Math.ceil( Number(getObj( 'R' + r + '_Ruoli' ).value) / 4 );
			valore = Math.round( valore * 100.0 ) / 100.0;
			SetNumericValue( 'R' + r + '_Marche' , valore );
		}



		if( r == 11 || r == 12 )
		{
			if ( getObj( 'R' + r + '_Marche_V' ).value == '' )
			{
			    valore = Math.ceil( Number(getObj( 'R' + r + '_Ruoli' ).value) / 4 );
			    valore = Math.round( valore * 100.0 ) / 100.0;
			    if( valore != 0 )
			        SetNumericValue( 'R' + r + '_Marche' , valore );
            }
		}

		if( r == 2 || r == 1 )
		{
			//if ( Number(getObj( 'R' + r + '_Marche' ).value) == 0 )
			if ( getObj( 'R' + r + '_Marche_V' ).value == '' )
			{

				valore = Math.ceil( Number(getObj( 'R' + r + '_Ruoli' ).value) / 4 );
				valore = Math.round( valore * 100.0 ) / 100.0;
				if( valore != 0 )
					SetNumericValue( 'R' + r + '_Marche' , valore );
			}
		}

		if( r == 8)
		{
			//if ( Number(getObj( 'R' + r + '_Marche' ).value) == 0 )
			if ( getObj( 'R' + r + '_Marche_V' ).value == '' )
			{
				valore = Math.ceil( Number(getObj( 'R' + r + '_Ruoli' ).value) / 2 );
				valore = Math.round( valore * 100.0 ) / 100.0;
				if( valore != 0 )
					SetNumericValue( 'R' + r + '_Marche' , valore );
			}
		}

		if(  r == 9  )
		{
			if ( getObj( 'R' + r + '_Marche_V' ).value == '' )
			{
			    valore = Math.ceil( Number(getObj( 'R' + r + '_Ruoli' ).value) / 2 );
			    valore = Math.round( valore * 100.0 ) / 100.0;
			    if( valore != 0 )
			        SetNumericValue( 'R' + r + '_Marche' , valore );
			}
		}

	}


	//-- calcolo la colonna DOVUTE
	for( r = 1 ; r < 17 ; r++ )
	{
		if( r != 7 && r != 10 )
		{
			valore = ( Number(getObj( 'R' + r + '_Marche' ).value) * Number(getObj( 'R' + r + '_ValoreMarca' ).value) );
			valore = Math.round( valore * 100.0 ) / 100.0;
			SetNumericValue( 'R' + r + '_Dovute' , valore );
		}
	}

	valore = 0.0;
	//-- calcolo la colonna la somma
	for( r = 1 ; r < 20 ; r++ )
	{
		if( r != 7 && r != 10 && r != 17 && r != 18)
		{
			valore = valore +  Number( getObj( 'R' + r + '_Dovute' ).value );
		}
	}
	valore = Math.round( valore * 100.0 ) / 100.0;
	SetNumericValue( 'R20_Saldo' , valore );
	
	//-- calcolo il valore Ruoli originali
	valore = 0.0;
	valore = valore +  Number( getObj( 'R1_Ruoli' ).value );
	valore = valore +  Number( getObj( 'R2_Ruoli' ).value );
	valore = valore +  Number( getObj( 'R8_Ruoli' ).value );
	valore = valore +  Number( getObj( 'R9_Ruoli' ).value );
	valore = valore +  Number( getObj( 'R11_Ruoli' ).value );
	valore = valore +  Number( getObj( 'R12_Ruoli' ).value );
	valore = Math.round( valore * 100.0 ) / 100.0;
	SetNumericValue( 'R25_Ruoli' , valore );
	

	//-- calcolo il valore Ruoli copie
	valore = 0.0;
	valore = valore +  Number( getObj( 'R3_Ruoli' ).value );
	valore = valore +  Number( getObj( 'R4_Ruoli' ).value );
	valore = valore +  Number( getObj( 'R5_Ruoli' ).value );
	valore = valore +  Number( getObj( 'R6_Ruoli' ).value );
	valore = valore +  Number( getObj( 'R13_Ruoli' ).value );
	valore = valore +  Number( getObj( 'R14_Ruoli' ).value );
	valore = valore +  Number( getObj( 'R15_Ruoli' ).value );
	valore = valore +  Number( getObj( 'R16_Ruoli' ).value );
	valore = Math.round( valore * 100.0 ) / 100.0;
	SetNumericValue( 'R26_Ruoli' , valore );


	valore = ( Number(getObj( 'R25_Ruoli' ).value) * Number(getObj( 'R25_ValoreMarca' ).value ));
	valore = Math.round( valore * 100.0 ) / 100.0;

    if(  OnLoad == 1 )
    {
        if( getObj('R25_Dovute').value != '' )
        {
        
            if ( valore != Number(getObj( 'R25_Dovute' ).value) )
            {
                Dovute_25 = 1;
            }
        }
    }

    if (  getObj('R25_Dovute').value == '' )
    { 
        Dovute_25 = 0;
    }

	if(  Dovute_25 == 0  )
	    SetNumericValue( 'R25_Dovute' , valore );
	    

	valore = ( Number(getObj( 'R26_Ruoli' ).value) * Number(getObj( 'R26_ValoreMarca' ).value ));
	valore = Math.round( valore * 100.0 ) / 100.0;
	
    if(  OnLoad == 1 )
    {
        if( getObj('R26_Dovute').value != '' )
        {
        
            if ( valore != Number(getObj( 'R26_Dovute' ).value) )
            {
                Dovute_26 = 1;
            }
        }
    }

    if (  getObj('R26_Dovute').value == '' )
    { 
        Dovute_26 = 0;
    }

	if(  Dovute_26 == 0  )	
	    SetNumericValue( 'R26_Dovute' , valore );


	//-- calcolo il totale DOVUTE
	valore = 0.0;
	for( r = 22 ; r < 28 ; r++ )
	{
		valore = valore +  Number( getObj( 'R' + r + '_Dovute' ).value );
	}
	valore = Math.round( valore * 100.0 ) / 100.0;
	
	
    if(  OnLoad == 1 )
    {
        if( getObj('R29_Dovute').value != '' )
        {
        
            if ( valore != Number(getObj( 'R29_Dovute' ).value) )
            {
                Dovute_29 = 1;
            }
        }
    }

    if (  getObj('R29_Dovute').value == '' )
    { 
        Dovute_29 = 0;
    }
	
	if(  Dovute_29 == 0  )	
    	SetNumericValue( 'R29_Dovute' , valore );
	
	//-- calcolo il totale SALDO
	valore = 0.0;
	for( r = 20 ; r < 29 ; r++ )
	{
		valore = valore +  Number( getObj( 'R' + r + '_Saldo' ).value );
	}
	valore = Math.round( valore * 100.0 ) / 100.0;
	SetNumericValue( 'R29_Saldo' , valore );
	
	//-- calcolo il Versato
	valore =  Number(getObj( 'R29_Dovute' ).value) + Number(getObj( 'R29_Saldo' ).value );
	valore = Math.round( valore * 100.0 ) / 100.0;
	SetNumericValue( 'R29_Versato' , valore );

	//-- calcolo il Totale Versato
	valore =  Number(getObj( 'R0_Versato' ).value) - valore;
	valore = Math.round( valore * 100.0 ) / 100.0;
	SetNumericValue( 'R31_Versato' , valore );
	
}


function UpdateAndExit( )
{
	if ( getObj( 'IDDOC' ) .value == '1' )
	{
		//Update();

	}
	
	self.close();
}


function UpdateAndExit2( )
{
    
    if ( opener.getObj('StatoRepertorio').value == 'Archiviato' )
	{
	    self.close();
	
	}
	else
    {

	    Update();

	    SaveDoc();
    	
	    self.close();
	}
	
	
}

function Update( ) 
{
		var valore = 0.0;
	
		opener.SetNumericValue( 'DirittiRogito' , getObj('R24_Dovute').value );
	
		//-- valori delle marche da 14,62
		valore = Number( getObj('R1_Marche').value ) + Number( getObj('R2_Marche').value ) + Number( getObj('R11_Marche').value ) + Number( getObj('R12_Marche').value ); 
		valore = Math.round( valore * 100.0 ) / 100.0;
		opener.SetNumericValue( 'NumMarche' , valore );

		valore = Number( getObj('R1_Dovute').value ) + Number( getObj('R2_Dovute').value ) + Number( getObj('R11_Dovute').value ) + Number( getObj('R12_Dovute').value ); 
		valore = Math.round( valore * 100.0 ) / 100.0;
		opener.SetNumericValue( 'ImportoMarche' , valore );
	
		//-- valori delle marche da 1,04
		valore = Number( getObj('R8_Marche').value ) + Number( getObj('R9_Marche').value ); 
		opener.SetNumericValue( 'NumMarche2' , valore );

		valore = Number( getObj('R8_Dovute').value ) + Number( getObj('R9_Dovute').value ); 
		opener.SetNumericValue( 'ImportoMarche2' , valore );

		//-- valori Diritti di accesso
		valore = Number( getObj('R3_Dovute').value ) + Number( getObj('R4_Dovute').value ) + Number( getObj('R5_Dovute').value ) + Number( getObj('R6_Dovute').value ) + Number( getObj('R13_Dovute').value ) + Number( getObj('R14_Dovute').value ) + Number( getObj('R15_Dovute').value ) + Number( getObj('R16_Dovute').value ); 
		opener.SetNumericValue( 'DirittiAccesso' , valore );

		//-- Diritti segreteria 
		valore = Number( getObj('R29_Dovute').value ) ; 
		opener.SetNumericValue( 'DirittiSegreteria' , valore );

		//-- Tassa registrazione 
		valore = Number( getObj('R19_Dovute').value ) ; 
		opener.SetNumericValue( 'TassaRegistrazione' , valore );

		//-- Importo complessivo
		valore = Number( getObj('R29_Versato').value ) ; 
		opener.SetNumericValue( 'ImportoComplessivo' , valore );

		//-- calcolo il Totale Versato - Saldo
		valore = Number( getObj('R31_Versato').value ) ; 
		opener.SetNumericValue( 'Saldo' , valore );

		//-- Riporto le spese postali
		valore = Number( getObj('R27_Saldo').value ) ; 
		opener.SetNumericValue( 'SpesePostali' , valore );

}