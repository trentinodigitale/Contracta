
function GetCheckSel(strCheck )
{
	var iNumCeck;
	var iLoop;
	var objCheck;
	var ret='';
	
	objCheck = getObj( strCheck );
	
	if (objCheck!= null) //controlliamo se vi sono check
	{
		iNumCeck=objCheck.length;

		if (iNumCeck!=null)
		{
			for (iLoop=0;iLoop<iNumCeck;iLoop++)
			{
				if ( objCheck[iLoop].checked )
				{
					if ( ret != '' ) ret = ret + ',';
					ret = ret + objCheck[iLoop].value;
				}
			}
		}
		else
		{
			if ( objCheck.checked )
			{
				ret = objCheck.value;
			}
		}
		
	}
	return	ret;
}
