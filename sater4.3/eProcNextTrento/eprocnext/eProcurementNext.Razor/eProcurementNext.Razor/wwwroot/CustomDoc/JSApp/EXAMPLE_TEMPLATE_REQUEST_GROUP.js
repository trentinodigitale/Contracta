window.onload = Onload_Page;

function Onload_Page()
{

	var nocache = new Date().getTime();

	//-- recupera l'esempio da visualizzare
	responseText = SUB_AJAX(  '../../CustomDoc/EXAMPLE_TEMPLATE_REQUEST_GROUP.ASP?IDMODULO=' + getObjValue( 'IDDOC' ) + '&nocache=' + nocache );
	getObj( 'EXAMPLE_CONTAINER_MODULE_REQUEST').innerHTML = responseText;
	
	
	//ajax.open("GET",   '../../CustomDoc/EXAMPLE_TEMPLATE_REQUEST_GROUP.ASP?IDMODULO=' + getObj( 'IDDOC' ) + '&nocache=' + nocache , false);
	//ajax.send(null);

	//if(ajax.readyState == 4) 
	//{
	//	if(ajax.status == 200)
	//	{
	//		getObj( 'EXAMPLE_CONTAINER_MODULE_REQUEST').innerHTML = ajax.responseText;
	//	}
	//}
	
	
	//-- aggiusta il tooltip
	$( function() {
		//$( document ).tooltip
		$('[data-toggle="tooltip"]').tooltip({
			items: "img, [data-toggle], [title]",
			content: function() {
				var element = $( this );
				if ( element.is( "[data-geo]" ) ) {
					var text = element.title();
					return '<div  class="TTBS" >' + unescape( text ) + '</div>';
				}
				if ( element.is( "[title]" ) ) {
					var text = element.attr( "title" );
					return '<div  class="TTBS" >' + unescape( text ) + '</div>';					
					//return element.attr( "title" );
				}
				if ( element.is( "img" ) ) {
					return element.attr( "alt" );
				}
			}
		});
	} );
	
  //$('[data-toggle="tooltip"]').tooltip(); 
	
}