window.onload = setdocument;

function setdocument()
{
	HideCestinodoc();
	Recupero_Descrizione();
	Hide_CLASSI();
	Filter_CLASSI();
	ControlloEliminato();
}


function ATTI_GARA_AFTER_COMMAND ()
{
	setdocument();
}

function HideCestinodoc()
{
    try{
        var i = 0;
		
		
		if ((getObj('StatoDoc').value== 'Saved' || getObj('StatoDoc').value == '' )  )
		{
			for( i=0; i < 10000; i++ )
			{
				try {
					if( getObj( 'R' + i + '_Allegato_OLD' ).value != '' || getObj( 'R' + i + '_Descrizione_OLD' ).value != '')
					{					
						getObj( 'ATTI_GARAGrid_r' + i + '_c0' ).innerHTML = '&nbsp;';
					}
					if( getObj( 'R' + i + '_Allegato_OLD' ).value == ''  &&  getObj( 'R' + i + '_Descrizione_OLD' ).value == '')
					{
						getObj( 'ATTI_GARAGrid_r' + i + '_c1' ).innerHTML = '&nbsp;';
					}
					if ( getObj( 'R' + i + '_AnagDoc' ).value != '' )					
						getObj( 'R' + i + '_Descrizione' ).disabled=true;						
					else
						getObj( 'R' + i + '_Descrizione' ).disabled=false;	
				 }catch(e){break;}
			}
		}
   }catch(e){}
  
}

function Doc_DettagliDel( grid , r , c )
{
	var v = '0';
	try
	{
		v = getObj( 'R' + r + '_Allegato_OLD' ).value ;
	}catch(e){};
	
    if( v != '' )
    {
        
    }
    else
    {
        DettagliDel( grid , r , c );
    }
}


function GetXMLHttpRequest() {
	var
		XHR = null,
		browserUtente = navigator.userAgent.toUpperCase();

	if(typeof(XMLHttpRequest) === "function" || typeof(XMLHttpRequest) === "object")
		XHR = new XMLHttpRequest();
		else if(window.ActiveXObject && browserUtente.indexOf("MSIE 4") < 0) {
			if(browserUtente.indexOf("MSIE 5") < 0)
				XHR = new ActiveXObject("Msxml2.XMLHTTP");
			else
				XHR = new ActiveXObject("Microsoft.XMLHTTP");
		}
		return XHR;
};
ajax = GetXMLHttpRequest();  

function GetDescrizioneAttiGara()
{
	var IDDOC='';
	IDDOC=getObj('LinkedDoc').value;

	if(ajax)
	{	
	   ajax.open("GET",   '../../CustomDoc/GetDescrizioneAttiGara.asp?IDDOC=' +  IDDOC  , false);
	   ajax.send(null);		
	}
	if(ajax.readyState == 4) 
	{		
			if(ajax.status == 200)
			{
				
				try
				{
					if( ajax.responseText != '' )
					{
					 arr = ajax.responseText.split("@@@"); 
					 for( i=0; i < 10000; i++ )
						{
							try {
								if( getObj( 'R' + i + '_Allegato_OLD' ).value != '' )
								{					
									 //getObj( 'R' + i + '_Descrizione_OLD' ).value =  arr[i];
									 
									 SetTextValue('R' + i + '_Descrizione_OLD',arr[i]);
									
								}
								
								}catch(e){break;}
						}
					}
				} catch ( e ) {};
			}
	}

}


function Recupero_Descrizione()
{
	 try{
			var i = 0;
			var sentinella='';
			
		if ( getObjValue('JumpCheck') != '55;167'	)
		{
			if ((getObj('StatoDoc').value== 'Saved' || getObj('StatoDoc').value == '' )  )
			{
				for( i=0; i < 10000; i++ )
				{
					try {
						if( getObj( 'R' + i + '_Allegato_OLD' ).value != '' )
						{					
							if( getObj( 'R' + i + '_Descrizione_OLD' ).value != '')
							{
								sentinella='no'
							}
						}
						
						}catch(e){break;}
				}
			}
			if ( sentinella == '' )
			{
				GetDescrizioneAttiGara();
			}
		}
		}catch(e){}
	

}


function RefreshContent()
{ 	
	RefreshDocument('');      
}
//nasconde la sezione delle classi se non vengo da un BANDO_ME
function Hide_CLASSI()
{
	try
	{
		if ( getObjValue('JumpCheck') != 'BANDO'	)
		{
			document.getElementById("CLASSI").style.display="none";
		}
	}catch(e){}
}



function Filter_CLASSI()
{
	try
	{
		var iddoc = getObj('IDDOC').value;	
	
		if(  getObjValue( 'StatoFunzionale' ) == 'InLavorazione'  )
		{
			
			var filtro = getObj('ClasseIscriz_Bando').value;
			
			if ( filtro != '')
			{
				//SetProperty( getObj('ClasseIscriz_Sospese'),'filter','SQL_WHERE=DMV_COD in ( select a.DMV_Cod from ClasseIscriz a,ClasseIscriz b where b.DMV_Cod in (select * from dbo.split(\'' + filtro + '\',\'###\')) and b.DMV_Father like a.DMV_Father + \'%\' )');
				SetProperty( getObj('ClasseIscriz_Sospese'),'filter','SQL_WHERE=DMV_COD in ( select * from dbo.split(\'' + filtro + '\',\'###\'))');
				SetProperty( getObj('ClasseIscriz_Revocate'),'filter','SQL_WHERE=DMV_COD in ( select * from dbo.split(\'' + filtro + '\',\'###\'))');
				//SetProperty( getObj('ClasseIscriz_Revocate'),'filter','SQL_WHERE=DMV_COD in ( select a.DMV_Cod from ClasseIscriz a,ClasseIscriz b where b.DMV_Cod in (select * from dbo.split(\'' + filtro + '\',\'###\')) and b.DMV_Father like a.DMV_Father + \'%\' )');
			}
		}		
	}catch(e){}
	
}

function OnchangeEliminato (obj)
{
	//se scelto eliminato = si allora nasconde il contenuto della colonna NuovaDescrizione e NuovoAllegato
	var i = obj.id.split('_');
	var row =  i[0];
	
	if ( obj.value == 'si' )
	{
		$("#"+ row + "_Descrizione").css({	"display": "none"})
		$("#"+ row + "_Allegato_V").css({	"display": "none"})
		
	}
	if ( obj.value != 'si' )
	{
		$("#"+ row + "_Descrizione").css({	"display": "block"})
		$("#"+ row + "_Allegato_V").css({	"display": "block"})
		
	}

}
function ControlloEliminato()
{
	if ( getObj('ATTI_GARAGrid') )
	{
		var numeroRighe = GetProperty( getObj('ATTI_GARAGrid') , 'numrow');
		for( i = 0 ; i <= numeroRighe ; i++ )
		{
			OnchangeEliminato (getObj('R'+ i + '_Eliminato'));
		}
	}
}








