

var AF_CHAT_OBJ = { "Title" :"" , "Chat":"" , "LastTime":"" , "CurRoom":"" , "ROOMS":[] , "Win":"Close" , "Service":false  , "ixCurRoom":-1 , "NumNotRead":0 }
var CHAT_TimeRefresh = 1000;
var CHAT_OUT_SESSION = 0;
//-- verifico se attivare il servizio di chat

function AF_CHAT_OpenDrawer() {
    let innerHtmlChat = document.getElementById("AF_CHAT_WIN").innerHTML;
    openDrawer(
        innerHtmlChat,
        false,
        "CHAT",
        "",
        false,
        true,
        false,
        null,
        false);

    $("#AF_CHAT_ROOM").width('unset');
    $("#AF_CHAT_ROOMS").height($("#rightArea").height() - 80);
   

}

function AF_CHAT_StartService( )
{
    if (typeof isFaseII !== 'undefined' && isFaseII) {
        let buttonChat = document.getElementById("buttonChat");
        if (buttonChat)
            buttonChat.onclick = AF_CHAT_OpenDrawer;
    }
    
    $( function() { $( "#AF_CHAT_WIN" ).dialog({  "autoOpen": false  , "height": 800,   width: 850,  resize: function( event, ui ) { AF_CHAT_Resize( ui ); }  });  } );    
    $('#AF_CHAT_WIN').on('dialogclose', function(event) { AF_CHAT_OBJ.Win = 'Close';  });
     
     
    AF_CHAT_Resize();

    AF_CHAT_OBJ.Win = 'Close';
    //$( "#AF_CHAT_WIN" ).dialog( "close" );
	$( "#AF_CHAT_WIN" ).dialog().dialog( "close" );
    
    
    var nocache = new Date().getTime();
	var ajax2 = GetXMLHttpRequest(); 
	
	if(ajax2)
	{

		ajax2.open("GET", pathRoot + 'CTL_Library/CHAT/Chat.asp?ACTION=&ROOM=&TIME=&nocache=' + nocache, true);

		ajax2.onreadystatechange = function( ) 
		{
			if(ajax2.readyState == 4 || ajax2.status == 200) 
			{
				var txt =  ajax2.responseText;
                if ( txt != '{}' && txt != '' )
                {
                    if ( AF_CHAT_OBJ.Service == false )
                    {
                        AF_CHAT_OBJ.Service = true;
                        window.setInterval ( AF_CHAT_UpdateWin ,CHAT_TimeRefresh);
                    
                        getObj( "AF_CHAT_ICO" ).style.display = '';
                        getObj( "AF_CHAT_WIN" ).style.display = '';
                    }                 
				}
			}
		}

		ajax2.send(null);
    }
}

//-- verifica la necessità di avviare il  servizio per le chat

setTimeout(function(){ AF_CHAT_StartService(); }, 500);




