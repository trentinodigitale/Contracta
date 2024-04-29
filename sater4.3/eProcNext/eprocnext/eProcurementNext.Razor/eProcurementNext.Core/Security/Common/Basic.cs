using eProcurementNext.CommonDB;
using Microsoft.Extensions.Configuration;

namespace eProcurementNext.Security
{
    public static class Basic
    {

        private static CommonDbFunctions cdf = new CommonDbFunctions();

        /// <summary>
        /// Funzione che permette di verificare se una data stringa è valida rispetto a un'espressione regolare
        /// passata come parametro o rispetto a un tipo di validazione noto
        /// </summary>
        /// <param name="configuration"></param>
        /// <param name="strValue">alore da validare</param>
        /// <param name="tipo">tipo di controllo :
        //    * 1 = Formato table like, valori attesi : stringa compresa tra 1 e 100 caratteri e possiede solo caratteri minuscoli e maiuscoli, numeri e il caratteri underscore "_"
        //    * 2 = Formato sort like, valori attesi  : decimali,caratteri dalla a alla z, underscore e virgole e spazi,
        //    * 3 = Formato sql filter
        //    * 4 = Formato che permette solo numeri e virgole</param>
        /// <param name="strRegExp">se diverso da stringa vuota allora usiamo questa espressione regolare passata per validare il parametro strValue</param>
        /// <param name="ignoreCase"></param>
        /// <param name="strConnectionString"></param>
        /// <returns></returns>
        public static bool isValid(IConfiguration configuration, string strValue, int tipo, string? strRegExp, bool ignoreCase = true, string strConnectionString = "")
        {
            return eProcurementNext.DashBoard.Basic.isValid(strValue, tipo, strRegExp, ignoreCase, strConnectionString);
        }

        public static bool IsNumeric(string value)
        {

            try
            {
                return int.TryParse(value, out _);
            }
            catch
            {
                return false;
            }
        }

    }
}
