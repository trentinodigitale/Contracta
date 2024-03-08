using eProcurementNext.Application;
using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static eProcurementNext.CommonModule.Basic;
using Basic = eProcurementNext.CommonDB.Basic;

namespace eProcurementNext.Razor.Pages.PCP
{
    public class PCP_CreaScheda : PageModel
    {

        public string CreaScheda(int idRow, int idRic, string operation)
        {
            DebugTrace dt = new();

            dt.Write($"PCP_CreaScheda - {idRow} - {idRic} - {operation} : Inizio creaScheda");
            UpdateServiceIntegration(idRow, "InGestione");

            var res = string.Empty;

            try
            {
                var urlToInvoke = "";

                urlToInvoke = $"{ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"]}/WebApiFramework/api/comunicaPostPubblicazione/creaScheda?idRow={idRow}&idDoc={idRic}&idpfu={-20}"; //&operation={operation}";

                dt.Write($"PCP_CreaScheda - {idRow} - {idRic} - {operation} : Invocazione di {urlToInvoke}");

                res = invokeUrl(urlToInvoke);

                dt.Write($"PCP_CreaScheda - {idRow} - {idRic} - {operation} : output della chiamata = {res}");
            }
            catch (Exception ex)
            {
                res = $"0#{ex}";

                dt.Write($"PCP_CreaScheda - {idRow} - {idRic} - {operation} : Exception = {res}");
            }
            finally
            {
                if ( res.StartsWith("0#") )
                    Basic.LogEvent(Basic.TsEventLogEntryType.Error, res, ApplicationCommon.Application["ConnectionString"],"PCP_CreaScheda");
                
                //Sarà il processo di finalizzazione a gestire la logica di business ( come ad es. un invio mail dopo un tot retry )
                UpdateServiceIntegration(idRow, res.StartsWith("1#") ? "RicevutaRisposta" : "RicevutoErrore", true,res.Replace("1#",""), res.Replace("0#",""));
            }

            return res;
        }

        public void UpdateServiceIntegration(int idRow, string stato, bool chiudi = false, string datoRichiesto = "", string msgError = "")
        {
            CommonDB.CommonDbFunctions cdf = new();
            var sqlParams = new Dictionary<string, object?>
            {
                { "@idRow", idRow },
                { "@statoRichiesta", stato }
            };

            var strSql = "UPDATE Services_Integration_Request set StatoRichiesta = @statoRichiesta, DataExecuted = getDate(), numRetry = isnull(numRetry,0) + 1 where IdRow = @idRow";

            //Se stiamo chiudendo il giro non devo fare lo stesso update di inizio
            if (chiudi)
            {
                //l'input e l'output dei WS li facciamo inserire al controller chiamato, dove abbiamo un dettaglio elevato di cosa si sta facendo e di cosa inserire
                strSql = @"UPDATE Services_Integration_Request 
                            set StatoRichiesta = @statoRichiesta, 
                                DataFinalizza = getDate(),
                                DatoRichiesto = @DatoRichiesto,
                                msgError = @msgError
                            where IdRow = @idRow";

                sqlParams.Add("@DatoRichiesto", datoRichiesto);
                sqlParams.Add("@msgError", msgError);
            }

            cdf.Execute(strSql, ApplicationCommon.Application["ConnectionString"], parCollection: sqlParams);
        }
       
    }
}
