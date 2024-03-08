using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Security
{
    public class Validation : IValidation
    {
        //IHttpContextAccessor _httpContextAccessor;
        eProcurementNext.Session.ISession _session;
        IConfiguration _configuration;
        HttpContext _context;

        public Validation(IConfiguration configuration, HttpContext httpContext, eProcurementNext.Session.ISession _session)
        {
            //_httpContextAccessor = httpContextAccessor;
            this._session = _session;
            _context = httpContext;
            _configuration = configuration;
        }
        public Validation()
        {
            //_httpContextAccessor = httpContextAccessor;

        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="nomeParametro">Nome del parametro (da GET o da POST) che si stà validando. O semplicemente un nome di variabile</param>
        /// <param name="valoreDaValidare">Valore che vogliamo validare per un controllo di sicurezza, probabile fonte : queryString o form</param>
        /// <param name="tipoDaValidare">Enumerato, indica il tipo di dati atteso. 1 = String; 2 = Intero/Long ; 3 = Float,Double ; 4 = Un qualsiasi numero ; 5 = Una data</param>
        /// <param name="sottoTipoDaValidare">(opz.) Enumerato, se il tipoDaValidare è 1 (stringa), questo parametro indica che tipo di stringa di aspettiamo.
        ///     * 1 = Formato table like, valori attesi : stringa compresa tra 1 e 100 caratteri e possiede solo caratteri minuscoli e maiuscoli, numeri e il caratteri underscore "_"
        ///     * 2 = Formato sort like, valori attesi  : decimali,caratteri dalla a alla z, underscore e virgole e spazi,
        ///     * 3 = Formato sql filter
        ///     * 4 = Formato che permette solo numeri e virgole' regExp              : (opz.) Se sottoTipoDaValidare è uguale a 0 e tipoDaValidare è uguale ad 1 andremo a validare il parametro valoreDaValidare rispetto all'espressione regolare contenuta in questo parametro
        /// </param>
        /// <param name="regExp"></param>
        /// <returns></returns>
        public bool validate(Session.ISession session, string nomeParametro, string valoreDaValidare, int tipoDaValidare, int sottoTipoDaValidare = 0, string regExp = "")
        {
            //var token = _context.User.Claims.First(item => item.Type == "JWT_Token").Value;
            //_session.Load(token);

            //bool isDevMode = false;
            //bool esito = false;
            dynamic valueTest;

            Dictionary<string, dynamic> attackerInfo;
            string mp_strConnectionString = string.Empty;
            bool isAttacked = false;
            string strCause = string.Empty;

            BlackList blackList = null;

            try
            {

                blackList = new BlackList();

                //'Se siamo in modalità di sviluppo non effettuiamo controlli di sicurezza
                if (blackList.isDevMode())
                {
                    return isAttacked;
                }

                isAttacked = true; //' Fino a prova contraria c'è stato un attacco

                mp_strConnectionString = ApplicationCommon.Application.ConnectionString;
                //mp_strConnectionString = _session["SESSION_CONNECTIONSTRING"].ToString();
                strCause = Const.ATTACK_PARAM_VALIDATE.Replace("##nome-parametro##", nomeParametro);

                switch (tipoDaValidare)
                {
                    case 2:
                        isAttacked = !Int64.TryParse(valoreDaValidare, out _);
                        //valueTest = Convert.ToInt64(valoreDaValidare);
                        //isAttacked = false; //'Se arrivo qui vuol dire che il cast ha avuto effetto e non c'è stato un attacco
                        break;
                    case 3:
                        isAttacked = !Double.TryParse(valoreDaValidare, out _);
                        //valueTest = Convert.ToDouble(valoreDaValidare);
                        //isAttacked = false; //'Se arrivo qui vuol dire che il cast ha avuto effetto e non c'è stato un attacco
                        break;
                    case 4:
                        isAttacked = !Basic.IsNumeric(valoreDaValidare); // Verificare se corretta traduzione di  isAttacked = Not IsNumeric(valoreDaValidare)
                        break;
                    case 5:
                        isAttacked = !DateTime.TryParse(valoreDaValidare, out _); // verificare se corretta traduzione di isAttacked = Not IsDate(valoreDaValidare)
                        break;
                    default:    // ' per valore 1, e maggiore di 5
                        if (Basic.isValid(_configuration, valoreDaValidare, sottoTipoDaValidare, regExp, true, null))
                        {
                            //' Se il valore passato è valido rispetto ai criteri scelti allora non c'è stato un attacco
                            isAttacked = false;
                        }
                        break;
                }
            }
            catch (Exception ex)
            {
            }
            finally
            {

                if (blackList == null)
                {
                    blackList = new BlackList();
                }

                //esito = isAttacked;

                //'Se è stato individuato un attacco e non siamo in modalità di sviluppo (debug mode)
                if (isAttacked && !blackList.isDevMode())
                {
                    //'Aggiungo l'ip in blacklist collezionando le informazioni sull'attacco (a meno che non è attiva la sys di disattivablacklist)
                    blackList.addIp(blackList.getAttackInfo(_context, _session[SessionProperty.IdPfu], strCause), _session, mp_strConnectionString);
                }
            }

            return isAttacked;
        }

        /// <summary>
        /// 'Funzione che permette di verificare se una data stringa è valida rispetto a un'espressione regolare
        ///'passata come parametro o rispetto a un tipo di validazione noto
        /// </summary>
        /// <param name="strValue"></param>
        /// <param name="tipo"></param>
        /// <param name="strRegExp"></param>
        /// <param name="ignoreCase"></param>
        /// <returns></returns>
        public bool isValidValue(string strValue, int tipo, string strRegExp = "", bool ignoreCase = true)
        {
            return eProcurementNext.DashBoard.Basic.isValid(strValue, tipo, strRegExp, ignoreCase);
        }

        public bool isValidFilterSql(string strFilter, string ParametroInutile="")
        {
            return eProcurementNext.DashBoard.Basic.isValidaSqlFilter(strFilter);
        }

        public bool checkSqlObjPermission(string strSqlTable, Session.ISession session)
        {
            return eProcurementNext.DashBoard.Basic.checkPermission(strSqlTable, session, ApplicationCommon.Application.ConnectionString);
        }

        /// <summary>
        /// '-- Funzione che controlla se un dato valore (potenzialmente arrivato da form) non contiene tag pericolosi per una successiva visualizzazione (attacchi XSS)
        /// </summary>
        /// <param name="Value"></param>
        /// <returns></returns>
        public bool isValidForm(string Value)
        {
            return isFormValid(Value);
        }

        public string htmlEncodeValue(string strValue)
        {
            if (!IsNull(strValue))
            {
                return HtmlEncode(strValue);
            };
            return "";
        }

        public bool isValidSqlSort(string strFilter, string strConnectionString = "")
        {
            return eProcurementNext.DashBoard.Basic.isValidSortSql(strFilter, strConnectionString);
        }

    }
}
