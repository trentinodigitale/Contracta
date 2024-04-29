

function DrawPropertySelector( id )
{
	var numPag;  //-- numero di pagine
	var html;    //-- TABELLA html che contiene la barra di paginazione
	var curPag;  //-- pagina corrente
	var startPag;  //-- pagina corrente
	var i;
	var html;
	var incP;
	var incC;
	
	//debugger;
	
	var style = eval( id + '_Style' ); 
	var num = eval( id + '_Num' ); 
	var attrib = eval( id + '_Attrib' ); 
	var caption = eval( id + '_Caption' ); 
	var vCap = caption.split( ',' );
	var pathImg = eval( id + '_strPath' ); 
	var value = '';

	try {

	//-- disegno la tabella con tutti gli attributi
	html =  '<table width=\"100\%\" height=\"100\%\" class=\"' + style + '_Table\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" >\n';

	//-- disegno la caption
	html = html + '<tr class=\"' + style + '_Caption\"  >\n';
		html = html + '<td>' + vCap[0] + '</td>\n';
		html = html + '<td>' + vCap[1] + '</td>\n';
		html = html + '<td>' + vCap[2] + '</td>\n';
		html = html + '<td>' + vCap[3] + '</td>\n';
		html = html + '<tr>\n'; 


	//-- disegno le righe
	for( i = 0; i < num ; i++ )
	{
		//debugger;
		html = html + '<tr class=\"' + style + '_Row\" >\n';
		//-- nome attributo
		html = html + '<td nowrap class=\"' + style + '_td\" >' + attrib[i][1] + '</td>\n';

		//-- checjk di visualizzazione
		html = html + '<td align=\"center\"  class=\"' + style + '_td\" ><input type=\"checkbox\" name=\"C1\" value=\"' + i + '\" onclick=\"ChangeVis( \'' + id + '\' , ' + i + ' , this.checked );\" ';
		if( attrib[i][2] == '1' ) html = html + 'checked';
		html = html + ' ></td>\n'; 

		
		//-- spin di sort
		html = html + '<td align=\"center\"  class=\"' + style + '_td\" ><table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" >';
		html = html + '<tr><td><img border=\"0\" src=\"' + pathImg + 'up.png\" onclick=\"MoveUpProp( \'' + id + '\' , ' + i + ' );\" ></td></tr>';
		html = html + '<tr><td><img border=\"0\" src=\"' + pathImg + 'down.png\" onclick=\"MoveDownProp( \'' + id + '\' , ' + i + ' );\" ></td></tr>';
		html = html + '</table>';
		html = html + '</td>\n';

		//-- combo per il tipo sort selected
		html = html + '<td align=\"center\" class=\"' + style + '_td\" ><select name=\"' + id + '_Sel' + i + '\" onchange=\"ChangeOrd( \'' + id + '\' , ' + i + ' , this.value );\" >';
		if( attrib[i][4] == 'asc' ){
			html = html + '<option selected value=\"asc\" >asc</option>';
			html = html + '<option  value=\"desc\" >desc</option>';
		}else{
			html = html + '<option  value=\"asc\" >asc</option>';
			html = html + '<option selected value=\"desc\" >desc</option>';
		}
		html = html + '</select> </td>\n';

		html = html + '</tr>\n';
		

	}
	html = html + '</table>\n'; 

	
	SetValuePropertySelector( id );
	

	//-- sostituzione della tabella nella div
	getObj( id + '_Control' ).innerHTML = html;
	
	}catch(e){
		alert('DrawPropertySelector'+e);
	}
	
}



function SetValuePropertySelector( id )
{
	var i;
	
	var num = eval( id + '_Num' ); 
	var attrib = eval( id + '_Attrib' ); 
	var value = '';
	var elem;
	
	try 
	{

		//-- 
		for( i = 0; i < num ; i++ )
		{
			value =  value + attrib[i][0] + ',' + attrib[i][2] + ',' + attrib[i][4] + '#';
		}

		getObj( id ).value = value;
		elem = getObj( id ); //Salvo l'elemento prima di cancellarlo dal dom

		//Cancello l'elemento 'property' e poi lo inserisco come figlio del form di ricerca così da farlo finire in post
		// quando viene fatta una submit
		
		removeElement(id);
		
		if (document.getElementById('FormViewerFiltro'))
			document.getElementById('FormViewerFiltro').appendChild(elem);

	}catch(e){
		//alert('SetValuePropertySelector'+e);
	}
	
}