//-- Aggiorna la finestra delle chat
function AF_CHAT_UpdateWin( )
{

    //se sono andato fuori sessione evito altre chiamate
	if ( CHAT_OUT_SESSION == 1 )
		return;
	
     //for( i = 0 ; i < 1000 ; i++ )       TEST
     {
        var nocache = new Date().getTime();
    	var ajax2 = GetXMLHttpRequest(); 
        
        
        var objDIV_Name , curRoom , curLastTime ;
    
        objDIV_Name = 'AF_CHAT_ROOM';
        curRoom = AF_CHAT_OBJ.CurRoom;
        curLastTime = AF_CHAT_OBJ.LastTime;
    	
    	if(ajax2)
    	{
    
    		ajax2.open("GET", pathRoot + 'CTL_Library/CHAT/Chat.asp?ACTION=&ROOM=' + escape( AF_CHAT_OBJ.CurRoom ) + '&TIME=' + escape( AF_CHAT_OBJ.LastTime ) + '&nocache=' + nocache, true);
    
    		ajax2.onreadystatechange = function( ) 
    		{
    			if(ajax2.readyState == 4 /*|| ajax2.readyState == 3*/) 
    			{
    				if (ajax2.status == 200) 
    				{
    					var txt =  ajax2.responseText;
                        
						//se ritorna vuoto sono fuori sessione
						if ( txt == '' )
							CHAT_OUT_SESSION = 1 ;

                        if ( txt != '{}' &&  txt != '' )
                        { 
                            var obj = JSON.parse(txt);
        
                            
                            try{
                                if (  obj.CHAT != undefined && ( AF_CHAT_OBJ.LastTime == '' || AF_CHAT_OBJ.LastTime < obj.LastTime ) )
                                {
                                    //-- accoda il nuovo contenuto alla chat corrente                         
                                    objRoom = getObj(objDIV_Name);
                                    if( AF_CHAT_OBJ.LastTime == '')
                                    {
                                        objRoom.innerHTML = ''; 
                                    }
                                    //AF_CHAT_MSG_NOT_READ       -->  AF_CHAT_MSG_READED
                                    var html = objRoom.innerHTML; 
                                    html = html.replace(/AF_CHAT_MSG_NOT_READ/g, 'AF_CHAT_MSG_READED');
                                    
                                    objRoom.innerHTML = html +  obj.CHAT;
                                    
                                    //-- mi posiziono in coda per mostrare l'ultimo messaggio arrivato
                                    setTimeout( function() { AF_CHAT_Show_Last( objDIV_Name )  } , 1 );
                                }
                            
                            } catch(e){}
                            
                            //-- aggiorna le rooms se ci sono novità
                            try
                            { 
                                if( obj.ROOMS.length > 0 )
                                    AF_CHAT_OBJ.ROOMS = obj.ROOMS;
                            }catch(e) {}
                            
                            //-- aggiorna la data di ultimo aggiornamento
                            try 
                            { 
                                if ( obj.LastTime != '' && obj.LastTime != undefined )  
                                    AF_CHAT_OBJ.LastTime = obj.LastTime;  
                            } catch(e) {}
                            
                            //-- aggiorno il titolo della stanza corrente
                            try
                            { 
                                if ( obj.Title != '' &&  obj.Title != undefined )  
                                    AF_CHAT_OBJ.Title = obj.Title;  
                            } catch(e) {}
                            
                            
                            //-- recupero il numero di messaggi non letti se inviato dal server
                            try
                            { 
                                if ( obj.NumNotRead != '' &&  obj.NumNotRead != undefined )  
                                    AF_CHAT_OBJ.NumNotRead = obj.NumNotRead;  
                            } catch(e) {}
    
        
                            //-- aggiorno l'elenco delle conversazioni
                            AF_CHAT_DrawContent( AF_CHAT_OBJ ); 
                        }                    
    				}
    			}
    
    		}
    
    		ajax2.send(null);
        }
    }
}



