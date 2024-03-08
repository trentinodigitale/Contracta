using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.VisualBasic;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class cnvModel : PageModel
    {
        private eProcurementNext.Session.ISession _session;
        private eProcurementNext.Application.IEprocNextApplication _application;

        public cnvModel(eProcurementNext.Session.ISession session, eProcurementNext.Application.IEprocNextApplication application)
        {
            _session = session;
            _application = application;
        }

        public void OnGet()
        {
        }

        public static string CNVMP(dynamic IdMp, dynamic str, eProcurementNext.Session.ISession _session)
        {
            return CNV(str, _session);
        }

        public static string CNVMPJS(dynamic lngIdMp, dynamic strkey, eProcurementNext.Session.ISession _session)
        {
            string temp = CNV(strkey, _session);
            temp = Strings.Replace(temp, "'", "\'");
            temp = Strings.Replace(temp, "\"", "\\");
            return temp;
        }

        public static string CNV(string str, eProcurementNext.Session.ISession _session)
        {
            return eProcurementNext.Application.ApplicationCommon.CNV(str, _session).Trim();
        }

        //public static void TraceMultilinguismo(dynamic strKey, IConfiguration configuration)
        //{
        //    //dynamic objDB;
        //    //objDB = createobject("ctldb.clsTabManage");

        //    TabManage objDB = new TabManage(configuration);

        //    objDB.ExecSql($"insert into TRACE_MULTILINGUISMO (idMultilng,Type) values ('{Strings.Replace(strKey, "'", "''")}','O')", _application["ConnectionString"]);

        //}

        //public static dynamic CNV_DOminio(dynamic Domino, dynamic strCodice, IConfiguration configuration)
        //{
        //    //'-- recupero lingua
        //    dynamic strSuffix;
        //    strSuffix = "";// _session("session")(11);
        //    if (strSuffix == "") {
        //        strSuffix = "I";
        //    }

        //    //dynamic objDB;
        //    //objDB = createobject("ctldb.clsTabManage");

        //    TabManage objDB = new TabManage(configuration);

        //    dynamic rsDescDominio;


        //    rsDescDominio = objDB.GetRsReadFromQueryy(cstr($"select dbo.GetCodDom2DescML_Ext('{Domino}','{strCodice}','{strSuffix}')  as Descrizione "), cstr(_session("Session")(8)));

        // if(rsDescDominio.recordcount > 0) {
        //        //rsDescDominio.movefirst 
        //        //ritorno il primo record trovato nel recordset
        //        return rsDescDominio("Descrizione").value;
        //    }
        //    else
        //    {
        //        throw new Exception("Nessun valore restituito da CNV_DOminio");
        //    }

        //}

    }
}
