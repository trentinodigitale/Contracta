function CalcolaCostoBurc( obj )
{
	
	//-- definisce il costo per il burc
	//SetNumericValue( 'CostoBurc' , getObj( 'NumRigheBollo' ).value.split('.')[0] * 1.55 );
	
	//-- richiama il processo del burc per evitare che si generino incoerenze
	ExecDocProcess( 'NEXT_BURC,RIC_PREV_PUBB,,NO_MSG' );

}


function CalcolaCostoGuri( obj )
{
	
	//-- definisce il costo per il Guri
	//SetNumericValue( 'CostoGuri' , getObj( 'NumRigheGuri' ).value.split('.')[0] * 20.24 );
	
	//-- richiama il processo del Guri per evitare che si generino incoerenze
	ExecDocProcess( 'NEXT_GURI,RIC_PREV_PUBB,,NO_MSG' );

}

function SelectPrestiti( strAREA  )
{

	var w;
	var h; 
	var Left;
	var Top;
	var strURL;
    
	w = screen.availWidth;
	h = screen.availHeight;
	Left=0;
	Top=0;

	w = 800;
	h = 600;
	Left = (screen.availWidth-w)/2;
	Top  = (screen.availHeight-h)/2;

	try
	{
		if( bProc == true )
		{
			return;
		}
	}catch( e ) {};
	

	try
	{
		

		if( strAREA == 'BURC' )
		{
			
			if( parseInt( getObj( 'NumRigheBollo' ).value) == 0 ) 
			{
				DMessageBox( '../' , "E' necessario prima indicare il numero righe uso bollo" , "ATTENZIONE", 4 , 400 , 300);
				return;
			}
			
			try
			{
				if ( getObj( 'BudgetProgettoBurc' ).value == '' )
				{
					//getObj( 'NumRigheBollo' ).value = '';
					SetNumericValue( 'NumRigheBollo' , 0 );
					DMessageBox( '../' , "Budget non calcolato, inserire nuovamente il numero righe" , "ATTENZIONE", 4 , 400 , 300);
					return 
				}
			}catch(e){};
			
			var costo = parseFloat( getObj( 'CostoBurc' ).value );
			var budget = parseFloat( getObj( 'BudgetProgettoBurc' ).value );
			var budgetTOT = parseFloat( getObj( 'BudgetPegBurc' ).value );
			
			if ( costo <= budget || costo > budgetTOT ) 
			{
				DMessageBox( '../' , 'Per il tipo di copertura non e\' richiesto prestito' , "ATTENZIONE", 4 , 400 , 300);
				return;
			}
			
			var valPrestito = costo - budget;
			
			strURL = '../../DASHBOARD/Viewer.asp?Table=RIC_PREV_PUBB_SELECT_PRESTITI_BURC&IDENTITY=Peg&OWNER=IdPfu&DOCUMENT=BURC,' + valPrestito + '&PATHTOOLBAR=../customdoc/&jscript=RIC_PREV_PUBB&AreaAdd=no&Caption=Seleziona il prestito per BURC&Height=50,100*,210&numRowForPag=1000&Sort=&SortOrder=&Exit=si';
			strURL = strURL + '&TOOLBAR=RIC_PREV_PUBB_ADD_PRESTITO&AreaFiltro=no&AreaInfo=yes&ACTIVESEL=2';
			strURL = strURL + '&FilterHide=Peg <> \'' + escape(getObj( 'Peg' ).value) + '\'';



		}
		else
		{
			if( parseInt( getObj( 'NumRigheGuri' ).value) == 0 ) 
			{
				DMessageBox( '../' , "E' necessario prima indicare il numero righe uso bollo" , "ATTENZIONE", 4 , 400 , 300);
				return;
			}

			try
			{
				if ( getObj( 'BudgetProgettoGuri' ).value == '' )
				{
					//getObj( 'NumRigheGuri' ).value = '';
					SetNumericValue( 'NumRigheGuri' , 0 );
					DMessageBox( '../' , "Budget non calcolato, inserire nuovamente il numero righe" , "ATTENZIONE", 4 , 400 , 300);
					return 
				}
			}catch(e){};


			var costo = parseFloat( getObj( 'CostoGuri' ).value );
			var budget = parseFloat( getObj( 'BudgetProgettoGuri' ).value );
			var budgetTOT = parseFloat( getObj( 'BudgetPegGuri' ).value );

			
			if ( costo <= budget || costo > budgetTOT ) 
			{
				DMessageBox( '../' , 'Per il tipo di copertura non e\' richiesto prestito' , "ATTENZIONE", 4 , 400 , 300);
				return;
			}
			
			var valPrestito = costo - budget;
			
			strURL = '../../DASHBOARD/Viewer.asp?Table=RIC_PREV_PUBB_SELECT_PRESTITI_GURI&IDENTITY=Peg&OWNER=IdPfu&DOCUMENT=GURI,' + valPrestito + '&PATHTOOLBAR=../customdoc/&jscript=RIC_PREV_PUBB&AreaAdd=no&Caption=Seleziona il prestito per GURI&Height=50,100*,210&numRowForPag=1000&Sort=&SortOrder=&Exit=si';
			strURL = strURL + '&TOOLBAR=RIC_PREV_PUBB_ADD_PRESTITO&AreaFiltro=no&AreaInfo=yes&ACTIVESEL=2';
			strURL = strURL + '&FilterHide=RDP_KeyProgetto <> \'' + escape( getObj( 'RDP_BDD_KeyProgetto' ).value )  + '\' and ID = ' + getObj( 'IDDOC' ).value;
			
			//strURL = strURL + '&FilterHide=ID = ' + getObj( 'IDDOC' ).value;
			//strURL = strURL + '&FilterHide=Peg <> \'' + escape(getObj( 'Peg' ).value) + '\'';
	
		}

		ExecFunction(  strURL    , 'SELPRESTITO' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h  );

	}
	catch( e ) 
	{
		DMessageBox( '../' , "E' necessario prima indicare il numero righe uso bollo" , "ATTENZIONE", 4 , 400 , 300);
	}
}



