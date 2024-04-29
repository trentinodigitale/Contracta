
/*
function ChangeTipoContratto( obj ) 
{ 
  if ( getObjValue( 'TipoEstensione' ) == 'Altro' ) 
  {    
    $( "#cap_PercEstensione" ).parents("table:first").css({"display":"block"})
	$( "#cap_ImportoEstensionedigitato" ).parents("table:first").css({"display":"block"})	
	
    if ( getObj('Motivazione').value == 'Sesto Quinto' )
	{
		getObj('Motivazione').value ='';
	}
  }
  else
  {  
	getObj( 'ImportoEstensionedigitato' ).value='';
	getObj( 'ImportoEstensionedigitato_V' ).value='';
	getObj( 'PercEstensione' ).value='';
	getObj( 'PercEstensione_V' ).value='';
	$( "#cap_PercEstensione" ).parents("table:first").css({"display":"none"})
	$( "#cap_ImportoEstensionedigitato" ).parents("table:first").css({"display":"none"})	
		
		 if (getObjValue( 'TipoEstensione' ) == 'Sesto\\Quinto')
		 {
		   getObj('Motivazione').value='Sesto Quinto';
		}
	}

controllorighe();	
  
}
  
*/

function SetEstensioneAltro()
{  	
		SetNumericValue( 'ImportoEstensionedigitato' , 0 );
		controllorighe();  
}  
function SetEstensioneImporto()
{
		SetNumericValue( 'PercEstensione' , 0 );
		controllorighe();
}

/*	
function TESTATA_OnLoad()
{  
  if ( GetProperty( getObj( 'val_' + 'TipoEstensione' ) , 'value' ) != 'Altro' )
  {  
 
    $( "#cap_PercEstensione" ).parents("table:first").css({"display":"none"})
	$( "#cap_ImportoEstensionedigitato" ).parents("table:first").css({"display":"none"})	
	
  }
  
}
*/

function controllorighe() 
{
var numrrowdoc = Number(GetProperty(getObj('CAPIENZA_LOTTIGrid') , 'numrow') );

var t=0;	

var Total=0;
var ImportoEstensione=0;
var a;
var b;
var ImportoEstensionedigitato=0;

	if(   numrrowdoc  >= 0 )
    {
		for (t=0;t<numrrowdoc+1;t++)
		{
			if ( getObj('RCAPIENZA_LOTTIGrid_' + t + '_Seleziona').value == 'escludi')
			{
				SetNumericValue( 'RCAPIENZA_LOTTIGrid_' + t + '_Estensione' , 0 );
				a=Number(getObj('RCAPIENZA_LOTTIGrid_' + t + '_Importo').value );
				SetNumericValue( 'RCAPIENZA_LOTTIGrid_' + t + '_Finale' , a );
				
			}
			if ( getObj('RCAPIENZA_LOTTIGrid_' + t + '_Seleziona').value == 'includi')
			{
			  /* 
				if (getObjValue( 'TipoEstensione' ) == 'Sesto\\Quinto')
				{
					a= Number(getObj('RCAPIENZA_LOTTIGrid_' + t + '_Importo').value );
					b=a/5;
					SetNumericValue( 'RCAPIENZA_LOTTIGrid_' + t + '_Estensione', b );
					SetNumericValue( 'RCAPIENZA_LOTTIGrid_' + t + '_Finale' , (a+b) );		
				}
				*/
				
				//if ( getObjValue( 'TipoEstensione' ) == 'Altro' ) 
				//{
					if ( Number(getObj( 'PercEstensione' ).value ) > 0 )
					{
						a= Number(getObj('RCAPIENZA_LOTTIGrid_' + t + '_Importo').value );
					  b=a * parseInt(Number(getObj( 'PercEstensione' ).value)) / 100;
						SetNumericValue( 'RCAPIENZA_LOTTIGrid_' + t + '_Estensione', b );
						SetNumericValue( 'RCAPIENZA_LOTTIGrid_' + t + '_Finale' , (a - b) );	
					
					}
					if ( Number(getObj( 'ImportoEstensionedigitato' ).value ) > 0 )
					{
						a= Number(getObj('RCAPIENZA_LOTTIGrid_' + t + '_Importo').value );
						b= Number(getObj( 'ImportoEstensionedigitato' ).value );
						SetNumericValue( 'RCAPIENZA_LOTTIGrid_' + t + '_Estensione', b );
						SetNumericValue( 'RCAPIENZA_LOTTIGrid_' + t + '_Finale' , (a - b) );	
					
					}
					
					if  ( Number(getObj( 'PercEstensione' ).value ) == 0 && Number(getObj( 'ImportoEstensionedigitato' ).value ) == 0  )
					{
						SetNumericValue( 'RCAPIENZA_LOTTIGrid_' + t + '_Estensione', 0 );
						a=Number(getObj('RCAPIENZA_LOTTIGrid_' + t + '_Importo').value );
						SetNumericValue( 'RCAPIENZA_LOTTIGrid_' + t + '_Finale' , a );
					}
				//}				
				
				ImportoEstensione=Number(ImportoEstensione) + Number(getObj('RCAPIENZA_LOTTIGrid_' + t + '_Estensione').value);
				
			}
			
		}	
	}
	
	
	SetNumericValue( 'ImportoEstensione' , ImportoEstensione );
	SetNumericValue( 'Total' , Number(getObj('Vaue_Originario').value) -  ImportoEstensione );
	
	
}


window.onload = OnLoadPage; 

function OnLoadPage()
{
	//TESTATA_OnLoad();
	controllorighe();

}