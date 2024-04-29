using eProcurementNext.BizDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.VisualBasic;
using System.Text;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.DashBoard
{
    public class GRFunz : IGRFunz
    {
        private IConfiguration _configuration;
        private IEprocResponse _response;

        private object mp_ObjSession;
        private string mp_Suffix;
        private string mp_User;
        private string mp_Nome;
        private string mp_Cognome;
        private string mp_Permission;
        private string mp_strConnectionString;

        private Group mp_objGroup;
        private Dictionary<string, dynamic> mp_objGroups;
        private GroupRow mp_objTitleGr;

        private Group mp_objGroupNozze;
        private GroupRow mp_objTitleGrNozze;

        private string mp_strcause;

        private Object Request_QueryString;
        private Object Request_Form;

        private string mp_DashGroup;
        private string mp_DefaultAreaFunz;
        public string response;

        private readonly HttpContext _context;
        private readonly eProcurementNext.Session.ISession _session;


        public GRFunz(Session.ISession session, HttpContext context, IEprocResponse response)
        {
            _session = session;
            _context = context;
            _response = response;
        }


        public string drawGruppi()
        {
            var groupName = GetParamURL(GetQueryStringFromContext(_context.Request.QueryString).ToString(), "GROUPS_NAME");
            mp_DashGroup = "DashBoardMain";

            if (!string.IsNullOrEmpty(groupName))
            {
                mp_DashGroup = groupName;
            }
            else
            {
                if (!string.IsNullOrEmpty(CStr(_session["GROUPS_NAME"])))
                {
                    mp_DashGroup = CStr(_session["GROUPS_NAME"]);
                }
            }


            mp_Suffix = _session[Session.SessionProperty.SESSION_SUFFIX];

            if (string.IsNullOrEmpty(mp_Suffix))
                mp_Suffix = "I";

            mp_Permission = _session[Session.SessionProperty.Funzionalita];

            Lib_dbFunctions libFunc = new Lib_dbFunctions();
            List<Group> mp_objGroups = libFunc.GetHtmlGroups(mp_DashGroup, "", mp_Permission, mp_Suffix);

            if (mp_objGroups.Count <= 0) return string.Empty;

            foreach (var obj in mp_objGroups)
            {
                _response.Write(obj.Html().ToString());
            }

            return _response.Out();
        }


    }
}
