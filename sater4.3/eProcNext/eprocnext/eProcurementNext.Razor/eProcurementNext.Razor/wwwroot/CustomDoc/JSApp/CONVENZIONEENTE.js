function OPENQUOTA( objGrid , Row , c )
{
    var cod;
	var nq;
    var imp;
	try	{ 	imp=getObjValue( 'R' + Row + '_Importo'); }catch( e ) {imp = 0};

    if ( imp == 0 )
	{
	    return;
	}
    
	//-- recupero il codice della riga passata
	try{ cod = getObjValue( 'R' + Row + '_IDQUOTA'); } catch(e){cod = ''};
    if ( cod == '' )
	{
	    return;
	}
	

    ShowDocument( 'QUOTA' , cod );
}

function OPENRICHIESTA( objGrid , Row , c )

{


    var cod;
	var nq;
	var imp;
	try	{ 	imp=getObjValue( 'R' + Row + '_ImportoRichiesto'); }catch( e ) {imp = 0};
	
    if ( imp == 0 )
	{
	    return;
	}

	//-- recupero il codice della riga passata
	try{ cod = getObjValue( 'R' + Row + '_IDRICHIESTAQUOTA'); } catch(e){cod = ''};
    if ( cod == '' )
	{
	    return;
	}
	

	
	
    ShowDocument( 'RICHIESTAQUOTA' , cod );


}



function NuovaRichiestaDiAllocazione( param ){
	var idRow;
	idRow = Grid_GetIdSelectedRow( 'GridViewer' );	
	idRow = idRow.replace( /~~~/g, ',')


	//recupero row riga selezionata
	var Row = GetPositionRow('GridViewer',idRow,'self');

	if ( Row > -1 )
	{

	  var GestioneQuote = getObjValue( 'R' + Row + '_GestioneQuote'); 
	  
	  if ( GestioneQuote == 'senzaquote')
		DMessageBox( '../' , 'La convenzione e senza quote' , 'Attenzione' , 2 , 400 , 300 );  
	  else
		DASH_NewDocumentFrom( 'RICHIESTAQUOTA#CONVENZIONE#800,600' )

	}else{
	
		DMessageBox( '../' , 'Selezionare una convenzione' , 'Attenzione' , 2 , 400 , 300 );  
	  
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
			//-- prelevo il valore dell'identificativo
			objInd = getObjPage( grid + '_idRow_' + nInd , Page);
			
			if (objInd)
			{
				if ( objInd.value == idRow )
				{
					return nInd;
				}
			}
		}
		
		return -1;
	}
	catch(  e ){ return -1; 	};

}


