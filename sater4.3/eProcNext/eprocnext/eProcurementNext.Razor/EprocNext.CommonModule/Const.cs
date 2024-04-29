using Microsoft.VisualBasic;

namespace eProcurementNext.CommonModule
{
    public static class Const
    {
        public static int RequestQueryString = 0;
        public static int RequestForm = 1;
        public static int SESSION_USER = 2;
        public static int OBJREQUEST = 3;
        public static int OBJSERVER = 4;
        public static int OBJSESSION = 5;
        public static int OBJAPPLICATION = 6;
        public static int OBJSCRIPTINGCONTEXT = 7;
        public static int SESSION_CONNECTIONSTRING = 8;
        public static int SESSION_RDS_SERVER = 9;
        public static int SESSION_PERMISSION = 10;
        public static int SESSION_SUFFIX = 11;
        public static int SESSION_WORKROOM = 12;
        public static int SESSION_MULTILNG = 13;

        public static string APPLICATION_BLACKLIST = "blacklist";
        public static string APPLICATION_OWNERLIST = "ownerslist";


        public static int TYPE_GENERICDOCUMENT = 55;

        public static string NUM_ROW_FOR_PAGE = "20";

        public enum TypeField
        {
            FldDomain = 4,
            FldDate = 6,
            FldCheckBox = 9,
            FldRadioButton = 10,
            FldStatic = 11
        }

        public enum ELAB_RET_CODE
        {
            RET_CODE_OK = 0,                               //ok
            RET_CODE_ERROR = 1,                         //errore
            RET_CODE_CHOOSE = 2,                      //scelta dell'utente
            RET_CODE_BREAKANDCOMMIT = 3,   //committ e fermo il processo
            RET_CODE_ERROR_NOCNV = 4           //errore e il messaggio di ritorno è gia con multilinguismo. non va quindi applicato dal chiamante
        }

        public static int DOM_connectionString = 0;
        public static int DOM_Desc = 1;
        public static int DOM_Dynamic = 2;
        public static int DOM_DynamicReload = 3;
        public static int DOM_elem = 4;
        public static int DOM_Filter = 5;
        public static int DOM_Id = 6;
        public static int DOM_LastLoad = 7;
        public static int DOM_Query = 8;
        public static int DOM_suffix = 9;

        public static int FIELD_mp_iType = 0;
        public static int FIELD_Name = 1;
        public static int FIELD_Value = 2;
        public static int FIELD_Domain = 3;
        public static int FIELD_umDomain = 4;
        public static int FIELD_strFormat = 5;
        public static int FIELD_Editable = 6;
        public static int FIELD_Obbligatory = 7;
        public static int FIELD_Caption = 8;
        public static int FIELD_PathImage = 9;
        public static int FIELD_ClassStyleCaption = 10;
        public static int FIELD_ClassStyleValue = 11;
        public static int FIELD_mp_OnFocus = 12;
        public static int FIELD_mp_OnBlur = 13;
        public static int FIELD_mp_OnClick = 14;
        public static int FIELD_MaxLen = 15;
        public static int FIELD_numDecimal = 16;
        public static int FIELD_sepDecimal = 17;
        public static int FIELD_width = 18;
        public static int FIELD_Condition = 19;
        public static int FIELD_Position = 20;
        public static int FIELD_colspan = 21;
        public static int FIELD_Help = 22;
        public static int FIELD_Error = 23;
        public static int FIELD_ErrDescription = 24;
        public static int FIELD_DefaultValue = 25;
        public static int FIELD_Language = 26;
        public static int FIELD_ConnectionString = 27;
        public static int FIELD_GetPredefiniteVisualDescription = 28;
        public static int FIELD_Style = 29;
        public static int FIELD_mp_objFieldStyle = 30;
        public static int FIELD_DomainFilter = 31;

        public static int FIELD_mp_OnChange = 32;
        public static int FIELD_Path = 33;
        public static int FIELD_Rows = 34;
        public static int FIELD_Multivalue = 35;

        /// <summary>
        /// Indice dell'ultima proprietà. Il numero di elementi è 39.
        /// </summary>
        public static int FIELD_NUMPROP = 38;

