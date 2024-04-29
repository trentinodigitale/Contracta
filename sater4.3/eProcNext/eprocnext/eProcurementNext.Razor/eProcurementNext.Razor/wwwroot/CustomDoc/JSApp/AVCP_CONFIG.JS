function MyOpen_AVCP_Config(grid , r , c)
{

var idRow;
	
	//-- recupero il codice della riga passata
	idRow = GetIdRow( grid , r , 'self' );
	
	var Statofunzionale = '';
	
	try	{ 	Statofunzionale = getObj( 'R' + r + '_StatoFunzionale').value;	}catch( e ) {};
	
	if ( Statofunzionale == '' || Statofunzionale == undefined )
	{
		try	{ 	Statofunzionale = getObj( 'R' + r + '_StatoFunzionale')[0].value; }catch( e ) {};
	}
	
	if ( Statofunzionale == 'Pubblicato' )
	{
		OpenDocumentColumn( grid , r , c );

	}
	else
	{
		var idRow = idRow.replace("-","");
		DASH_NewDocumentFrom('AVCP_CONFIG#AVCP_CONFIG_VIEWER,'+ idRow +'#900,600###');
		//DASH_NewDocumentFrom('AVCP_CONFIG#AVCP_CONFIG_VIEWER,'+ idRow +'#900,600###../ctl_library/document/document.asp?')
		//alert(idRow);
		
	}
	
	

}

function RefreshContent()
{
	
	RefreshDocument('');
}
window.onload=view_differenze;
function view_differenze()
{
	
	try{ShowEvidenza( 'Body' , '1px solid red' );}catch(e){}
	change_type_psw();
	gestione_metodo();
	
}
//cambio il tipo da text a password
function change_type_psw()
{	
	if ( getObj('StatoFunzionale').value == 'InLavorazione' )	
	{
		var obj=getObj('PasswordFtp');		
		var newO=document.createElement('input');
		newO.setAttribute('type','password');
		newO.setAttribute('name','PasswordFtp');
		newO.setAttribute('id','PasswordFtp');		
		newO.setAttribute('class','Text');
		obj.parentNode.replaceChild(newO,obj);
	}
	else
	{
		var obj=getObj('PasswordFtp_V');		
		var newO=document.createElement('input');
		newO.setAttribute('type','password');
		newO.setAttribute('name','PasswordFtp');
		newO.setAttribute('id','PasswordFtp');		
		newO.setAttribute('class','Text');
		obj.parentNode.replaceChild(newO,obj);
		
		
	}

}


function ValidaUrl() 
{
url=getObj( 'URL_CLIENT' ).value;
url=url.trim();
var RegExp =  /(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/;
//var RegExp = /((?:https?\:\/\/|www\.)(?:[-a-z0-9]+\.)*[-a-z0-9]+.*)/

	if(!RegExp.test(url))
	{
		
		DMessageBox( '../../ctl_library/' , 'Url non valido' , 'Attenzione' , 1 , 400 , 300 ); 
		getObj( 'URL_CLIENT' ).value='';
		return false;	
	}
	//controllo che non termina con /
	if(url.substring(url.length-1,url.length) == '/' || url.lastIndexOf("\\")!=-1)
	{
		
		DMessageBox( '../../ctl_library/' , 'Url non valido' , 'Attenzione' , 1 , 400 , 300 ); 
		getObj( 'URL_CLIENT' ).value='';
		return false;	
	}
	return true;

}
function verifica_estensione(obj) 
{
var nome;
var posizione_punto;
var lunghezza_stringa;
var estensione;
	
	nome=obj.value;
    posizione_punto=nome.lastIndexOf(".");
	lunghezza_stringa=nome.length;
	estensione=nome.substring(posizione_punto+1,lunghezza_stringa);
	if ( estensione != '' && estensione != nome )
	{
		DMessageBox( '../../ctl_library/' , 'Digitale il nome del file senza estensione' , 'Attenzione' , 1 , 400 , 300 ); 
		obj.value='';
		return false;
	}
	
	return true;
}


//nasconde i campi in funzione del metodo
function gestione_metodo()
{
	var metodo;
	try{ metodo=getObjValue( 'Metodo' );}catch(e){metodo=getObjValue( 'val_Metodo' );}
	
	if ( metodo == 'Locale' )
	{
		
		setVisibility(getObj('PercorsoDiRete'), '');
		setVisibility(getObj('cap_PercorsoDiRete'), '');
		DisableObj('PercorsoDiRete',false);		
		DisableObj('FTP',true);
		DisableObj('Porta',true);
		DisableObj('Login',true);
		DisableObj('PasswordFtp',true);
		setVisibility(getObj('cap_FTP'), 'none');
		setVisibility(getObj('FTP'), 'none');
		setVisibility(getObj('Cell_FTP').offsetParent, 'none');		
		setVisibility(getObj('Cell_FTP'), 'none');
		setVisibility(getObj('Porta_V'), 'none');
		setVisibility(getObj('Cell_Porta').offsetParent, 'none');
		setVisibility(getObj('Cell_Porta'), 'none');		
		setVisibility(getObj('cap_Porta'), 'none');
		setVisibility(getObj('cap_Login'), 'none');
		setVisibility(getObj('Login'), 'none');
		setVisibility(getObj('Cell_Login').offsetParent, 'none');
		setVisibility(getObj('Cell_Login'), 'none');		
		setVisibility(getObj('cap_PasswordFtp'), 'none');
		setVisibility(getObj('PasswordFtp'), 'none');
		setVisibility(getObj('Cell_PasswordFtp').offsetParent, 'none');
		setVisibility(getObj('Cell_PasswordFtp'), 'none');
		
	}
	if ( metodo == 'Remoto' )
	{
		setVisibility(getObj('PercorsoDiRete'), 'none');
		setVisibility(getObj('cap_PercorsoDiRete'), 'none');		
		DisableObj('PercorsoDiRete',true);							
		DisableObj('FTP',false);
		DisableObj('Porta',false);
		DisableObj('Login',false);
		DisableObj('PasswordFtp',false);			
		setVisibility(getObj('cap_FTP'), '');
		setVisibility(getObj('FTP'), '');			
		setVisibility(getObj('Porta_V'), '');
		setVisibility(getObj('cap_Porta'), '');
		setVisibility(getObj('cap_Login'), '');		
		setVisibility(getObj('Login'), '');
		setVisibility(getObj('cap_PasswordFtp'), '');		
		setVisibility(getObj('PasswordFtp'), '');
		setVisibility(getObj('Cell_PasswordFtp').offsetParent, '');
		setVisibility(getObj('Cell_FTP').offsetParent, '');	
		setVisibility(getObj('Cell_Porta').offsetParent, '');
		setVisibility(getObj('Cell_Login').offsetParent, '');
	}
	
	
}

function TEST_PATH_RETE()
{
	var param=getObj('PercorsoDiRete').value;
	
	if ( param == '' )
	{
		DMessageBox( '../../ctl_library/' , 'Inserire un percorso di rete prima di fare il test' , 'Attenzione' , 1 , 400 , 300 ); 
		return false;
	}

	
	objForm = getObj('FORMDOCUMENT');
	var oldAction = objForm.action;
	var oldtarget = objForm.target;
	
	objForm.action='../../AVCP/test_Path.asp';
	//objForm.target='_top';
	// open a new window with proper size    
	window.open("", "MySubWindow", "height=480,width=640");
	objForm.target = "MySubWindow";
	
	objForm.submit();
	
	objForm.action=oldAction; 
	objForm.target=oldtarget;

}




