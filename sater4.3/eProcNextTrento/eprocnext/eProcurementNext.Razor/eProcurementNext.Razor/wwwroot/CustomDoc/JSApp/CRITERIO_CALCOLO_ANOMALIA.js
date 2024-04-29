function controlli (param)
{
	if (getObj('DOCUMENT_READONLY').value != '1' )
	{	
		var err = 0;
		var	cod = getObj( "IDDOC" ).value;
		
		
		if ( getObj( 'check_criterio_a' ).checked == false &&  getObj( 'check_criterio_b' ).checked == false &&  getObj( 'check_criterio_c' ).checked == false &&  getObj( 'check_criterio_d' ).checked == false &&  getObj( 'check_criterio_e' ).checked == false )
		{
			err = 1;
			TxtErr( 'check_criterio_a' );
			TxtErr( 'check_criterio_b' );
			TxtErr( 'check_criterio_c' );
			TxtErr( 'check_criterio_d' );
			TxtErr( 'check_criterio_e' );
		}
		else
		{
			TxtOK( 'check_criterio_a' );
			TxtOK( 'check_criterio_b' );
			TxtOK( 'check_criterio_c' );
			TxtOK( 'check_criterio_d' );
			TxtOK( 'check_criterio_e' );
		} 
		
		if ( getObj( 'check_criterio_e' ).checked == true )
		{
			 var ThisChecked = 'No';
			 var AllRadioOptions = document.getElementsByName('Coefficiente_Scelta_Criterio');
			for (x = 0; x < AllRadioOptions.length; x++)
            {
                 if (AllRadioOptions[x].checked && ThisChecked == 'No')
                 {
                     ThisChecked = 'Yes';
                     break;
                 } 
            }   
			if (ThisChecked == 'No' )
			{
				err = 1;
				TxtErr( 'Coefficiente_Scelta_Criterio');
			}
			else
			{
				TxtOK( 'Coefficiente_Scelta_Criterio' );
			}
					
		}
			
		
		if(  err > 0 )
		{
			
			DMessageBox( '../' , 'Per proseguire e\' necessaria la compilazione di tutti i campi evidenziati' , 'Attenzione' , 1 , 400 , 300 );
			return -1;
		}
		else
		{
			ExecDocProcess(param);
		}
	
	}
}
window.onload = campo_not_edit;

function campo_not_edit()
{
	if (getObj('DOCUMENT_READONLY').value != '1' )
	{
		if ( getObj( 'check_criterio_e' ).checked == false)
		{
			SelectreadOnly( 'Coefficiente_Scelta_Criterio' ,true);
		}
	}
	else
	{
		
		//Se esiste l'input hidden CRITERI_DAL_22_05_2017 nascondo i valori non pertinenti del dominio dei coefficienti
		//	(questo perchè essendo il modello readonly non filtriamo più i domini e con la format del dominio a radio button escono tutti i valori)
		
		if ( getObj('CRITERI_DAL_22_05_2017') )
		{
			var criteri = document.getElementsByClassName('DOM_OPT');
			
			for (var i = 0; i < criteri.length; i++) 
			{
				var innerhtml = criteri[i].innerHTML;
				
				if ( innerhtml.indexOf('0,6') == -1 && innerhtml.indexOf('0,7') == -1 && innerhtml.indexOf('0,8') == -1 && innerhtml.indexOf('0,9') == -1 )
				{
					criteri[i].style.display = 'none';
				}
			}
			
		}
		
		
	}
		
	//ricarica il chiamante dal DB per fargli capire al primo giro che esiste il documento di criterio
	//var linkedDoc = getObjValue('LinkedDoc');
	//var tipoDocChiamante = 'PDA_MICROLOTTI';

	//ReloadDocFromDB( linkedDoc , tipoDocChiamante ) ;	
	//removeDocFromMem(linkedDoc , tipoDocChiamante ) ;	
	
}

function MyExecDocProcess(param){
	
	controlli(param);	
	
}

function OnChangeCheck(obj)
{
	var name=obj.name;
	var valore=obj.value;	
	
	
	if ( name.substring(0,name.length - 2) == 'check_criterio' && valore == '1' )
	{
		 getObj('check_criterio_a').checked = false;	
		 getObj('check_criterio_b').checked = false;	
		 getObj('check_criterio_c').checked = false;	
		 getObj('check_criterio_d').checked = false;	
		 getObj('check_criterio_e').checked = false;	
		 getObj(name).checked = true;
		 if ( name == 'check_criterio_e')
		 {
			var AllRadioOptions = document.getElementsByName('Coefficiente_Scelta_Criterio');
			for (x = 0; x < AllRadioOptions.length; x++)
            {
				AllRadioOptions[x].disabled = false;
            }   
		 }
		 else
		 {
			var AllRadioOptions = document.getElementsByName('Coefficiente_Scelta_Criterio');
			for (x = 0; x < AllRadioOptions.length; x++)
            {
                AllRadioOptions[x].checked =false;
				AllRadioOptions[x].disabled = true;
            }   
		 }
		 return;
	}
}


