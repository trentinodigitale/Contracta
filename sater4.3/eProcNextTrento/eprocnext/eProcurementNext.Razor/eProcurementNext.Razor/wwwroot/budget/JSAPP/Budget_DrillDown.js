function Budget_DrillResiduo( strNameGrid,nInd,nIndCol )
{
 var nIdDett;
 var period;
 var ATTRIB_KEY_DRILL;
 var key;
 
 //debugger; 
 Key=escape( GetIdRow( strNameGrid , nInd , ''));
 try {
 
  period = getObj( 'PERIOD' ).value;
  var FilterHide  = getObj( 'FILTERHIDE' ).value;
  ATTRIB_KEY_DRILL =  getObj( 'ATTRIB_KEY_DRILL' ).value ;
  //alert( Key);
  //alert( escape( getObj( 'ATTRIB_KEY_DRILL' ).value ));
 
  TypeMove = '\'BudgetDefinition\',\'Prenotation\',\'Approvation\',\'Ordered\',\'Rettifica\',\'Revisione\'';
  ExecFunction( 'Budget_DrillDown.asp?FilterHide=' + FilterHide + '&CAPTION=Dettaglio movimenti residuo&PERIOD=' + period + '&ATTRIB_KEY_DRILL=' + ATTRIB_KEY_DRILL + '&KEY_DRILL=' + Key + '&TYPE_MOVEMENT=' + TypeMove + '&Sort=BDM_Data&SortOrder=asc&numRowForPag=15' , 'Budget_DrillDown' , ',height=600,width=800' );
  
  //ExecFunction( 'Budget_DrillDown.asp?FilterHide=' + FilterHide + '&CAPTION=Dettaglio movimenti residuo&PERIOD=' + period + '&ATTRIB_KEY_DRILL=' + ATTRIB_KEY_DRILL + '&KEY_DRILL=' + Key + '&TYPE_MOVEMENT=&Sort=BDM_Data&SortOrder=asc&numRowForPag=15' , 'Budget_DrillDown' , ',height=600,width=800' );
 
 }
 catch( e ) {};
 
 
}
 


function Budget_DrillResiduoNORDA( strNameGrid,nInd,nIndCol )
{
 var nIdDett;
 var period;
 var ATTRIB_KEY_DRILL;
 var key;
 
 //debugger; 
 Key=escape( GetIdRow( strNameGrid , nInd , ''));
 try {
 
  period = getObj( 'PERIOD' ).value;
  var FilterHide  = getObj( 'FILTERHIDE' ).value;
  ATTRIB_KEY_DRILL =  getObj( 'ATTRIB_KEY_DRILL' ).value ;
  //alert( Key);
  //alert( escape( getObj( 'ATTRIB_KEY_DRILL' ).value ));
 
  TypeMove = '\'BudgetDefinition\',\'Prenotation\',\'Approvation\',\'OrderedRDA\',\'Ordered\',\'Rettifica\',\'Revisione\'';
  ExecFunction( 'Budget_DrillDown.asp?FilterHide=' + FilterHide + '&CAPTION=Dettaglio movimenti residuo&PERIOD=' + period + '&ATTRIB_KEY_DRILL=' + ATTRIB_KEY_DRILL + '&KEY_DRILL=' + Key + '&TYPE_MOVEMENT=' + TypeMove + '&Sort=BDM_Data&SortOrder=asc&numRowForPag=15' , 'Budget_DrillDown' , ',height=600,width=800' );
  
  //ExecFunction( 'Budget_DrillDown.asp?FilterHide=' + FilterHide + '&CAPTION=Dettaglio movimenti residuo&PERIOD=' + period + '&ATTRIB_KEY_DRILL=' + ATTRIB_KEY_DRILL + '&KEY_DRILL=' + Key + '&TYPE_MOVEMENT=&Sort=BDM_Data&SortOrder=asc&numRowForPag=15' , 'Budget_DrillDown' , ',height=600,width=800' );
 
 }
 catch( e ) {};
 
 
}
 



