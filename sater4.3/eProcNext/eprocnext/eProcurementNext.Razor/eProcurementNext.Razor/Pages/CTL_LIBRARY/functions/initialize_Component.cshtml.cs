using Microsoft.AspNetCore.Mvc.RazorPages;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class initialize_ComponentModel : PageModel
    {

        //  <%
        //	dim MyGlobalObjRds
        //	if application("AddressOfObject") <> "" then 
        //		if isempty(MyGlobalObjRds) then set MyGlobalObjRds = server.createObject("RDS.Dataspace")	
        //	end if	

        //	function MyCreateObject(strProgId)

        //		if application("AddressOfObject") <> "" then
        //			set MyCreateObject = MyGlobalObjRds.createObject(strProgId, application("AddressOfObject"))
        //		else
        //			set MyCreateObject = Server.CreateObject(strProgId)
        //		end if

        //	end function
        //%>

        public void OnGet()
        {
        }
    }
}
