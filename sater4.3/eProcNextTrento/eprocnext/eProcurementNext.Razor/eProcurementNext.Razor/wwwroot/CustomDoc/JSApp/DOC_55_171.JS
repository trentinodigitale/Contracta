
<script language="javascript">

window.onload = InitOfferta ;

//INIZIALIZZAZIONE   
function InitOfferta() {

    //VISUALIZZO BUSTA CORRETTA
    DRAWBUSTA();
    
    //VISUALIZZO IN FUNZIONE DEI LOTTI
    HandleCampiMicroLotti();
    
    
    //gestione aree RTI,CONSORZIO,AVVALIMENTO se non richieste
    HandleAreeRTI();
}



//VISUALIZZA LA BUSTA CORRETTA SECONDO DOVE SONO ARRIVATO NELLA PDA
function DRAWBUSTA(){
 
 try{
  
  strSectionToOpen = self.opener.getObj('Valutazione_griglia_SECTION_TO_OPEN').value;
  
 }catch(e){
 
  strSectionToOpen='DOCUMENTAZIONE';
  
 }
 
 if ( strSectionToOpen == 'TECNICA' && getObj('TECNICA_Hide').value=='1' ) 
  strSectionToOpen = 'ECONOMICA';
 
 if (strSectionToOpen == 'DOCUMENTAZIONE' ){
 
  DrawLabel('1');
  try { 
    FUNC_OPEN('55','171','1',getObj('lIdPfu').value,getObj('lIdMsgPar').value,'PRODUCTS','DOCUMENTAZIONE','AFLGenericDocument.clsTabProducts','3','628','DIV_DOCUMENTAZIONE','Open_DOCUMENTAZIONE');
  } 
  catch(e){} 
  
  FUNC_DOCUMENTAZIONE();
 
 }
 
 if (strSectionToOpen == 'TECNICA' ){
 
  DrawLabel('2');
  try { 
    FUNC_OPEN('55','171','1',getObj('lIdPfu').value,getObj('lIdMsgPar').value,'PRODUCTS','TECNICA','AFLGenericDocument.clsTabProducts','4','631','DIV_TECNICA','Open_TECNICA');
  } 
  catch(e){} 
  
  FUNC_TECNICA();
 
 }
 
 if (strSectionToOpen == 'ECONOMICA' ){
 
  DrawLabel('3');
  try { 
    FUNC_OPEN('55','171','1',getObj('lIdPfu').value,getObj('lIdMsgPar').value,'PRODUCTS','ECONOMICA','AFLGenericDocument.clsTabProducts','5','709','DIV_ECONOMICA','Open_ECONOMICA');
  } 
  catch(e){} 
  
  FUNC_ECONOMICA(); 
 
 }
 
 
  if (strSectionToOpen == 'MicroLotti' ){
 
  DrawLabel('4');
  try { 
    FUNC_OPEN('55','171','1',getObj('lIdPfu').value,getObj('lIdMsgPar').value,'PRODUCTS','MicroLotti','AFLGenericDocument.clsTabProducts','5','687','DIV_MicroLotti','Open_MicroLotti');
  } 
  catch(e){} 
  
  FUNC_MicroLotti(); 
 
 }
}


   
//SETTA LE SEZIONI DELL'OFFERTA IN FUNZIONE del campo Divisione_lotti 
function HandleCampiMicroLotti(){

if ( getObj( 'Divisione_lotti' ).value == '2'  ){

  //microlotti nascondo la sezione economica
  hObjSection = getObj( 'ECONOMICA_Hide' );                   
  hObjSection.value = 1 ;     
  
  
  //se selezionato un modello allora carico nell'area URL il viewer
  //per visualizzare il modello di micro lotto caricato
  DisplayAreaUrlMicroLotto();
  
}else{
  
  //altrimenti nascondo la sezione microlotti
  hObjSection = getObj( 'MicroLotti_Hide' );                   
  hObjSection.value = 1 ;    

}

DrawLabel( LinkAttivo );   
    
}


