function STORICOCONTROLLI_OnLoad(){

  

  //recupero id documento
  //var IDDOC = getObj( 'IDDOC' ).value;
  
  //alert(IDDOC);

  //recupero id azienda;
  idazi=getObj('idAziControllata').value;

  
  //strFilterhide='idazicontrollata=' + idazi + ' and ((idSchedaGara <> ' + IDDOC.value + ') or (idschedagara is null))';
  strFilterhide='idazicontrollata=' + idazi  + ' and Protocol <> \'\'';
  
  //url viewer per storico controlli dell'azienda;
  URLVIEWER='../../DASHBOARD/Viewer.asp?AreaFiltro=no&Table=Document_Aziende_Comunicazioni&OWNER=&IDENTITY=idazicontrollata&TOOLBAR=&DOCUMENT=&PATHTOOLBAR=&AreaAdd=no&Caption=&Height=130,100*,210&numRowForPag=25&Sort=tipocomunicazione&SortOrder=asc&ACTIVESEL=1&FilterHide=' + strFilterhide;
  
  
  //carico viewer nell'area statica;
  frames['STORICOCONTROLLI'].location=URLVIEWER;

}