using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static eProcurementNext.CommonModule.Basic;
namespace eProcurementNext.Razor.Pages.PCP
{
    public class PCP_DownloadPayload : PageModel
    {

        public string DownloadPayload(int idRow,int idRic,string operation, int req,string tipoScheda, out string filename)
        {

            /*
             * '-- 1. controllo di sicurezza. verifico se la vista sotto cronologia_pcp ritorna il record ( entrando per idRow,idRichiesta ed operazioneRichiesta. restringo i dati recuperabili )
               '--			altrimenti permetterei un download di qualsiasi input/output della tabella Services_Integration_Request scorrendo tutti gli id portando fuori anche potenziali
               '--			dati sensibili 
               '--  2. recupero l'input o l'output della riga richiesta in base all'operation passato
               '--	3. porto a video il contenuto della colonna con il content type coerente
             */
            var strSql = "select idRow from BANDO_PCP_CRONOLOGIA_VIEW where idRow = @idRow and TipoDoc = @operation and idRichiesta = @idRic";
            filename = "";

            CommonDbFunctions db = new();
            Dictionary<string, dynamic?>? parmS = new()
            {
                { "@idRow", idRow },
                { "@operation", operation },
                { "@idRic", idRic }
            };

            var rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, parmS);

            if (rs is null || rs.RecordCount == 0)
            {
                return "Recupero fallito. Richiesta non valida";
            }

            //'--avendo effettuato i controlli di sicurezza per il recupero del record giusto, posso andare solo con idRow
            strSql = $"select {(req == 1? "inputWS as payload" : "outputWS as payload")} from Services_Integration_Request with(nolock) where idRow = @idRow";

            parmS.Clear();
            parmS.Add("@idRow", idRow);

            rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, parmS);

            if (rs is null || rs.RecordCount == 0)
            {
                return "Recupero fallito. Payload non trovato";
            }

            rs.MoveFirst();

            var payload = CStr(rs["payload"]);

            var extType = "txt"; // '--default

            if (payload.StartsWith("<?"))
                extType = "xml";
            else if (payload.StartsWith("{"))
                extType = "json";

            filename = "payload";

            if (operation.Trim() != "")
                filename = operation;

            if (tipoScheda.Trim() != "")
                filename = $"{filename}_{tipoScheda}";

            filename += (req == 1 ? "_Request": "_Response") + $".{extType}";

            return payload;

        }

    }
}
