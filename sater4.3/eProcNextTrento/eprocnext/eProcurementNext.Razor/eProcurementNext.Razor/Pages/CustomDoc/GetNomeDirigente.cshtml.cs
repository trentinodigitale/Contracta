using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.Razor.Pages.CTL_LIBRARY.DOCUMENT.CommonModel;
namespace eProcurementNext.Razor.Pages.CustomDoc
{
    public class GetNomeDirigenteModel : PageModel
    {
        public const string GARE_E_CONTRATTI = "GARE_E_CONTRATTI";
        public void OnGet()
        {
        }
        public static string GetNomeDirigente(string direzione, string Data)
        {
            string _GetNomeDirigente = string.Empty;
            string attValue = RelationTime("DIRIGENTE_ALLA_FIRMA", direzione, Convert.ToDateTime(Data.Replace("T", " ")));
            CommonDbFunctions cdf = new();
			var sqlParams = new Dictionary<string, object?>();
			sqlParams.Add("@attValue", attValue);
			TSRecordSet rs = cdf.GetRSReadFromQuery_("select IdPfu from ProfiliUtenteAttrib where dztNome='UserRole'  and attValue = @attValue", ApplicationCommon.Application.ConnectionString, sqlParams);
            if (rs.RecordCount == 0)
            {
                _GetNomeDirigente = string.Empty;
            }
            else
            {
                sqlParams.Clear();
				sqlParams.Add("@IdPfu", CInt(rs["IdPfu"]!));
                rs = cdf.GetRSReadFromQuery_("select PfuNome from ProfiliUtente where IdPfu = @IdPfu", ApplicationCommon.Application.ConnectionString, sqlParams);

                if (rs.RecordCount == 0)
                {
                    _GetNomeDirigente = string.Empty;
                }
                else
                {
                    _GetNomeDirigente = CStr(rs["PfuNome"]);
                }
            }
            return _GetNomeDirigente;
        }
    }
}
