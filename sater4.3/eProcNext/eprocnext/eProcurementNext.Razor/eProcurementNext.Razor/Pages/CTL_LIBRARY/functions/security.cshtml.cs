using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class securityModel : PageModel
    {
        public const int TIPO_PARAMETRO_STRING = eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.TIPO_PARAMETRO_STRING;
        public const int TIPO_PARAMETRO_INT = eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.TIPO_PARAMETRO_INT;
        public const int TIPO_PARAMETRO_FLOAT = eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.TIPO_PARAMETRO_FLOAT;
        public const int TIPO_PARAMETRO_NUMERO = eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.TIPO_PARAMETRO_NUMERO;
        public const int TIPO_PARAMETRO_DATA = eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.TIPO_PARAMETRO_DATA;
        public const int SOTTO_TIPO_PARAMETRO_CUSTOM = eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.SOTTO_TIPO_PARAMETRO_CUSTOM;
        public const int SOTTO_TIPO_PARAMETRO_NESSUNO = eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.SOTTO_TIPO_PARAMETRO_NESSUNO;
        public const int SOTTO_TIPO_VUOTO = eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.SOTTO_TIPO_VUOTO;
        public const int SOTTO_TIPO_PARAMETRO_TABLE = eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.SOTTO_TIPO_PARAMETRO_TABLE;
        public const int SOTTO_TIPO_PARAMETRO_PAROLASINGOLA = eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.SOTTO_TIPO_PARAMETRO_PAROLASINGOLA;
        public const int SOTTO_TIPO_PARAMETRO_SORT = eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.SOTTO_TIPO_PARAMETRO_SORT;
        public const int SOTTO_TIPO_PARAMETRO_FILTROSQL = eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.SOTTO_TIPO_PARAMETRO_FILTROSQL;
        public const int SOTTO_TIPO_PARAMETRO_TEXTAREA = eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.SOTTO_TIPO_PARAMETRO_TEXTAREA;
        public const int SOTTO_TIPO_PARAMETRO_LISTANUMERI = eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.SOTTO_TIPO_PARAMETRO_LISTANUMERI;
		public const int SOTTO_TIPO_PARAMETRO_ONSUBMIT = eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.SOTTO_TIPO_PARAMETRO_ONSUBMIT;

		public const string key_sicurezza_disattiva_redirect = "sicurezza_disattiva_redirect";
        public const string key_sicurezza_esito_blocco = "sicurezza_esito_blocco";

        CommonDbFunctions cdf = new CommonDbFunctions();

        /// <summary>
        /// 
        /// </summary>
        /// <param name="nomeParametro">Nome del parametro (da GET o da POST) che si st� validando. O semplicemente un nome di variabile</param>
        /// <param name="valoreDaValidare">Valore che vogliamo validare per un controllo di sicurezza, probabile fonte : queryString o form</param>
        /// <param name="tipoDaValidare">Tipo di dati atteso
        ///     1 = String
        ///	    2 = Intero/Long 
        ///	    3 = Float,Double 
        ///	    4 = Un qualsiasi numero 
        ///	    5 = Una data
        /// </param>
        /// <param name="sottoTipoDaValidare">Se il tipoDaValidare � 1 (stringa), questo parametro indica che tipo di stringa di aspettiamo
        ///     * 1 = Formato table like, valori attesi : stringa compresa tra 1 e 100 caratteri e possiede solo caratteri minuscoli e maiuscoli, numeri e il caratteri underscore "_"
        ///     * 2 = Formato sort like, valori attesi  : decimali,caratteri dalla a alla z, underscore e virgole e spazi,
        ///     * 3 = Formato sql filter
        ///     * 4 = Formato che permette solo numeri e virgole
        /// </param>
        /// <param name="regExp">Se sottoTipoDaValidare � uguale a 0 e tipoDaValidare � uguale ad 1 andremo a validare il parametro valoreDaValidare rispetto all'espressione regolare contenuta in questo parametro.
        /// Valorizzare a stringa vuota se non serve usarla
        /// </param>
        /// <param name="obblig">Indica se campo obbligatorio
        ///     1 = parametro obbligatorio,
        ///     0 = parametro opzionale
        /// </param>
        /// <param name="session"></param>
        /// <param name="blackList"></param>
        /// <param name="httpContext"></param>
        /// <returns></returns>
        public static string validate(string nomeParametro, string valoreDaValidare, int tipoDaValidare, int sottoTipoDaValidare, string regExp, int obblig, HttpContext httpContext, eProcurementNext.Session.ISession session)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.validate(nomeParametro, valoreDaValidare, tipoDaValidare, sottoTipoDaValidare, regExp, obblig, httpContext, session);
        }

        public static void traceAttack(string trace, eProcurementNext.Session.ISession session, HttpContext httpContext)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.traceAttack(trace, session, httpContext);
        }

        public static void traceEventViewer(string mErrSource, string mErrDescription, int tipo)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.traceEventViewer(mErrSource, mErrDescription, tipo);
        }

        public static string insertAccessBarrier(eProcurementNext.Session.ISession session, HttpContext context)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.insertAccessBarrier(session, context);

        }

        public static int getAccessFromGuid(string guid)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.getAccessFromGuid(guid);
        }

        public static bool passWhiteList(string pagina, string parametro, string valore)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.passWhiteList(pagina, parametro, valore);
        }

        public static void disattivaRedirect(HttpContext context)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.disattivaRedirect(context);
        }

        public static int isSecurityBlocked(HttpContext httpContext)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.isSecurityBlocked(httpContext);
        }
        //'--FUNZIONE PER DOWNLOAD AND DELETE BIG FILE 
        public static void Redirect_2_DownLoadFile(string strFilePath, string NomeFile, string strDeleteFile, eProcurementNext.Session.ISession session, HttpContext HttpContext, EprocResponse htmlToReturn)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel.Redirect_2_DownLoadFile(strFilePath, NomeFile, strDeleteFile, session, HttpContext, htmlToReturn);

        }


        public void OnGet()
        {
        }
    }
}
