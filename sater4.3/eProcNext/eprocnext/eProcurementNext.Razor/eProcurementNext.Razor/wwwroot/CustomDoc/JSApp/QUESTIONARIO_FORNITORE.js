function HideAttrib()
{
       var i = 0;
		var element='';
		var valore;
		var readonly;
		
		valore = getObj( 'istestata' ).value;
		
		readonly = getObj( 'DOCUMENT_READONLY' ).value;
		
		
		
		//alert(valore);
		
		if(valore == '0')
		{
			//getObj( 'cap_Punteggio' )=false;
			try
			{
				
				if(readonly=='0')
				{
				setVisibility(getObj('cap_Punteggio'), 'none');
				setVisibility(getObj('Punteggio'), 'none');
				}
				
				else
				{
				setVisibility(getObj('cap_Punteggio'), 'none');
				setVisibility(getObj('val_Punteggio'), 'none');
				}
				//getObj('Punteggio').style.display = 'none';
				
				
				
				//Nascondo le sezioni
				setVisibility(getObj('TESTATA'), 'none');
				setVisibility(getObj('POSIZIONI_INPS'), 'none');
				setVisibility(getObj('DISPLAY_INAIL'), 'none');
				setVisibility(getObj('POSIZIONI_INAIL'), 'none');
				setVisibility(getObj('DISPLAY_CASSAEDILE'), 'none');
				setVisibility(getObj('POSIZIONI_CASSAEDILE'), 'none');
				setVisibility(getObj('DISPLAY_ABILITAZIONI'), 'none');
				
				
				
			}catch(e){};
		}
		else
		{
			for( i=0; i < DOCUMENTAZIONE_RICHIESTAGrid_EndRow+1 ; i++ )
			{
				try
				{
					setVisibility(getObj('DOCUMENTAZIONE_RICHIESTAGrid_Punteggio'), 'none');
					setVisibility(getObj('RDOCUMENTAZIONE_RICHIESTAGrid_' + i + '_Punteggio'), 'none');
				}catch(e){};
			}
		}	
		
}


function SetPunteggio()
{
		var i = 0;
		var element='';
		var valore;
		var filter = '';
		
		valore = getObj( 'istestata' ).value
		
		//alert(valore);
		
		//if(valore == '0')
		//{
			//getObj( 'cap_Punteggio' )=false;
			try
			{
				
				filter = 'SQL_WHERE= dmv_cod in ( \'-1\' , \'0\' , \'1\' , \'2\' , \'3\' , \'4\' , \'5\' , \'6\' , \'7\' , \'8\' , \'9\' , \'10\' )';

				FilterDom('Punteggio', 'Punteggio', getObjValue('Punteggio'), filter , '', '');

			}catch(e){};
		//}
		//else
		//{
			for( i=0; i < DOCUMENTAZIONE_RICHIESTAGrid_EndRow + 1 ; i++ )
			{
				try
				{
					//setVisibility(getObj('DOCUMENTAZIONE_RICHIESTAGrid_Punteggio'), 'none');
					//setVisibility(getObj('RDOCUMENTAZIONE_RICHIESTAGrid_' + i + '_Punteggio'), 'none');
					
					var conf;
					
					conf = '';
					
					conf = getObjValue('RDOCUMENTAZIONE_RICHIESTAGrid_' + i + '_TipoValutazione');
					
					if(conf == 'Peso')
						filter = 'SQL_WHERE= dmv_cod in ( \'-1\' , \'0\' , \'1\' , \'2\' , \'3\' , \'4\' , \'5\' , \'6\' , \'7\' , \'8\' , \'9\' , \'10\' )';
					else				
						filter = 'SQL_WHERE= dmv_cod in (  \'11\' , \'12\' )';
					
					//conf = getObjValue('RDOCUMENTAZIONE_RICHIESTAGrid_' + i + '_Punteggio');

					var valoreDom;


					valoreDom = getObjValue('RDOCUMENTAZIONE_RICHIESTAGrid_' + i + '_Punteggio');
					
					FilterDom('RDOCUMENTAZIONE_RICHIESTAGrid_' + i + '_Punteggio', 'Punteggio',valoreDom, filter, 'DOCUMENTAZIONE_RICHIESTAGrid_' + i, '');

					
				}catch(e){};
			}
		//}	
		
}


function OnLoadFunctions()
{  
	
	SetPunteggio();
	HideAttrib();
	
	
}
function readOnlyCheckBox() {
   return false;
}

/*
function afterProcess(param) 
{

	 if (param == 'SEND') 
	 {
	  parent.location = parent.location;
	 }

}
*/


window.onload = OnLoadFunctions;