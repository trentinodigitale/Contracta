function Disable()
{

	var i =1;
    var Last = 	DETTAGLIGrid_EndRow;
    
	//-- disattivo l'edit su tutti i nodi 
	/*
	try{
		for( i=0; i <= DETTAGLIGrid_EndRow ; i++ )
		{
	        getObj( 'R' + i + '_StatoRiga' ).disabled=true;
	        getObj( 'R' + i + '_EsitoRiga' ).disabled=true;					
		}	
	}catch(e){}   


	//-- attivo l'edit SOLO SULLE RIGHE UTILI
	try{
		for( i=0; i <= DETTAGLIGrid_EndRow ; i++ )
		{
			//-- se lo stato della riga è NonConforme si lascia editabile per consentirgli di cambiare idea
			if ( getObj( 'R' + i + '_StatoRiga' ).value=='NonConforme' )
			{
				getObj( 'R' + i + '_StatoRiga' ).disabled=false;
				getObj( 'R' + i + '_EsitoRiga' ).disabled=false;		
			}
			else
			{
			    //-- conservo l'ultima posizione da attivare
                Last = i;
                break;			     
			}
			//rank=getObj('R' + i + '_Graduatoria').value;
		}	
		
	}catch(e){}   
	
	
	//-- ora se l'ultima posizione attiva ha degli exequo allora vanno attivati anche questi per dare una conformità a tutti gli exequo
	try{
        rank=getObj('R' + Last + '_Graduatoria').value +'-'+getObj('R' + Last + '_Sorteggio').value;
		for( i=Last  ; i <= DETTAGLIGrid_EndRow ; i++ )
		{
			if ( rank == getObj( 'R' + i + '_Graduatoria' ).value  + '-' +getObj('R' + i + '_Sorteggio').value )
			{
			    getObj( 'R' + i + '_StatoRiga' ).disabled=false;
			    getObj( 'R' + i + '_EsitoRiga' ).disabled=false;					
			}
		}	
	}catch(e){}   

	*/
    return;





//	var rank
//	
//	rank=getObj('R0_Graduatoria').value +'-'+getObj('R0_Sorteggio').value;
//	
//	
//	
//	var i =1;
//	try{
//		for( i=1; i < DETTAGLIGrid_EndRow+1 ; i++ )
//		{
//			if ( rank != getObj( 'R' + i + '_Graduatoria' ).value  + '-' +getObj('R' + i + '_Sorteggio').value &&  getObj( 'R' + i + '_StatoRiga' ).value=='' )
//			{
//				getObj( 'R' + i + '_StatoRiga' ).disabled=true;
//				getObj( 'R' + i + '_EsitoRiga' ).disabled=true;					
//			}
//			//rank=getObj('R' + i + '_Graduatoria').value;
//		}	
//		
//	}catch(e){}   
//	
//	var next = 'si'
//		
//		for( i=0; i < DETTAGLIGrid_EndRow+1 ; i++ )
//		{			
//				if ( getObj('R' + i + '_StatoRiga').value == 'Conforme' || getObj('R' + 0 + '_StatoRiga').value=='' )
//				{
//					next = 'no'
//				}
//			
//		}
//		if ( next=='si' )
//		{
//		    rank=0;
//			for( i=0; i < DETTAGLIGrid_EndRow+1 ; i++ )
//			{
//				if ( getObj( 'R' + i + '_StatoRiga' ).disabled==true && ( rank==getObj('R' + i + '_Graduatoria').value + '-' +getObj('R' + i + '_Sorteggio').value ))
//				{
//				  getObj( 'R' + i + '_StatoRiga' ).disabled=false;
//				  rank=getObj('R' + i + '_Graduatoria').value + '-' +getObj('R' + i + '_Sorteggio').value ;
//				  
//				}
//			}	
//			
//		}
	
}