        public static int PROP_Alignment = 0;
        public static int PROP_Dimension = 1;
        public static int PROP_Hide = 2;
        public static int PROP_Length = 3;
        public static int PROP_Name = 4;
        public static int PROP_OnClickCell = 5;
        public static int PROP_Sort = 6;
        public static int PROP_Style = 7;
        public static int PROP_Total = 8;
        public static int PROP_vAlignment = 9;
        public static int PROP_Width = 10;
        public static int PROP_Wrap = 11;
        public static int PROP_Expr = 12;
        public static int PROP_bSumm = 13;
        public static int PROP_FormatCondition = 14;

        public static int FIELD_ValidazioneFormale = 37;
        public static int FIELD_RegExp = 38;


        //Costanti per info Tentativo di attacco alla sicurezza
        public static string ATTACK_QUERY_TABLE = "SQLInjection o Hack-QueryString : Tentativo di modifica del parametro 'table'";
        public static string ATTACK_QUERY_FILTERHIDE = "SQLInjection o Hack-QueryString : Tentativo di modifica del parametro 'FilterHide'";
        public static string ATTACK_QUERY_OWNER = "Hack-QueryString : Tentativo di modifica del parametro 'owner'";
        public static string ATTACK_QUERY_SORT = "SQLInjection o Hack-QueryString : Tentativo di modifica del parametro 'sort'";
        public static string ATTACK_QUERY_SORT_ORDER = "SQLInjection o Hack-QueryString : Tentativo di modifica del parametro 'sort_order'";
        public static string ATTACK_QUERY_IDENTITY = "SQLInjection o Hack-QueryString : Tentativo di modifica del parametro 'identity'";
        public static string ATTACK_QUERY_TOOLBAR = "SQLInjection o Hack-QueryString : Tentativo di modifica del parametro 'toolbar'";
        public static string ATTACK_QUERY_MODGRIGLIA = "SQLInjection o Hack-QueryString : Tentativo di modifica del parametro 'modGriglia'";
        public static string ATTACK_QUERY_POSITIONALMODELGRID = "SQLInjection o Hack-QueryString : Tentativo di modifica del parametro 'POSITIONALMODELGRID'";
        public static string ATTACK_QUERY_MODFILTROADD = "SQLInjection o Hack-QueryString : Tentativo di modifica del parametro 'mp_ModFiltroAdd'";
        public static string ATTACK_QUERY_MODFILTROUPD = "SQLInjection o Hack-QueryString : Tentativo di modifica del parametro 'mp_ModFiltroUpd'";
        public static string ATTACK_QUERY_FILTER = "SQLInjection o Hack-QueryString : Tentativo di modifica del parametro 'Filter'";
        public static string ATTACK_QUERY_MODFILTRO = "SQLInjection o Hack-QueryString : Tentativo di modifica del parametro 'modFiltro'";
        public static string ATTACK_QUERY_MODADD = "SQLInjection o Hack-QueryString : Tentativo di modifica del parametro 'ModelloAdd'";
        public static string ATTACK_QUERY_MODCUBE = "SQLInjection o Hack-QueryString : Tentativo di modifica del parametro 'mp_ModuleCUBE'";
        public static string ATTACK_QUERY_CUBEMODE = "SQLInjection o Hack-QueryString : Tentativo di modifica del parametro 'mp_CUBEMode'";
        public static string ATTACK_QUERY_SQLINJECTION = "SQLInjection : Tentativo di modifica del parametro '##nome-parametro##'";


        public static string ATTACK_DOCUMENT_ID = "SQLInjection o Hack-QueryString : Tentativo di modifica del parametro 'id' su documento";
        public static string ATTACK_PARAM_VALIDATE = "Injection, CtlSecurity.validate() : Tentativo di modifica del parametro '##nome-parametro##'";
        public static string ATTACK_CONTROLLO_PERMESSI = "Privilege escalation : Accesso non consentito all'oggetto sql '##nome-parametro##'";

        public static string? globalConnectionString;
        public static string? attivaDbProfiler;

        //----------------------------------------------------------------------------
        // Costanti relative alla gestione degli errori
        //----------------------------------------------------------------------------
        public static long mErrNumber;
        public static string? mErrSource;
        public static string? mErrDescription;


        public static string MyReplace(string expression, string find, string rpl, int start = 1, int count = -1, CompareMethod compare = CompareMethod.Text)
        {

            string? output;

            output = Strings.Replace(expression, find, rpl, start, count, compare);

            return output != null ? output : "";

        }


    }
}