//-- aggiorno la DIV della conversazione
function AF_CHAT_UpdateDIV( DIV_Name ,curRoom , curLastTime )
{
	var nocache = new Date().getTime();
	var ajax2 = GetXMLHttpRequest(); 
    
    
    var objDIV_Name , time ;

    objDIV_Name = DIV_Name;
    
    time = curLastTime('');
	
	if(ajax2)
	{

		ajax2.open("GET", pathRoot + 'CTL_Library/CHAT/Chat.asp?ACTION=GET_MESSAGES&ROOM=' + escape( curRoom ) + '&TIME=' + escape( time ) + '&nocache=' + nocache, true);

		ajax2.onreadystatechange = function( ) 
		{
			if(ajax2.readyState == 4 /*|| ajax2.readyState == 3*/) 
			{
				if (ajax2.status == 200) 
				{
					var txt =  ajax2.responseText;
                    
                    if ( txt != '{}' &&  txt != '' )
                    { 
                        var obj = JSON.parse(txt);
    
                        
                        try{
                            if (  obj.CHAT != undefined && ( time == '' || time < obj.LastTime ) )
                            {
                                //-- accoda il nuovo contenuto alla chat corrente                         
                                objRoom = getObj(objDIV_Name);
                                if( time == '')
                                {
                                    objRoom.innerHTML = ''; 
                                }
                                
                                //objRoom.innerHTML = objRoom.innerHTML +  obj.CHAT;
                                //AF_CHAT_MSG_NOT_READ       -->  AF_CHAT_MSG_READED
                                var html = objRoom.innerHTML; 
                                html = html.replace(/AF_CHAT_MSG_NOT_READ/g, 'AF_CHAT_MSG_READED');
                                
                                objRoom.innerHTML = html +  obj.CHAT;
															
                                //objRoom.innerHTML = '<div id="NASCONDI_PARTECIPANTI" class="CHAT_NASCONDI_PARTECIPANTI" onclick="javascript:CHAT_DISPLAY_PARTECIPANTI(\'HIDE\')";>Nascondi Partecipanti</div>' 
								//objRoom.innerHTML = objRoom.innerHTML + '<div style="display:none;" id="VISUALIZZA_PARTECIPANTI" class="CHAT_VISUALIZZA_PARTECIPANTI" onclick="javascript:CHAT_DISPLAY_PARTECIPANTI(\'\')";>Visualizza Partecipanti</div>' 
								//objRoom.innerHTML = objRoom.innerHTML + html +  obj.CHAT;    
								
                                //-- mi posiziono in coda per mostrare l'ultimo messaggio arrivato
                                setTimeout( function() { AF_CHAT_Show_Last( objDIV_Name )  } , 1 );
                                
                                curLastTime( obj.LastTime );
                                
                            }
                        
                        } catch(e){}
                        
                        //-- NASCONDO TEXTAREA E BOTTONE SE LA CHAT NON è open
                        try{
                            DOC_CHAT_Stato = obj.Stato;
                        }catch(e){}

                        try
                        {
                        	var messaggioChat = getObj('AF_CHAT_MSG_DOC');
                        	var bottoneChat = getObj('AF_CHAT_BUTTON_DOC');

                            if ( DOC_CHAT_Stato == 'OPEN' )
                            {
                            	messaggioChat.style.display = '';
                            	bottoneChat.style.display = '';
                            }
                            else
                            {
                                messaggioChat.style.display = 'none';
                            	bottoneChat.style.display = 'none';
                            } 
                        }catch(e){}                                                        
                       
                    }                    
				}
			}

		}

		ajax2.send(null);
    }

}



function AF_CHAT_Show_Last( objDIV_Name )
{
    //var objRoom = getObj('AF_CHAT_ROOM');    
    var objRoom = getObj(objDIV_Name);    
    objRoom.scrollTop = objRoom.scrollHeight;
    
    
} 



//-- effettuo il disegno del conbtenuto di tutto il dialogo delle chat
function AF_CHAT_DrawContent( obj  )
{

    try{
        var NumNotRead = 0;
    
        var htmlRooms = '<ul>';
        
        // -- disegno l'elenco delle stanze
        for ( i = 0 ; i < obj.ROOMS.length ; i++ )
        {

            htmlRooms = htmlRooms + '<li class="AF_CHAT_ROOM' 
            if( obj.CurRoom == obj.ROOMS[i].ID )
                htmlRooms = htmlRooms + '_CURRENT'; 

            if( obj.ROOMS[i].Stato == 'OPEN'  )
				htmlRooms = htmlRooms + ' AF_CHAT_OPEN';
                
            if ( obj.ROOMS[i].Num_Msg != 0 )                 
                 htmlRooms = htmlRooms + ' AF_CHAT_ROOM_NOT_READ';

             
            htmlRooms = htmlRooms + '" onclick="AF_CHAT_OnClick(\'' + i +'\' )" >' +    obj.ROOMS[i].Name + '<ul>'
            if ( obj.ROOMS[i].Num_Msg != 0  )
            {
                htmlRooms = htmlRooms + '<li class="AF_CHAT_ICO_NOT_READ"></li><li class="AF_CHAT_NUM_NOT_READ">' +  obj.ROOMS[i].Num_Msg +  '</li>';
                NumNotRead += obj.ROOMS[i].Num_Msg;
            }
               
            htmlRooms = htmlRooms + '</ul> </li>';                              
        
        }
        
        htmlRooms = htmlRooms + '</ul>';
        getObj('AF_CHAT_ROOMS').innerHTML = htmlRooms;
        
        
        //-- aggiorna il numero di messagii non letti
        //if ( obj.NumNotRead != 0 )
        if ( NumNotRead != 0 )
        {
            getObj('AF_CHAT_NUM_MSG_NOT_READ').style.display = '';
            getObj('AF_CHAT_NUM_MSG_NOT_READ').innerHTML = obj.NumNotRead;
        }
        else
        {
            getObj('AF_CHAT_NUM_MSG_NOT_READ').style.display = 'none';
            getObj('AF_CHAT_NUM_MSG_NOT_READ').innerHTML = '';
        
        }
        
    } catch( e ) {}

}