//-- effettua il calcolo degli importi selezionati
function GridViewer_ChangeSel( ) 
{
	
	var vTotal = 0;
	var sel;
	
	//ciclo su tutte le righe per prendere i valori dei residui selezionati
	for( i = 0 ; i <= GridViewer_NumRow ; i++)
	{
		sel = eval( 'GridViewer_SelectedRow[ ' +  i  + '];' );
		if ( sel == 1 )
		{
			vTotal = vTotal + parseFloat( getObj( 'R' + i + '_RDA_ResidualBudget' )[0].value );
		}
	
	}
	
	parent.ViewerInfo.SetNumericValue( 'Total' , vTotal );
	
	//-- recupera il valore del prestito
	var v = getObj('DOCUMENT').value.split(',',10);
	
	var Prestito = parseFloat( v[1] );
	
	/*
	parent.ViewerInfo.setClassName('Total_V', 'Fld_Number');
	
	
	if( vTotal < Prestito )
	{
		parent.ViewerInfo.setClassName('Total_V', 'Fld_Number_NEG');
	}
	
	if( vTotal > Prestito )
	{
		parent.ViewerInfo.setClassName('Total_V', 'Fld_Number_POS');
	}
	*/
	return vTotal;
	//alert( 'Diff = ' + (Prestito - vTotal));

	
}

function ViewerAddPrestitoDOC()
{
	//-- recupera il tipo
	var v = getObj('DOCUMENT').value.split(',',10);
	var vTotal = 0;//GridViewer_ChangeSel();

	var Prestito = parseFloat( v[1] );

  alert(Prestito);
    
	
	//-- recupera i peg/prog selezionati
	var sel = '';//Grid_GetIdSelectedRow( 'GridViewer' );
	
	var i;
	var result = '';
	var NumRow = eval( 'GridViewer_EndRow;' );
	var app = '';
	var valRow = 0;


    //-- inserisce la riga sul peg base
    
    result = parent.opener.getObj( 'Peg' ).value ;
    if( v[0] == 'BURC' )
    {
	    result = result + '**' + (parseFloat( parent.opener.getObj( 'CostoBurc' ).value ) - parseFloat( Prestito ));
	    result = result + '**' + parent.opener.getObj( 'RDP_BDD_KeyProgetto' ).value + '**' + parent.opener.getObj( 'RDP_BDD_id' ).value ;
	    result = result + '**' + parseFloat( parent.opener.getObj( 'BudgetProgettoBurc' ).value ) ;
	    
    }
    else
    {
	    result = result + '**' + (parseFloat( parent.opener.getObj( 'CostoGuri' ).value ) - parseFloat( Prestito ));
	    result = result + '**' + parent.opener.getObj( 'RDP_BDD_KeyProgetto' ).value + '**' + parent.opener.getObj( 'RDP_BDD_id' ).value ;
	    result = result + '**' + parseFloat( parent.opener.getObj( 'BudgetProgettoGuri' ).value ) ;
	  }
    
    
	
	for ( i = 0 ; i <= NumRow && vTotal < Prestito; i++ )
	{
		try {
			if( eval( 'GridViewer_SelectedRow[ ' + ( i  ) + '];' ) == 1 )
			{
				
				app = GetIdRow( 'GridViewer' , i , '' );
				if ( app != '' )
				{
					if ( result != '' ) result = result +  '~~~';
					
					result = result + app;
					valRow = parseFloat( getObj( 'R' + i + '_RDA_ResidualBudget' )[0].value );
					if(  vTotal + valRow < Prestito )
					{
						vTotal = vTotal + valRow;
						result = result + '**' + valRow;
						result = result + '**' + getObj( 'R' + i + '_RDP_KeyProgetto' )[0].value;
						result = result + '**' + getObj( 'R' + i + '_RDP_BDD_id' )[0].value;
						result = result + '**' + parseFloat( getObj( 'R' + i + '_RDA_ResidualBudget' )[0].value ) ;
					}
					else
					{
						//-- pre l'ultima riga prendo solo la quota necessaria
						result = result + '**' + ( Prestito - vTotal );
						result = result + '**' + getObj( 'R' + i + '_RDP_KeyProgetto' )[0].value;
						result = result + '**' + getObj( 'R' + i + '_RDP_BDD_id' )[0].value;
						result = result + '**' + parseFloat( getObj( 'R' + i + '_RDA_ResidualBudget' )[0].value ) ;
						vTotal = Prestito;
						
					}
					

				}
			}
		}catch(e){
		}
	}

	if( vTotal < Prestito )
	{
		DMessageBox( '../CTL_LIBRARY/' , 'Il budget selezionato non e\' sufficiente' , "ATTENZIONE", 4 , 400 , 300);
		return;
	}

	
	parent.opener.DocumentAddPrestito( v[0] , result );
	
	parent.close();

}

