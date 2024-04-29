

function ApriDoc(){
	
	if ( GridViewer_NumRow == 0 )
	{
		//apro ildocumento
		OpenDocument('GridViewer' , 0 , 0 );
	  
    //chiudo la lista
    top.close(); 	
	}
}



window.onload = ApriDoc ;