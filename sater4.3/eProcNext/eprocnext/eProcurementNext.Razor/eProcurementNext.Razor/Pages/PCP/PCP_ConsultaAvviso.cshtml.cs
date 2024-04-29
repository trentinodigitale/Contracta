using eProcurementNext.Application;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static eProcurementNext.CommonModule.Basic;
using Basic = eProcurementNext.CommonDB.Basic;

namespace eProcurementNext.Razor.Pages.PCP
{
    public class PCP_ConsultaAvviso : PageModel
    {

        public string? consultaAvviso(int idRow, int idGara, string operation)
        {

            string res = string.Empty;

            try
            {
                //Se la pagina viene chiamata tramite una sentinella di integrazione ( e non direttamente dalla gara con un operazione sincrona )
                if (idRow > 0)
                    UpdateServiceIntegration(idRow, "InGestione");

                var urlToInvoke = $@"{ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"]}/WebApiFramework/api/ConfermaAppalto/consultaAvviso?idDoc={idGara}&idRow={idRow}";

                res = invokeUrl(urlToInvoke);

            }
            catch (Exception ex) 
            {
                if (idRow > 0)
                    UpdateServiceIntegration(idRow, "Errore", ex.ToString()); //Senza questo update la sentinella resta "bloccata" nello stato di "InGestione"

                //Se l'eccezione è nel formato standard restituito dalla invokeUrl, prendo solo il messaggio di errore
                if (ex.Message.IndexOf("Output: ") != -1)
                {
                    res = ex.Message[(ex.Message.IndexOf("Output: ") + "Output: ".Length)..];
                    if (!res.StartsWith("0#"))
                    {
                        res = $"0#{res}";
                    }
                }
                else
                {
                    res = $"0#{ex.Message}";
                }
            }
            finally
            {
                if (res.StartsWith("0#"))
                    Basic.LogEvent(Basic.TsEventLogEntryType.Error, res, ApplicationCommon.Application["ConnectionString"], "PCP_ConsultaAvviso");
            }

            if (res.StartsWith("0#") || res.StartsWith("1#"))
            {
                return res;
            }

            return !res.StartsWith("1#") ? $"1#{res}" : res;
        }

        public void UpdateServiceIntegration(int idRow, string stato, string msgError = "")
        {
            CommonDB.CommonDbFunctions cdf = new();
            var sqlParams = new Dictionary<string, object?>();

            sqlParams.Add("@idRow", idRow);
            sqlParams.Add("@dataExecuted", DateTime.Now);
            sqlParams.Add("@statoRichiesta", stato);

            string strSQL = "UPDATE Services_Integration_Request set StatoRichiesta = @statoRichiesta, DataExecuted = @dataExecuted ";

            if (!string.IsNullOrEmpty(msgError))
            {
                strSQL += ", MsgError = @msgError";
                sqlParams.Add("@msgError", msgError);
            }

            strSQL += " where IdRow = @idRow";

            cdf.Execute(strSQL, ApplicationCommon.Application["ConnectionString"], parCollection: sqlParams);

        }

    }

}
