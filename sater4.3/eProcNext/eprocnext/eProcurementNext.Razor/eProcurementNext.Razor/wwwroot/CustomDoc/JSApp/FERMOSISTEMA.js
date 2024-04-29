
$( document ).ready(function() {
    DisplaySection();
});


function DisplaySection ()
{
	
	setVisibility(getObj('TESTATA' ), 'none');
	setVisibility(getObj('AVVISO' ), 'none');
	
	//visualizzo la sezione corretta a seconda del valore del campo fermo/sistema
	//alert('visualizzo la sezione coerente con il valore selezionato');
	if ( getObjValue('Fermo_Avviso')  == 'fermosistema' )
	{
		setVisibility(getObj('TESTATA'), '');
		
	}
	else if ( getObjValue('Fermo_Avviso')  == 'avviso' )
	{
		setVisibility(getObj('AVVISO' ), '');
	}
}

