function OpenLevel( objGrid , Row , c )
{
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );
	
    var loc = getObjValue( 'QueryString' );
    var loc2 = '';
    
    loc=loc.replace(/%20/g," ");
    
    var n=loc.indexOf("&FilterHide=");
    {
        
        var j=loc.indexOf("&" , n + 1);
        var x=loc.indexOf(" and " , n + 1);
        if ( x < 0 ) 
        {
            x=loc.indexOf("&" , n + 1);
        }
        
        loc2 = loc.substring( 0 , n ) + loc.substring( j , 5000 ) + '&FilterHide=' + loc.substring( n + 12 , x ) + ' and ' + cod;
    }
    if ( isSingleWin() )
	{
		self.location = 'Viewer.asp?' + loc2;
	}
	else
	{
		self.location = 'ViewerGriglia.asp?' + loc2;
	}
    
    



}