//VISUALIZZA AREA VIEWR PER I MICROLOTTI
function DisplayAreaUrlMicroLotto(){

  var objListaModelli = getObj('ListaModelliMicrolotti');
   
  if ( objListaModelli.value != '') {
    
    //alert(getObj('iframe_MicroLotti_MicrolottoUrl').src);
    
    ajax = GetXMLHttpRequest(); 

  	if(ajax){
  				 
  		  ajax.open("GET", '../../CustomDoc/GetInfoModelloMicrolotto.asp?CODICE=' + escape(  objListaModelli.value ), false);
  	 		 
  			ajax.send(null);
  			
        
  			
  			if(ajax.readyState == 4) {
  			
  				if(ajax.status == 200)
  				{
  				
  				  if ( ajax.responseText != '' ) {
  				    var strresult = ajax.responseText;
  				    var ainfo = strresult.split('@@@');
              var ModelloOfferta=ainfo[2];
              //alert(ModelloOfferta);
              getObj('ModelloOffertaMicrolotto').value = ModelloOfferta ;
              
  				  }
  				}
  			}
  
  	}
    
    
    //recupero idmsg dell'offerta a cui sono legati i dettagli 
    var IdHeader = -1 ;
    var IDDOC = getObj('IdDoc').value;
    
    if(ajax){
  				 
  		  ajax.open("GET", '../../CustomDoc/GetMsgOffertaMicrolotto.asp?IDDOC=' + escape(  IDDOC ), false);
  	 		 
  			ajax.send(null);
  			
        
  			if(ajax.readyState == 4) {
  			   
  				if(ajax.status == 200)
  				{
  				
  				  if ( ajax.responseText != '' ) {
  				    IdHeader = ajax.responseText;
  				    //alert(IdHeader);
  				  }
  				}
  			}
  
  	}
        
    var strURL = '../../DASHBOARD/Viewer.asp?PATHTOOLBAR=../customdoc/&JScript=&Exit=&Table=View_Document_MicroLotti_Dettagli&OWNER=&IDENTITY=ID&TOOLBAR=&DOCUMENT=&AreaAdd=no&CaptionNoML=no&Caption=&Height=0,100*,210&numRowForPag=25&Sort=NumeroLotto&SortOrder=asc&ACTIVESEL=1&AreaFiltroWin=0&AreaFiltro=no&';  
    var  FilterHide = 'FilterHide=IdHeader=' + IdHeader ;
    strURL = strURL + FilterHide ;
    strURL = strURL + '&ModGriglia=' + ModelloOfferta ;
    getObj('iframe_MicroLotti_MicrolottoUrl').src = strURL;
    
     
  }
 
}     

//ritorna la desc relativo all'attributo Quiz della griglia
function GetDescriptionforQuiz( objName ){
  var aInfo;
  var nIndRrow;
  
  aInfo = objName.split('_');
  
  nIndRrow = aInfo[2];
  
  var strNameControl='TECNICA_griglia' ;
  var nPos=GetColumnPositionInGrid('DescrAttach',strNameControl);
  var strDesc ; 
  
  try{
    strDesc  = getObj(strNameControl + '_' + nIndRrow + '_' + nPos ).value ;
  }catch(e){
    strDesc  = getObj('cell_' + strNameControl + '_' + nIndRrow + '_' + nPos ).innerHTML ;
  }
  
  //strDesc = replace_special_charset(strDesc);
  //strDesc = escape( strDesc) ;
  return  strDesc;
}


 
 function HandleAreeRTI(){
    
    //setto onchange sul campo radio per nascondere visualizzare area RTI  
    var PartecipaFormaRTI = get_IdDztFromDztNome_AreaOfid('DOCUMENTAZIONE_comuneATI','PartecipaFormaRTI');
    
    getObj('elemento1_DOCUMENTAZIONE_comuneATI_' + PartecipaFormaRTI + '_1' ).style.display='inline';
    getObj('elemento1_DOCUMENTAZIONE_comuneATI_' + PartecipaFormaRTI + '_2' ).style.display='inline';
    
    //setto onchange sul campo radio per nascondere visualizzare area Consorzio  
    var Esecutrice = get_IdDztFromDztNome_AreaOfid('DOCUMENTAZIONE_ComuneConsorzio','InserisciEsecutriciLavori');
    
    getObj('elemento1_DOCUMENTAZIONE_ComuneConsorzio_' + Esecutrice + '_1' ).style.display='inline';
    getObj('elemento1_DOCUMENTAZIONE_ComuneConsorzio_' + Esecutrice + '_2' ).style.display='inline';
		
		//setto onchange sul campo radio per nascondere visualizzare area Avvalimento 
    var Avvalimento = get_IdDztFromDztNome_AreaOfid('DOCUMENTAZIONE_ComuneAvvalimento','RicorriAvvalimento');
    getObj('elemento1_DOCUMENTAZIONE_ComuneAvvalimento_' + Avvalimento + '_1' ).style.display='inline';
    getObj('elemento1_DOCUMENTAZIONE_ComuneAvvalimento_' + Avvalimento + '_2' ).style.display='inline';
    
    
	}
  	
</script>


 