function  ChangeVis( id , pos , chk )
{
	var num = eval( id + '_Num' ); 
	var attrib = eval( id + '_Attrib' ); 
	//debugger;
	if( chk )
	{
		attrib[pos][2]='1';
	}
	else
	{
		attrib[pos][2]='0';
	}
	
	SetValuePropertySelector( id );

	//-- controlla che ci sia almeno un elemento selezionato
	var i;
	//debugger;
	for ( i = 0 ; i < num ; i++ )
	{
		if ( attrib[i][2]=='1' )
		{
			return;
		}
	}
	attrib[0][2]='1';
	DrawPropertySelector( id );
}

function  ChangeOrd( id , pos , val )
{
	var num = eval( id + '_Num' ); 
	var attrib = eval( id + '_Attrib' ); 

	attrib[pos][4]=val;
	
	SetValuePropertySelector( id );

}

function  MoveUpProp( id , pos )
{
	//debugger;
	var num = eval( id + '_Num' ); 
	var attrib = eval( id + '_Attrib' ); 

	if(  pos == 0 ) return;
	
	
	//-- scambia le posizioni
	var ap;
	ap = attrib[pos];
	attrib[pos] = attrib[pos-1];
	attrib[pos-1] = ap;
	
	//ap = getObj( id + '_Control' ).children[0].rows[pos +1].innerHTML;
	//getObj( id + '_Control' ).children[0].rows[pos +1].innerHTML = getObj( id + '_Control' ).children[0].rows[pos ].innerHTML;
	//getObj( id + '_Control' ).children[0].rows[pos ].innerHTML = ap;
	
	//ap = getObj( id + '_Row'+ pos ).innerHTML;
	//getObj( id + '_Row'+ ( pos ) ).innerHTML = getObj( id + '_Row'+ ( pos - 1 ) ).innerHTML;
	//getObj( id + '_Row'+ ( pos - 1 ) ).innerHTML = ap;

	//InvertTR( getObj( id + '_Row'+ pos ) , getObj( id + '_Row'+ ( pos - 1 ) ) );

	DrawPropertySelector( id );
}

function  MoveDownProp( id , pos )
{

	var num = eval( id + '_Num' ); 
	var attrib = eval( id + '_Attrib' ); 

	
	if( pos + 1 >= num )return;
	
	//-- scambia le posizioni
	var ap;
	ap = attrib[pos];
	attrib[pos] = attrib[pos+1];
	attrib[pos+1] = ap;

	//ap = getObj( id + '_Control' ).children[0].rows[pos +1].innerHTML;
	//getObj( id + '_Control' ).children[0].rows[pos +1].innerHTML = getObj( id + '_Control' ).children[0].rows[pos + 2 ].innerHTML;
	//getObj( id + '_Control' ).children[0].rows[pos +2].innerHTML = ap;

	//ap = getObj( id + '_Row'+ pos ).innerHTML;
	//getObj( id + '_Row'+ pos ).innerHTML = getObj( id + '_Row'+ ( pos + 1 ) ).innerHTML;
	//getObj( id + '_Row'+ ( pos + 1 ) ).innerHTML = ap;
	
	//InvertTR( getObj( id + '_Row'+ pos ) , getObj( id + '_Row'+ ( pos + 1 ) ) );
	
	DrawPropertySelector( id );
}

function InvertTR( R1 , R2 )
{
	var n = R1.children.length;
	var i;
	var ap
	
	for ( i = 0 ; i < n ; i++ )
	{
		ap = R1.children[i].innerHTML;
		R1.children[i].innerHTML = R2.children[i].innerHTML;
		R2.children[i].innerHTML = ap;
	}

}