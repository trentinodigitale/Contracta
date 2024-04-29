using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using Microsoft.AspNetCore.Http;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Email
{
    public class SendMailError
    {
        const string DateFormat = "yyyy-MM-dd";
        const string TimeFormat = "HH:mm:ss";

        public static void SendMailErrorBackoffice(dynamic oggettoMail, dynamic contestoApplicativo, dynamic errorMsg, dynamic errorNumber, dynamic errorSource, dynamic strErrorCause, HttpContext httpContext, eProcurementNext.Session.ISession session)
        {
            CommonDbFunctions cdf = new CommonDbFunctions();

            eProcurementNext.Application.IEprocNextApplication application = ApplicationCommon.Application;

            string strNomeCliente = CStr(application["NOMEGESTORE"]);
            string strAmbiente = CStr(application["AFUPDATE_AMBIENTE"]);
            string userIp = "";
            string ipServer = "";

            string paginaRichiesta = "";
            string paginaChiamante = "";
            string queryString = CStr(httpContext.Request.QueryString);

            string mollicaDiPane = "";//GetLastBreadCrumb(session);

            string strDataErrore = DateTime.Now.ToString(DateFormat + " " + TimeFormat);

            string strUserName = CStr(session["UserName"]);
            string strCodAzi = CStr(session["ICodeAzi"]);
            string strIdPfu = CStr(session["IdPfu"]);

            string strMailBody = "<p>" + Environment.NewLine;
            strMailBody = strMailBody + "Email di alert backoffice generata a partire da un errore nell'inserimento di un allegato utente<br/>" + Environment.NewLine;

            strMailBody = strMailBody + "<hr/>" + Environment.NewLine;

            strMailBody = strMailBody + "<p>" + Environment.NewLine;
            strMailBody = strMailBody + "<strong>INFORMAZIONI SUL SERVER DOVE E' AVVENUTO L'ERRORE</strong>" + Environment.NewLine;
            strMailBody = strMailBody + "<br/> CLIENTE  : " + strNomeCliente + Environment.NewLine;
            strMailBody = strMailBody + "<br/> AMBIENTE : " + strAmbiente + Environment.NewLine;
            strMailBody = strMailBody + "<br/> IP NODO  : " + ipServer + Environment.NewLine;
            strMailBody = strMailBody + "</p>" + Environment.NewLine;

            strMailBody = strMailBody + "<hr/>" + Environment.NewLine;

            strMailBody = strMailBody + "<p>" + Environment.NewLine;
            strMailBody = strMailBody + "<strong>INFORMAZIONI SULL'UTENTE</strong>" + Environment.NewLine;
            strMailBody = strMailBody + "<br/> IDPFU  		 				  : " + strIdPfu + Environment.NewLine;

            if (strCodAzi != "")
            {
                strMailBody = strMailBody + "<br/> IDAZI					  : " + CStr(strCodAzi) + Environment.NewLine;
            }

            strMailBody = strMailBody + "<br/> IP 					  : " + CStr(userIp) + Environment.NewLine;

            strMailBody = strMailBody + "</p>" + Environment.NewLine;

            strMailBody = strMailBody + "<hr/>" + Environment.NewLine;

            strMailBody = strMailBody + "<p>" + Environment.NewLine;
            strMailBody = strMailBody + "<strong>INFORMAZIONI SULL'ERRORE</strong>" + Environment.NewLine;
            strMailBody = strMailBody + "<br/> CONTESTO  			 		  : " + contestoApplicativo + Environment.NewLine;
            strMailBody = strMailBody + "<br/> NUMERO DELL'ERRORE  			  : " + CStr(errorNumber) + Environment.NewLine;

            if (errorSource != "")
            {
                strMailBody = strMailBody + "<br/> ERR.SOURCE					  : " + CStr(errorSource) + Environment.NewLine;
            }

            if (strErrorCause != "")
            {
                strMailBody = strMailBody + "<br/> STR CAUSE					  : " + CStr(strErrorCause) + Environment.NewLine;
            }

            strMailBody = strMailBody + "<br/> DATA INVIO EMAIL/DATA ERRORE   : " + CStr(strDataErrore) + Environment.NewLine;
            strMailBody = strMailBody + "<br/> PAGINA CHIAMANTE 			  : " + CStr(paginaChiamante) + Environment.NewLine;

            strMailBody = strMailBody + "<br/> ELEMENTO CORRENTE BRICIOLE DI PANE : " + CStr(mollicaDiPane) + Environment.NewLine;


            strMailBody = strMailBody + "<br/> PAGINA RICHIESTA 			  : " + CStr(paginaRichiesta) + Environment.NewLine;
            strMailBody = strMailBody + "<br/> QUERY STRING 				  : " + CStr(queryString) + Environment.NewLine;

            strMailBody = strMailBody + "<br/> MESSAGGIO DI ERRORE   		  : " + CStr(errorMsg) + Environment.NewLine;
            strMailBody = strMailBody + "</p>" + Environment.NewLine;

            strMailBody = strMailBody + "</p>" + Environment.NewLine;

            strMailBody = strMailBody + "<hr/>" + Environment.NewLine;


            string strMailFrom = "";

            string strSQL = "select mpmTo, mpmFrom from MPMail with(nolock) where mpmEvento = 'ERRORE_ALLEGATO'";

            TSRecordSet rsMail = cdf.GetRSReadFromQuery_(strSQL, ApplicationCommon.Application.ConnectionString);

            string strMailTo = "";

            if (rsMail != null & !(rsMail.EOF && rsMail.BOF))
            {
                rsMail.MoveFirst();

                strMailTo = GetValueFromRS(rsMail.Fields["mpmTo"]);
                strMailFrom = GetValueFromRS(rsMail.Fields["mpmFrom"]);
            }
            else
            {
                //'--- IN ASSENZA DELL'EVENTO NELL'MPMAIL NON FACCIO PARTIRE L'EMAIL
                return;
            }


            using SqlConnection objLocalConn = new SqlConnection(ApplicationCommon.Application.ConnectionString);
            objLocalConn.Open();

            Email.Basic.SendMailCentralizzata_New(strMailTo, strMailFrom, "", "", "", oggettoMail, strMailBody, "I", objLocalConn, null,
                                        null, null, null, null, null, null, null, null, null, null);
        }

        public static bool LocalFieldExistsInRS(TSRecordSet rs, string FieldName)
        {
            return rs.Columns.Contains(FieldName);
        }

        public static string GetLastBreadCrumb(Session.ISession session)
        {
            string ret = "";
            string briciola = "";

            if (IsEmpty(session["stack_path"]))
            {
                return ret;
            }

            try
            {
                dynamic[,] mp_stackMatrix = session["stack_path"];
                int posCorrente = session["stack_index"];

                briciola = ApplicationCommon.CNV(mp_stackMatrix[posCorrente, 2]);   //'-- l'ultimo elemento dello stack
                string urlBriciola = mp_stackMatrix[posCorrente, 1];
                ret = briciola + " (  " + urlBriciola + " ) ";
            }
            catch (Exception ex)
            {
                throw new Exception("GetLastBreadCrumb() - fallito recupero ultima posizione delle molliche di pane", ex);
            }

            return ret;
        }
    }
}