//-- avvia la conversazione su una stanza indicata
function AF_CHAT_OnClick( ix )
{
    if (typeof isFaseII !== 'undefined' && isFaseII) {

        AF_CHAT_OBJ.CurRoom = AF_CHAT_OBJ.ROOMS[ix].ID;
        AF_CHAT_OBJ.ixCurRoom = ix;

        AF_CHAT_OBJ.LastTime = '';
        getObj('AF_CHAT_ROOM').innerHTML = '';

        //-- verifico se la chat è aperta
        if (AF_CHAT_OBJ.ROOMS[ix].Stato == 'OPEN') {
            getObj("AF_CHAT_MSG").style.display = '';
        }
        else {
            getObj("AF_CHAT_MSG").style.display = 'none';
        } 


        $("#AF_CHAT_ROOM").width($("#rightArea").width() - $("#AF_CHAT_ROOMS").width());
        $("#AF_CHAT_ROOM").height($("#rightArea").height() - 80 - $('#AF_CHAT_MSG').height() - 2); //-2 per border-bottom
        $("#AF_CHAT_ROOMS").height($("#rightArea").height() - 80);
        AF_CHAT_UpdateWin();

        try { resetSessionTimer(); } catch (e) { } 

        return;
    }
    
    AF_CHAT_OBJ.CurRoom = AF_CHAT_OBJ.ROOMS[ix].ID;
    AF_CHAT_OBJ.ixCurRoom = ix;
    
    AF_CHAT_OBJ.LastTime = '';
    getObj('AF_CHAT_ROOM').innerHTML = '';

    //-- verifico se la chat è aperta
    if( AF_CHAT_OBJ.ROOMS[ix].Stato == 'OPEN' )
    {
        getObj( "AF_CHAT_MSG" ).style.display = '';    
    }
    else
    {
        getObj( "AF_CHAT_MSG" ).style.display = 'none';    
    } 

    AF_CHAT_Resize();
    AF_CHAT_UpdateWin(); 
    
    try{ resetSessionTimer(); }catch(e){}  

}


//-- apre e chiude il dialogo delle conversazione
function AF_CHAT_OpenWin()
{
    
    if ( AF_CHAT_OBJ.Win == 'Close' )
    {
        AF_CHAT_OBJ.Win = 'Open';
        
        $( "#AF_CHAT_WIN" ).dialog( "open" );
        var H = $( "#AF_CHAT_WIN" ).height();
        
        if ( window.innerHeight < H )
        {
             $( "#AF_CHAT_WIN" ).height(  window.innerHeight - 50 ) ;
        }

                
        
        AF_CHAT_Resize();

    } 
    else
    {
        AF_CHAT_OBJ.Win = 'Close';
        $( "#AF_CHAT_WIN" ).dialog( "close" );
    } 

}


