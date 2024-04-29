
function PosTop( obj )
{

	//return GetTop (obj);

	var p;
	var t;
	
	t = obj.offsetTop;
	
	p = obj.offsetParent;
	
	while( p != null )
	{
		t += p.offsetTop;
		p = p.offsetParent;	
	}

	return t;
}

function PosLeft( obj )
{

	//return GetLeft (obj);

	var p;
	var t;
	
	t = obj.offsetLeft;
	
	p = obj.offsetParent;
	
	while( p != null )
	{
		t += p.offsetLeft;
		p = p.offsetParent;	
	}
	
	return t;
}

function GetOffset (object, offset) 
{
	if (!object)
		return;
		
	offset.x += object.offsetLeft;
	offset.y += object.offsetTop;

	GetOffset (object.offsetParent, offset);
}

function GetScrolled (object, scrolled)
{
	if (!object)
		return;
		
	scrolled.x += object.scrollLeft;
	scrolled.y += object.scrollTop;

	if (object.tagName.toLowerCase () != "html")
	{
		GetScrolled (object.parentNode, scrolled);
	}
}

function GetTop (obj) 
{
	var div = obj;
	var offset = {x : 0, y : 0};
	
	GetOffset (div, offset);

	var scrolled = {x : 0, y : 0};
	GetScrolled (div.parentNode, scrolled);

	var posX = offset.x - scrolled.x;
	var posY = offset.y - scrolled.y;
	
	return posX;
	
}

function GetLeft (obj) 
{
	var div = obj;
	var offset = {x : 0, y : 0};
	
	GetOffset (div, offset);

	var scrolled = {x : 0, y : 0};
	GetScrolled (div.parentNode, scrolled);

	var posX = offset.x - scrolled.x;
	var posY = offset.y - scrolled.y;
	
	return posY;
}
