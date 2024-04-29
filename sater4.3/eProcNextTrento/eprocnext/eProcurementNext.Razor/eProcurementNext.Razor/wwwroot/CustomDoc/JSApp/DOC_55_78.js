
<script language="javascript">
//Versione=1&data=2012-10-17&Attvita=39758&Nominativo=Francesco


var oldSend;

function NewSend()
{
	
	//innesco i controlli base di tipo CANSEND del documento
  if  ( ! SENDBASE())
	 return;
	
  
	//se devo inserire i destinatari lo controllo dando un messaggio 
  //if ( nNumCurrCompany_CompanyDes == 0 ){
    
  //  alert(CNV ('../../' , 'Inserire almeno un Destinatario' ));
  //  DrawLabel('1'); 
  //  FUNC_CompanyDes();
  //  return;
  //}  
	
	
	oldSend('SEND,APPROVAZIONE');
	
	
}	





//INVOCO SETTAGGI APPENA E' PRONTO IL DOC DELLA PAGINA
window.onload = SetOnChangeAttributi;




function SetOnChangeAttributi()
{
	
	//controllo se rimappare la SEND in funzione del ciclo di approvazione	
	if (getObj('AdvancedState').value!='4' && getObj('Stato').value!='2' )
	{
	
	  oldSend=ExecDocProcess;
		ExecDocProcess = NewSend;
		  
	}

	//gestione sezione destinatari
  HandleSezioneDestinatari();
	
}



//Gestione Sezione Destinatari:
//se doc salvato visualizzo nuovo viewer altrimenti vecchia griglia
function HandleSezioneDestinatari(){
  
  //se ho la nuova area dei destinatari
  if ( getObj('iframe_CompanyDes_ViewerDestinatari') != null ){
  
    //se documento nuovo/salvato visualizzo nuovo viewer altrimenti vecchio
    if ( getObj('Stato').value == '0' ||  getObj('Stato').value == '1' ){
      
      //nascondo il comando esporta in excel
      try{getObj('CompanyDes_GridDest_Esporta in Excel1').style.display='none'; }catch(e){}
      
      //nascondo la vecchia area
      getObj( 'CompanyDes_GridDest' ).style.display='none'; 
      
      //carico nella nuov aarea il nuovo viewer 
      var IdHeader = getObj('lIdMsgPar').value;
      
      var strURL = '../../DASHBOARD/Viewer.asp?PATHTOOLBAR=../customdoc/&JScript=&Exit=&Table=DESTINATARI_RICERCA_OE&OWNER=&IDENTITY=IdAzi&TOOLBAR=DESTINATARI_RICERCA_TOOLBAR&DOCUMENT=&AreaAdd=no&CaptionNoML=no&Caption=&Height=0,100*,210&numRowForPag=25&Sort=aziragionesociale&SortOrder=asc&ACTIVESEL=1&AreaFiltroWin=0&AreaFiltro=no&';  
      var  FilterHide = 'FilterHide=linkedDoc=' + IdHeader ;
      strURL = strURL + FilterHide ;
      //strURL = strURL + '&ModGriglia=';
      getObj('iframe_CompanyDes_ViewerDestinatari').src = strURL;
       
    }else{  
      getObj( 'CompanyDes_ViewerDestinatari' ).style.display='none'; 
    }
    
  }      
    
  
}
  
  
function RefreshContent(){
  
  if ( getObj('iframe_CompanyDes_ViewerDestinatari') != null ){
  
    if ( getObj('Stato').value != '2' ){
    
      //ricarico il viewer dei destinatari
      var IdHeader = getObj('lIdMsgPar').value
      var strURL = '../../DASHBOARD/Viewer.asp?PATHTOOLBAR=../customdoc/&JScript=&Exit=&Table=DESTINATARI_RICERCA_OE&OWNER=&IDENTITY=IDROW&TOOLBAR=DESTINATARI_RICERCA_TOOLBAR&DOCUMENT=&AreaAdd=no&CaptionNoML=no&Caption=&Height=0,100*,210&numRowForPag=25&Sort=aziragionesociale&SortOrder=asc&ACTIVESEL=1&AreaFiltroWin=0&AreaFiltro=no&';  
      var  FilterHide = 'FilterHide=linkedDoc=' + IdHeader ;
      strURL = strURL + FilterHide ;
      //strURL = strURL + '&ModGriglia=BANDO_GARA_DESTINATARI';
      getObj('iframe_CompanyDes_ViewerDestinatari').src = strURL;
      
    }
  }
}
</script>

