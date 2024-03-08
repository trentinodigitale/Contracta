var visibleBelongCCIAA;

//funzione per inserire nella sezione documentazione i tipi allegati consentiti scelti in creazione del BANDO
function FormatAllegato()
{
	var numDocu = GetProperty( getObj('DOCUMENTAZIONE_RICHIESTAGrid') , 'numrow');
	var tipofile;
	var onclick;
	var obj;
	
	//alert(numDocu);
	
	for( i = 0 ; i <= numDocu ; i++ )
	{
		try
		{
			tipofile=getObj('RDOCUMENTAZIONE_RICHIESTAGrid_' + i + '_TipoFile').value;
			
			if ( tipofile != '' )
			{
				tipofile=ReplaceExtended(tipofile,'###',',');
				tipofile='EXT:'+tipofile.substring(1,tipofile.lenghth);
				tipofile=tipofile.substring(0, tipofile.length-1)+'-';
				tipofile='FORMAT='+tipofile;
				obj=getObj('RDOCUMENTAZIONE_RICHIESTAGrid_' + i + '_AllegatoRichiesto_V_BTN' ).parentElement;
				onclick=obj.innerHTML;
				onclick=onclick.replace(/FORMAT=NT/g,tipofile);
				obj.innerHTML = onclick;
			}
		}
		catch(e){}
	}

	
}


function Filtro_Classe_Iscrizione()
{
	
	//if(  getObjValue( 'StatoFunzionale' ) == 'InLavorazione'  )
	//{
		
		var class_bando = getObj('MerceologiaBando').value;
		var filter = '';
		
		//alert(class_bando);
		
		filter =  GetProperty ( getObj('ArtClasMerceologica'),'filter') ;				
		
			if ( filter == '' || filter == undefined || filter == null )
			{					
				
				/*
					dmv_cod in (  select B.dmv_cod  
						from ClasseIscriz a
					--adesso va solo in discesa se tolgo il commento risale anche
					INNER JOIN ClasseIscriz B ON a.dmv_father = left( b.dmv_father , len ( a.dmv_father ) ) --or b.dmv_father = left( a.dmv_father , len ( b.dmv_father ) )
					where  '###61###66###' like '%###' + A.DMV_COD + '###%'
					)
				*/
				
				//SetProperty( getObj('Merceologia'),'filter','SQL_WHERE= dmv_cod in (  select B.dmv_cod  from ClasseIscriz a  INNER JOIN ClasseIscriz B ON a.dmv_father = left( b.dmv_father , len ( a.dmv_father ) )  or  b.dmv_father = \'000.\'  or b.dmv_father = left( a.dmv_father , len ( b.dmv_father ) )     where  \'' + class_bando + '\' like \'%###\' + A.DMV_COD + \'###%\'    )');
				
				//SetProperty( getObj('Merceologia'),'filter','SQL_WHERE= dgcodiceinterno in (  select dgcodiceinterno  from dominigerarchici   where dgtipogerarchia = 16 and \'' + class_bando + '\' like \'%###\' + dgcodiceinterno + \'###%\'    )');
				SetProperty( getObj('ArtClasMerceologica'),'filter','SQL_WHERE= dgcodiceinterno   in (  select b.dgcodiceinterno  from dominigerarchici a INNER JOIN  dominigerarchici b ON  a.dgPath = left( b.dgPath , len ( a.dgPath ) )  or  b.dgPath = \'000.\'  or b.dgPath = left( a.dgPath , len ( b.dgPath ) )   where a.dgtipogerarchia = 16 and b.dgtipogerarchia = 16  and \'' + class_bando + '\' like \'%###\' + a.dgcodiceinterno + \'###%\'   )');
				
				                                            
			}			
	//}	
}



function Doc_DettagliDel( grid , r , c )
{
	var v = '0';
	try
	{
		v = getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + r + '_Obbligatorio' ).value ;
	}catch(e){};
	
    if( v == '1' )
    {
        //DMessageBox( '../' , 'La documentazione è obbligatoria' , 'Attenzione' , 1 , 400 , 300 );
    }
    else
    {
        DettagliDel( grid , r , c );
    }
}

function HideCestinodoc()
{
	
	
    
        var i = 0;
		var element='';
		
		try
		{
			for( i=0; i < DOCUMENTAZIONE_RICHIESTAGrid_EndRow+1 ; i++ )
			{
				//if( getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + i + '_AreaValutazione' ).value != '' )
				//{
							
					//getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + i + '_Obbligatorio' ).setAttribute("onclick","return false;");
					
				//}
				
				//alert(getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + i + '_Obbligatorio' ).value);
				
				//if( getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + i + '_Obbligatorio' ).checked == true )
				if( getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + i + '_Obbligatorio' ).value == 1 )
				{
					try
					{
						getObj( 'DOCUMENTAZIONE_RICHIESTAGrid_r' + i + '_c0' ).innerHTML = '&nbsp;';
						getObj( 'DOCUMENTAZIONE_RICHIESTAGrid_r' + i + '_c0' ).setAttribute("onclick","return false;");						
						getObj( 'DOCUMENTAZIONE_RICHIESTAGrid_r' + i + '_c0' ).setAttribute("class","");		
						//getObj( 'RDOCUMENTAZIONE_RICHIESTAGrid_' + i + '_FNZ_DEL' ).setAttribute("class","");
						
											
					}catch(e){};
				}
			}
			
		}catch(e){};
		
   
  
}