function Budget_DrillPrenotato( strNameGrid,nInd,nIndCol )
{
 var TypeMove;
 var period;
 var ATTRIB_KEY_DRILL;
 var key;
 
 //debugger; 
 Key=escape( GetIdRow( strNameGrid , nInd , ''));
 try {
 
  var FilterHide  = getObj( 'FILTERHIDE' ).value;
  period = getObj( 'PERIOD' ).value;
  ATTRIB_KEY_DRILL =  getObj( 'ATTRIB_KEY_DRILL' ).value ;
  //alert( Key);
  //alert( escape( getObj( 'ATTRIB_KEY_DRILL' ).value ));
 
  TypeMove = '\'Prenotation\'';
  ExecFunction( 'Budget_DrillDown.asp?FilterHide=' + FilterHide + '&CAPTION=Dettaglio movimenti prenotazione&PERIOD=' + period + '&ATTRIB_KEY_DRILL=' + ATTRIB_KEY_DRILL + '&KEY_DRILL=' + Key + '&TYPE_MOVEMENT=' + TypeMove + '&Sort=BDM_Data&SortOrder=asc&numRowForPag=15' , 'Budget_DrillDown' , ',height=600,width=800' );
 
 }
 catch( e ) {};
 
 
}
 

function Budget_DrillApprovato( strNameGrid,nInd,nIndCol )
{
 var TypeMove;
 var period;
 var ATTRIB_KEY_DRILL;
 var key;
 
 //debugger; 
 Key=escape( GetIdRow( strNameGrid , nInd , ''));
 try {
 
  var FilterHide  = getObj( 'FILTERHIDE' ).value;
  period = getObj( 'PERIOD' ).value;
  ATTRIB_KEY_DRILL =  getObj( 'ATTRIB_KEY_DRILL' ).value ;
  //alert( Key);
  //alert( escape( getObj( 'ATTRIB_KEY_DRILL' ).value ));
 
  //TypeMove = '\'Approvation\',\'OrderDeleted\'';
  TypeMove = '\'Approvation\'';
  ExecFunction( 'Budget_DrillDown.asp?FilterHide=' + FilterHide + '&CAPTION=Dettaglio movimenti aprovato&PERIOD=' + period + '&ATTRIB_KEY_DRILL=' + ATTRIB_KEY_DRILL + '&KEY_DRILL=' + Key + '&TYPE_MOVEMENT=' + TypeMove + '&Sort=BDM_Data&SortOrder=asc&numRowForPag=15' , 'Budget_DrillDown' , ',height=600,width=800' );
 
 }
 catch( e ) {};
 
 
}
 
function Budget_DrillOrdinato( strNameGrid,nInd,nIndCol )
{
 var TypeMove;
 var period;
 var ATTRIB_KEY_DRILL;
 var key;
 
 //debugger; 
 Key=escape( GetIdRow( strNameGrid , nInd , ''));
 try {
 
  var FilterHide  = getObj( 'FILTERHIDE' ).value;
  period = getObj( 'PERIOD' ).value;
  ATTRIB_KEY_DRILL =  getObj( 'ATTRIB_KEY_DRILL' ).value ;
  //alert( Key);
  //alert( escape( getObj( 'ATTRIB_KEY_DRILL' ).value ));
 
  TypeMove = '\'Ordered\'';
  ExecFunction( 'Budget_DrillDown.asp?FilterHide=' + FilterHide + '&CAPTION=Dettaglio movimenti ordinato&PERIOD=' + period + '&ATTRIB_KEY_DRILL=' + ATTRIB_KEY_DRILL + '&KEY_DRILL=' + Key + '&TYPE_MOVEMENT=' + TypeMove + '&Sort=BDM_Data&SortOrder=asc&numRowForPag=15' , 'Budget_DrillDown' , ',height=600,width=800' );
 
 }
 catch( e ) {};
 
 
}
 