function AF_CHAT_Resize( obj )
{
    try{
    
        //-- controllo le dimensioni della finerstra per eventualmente ridurre le dimensioni della CHAT
        document.height
        

        $( "#AF_CHAT_ROOM" ).width(  $( "#AF_CHAT_WIN" ).width() -  $( "#AF_CHAT_ROOMS" ).width() );
        $( "#AF_CHAT_ROOMS" ).height( $( "#AF_CHAT_WIN" ).height()  - 5);
        
        
        if( AF_CHAT_OBJ.ROOMS[AF_CHAT_OBJ.ixCurRoom].Stato == 'OPEN' )
        {
        
            $( "#AF_CHAT_ROOM" ).height( $( "#AF_CHAT_WIN" ).height()  -  $( "#AF_CHAT_MSG" ).height() - 5);
            $( "#AF_CHAT_MSG" ).width( $( "#AF_CHAT_WIN" ).width()  -  $( "#AF_CHAT_ROOMS" ).width() );
        }
        else
        {
            $( "#AF_CHAT_ROOM" ).height( $( "#AF_CHAT_WIN" ).height()  - 5);
        }


    }catch(e){} ;
}


//-- inserisco il testo nella conversazione della stanza corrente
function AF_CHAT_NewMSG( Room , FormName)
{
 
 	var nocache = new Date().getTime();
	var STR_URL;
    
    var CurRoom =  AF_CHAT_OBJ.CurRoom 
    
	
	
	
    if ( Room != undefined )  CurRoom = Room;
    
	

	STR_URL = pathRoot + 'CTL_Library/CHAT/Chat.asp?ACTION=NEW_MSG&ROOM=' + escape(  CurRoom ) + '&nocache=' + nocache ;
    
    if ( FormName == undefined )
    {
		
		//controllo messaggio valorizzato
		if ( JSTrim ( getObj( 'AF_CHAT_MESSAGE' ).value ) == '' )
		{
			//getObj( 'AF_CHAT_MESSAGE' ).value = 'Inserire un Messaggio';
			AF_Alert( 'Inserire un Messaggio nella chat' );
			return;
		}	
	
        SEND_FORM_AJAX(  STR_URL, 'AF_CHAT_NEW_MSG', 'AF_CHAT_RESULT', true );
        getObj( 'AF_CHAT_MESSAGE' ).value = '';
    }
    else
    {
		//controllo messaggio valorizzato
		if ( JSTrim ( getObj( 'AF_CHAT_MESSAGE_DOC' ).value ) == '' )
		{
			getObj( 'AF_CHAT_MESSAGE_DOC' ).value = 'Inserire un Messaggio';
			return;
		}
		
        SEND_FORM_AJAX(  STR_URL, FormName, 'AF_CHAT_RESULT_DOC', true );
        getObj( 'AF_CHAT_MESSAGE_DOC' ).value = '';
    }
            
    //getObj( 'AF_CHAT_NEW_MSG' ).value = '';

    
    
    try{ resetSessionTimer(); }catch(e){}
    
}




//-- chiamata per tracciare IN/OUT nella room dell'utente
// TypeAction = IN/OUT
function AF_CHAT_IN_OUT_USER ( curRoom , TypeAction )
{
	var nocache = new Date().getTime();
	var ajax2 = GetXMLHttpRequest(); 
       
	
	if(ajax2)
	{

		ajax2.open("GET", pathRoot + 'CTL_Library/CHAT/Chat.asp?ACTION=' + TypeAction + '&ROOM=' + escape( curRoom ) + '&nocache=' + nocache, true);

		ajax2.onreadystatechange = function( ) 
		{
			if(ajax2.readyState == 4 /*|| ajax2.readyState == 3*/) 
			{
				if (ajax2.status == 200) 
				{
					var txt =  ajax2.responseText;
                    
                    //if ( txt != '{}' &&  txt != '' )
                    //{ 
                        //var obj = JSON.parse(txt);
                        //alert(txt);                                               
                       
                    //}                    
				}
			}

		}

		ajax2.send(null);
    }

}