function DOCUMENTAZIONE_RICHIESTA_AFTER_COMMAND ()
{
	HideCestinodoc();
	FormatAllegato();
	
}



function OnLoadFunctions()
{  
	
	HideCestinodoc();
	FormatAllegato();
	Filtro_Classe_Iscrizione();
	
	//Reati1();
	//getObj( 'SentenzaReati').disabled=true;
	OnChangeBelongCCIAA ('');
	initAziEnte();
	
}
function readOnlyCheckBox() {
   return false;
}


function Reati1() 
{
if( getObj( 'CheckReati1' ).checked == true )
    {
      
	  getObj('CheckReati2').checked = false;
	  getObj( 'SentenzaReati').value="";
	  getObj( 'SentenzaReati').disabled=true;
	  
	  
    }
}
function Reati2() 
{
if( getObj( 'CheckReati2' ).checked == true )
    {
       getObj('CheckReati1').checked = false;	    
	   getObj( 'SentenzaReati').disabled=false;
    }
}

/*
function SetInitField()
{
    
	var i = 0;
	for( i = 0 ; i < NumControlli ; i++ )
	{
		if ( getObjValue('Not_Editable').indexOf( LstAttrib[i] + ' ,') < 0 )
		{
			TxtOK( LstAttrib[i] );
		}
	}

    
    
    
} 
*/

function trim(str){
    return str.replace(/^\s+|\s+$/g,"");
}


function controlli ()
{



	if (getObj('DOCUMENT_READONLY').value != '1' )
	{
			var err = 0;
			var	cod = getObj( "IDDOC" ).value;

			 
			var strRet = CNV( '../' , 'ok' );

			var Descr;

			//SetInitField();
			
			
			//-- effettuare tutti i controlli



			//-- controllo i dati della richiesta
			var i = 0;
			

			
			
			if( getObj( 'CheckReati2' ).checked == true )
			{
			  if( trim(getObjValue( 'SentenzaReati' )) == '' )
				{
					err = 1;/*TxtErr( 'SentenzaReati' );*/
					Descr = 'Per proseguire e\' necessaria la compilazione coerente del punto 3b relativo alle eventuali condanne per reati a danno dello stato';
				}	
			}
			
			
			if ( getObj( 'CheckReati1' ).checked == false &&  getObj( 'CheckReati2' ).checked == false  )
				{
					err = 1;
					Descr = 'Per proseguire e\' necessaria la compilazione coerente del punto 3b relativo alle eventuali condanne per reati a danno dello stato';
					/*
				  TxtErr( 'CheckReati1' );
				  TxtErr( 'CheckReati2' );
				  */
				}
				/*
				else
				{
						  TxtOK( 'CheckReati1' );
						  TxtOK( 'CheckReati2' );
				}   
				*/
				
			// controlla i campi obbligatori solo se la div è visibile	
			if ( visibleBelongCCIAA != 'NO' && err == 0 )
			{
				
				if( trim(getObjValue( 'ANNOCOSTITUZIONE' )) == '' ){err = 1;}	
				
				if( trim(getObjValue( 'SedeCCIAA' )) == '' ){err = 1;}
				
				if( trim(getObjValue( 'IscrCCIAA' )) == '' ){err = 1;}
				
				if (err == 1)
					Descr = 'Avvalorare Anno di Iscrizione, Provincia della Camera di Commercio e numero REA';
				
			}
			  
			  
			if(  err > 0 )
			{
				
				//DMessageBox( '../' , 'Per proseguire e\' necessaria la compilazione coerente del punto 3b relativo alle eventuali condanne per reati a danno dello stato' , 'Attenzione' , 1 , 400 , 300 );
				DMessageBox( '../' , Descr , 'Attenzione' , 1 , 400 , 300 );
				return -1;
			}
			else
				return 0;
		}


}


function InvioIstanza(  )
{
		
		var value=controlli();
		
	 
		if (value == -1)
			return;
	   
		
		ExecDocProcess( 'SEND:-1:CHECKOBBLIG,ISTANZA_AlboOperaEco_QF');
		
	 
	
}






window.onload = OnLoadFunctions;




function OnChangeBelongCCIAA ()
{
	
	visibleBelongCCIAA = '';
	
    try{
		if( getObjValue( 'BelongCCIAA' ) == 'NO'   )
		 {
			document.getElementById('BelongCCIAADIV').style.display = "none";	    
			visibleBelongCCIAA = 'NO';
		 }
		if( getObjValue( 'BelongCCIAA' ) == 'SI' )
		 {
			document.getElementById('BelongCCIAADIV').style.display = "";	    
		 }
	}catch( e ) 
	{
		if( getObjValue( 'val_BelongCCIAA' ) == 'NO'   )
		 {
			document.getElementById('BelongCCIAADIV').style.display = "none";	    
			visibleBelongCCIAA = 'NO';
		 }
		if( getObjValue( 'val_BelongCCIAA' ) == 'SI' )
		 {
			document.getElementById('BelongCCIAADIV').style.display = "";	    
		 }
	}
	
	
	
}