function Budget_DrillDefinito( strNameGrid,nInd,nIndCol )
{
 var TypeMove;
 var period;
 var ATTRIB_KEY_DRILL;
 var key;
 
 //debugger; 
 Key=escape( GetIdRow( strNameGrid , nInd , ''));
 try {
 
  var FilterHide  = getObj( 'FILTERHIDE' ).value;
  period = getObj( 'PERIOD' ).value;
  ATTRIB_KEY_DRILL =  getObj( 'ATTRIB_KEY_DRILL' ).value ;
  //alert( Key);
  //alert( escape( getObj( 'ATTRIB_KEY_DRILL' ).value ));
 
  TypeMove = '\'BudgetDefinition\',\'Rettifica\',\'Revisione\'';
  ExecFunction( 'Budget_DrillDown.asp?FilterHide=' + FilterHide + '&CAPTION=Dettaglio movimenti previsionale&PERIOD=' + period + '&ATTRIB_KEY_DRILL=' + ATTRIB_KEY_DRILL + '&KEY_DRILL=' + Key + '&TYPE_MOVEMENT=' + TypeMove + '&Sort=BDM_Data&SortOrder=asc&numRowForPag=15' , 'Budget_DrillDown' , ',height=600,width=800' );
 
 }
 catch( e ) {};
 
 
}


function Budget_DrillConsegnato( strNameGrid,nInd,nIndCol )
{
 var TypeMove;
 var period;
 var ATTRIB_KEY_DRILL;
 var key;
 
 //debugger; 
 Key=escape( GetIdRow( strNameGrid , nInd , ''));
 try {
 
  var FilterHide  = getObj( 'FILTERHIDE' ).value;
  period = getObj( 'PERIOD' ).value;
  ATTRIB_KEY_DRILL =  getObj( 'ATTRIB_KEY_DRILL' ).value ;
  //alert( Key);
  //alert( escape( getObj( 'ATTRIB_KEY_DRILL' ).value ));
 
  TypeMove = '\'BOLLA\'';
  ExecFunction( 'Budget_DrillDown.asp?FilterHide=' + FilterHide + '&CAPTION=Dettaglio movimenti Consegnato&PERIOD=' + period + '&ATTRIB_KEY_DRILL=' + ATTRIB_KEY_DRILL + '&KEY_DRILL=' + Key + '&TYPE_MOVEMENT=' + TypeMove + '&Sort=BDM_Data&SortOrder=asc&numRowForPag=15' , 'Budget_DrillDown' , ',height=600,width=800' );
 
 }
 catch( e ) {};
 
 
}


function Budget_DrillColumn( strNameGrid,nInd,nIndCol )
{
 var TypeMove;
 var period;
 var ATTRIB_KEY_DRILL;
 var key;
 
 //debugger; 
 Key=escape( GetIdRow( strNameGrid , nInd , ''));
 try {
 
  var strColName = GetColName( strNameGrid, nIndCol , '' )
 
  var FilterHide  = getObj( 'FILTERHIDE' ).value;
  
  if ( FilterHide == '' ) 
  {
	FilterHide = ' ' + strColName + ' <> 0 ';
  }
  else
  {
  	FilterHide = FilterHide + ' and ' + strColName + ' <> 0 ';
  }
  
  period = getObj( 'PERIOD' ).value;
  ATTRIB_KEY_DRILL =  getObj( 'ATTRIB_KEY_DRILL' ).value ;
 
  TypeMove = '';
  ExecFunction( 'Budget_DrillDown.asp?FilterHide=' + FilterHide + '&CAPTION=Dettaglio movimenti ' + strColName + '&PERIOD=' + period + '&ATTRIB_KEY_DRILL=' + ATTRIB_KEY_DRILL + '&KEY_DRILL=' + Key + '&TYPE_MOVEMENT=' + TypeMove + '&Sort=&SortOrder=&numRowForPag=15' , 'Budget_DrillDown' , ',height=600,width=800' );
 
 }
 catch( e ) {};
 
 
}


function GetColName( grid , indexCol , Page )
{

	var objInd;
	var nInd; 
	var obj;
	var numRow;
	var name;
	
	
	try
	{
		
		obj = getObjPage( grid  , Page);

		try
		{
			name =  obj.cells[ indexCol ].id;
		}
		catch(  e ){
			name =  obj[0].cells[ indexCol ].id;
	  	};

		//toglgie dal nome della colonna il nome della griglia
		return name.substr( grid.length + 1 );
	}
	catch(  e ){  	};
	
	
	
	

}
