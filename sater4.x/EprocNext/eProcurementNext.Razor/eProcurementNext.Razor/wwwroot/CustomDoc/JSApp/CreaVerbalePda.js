function CreaVerbalePda( objGrid , Row , c )
{
	var cod;
	var nq;
  var strURL;
  var IdMsgSource;
  var NumVerbali;
  var VerbaleMultiplo;
  
	//-- recupero il codice della riga passata
	cod = GetIdRow( objGrid , Row , 'self' );

  //-- recupero numero verbali fatti del tipo corrente
  NumVerbali = 0 ;
  
  NumVerbali = getObjValue ('R' + Row + '_NumeroVerbali' )
  
  //recupero se sono ammessi n verbali
  VerbaleMultiplo='no';
  VerbaleMultiplo = getObjValue( 'val_R' + Row + '_Multiplo') ;
  
  
  if ( NumVerbali > 0 && VerbaleMultiplo == 'no' ){
    
    DMessageBox( '../CTL_Library/' , 'non possibile creare un altro verbale di questa tipologia' , 'Attenzione' , 2 , 400 , 300 ); 
    return; 
  }
  
  //recupero idmsg della PDA
	IdMsgSource = getObj('DOCUMENT').value;
	
  strURL = '../CustomDoc/CreaVerbaleGara.asp?ProvenienzaPortale=1&lIdmpPar=1&lIdMsgPar=' + IdMsgSource + '&ID=' + cod
  
  //alert(strURL);
  
	ExecFunctionCenter( strURL + '#VerbalediGara' );
	
}