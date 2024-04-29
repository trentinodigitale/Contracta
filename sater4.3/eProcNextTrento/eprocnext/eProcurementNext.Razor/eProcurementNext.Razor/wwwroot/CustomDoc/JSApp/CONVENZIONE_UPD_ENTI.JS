



//window.onload = OnLoadPage; 
$( document ).ready(function() {
    OnLoadPage();
});

function OnLoadPage()
{
	
	
	var DOCUMENT_READONLY = '0';
	
	try
	{
		DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	}
	catch(e)
	{
		
	}
	
	//se il documento è editabile faccio i settaggi 
	if ( DOCUMENT_READONLY == '0' )
	{
		
		
		PLANT_OnLoad();
	}
	
	
	
	
	
	
}   

function SetFilterPlant( obj , nSvuota)
{
	//R0_AZI_Ente_edit
	//alert(obj.name);
	
	//ricavo la riga
	var vetInfoRow = obj.name.split( '_' );
	
	//alert(vetInfoRow[0] + '_' + vetInfoRow[1] );
	
	var namerow = vetInfoRow[0] + '_' + vetInfoRow[1];
	
	objBtn_Plant = getObj( namerow  + '_Plant_button') ;
	
	//se il campo visivbile allora esiste il bottone per la selezione
	
	if ( objBtn_Plant != null )
	{
		var NameRowPlant = namerow + '_Plant_extraAttrib';
		//strformat#=#M#@#filter#=##@#multivalue#=#1
		var filter = 'idaz in ( ' + getObj( namerow + '_AZI_Ente').value + ' )' ;
		getObj( NameRowPlant ).value= 'strformat#=#M#@#filter#=#SQL_WHERE= ' + filter + '#@#multivalue#=#1';
		
		//svuoto il campo
		if ( nSvuota == 1)
		{	
			getObj( namerow + '_Plant').value = '';
			getObj( namerow + '_Plant_edit_new').value = '0 Selezionati';
		}
	}
}




function PLANT_OnLoad()
{
  
	
	var DOCUMENT_READONLY = '0';
	
	try
	{
		DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	}
	catch(e)
	{
		
	}
	try
	{
		DOCUMENT_READONLY = getObj('DOCUMENT_READONLY').value;
	}
	catch(e)
	{
		
	}
	
	//Se il documento è editabile
	if (DOCUMENT_READONLY == '0')
	{
		//numRow = eval('PRODOTTIGrid_NumRow') ;
		var numRow = GetProperty( getObj('PLANTGrid') , 'numrow');
		//alert(numRow);
		for( i = 0; i <= numRow ; i++ )
		{
			
			SetFilterPlant( getObj('RPLANTGrid_' + i + '_AZI_Ente') , 0 );
			
    
		}
		
		
		
	}
	
}


function PLANT_AFTER_COMMAND( com )
{
    PLANT_OnLoad();
    
}
