
window.onload= ShowFieldModalita;



function ShowFieldModalita( )
{
	
	
	var flag_sorteggio_territoriale =  getObj( 'Flag_SorteggioTerritoriale' ).value;
	var DOCUMENT_READONLY = getObj( 'DOCUMENT_READONLY' ).value;
	var ObjNumMinimo;
	var ObjNumOE;
	var ObjModalita;
	var Objterritorio;
	
	//recupero oggetti da visualizzare/nascondere a seconda se il doc è readonly oppure no
	if ( DOCUMENT_READONLY == "1")
	{
		ObjNumOE = getObj( 'NumOeSorteggiati_V' ).parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
		ObjModalita = getObj( 'val_ModalitadiSorteggio' ).parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
		ObjNumMinimo = getObj( 'NumeroMinimoOperatoridaInvitare_V' ).parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
		Objterritorio = getObj( 'aziProvinciaLeg3' ).parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
		
	}
	else
	{	
		ObjNumOE = getObj( 'NumOeSorteggiati' ).parentNode.parentNode.parentNode;
		ObjModalita = getObj( 'ModalitadiSorteggio' ).parentNode.parentNode.parentNode.parentNode;
		ObjNumMinimo = getObj( 'NumeroMinimoOperatoridaInvitare' ).parentNode.parentNode.parentNode;
		Objterritorio = getObj( 'aziProvinciaLeg3_edit_new' ).parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
	}
	
	//alert (getObj( 'ModalitadiSorteggio' ).value);
	var strModalitaSorteggio = getObj( 'ModalitadiSorteggio' ).value;
	
	//if ( DOCUMENT_READONLY == "0")
	//{
	
		//var ObjNumOE = getObj( 'NumOeSorteggiati' ).parentNode.parentNode.parentNode;
		
		//var ObjNumMinimo = getObj( 'NumeroMinimoOperatoridaInvitare' ).parentNode.parentNode.parentNode;
		//var Objterritorio = getObj( 'aziProvinciaLeg3_edit_new' ).parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
		
		setVisibility( ObjNumMinimo , 'none' );
		setVisibility( Objterritorio , 'none' );
		setVisibility( ObjNumOE , 'none' );
		
		if ( strModalitaSorteggio == 'sorteggioterritoriale' ) 
		{
			setVisibility( ObjNumMinimo , '' );
			setVisibility( Objterritorio , '' );
			setVisibility( ObjNumOE , 'none' );
			
		}
		
		if ( strModalitaSorteggio == 'num_oe_da_sorteggiare' ) 
		{
			setVisibility( ObjNumMinimo , 'none' );
			setVisibility( Objterritorio , 'none' );
			setVisibility( ObjNumOE , '' );
		}
	//}		
}