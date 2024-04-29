
<script language="javascript">

window.onload = InitOfferta; 

//INIZIALIZZAZIONE   
function InitOfferta() {

    //VISUALIZZO BUSTA CORRETTA
    DRAWBUSTA();
    
    //NASCONDO AREE OLD
    HideAreeOld();
    
    
    //gestione aree RTI,CONSORZIO,AVVALIMENTO se non richieste
    try{
      HandleAreeRTI();
    }catch(e){}
}

//VISUALIZZO BUSTA CORRETTA
function DRAWBUSTA(){
  //visualizzo la busta di documentazione
  DrawLabel('1'); 
  try { 
    FUNC_OPEN('55','23','1',getObj('lIdPfu').value,getObj('lIdMsgPar').value,'PRODUCTS','DOCUMENTAZIONE','AFLGenericDocument.clsTabProducts','3','404','DIV_DOCUMENTAZIONE','Open_DOCUMENTAZIONE');
  } 
  catch(e){} 
  FUNC_DOCUMENTAZIONE(); 
}

//NASCONDO AREE OLD
function HideAreeOld(){
  //nascondo area allegati della sezione tecnica e della sezione economica in caso di nuovo documento
  try{
  	var nHide=0;
  
  	strdata=getObj('ReceivedDataMsg').value;
  
  	if ( strdata > '2009-10-30T00:00:00')
  		nHide=1;
  
  	if (getObj('Stato').value == '0' || getObj('Stato').value == '1' || nHide==1){
  		setVisibility(getObj('DIV_DOCUMENTAZIONE_allegati'),'none');
  	}
  }catch(e){
  }
}

//gestione aree RTI,CONSORZIO,AVVALIMENTO se non richieste
function HandleAreeRTI(){
    
   //radio area RTI  
  var PartecipaFormaRTI = get_IdDztFromDztNome_AreaOfid('DOCUMENTAZIONE_comuneATI','PartecipaFormaRTI');
  
  getObj('elemento1_DOCUMENTAZIONE_comuneATI_' + PartecipaFormaRTI + '_1' ).style.display='inline';
  getObj('elemento1_DOCUMENTAZIONE_comuneATI_' + PartecipaFormaRTI + '_2' ).style.display='inline';
  
  //radio area Consorzio  
  var Esecutrice = get_IdDztFromDztNome_AreaOfid('DOCUMENTAZIONE_ComuneConsorzio','InserisciEsecutriciLavori');
  getObj('elemento1_DOCUMENTAZIONE_ComuneConsorzio_' + Esecutrice + '_1' ).style.display='inline';
  getObj('elemento1_DOCUMENTAZIONE_ComuneConsorzio_' + Esecutrice + '_2' ).style.display='inline';
	
	//radio area  Avvalimento 
  var Avvalimento = get_IdDztFromDztNome_AreaOfid('DOCUMENTAZIONE_ComuneAvvalimento','RicorriAvvalimento');
  getObj('elemento1_DOCUMENTAZIONE_ComuneAvvalimento_' + Avvalimento + '_1' ).style.display='inline';
  getObj('elemento1_DOCUMENTAZIONE_ComuneAvvalimento_' + Avvalimento + '_2' ).style.display='inline';
    
	}

</script>