function DocumentAddPrestito( sezione , selezione )
{
	if( sezione == 'BURC' )
	{
		var costo = parseFloat( getObj( 'CostoBurc' ).value );
		var budget = parseFloat( getObj( 'BudgetProgettoBurc' ).value );
		ExecDocCommand2( 'CUSTOMSECTION' , sezione , 'Sel=' + escape( selezione ) + '&Residuo=' + (costo - budget)   );
		
		SetTextValue( 'CoperturaBurc_lbl' , 'Si, utilizzando altri Progetti' );
		getObj('CoperturaBurc').value = 'Si - Peg';
		
		//-- aggiorna la dicitura per il guri
		if ( getObj('CoperturaGuri').value == 'Si - Peg' )
		{
			getObj('CoperturaGuri').value = 'No - Peg';
			SetTextValue( 'CoperturaGuri_lbl' , 'No, prova con altri Progetti' );
		}

		
		
		
	}
	else
	{
		var costo = parseFloat( getObj( 'CostoGuri' ).value );
		var budget = parseFloat( getObj( 'BudgetProgettoGuri' ).value );
		ExecDocCommand2( 'CUSTOMSECTION' , sezione , 'Sel=' + escape( selezione ) + '&Residuo=' + (costo - budget)   );

		SetTextValue( 'CoperturaGuri_lbl' , 'Si, utilizzando altri Progetti' );
		getObj('CoperturaGuri').value = 'Si - Peg';

	}
	
}


function DocumentPrevediMandato( sezione , selezione )
{
	if( sezione == 'BURC' )
	{
		var costo = parseFloat( getObj( 'CostoBurc' ).value );
		var budget = parseFloat( getObj( 'BudgetProgettoBurc' ).value );
		ExecDocCommand2( 'CUSTOMSECTION' , sezione , 'Sel=' + escape( selezione ) + '&Residuo=' + (costo - budget)   );
		
		SetTextValue( 'CoperturaBurc_lbl' , 'No, prevedere il mandato in determina' );
		getObj('CoperturaBurc').value = 'No - Mandato';
		
		//-- aggiorna la dicitura per il guri
		//costo = parseFloat( getObj( 'CostoGuri' ).value );
		//budget = parseFloat( getObj( 'BudgetProgettoGuri' ).value );
		/*
		if ( getObj('CoperturaGuri').value == 'Si - Peg' )
		{
			getObj('CoperturaGuri').value = 'No - Peg';
			SetTextValue( 'CoperturaGuri_lbl' , 'No, prova con altri Progetti' );
		}
		*/
		getObj('CoperturaGuri').value = '';
		SetTextValue( 'CoperturaGuri_lbl' , '' );
		
		SetNumericValue( 'NumRigheGuri' , 0 );
		SetNumericValue( 'CostoGuri' , 0 );
		SetNumericValue( 'BudgetProgettoGuri' , 0 );
		SetNumericValue( 'BudgetPegGuri' , 0 );
		
		
	}
	else
	{
		var costo = parseFloat( getObj( 'CostoGuri' ).value );
		var budget = parseFloat( getObj( 'BudgetProgettoGuri' ).value );
		ExecDocCommand2( 'CUSTOMSECTION' , sezione , 'Sel=' + escape( selezione ) + '&Residuo=' + (costo - budget)   );

		SetTextValue( 'CoperturaGuri_lbl' , 'No, prevedere il mandato in determina' );
		getObj('CoperturaGuri').value = 'No - Mandato';
	}
	
}



function PrevedereMandato()
{
	//-- recupera il tipo
	var v = getObj('DOCUMENT').value.split(',',10);
	
	var result = '';


	
	parent.opener.DocumentPrevediMandato( v[0] , result );
	
	parent.close();


}

function OpenQuotidiani ()
{
	alert ('Utente non abilitato alla funzione')
}