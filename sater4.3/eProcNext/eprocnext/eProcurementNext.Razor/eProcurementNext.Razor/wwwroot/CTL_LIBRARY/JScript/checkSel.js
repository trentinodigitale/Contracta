
function SelectAll( strCheck )
{
	CheckSel(strCheck , 1 );
}

function DeselectAll( strCheck )
{
	CheckSel(strCheck , 2 );
}

function InvertSelection( strCheck )
{
	CheckSel(strCheck , 3 );
}

//-- sull'oggetto passato in input mette, toglie o inverte la selezione
function CheckSel(strCheck , Tipo )
{
	var iNumCeck;
	var iLoop;
	var objCheck;
	
	objCheck = getObj( strCheck );
	
	if (objCheck!= null) //controlliamo se vi sono check
	{
		iNumCeck=objCheck.length;

		if (iNumCeck!=null)
		{
			for (iLoop=0;iLoop<iNumCeck;iLoop++)
			{
				SetSel( objCheck[iLoop] , Tipo );
			}
		}
		else
		{
			SetSel( objCheck , Tipo );
		}
		
	}
	return	
}

function SetSel( obj , tipo )
{
	if ( tipo == 1 )
	{
		obj.checked = true;	
	}
	
	if ( tipo == 2 )
	{
		obj.checked = false
	}

	if ( tipo == 3 )
	{

		if (obj.checked == true )
		{
			obj.checked = false;
		}
		else
		{
			obj.checked = true;	
		}
	
	}

}

