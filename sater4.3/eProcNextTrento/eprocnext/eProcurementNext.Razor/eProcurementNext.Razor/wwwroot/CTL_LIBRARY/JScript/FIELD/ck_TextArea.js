
function TA_MaxLen( field, maxlimit ) {
  if ( field.value.length > maxlimit )
  {
    field.value = field.value.substring( 0, maxlimit );
    //alert( 'Superata la lunghezza massima' );
    return false;
  }
  else
  {
    //countfield.value = maxlimit - field.value.length;
  }
}


//-- valorizza un attributo di tipo textarea
function SetTAValue( objName , value )
{
	
	
	
	var val;
	var Field;
	var Field_V;
	
	//-- verifica se il campo è unico o un array, in tal caso lavora sul primo
	try 
	{
		Field = getObj( objName );
		
		try{
      Field.innerHTML = value;
		}catch( e ){
      Field.value = value;
    }
		
		//se la classe è fld_Evidence la cambio
		if (Field.className=='fld_Evidence')
			Field.className='Text';
			
	}catch ( e ) {
	}
	
	try 
	{
		Field_V = getObj( objName + '_V' );
		if (value=='')
			Field_V.innerHTML = ' ';
		else
			Field_V.innerHTML = value;
		
		//se la classe è fld_Evidence la cambio
		if (Field_V.className=='fld_Evidence')
			Field_V.className='Text';
			
	}catch ( e ) {
			
	}

}



function SetTAValueHTML( objName , value )
{
	
	
	
	var val;
	var Field;
	var Field_V;
	
	//-- verifica se il campo è unico o un array, in tal caso lavora sul primo
	try 
	{
		Field = getObj( objName );
		
		try{
      Field.value = value;
		}catch( e ){
      Field.value = value;
    }
		
		//se la classe è fld_Evidence la cambio
		if (Field.className=='fld_Evidence')
			Field.className='Text';
			
	}catch ( e ) {
	}
	
	try 
	{
		Field_V = getObj( objName + '_V' );
		if (value=='')
			Field_V.value = ' ';
		else
			Field_V.value = value;
		
		//se la classe è fld_Evidence la cambio
		if (Field_V.className=='fld_Evidence')
			Field_V.className='Text';
			
	}catch ( e ) {
			
	}

}