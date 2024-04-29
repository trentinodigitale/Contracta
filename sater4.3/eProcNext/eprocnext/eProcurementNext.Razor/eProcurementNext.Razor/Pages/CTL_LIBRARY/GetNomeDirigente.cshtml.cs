using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.Razor.Pages.CTL_LIBRARY.DOCUMENT;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY
{
    public class GetNomeDirigenteModel : PageModel
    {

        public void OnGet()
        {
        }
        public const string GARE_E_CONTRATTI = "GARE_E_CONTRATTI";


        public string GetNomeDirigente(string direzione, DateTime Data)
        {
            string costante = "";
            string attValue = "";
            string GetNomeDirigente = "";

            if (Data.GetType() == typeof(DateTime))
            {
                attValue = CommonModel.RelationTime("DIRIGENTE_ALLA_FIRMA", direzione, Data);
                int IdPfu = 0;
                string connectionString = ApplicationCommon.Application.ConnectionString;
                CommonDbFunctions cdb = new CommonDbFunctions();
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@att", attValue);
                sqlParams.Add("@nome", "UserRole");
				TSRecordSet rs = cdb.GetRSReadFromQuery_("select * from ProfiliUtenteAttrib where DZTNome= @nome  and attValue = @att ", connectionString, sqlParams);
                if (rs.RecordCount == 0)
                {
                    GetNomeDirigente = "";
                }
                else
                {
                    IdPfu = CInt(rs["IdPfu"]!);
                    CommonDbFunctions commondb = new();
                    sqlParams.Clear();
                    sqlParams.Add("@idpfu", IdPfu);
                    rs = commondb.GetRSReadFromQuery_("select * from ProfiliUtente where IdPfu = @idpfu", connectionString, sqlParams);
                    if (rs.RecordCount == 0)
                    {
                        GetNomeDirigente = "";
                    }
                    else
                    {
                        GetNomeDirigente = CStr(rs["PfuNome"]);
                    }
                }
            }
            return GetNomeDirigente;
        }
    }
}