function controlli()
{
	var i =0;
	
	for( i=0; i < DETTAGLIGrid_EndRow+1 ; i++ )
	{
		if ( getObj( 'R' + i + '_StatoRiga' ).value == 'NonConforme' &&   getObj( 'R' + i + '_EsitoRiga' ).value == ''   )
		{
			return 'RIGAVUOTA';					
		}	
		if ( getObj( 'R' + i + '_StatoRiga' ).disabled==false && getObj( 'R' + i + '_StatoRiga' ).value!= '')
		{
			//if( getObj( 'R' + i + '_StatoRiga' ).value!= 'NonConforme' && getObj( 'R' + i + '_StatoRiga' ).value!= 'Conforme')
			//{
			//	return i;
			//} 
			
			if(  getObj( 'R' + i + '_StatoRiga' ).value == 'Conforme' &&   getObj( 'R' + i + '_EsitoRiga' ).value != '' )
			{
				return 'NONOTA';	
			}

		}
		
	}
	
	return 'ok'
	
	
	
}

function Conferma( param )
{
	var ret=controlli();
	if( ret != 'ok' && ret != 'RIGAVUOTA'  && ret != 'NONOTA' )
	{
		DMessageBox( '../' , 'Compilare correttamente le righe' , 'Attenzione' , 1 , 400 , 300 ); 
		getObj('R' + ret + '_StatoRiga').focus();
	}
	if (ret == 'RIGAVUOTA')
	{
		DMessageBox( '../' , 'Per ogni riga non conforme e\' necessario inserire delle note' , 'Attenzione' , 1 , 400 , 300 ); 	
	}
	if (ret == 'NONOTA')
	{
		DMessageBox( '../' , 'Per ogni riga conforme non e\' richiesta una motivazione' , 'Attenzione' , 1 , 400 , 300 ); 	
	}
	if (ret=='ok')
	{
		ExecDocProcess(param);   
	}
}

function OnChange_StatoRiga ( obj )
{
    Disable();

//	var Row=Number(obj.id.split('_')[0].substring(1));
//	var RowN=Row+1
//	var rank
//	
//	if ( obj.value == 'NonConforme' )
//	{
//		var next = 'si'
//		
//		for( i=0; i < DETTAGLIGrid_EndRow+1 ; i++ )
//		{
//			if ( getObj('R' + Row + '_Graduatoria').value == getObj('R' + i + '_Graduatoria').value)
//			{
//				if ( getObj('R' + i + '_StatoRiga').value == 'Conforme' )
//				{
//					next = 'no'
//				}
//			}
//		}
//		if ( next=='si' )
//		{
//			getObj( 'R' + RowN + '_StatoRiga' ).disabled=false;
//			getObj( 'R' + RowN + '_EsitoRiga' ).disabled=false;		
//			rank=getObj('R' + RowN + '_Graduatoria').value + '-' + getObj('R' + RowN + '_Sorteggio').value;
//			var i =RowN;
//			for( i=RowN; i < DETTAGLIGrid_EndRow+1 ; i++ )
//			{
//				if (rank == getObj( 'R' + i + '_Graduatoria' ).value  + '-' + getObj('R' + i + '_Sorteggio').value )
//				{
//					getObj( 'R' + i + '_StatoRiga' ).disabled=false;
//					getObj( 'R' + i + '_EsitoRiga' ).disabled=false;		
//				}
//				
//			}
//		}
//	}
}
window.onload=Disable;


function OpenBustaTec( objGrid , Row , c )
{
	if ( getObj( 'Divisione_lotti' ).value == '0'  )
		TipoDoc =  'OFFERTA#&CUR_FLD_SELECTED_ON_DOC=FLD_BUSTA_TECNICA'
	else
		TipoDoc =  'OFFERTA_BUSTA_TEC'
	 
    ShowDocumentFromAttrib( TipoDoc + ',' +  'R' + Row  + '_IdOffertaLotto' );
        
}