//visualizza oppure nasconde le righe di IN/OUT dalla chat
function AF_CHAT_DISPLAY_PARTECIPANTI(param)
{
	
	//AF_CHAT_IN_OE_OUT    AF_CHAT_IN_OE_USER_OUT
	//AF_CHAT_OUT_OE_OUT   AF_CHAT_OUT_OE_USER_OUT
	//AF_CHAT_MSG_TIME_IN AF_CHAT_MSG_TIME_OUT
	
	
	
	if (param == 'HIDE')
	{
		
		
		$( ".AF_CHAT_IN_OE_OUT" ).css( "display", "none" );
		$( ".AF_CHAT_OUT_OE_OUT" ).css( "display", "none" );
		$( ".AF_CHAT_MSG_TIME_IN" ).css( "display", "none" );
		$( ".AF_CHAT_MSG_TIME_OUT" ).css( "display", "none" );
		
		//nascondo bottone per nascondere 
		getObj('NASCONDI_PARTECIPANTI').style.display='none';
		//visualizzo bottone per visualizzare
		getObj('VISUALIZZA_PARTECIPANTI').style.display='';
		
	}
	else
	{
		
		
		$( ".AF_CHAT_IN_OE_OUT" ).css( "display", "" );
		$( ".AF_CHAT_OUT_OE_OUT" ).css( "display", "" );
		$( ".AF_CHAT_MSG_TIME_IN" ).css( "display", "" );
		$( ".AF_CHAT_MSG_TIME_OUT" ).css( "display", "" );
		
		//visualizzo bottone per nascondere 
		getObj('NASCONDI_PARTECIPANTI').style.display='';
		//nascondo bottone per visualizzare
		getObj('VISUALIZZA_PARTECIPANTI').style.display='none';
		
	}
	
	
	
	
}
//-------------------------------------
//-- funzioni per la CHAT nel documento - se il template per la rappresentazione è sempre quello 
//-------------------------------------

//-- data ultimo aggiornamento della conversazione per recuiperare solo i messaggi nuovi rispetto alla data di ultimo aggiornamento
var DOC_ChatTimeUPD = '';
var DOC_CHAT_Room;
var DOC_CHAT_Stato = '';

//-- funzione richiamata ogni secondo per avere il contenuto aggiornato
function  DOC_CHAT_UpdateWin()
{
    //AF_CHAT_UpdateDIV( 'chatConversazione' , getObj( 'IDDOC' ).value, func_ChatTimeUPD );
    AF_CHAT_UpdateDIV( 'chatConversazione' , DOC_CHAT_Room, func_ChatTimeUPD );
}

//-- funzione per aggiornare, o farsi ritornare , la data di ultimo aggiornamento della chat
function func_ChatTimeUPD( time )
{
    if ( time != undefined && time != '' )
        DOC_ChatTimeUPD = time
        
    return DOC_ChatTimeUPD; 
}


//-- la funzione viene invocata dal template HTML utilizzato sul documento per l'inserimento di un nuovo messaggio
function AF_CHAT_NewMSG_DOC( )
{
    //AF_CHAT_NewMSG( getObj( 'IDDOC' ).value , 'AF_CHAT_MSG_DOC' );
    AF_CHAT_NewMSG( DOC_CHAT_Room , 'AF_CHAT_MSG_DOC' );
}

function JSTrim(Str)
{
	var cnt1, cnt2;
    var objStr = new String(Str);
    var objTmpStr = new String('');
    var LenStr = objStr.length;
    
    // cerca il primo carattere non blank
    for (cnt1=0; ((cnt1 < LenStr - 1) && (objStr.charAt(cnt1) == " ")); cnt1++);

    // partendo dall'ultimo, cerca il primo carattere non blank
    for (cnt2 = LenStr - 1; ((cnt2>=0) && (objStr.charAt(cnt2) == " ")); cnt2--);

    // crea la stringa senza i blank all'inizio
	objTmpStr = objStr.substr(cnt1, (cnt2 - cnt1 + 1));
       
	return objTmpStr;
}




//-------------------------------------
//-- funzioni per la CHAT nel documento - END 
//-------------------------------------