//GESTIONE DEI CAMPI LOCALITA PROVINCIA E STATO

function initAziEnte()
{
	enableDisableAziGeo('LocalitaRapLeg','ProvinciaRapLeg','StatoRapLeg','apriGEO',true);
	enableDisableAziGeo('ResidenzaRapLeg','ProvResidenzaRapLeg','StatoResidenzaRapLeg','apriGEO2',true);
	enableDisableAziGeo('LOCALITALEG','PROVINCIALEG','STATOLOCALITALEG','apriGEO3',true);
}


function impostaLocalita(cod,fieldname)
{
	ajax = GetXMLHttpRequest(); 
	
	var comuneTec;
	var provinciaTec;
	var statoTec;
	var comuneDesc; 
	var provinciaDesc;
	var statoDesc;
	
	if ( fieldname == 'RapLeg' )
	{
		comuneTec='LocalitaRapLeg2';
		provinciaTec='ProvinciaRapLeg2';
		statoTec='StatoRapLeg2';
		comuneDesc='LocalitaRapLeg';
		provinciaDesc='ProvinciaRapLeg';
		statoDesc='StatoRapLeg';
		geo='apriGEO'
	}
	if ( fieldname == 'ResidenzaRapLeg' )
	{
		comuneTec='ResidenzaRapLeg2';
		provinciaTec='ProvResidenzaRapLeg2';
		statoTec='StatoResidenzaRapLeg2';
		comuneDesc='ResidenzaRapLeg';
		provinciaDesc='ProvResidenzaRapLeg';
		statoDesc='StatoResidenzaRapLeg';
		geo='apriGEO2'
	}
	if ( fieldname == 'LOCALITALEG' )
	{
		comuneTec='LOCALITALEG2';
		provinciaTec='PROVINCIALEG2';
		statoTec='STATOLOCALITALEG2';
		comuneDesc='LOCALITALEG';
		provinciaDesc='PROVINCIALEG';
		statoDesc='STATOLOCALITALEG';
		geo='apriGEO3'
	}
	

	if(ajax)
	{
		ajax.open("GET", '../../ctl_library/functions/infoNodoGeo.asp?fldname=localita&cod=' + escape(cod), false);
		//output nella forma : COD-COMUNE#@#DESC-COMUNE#@#COD-PROVINCIA#@#DESC-PROVINCIA#@#COD-STATO#@#DESC-STATO
		ajax.send(null);

		if(ajax.readyState == 4) 
		{
			//Se non ci sono stati errori di runtime
			if(ajax.status == 200)
			{
				if ( ajax.responseText != '' ) 
				{
					var res = ajax.responseText;
					
					//Se l'esito della chiamata è stato positivo
					if ( res.substring(0, 2) == '1#' ) 
					{
						try
						{
							var vet = res.substring(4).split( '#@#' );
							
							var codLoc;
							var descLoc;
							var codProv;
							var descProv;
							var codStato;
							var descStato;

							codLoc = vet[0];
							descLoc = vet[1];
							codProv = vet[2];
							descProv = vet[3];
							codStato = vet[4];
							descStato = vet[5];

							getObj(comuneTec).value = codLoc;
							getObj(comuneDesc).value = descLoc;

							if ( codLoc == '' || codLoc.substring( codLoc.length-3, codLoc.length ) == 'XXX' )
								disableGeoField( comuneDesc, false);
							else
								disableGeoField( comuneDesc, true);

							getObj(provinciaTec).value = codProv;
							getObj(provinciaDesc).value = descProv;

							if ( codProv == '' || codProv.substring( codProv.length-3, codProv.length ) == 'XXX' )
								disableGeoField( provinciaDesc, false);
							else
								disableGeoField( provinciaDesc, true);

							getObj(statoTec).value = codStato;
							getObj(statoDesc).value = descStato;

							if ( codStato == ''  || codStato.substring( codStato.length-3, codStato.length ) == 'XXX' )
								disableGeoField( statoDesc, false);
							else
								disableGeoField( statoDesc, true);
								
						}
						catch(e)
						{
							alert('Errore:' + e.message);
							
						}
					}
					else
					{
						alert('errore.msg:' + res.substring(2));
						enableDisableAziGeo(comuneDesc,provinciaDesc,statoDesc,geo,false);
					}
				}
			}
			else
			{
				alert('errore.status:' + ajax.status);
				enableDisableAziGeo(comuneDesc,provinciaDesc,statoDesc,geo,false);
				
			}
		}
		else
		{
			alert('errore in impostaLocalita');
			enableDisableAziGeo(comuneDesc,provinciaDesc,statoDesc,geo,false);
		}
	}
}