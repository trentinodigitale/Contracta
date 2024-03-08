

window.onload = Init_ODC;


function Init_ODC(){
  
  //se senza quote nascondo ResiduoQuote
  if (getObj('GestioneQuote').value == 'senzaquote'){
	 $( "#cap_ImportoQuota" ).parents("table:first").css({"display":"none"})
  }
  
  //se TipoScadenzaOrdinativo sulla convenzione =immediatamenteesecutivo
  //nascondo data sacdenza ordinativo
  if (getObj('TipoScadenzaOrdinativo').value == 'immediatamenteesecutivo'){
    $( "#cap_RDA_DataScad" ).parents("table:first").css({"display":"none"})
  }
  
  
  //se tipoimporto è ivainclusa o esente nascondo valoreiva e totaleordinativocon iva
  if ( getObj('TipoImporto').value == 'esente' || getObj('TipoImporto').value == 'ivainclusa' ){
    $( "#cap_ValoreIva" ).parents("table:first").css({"display":"none"})
    $( "#cap_TotalIva" ).parents("table:first").css({"display":"none"})
  }
  
}


