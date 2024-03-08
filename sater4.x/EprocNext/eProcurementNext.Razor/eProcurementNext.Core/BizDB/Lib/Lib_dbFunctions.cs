using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.HTML;
using eProcurementNext.Session;
using Microsoft.Extensions.Configuration;
using Microsoft.VisualBasic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.BizDB
{
    public class Lib_dbFunctions : iLib_dbFunctions
    {
        private readonly IConfiguration _configuration;
        private static string connString;
        public static string strConnectionString;
        private List<Group> groupList;

        private static CommonDbFunctions cdf = new CommonDbFunctions();

        public Lib_dbFunctions(IConfiguration configuration)
        {
            connString = configuration.GetConnectionString("DefaultConnection");
            _configuration = configuration;
        }

        public Lib_dbFunctions()
        {
            connString = Application.ApplicationCommon.Application.ConnectionString;
            strConnectionString = Application.ApplicationCommon.Application.ConnectionString;
        }

        public Lib_dbFunctions(string _connString)
        {
            connString = _connString;
            strConnectionString = _connString;
        }

        public static TSRecordSet GetRSGroupFunction(string nomeGruppo, int Context = 0)
        {
            TSRecordSet dt = new();

            if (!String.IsNullOrWhiteSpace(nomeGruppo))
            {
                Dictionary<string, object?> parcoll = new()
                {
                    { "@nomeGruppo", nomeGruppo },
                    { "@Context", Context }
                };

                string strSQL = $"SELECT * FROM LIB_Functions with(nolock) where LFN_GroupFunction = @nomeGruppo and LFN_Context = @Context order by LFN_Order";
                dt = cdf.GetRSReadFromQuery_(strSQL, connString, parCollection: parcoll);
            }

            return dt;
        }


        public static TSRecordSet GetRSGroupFunction_(string strGroup, int Context = 0)
        {

            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@strGroup", strGroup);
            sqlParams.Add("@Context", Context);

			string strSql = "SELECT * FROM LIB_Functions with(nolock) where LFN_GroupFunction = @strGroup and LFN_Context = @Context order by lfn_order";
			TSRecordSet rs = cdf.GetRSReadFromQuery_(strSql, ApplicationCommon.Application["ConnectionString"], null, parCollection: sqlParams);

            return rs;
        }

        //'-- carico un oggetto di tipo toolbar con le informazioni prese dalla tabella
        public static Toolbar GetHtmlToolbar(string group, string strPermission, string suffix, string strConnectionStringOpt = "", dynamic? sessionUser = null)
        {
            Toolbar objToolbar = new();

            LoadHtmlFunctionObj(objToolbar, group, strPermission, suffix, strConnectionStringOpt, sessionUser);

            objToolbar.id = group;
            return objToolbar;
        }

        private static void LoadHtmlFunctionObj(dynamic objHtml, string group, string strPermission, string suffix, string strConnectionStringOpt = "", eProcurementNext.Session.ISession? sessionUser = null)
        {

            HTML.ToolbarButton objButton;

            int numButton;
            TSRecordSet rs;
            int i;
            int nPosPermission;

            if (!string.IsNullOrEmpty(strConnectionStringOpt))
            {
                connString = strConnectionStringOpt;
            }

            //'-- prende il recordset completo per il disegno dei gruppi
            var sqlParams = new Dictionary<string, object?>
            {
                { "@group", group }
            };

            var cdf = new CommonDbFunctions();
            rs = cdf.GetRSReadFromQuery_("SELECT * FROM LIB_Functions WITH (nolock) where LFN_GroupFunction = @group and LFN_Context = 0 order by lfn_order", connString, parCollection: sqlParams); //GetRSGroupFunction_(group);
            if (rs is null)
            { 
                return;
			}

			numButton = rs.RecordCount;
            rs.MoveFirst();

            //'-- scorro tutti i record degli eventi
            for (i = 0; i <= numButton - 1; i++)
            {
                nPosPermission = 0;
                if (rs["LFN_PosPermission"] is not null)
                {
                    nPosPermission = CInt(rs["LFN_PosPermission"]!);
                }

                if (IsEnabled(strPermission, nPosPermission))
                {
                    //'-- creo il nuovo bottone
                    objButton = new HTML.ToolbarButton
                    {
                        Icon = CStr(rs["LFN_UrlImage"]),
                        Id = CStr(rs["LFN_id"]),
                        paramTarget = CStr(rs["LFN_paramTarget"]),
                        Target = CStr(rs["LFN_Target"])

                    };
                    if (sessionUser != null)
                    {
                        objButton.Text = ApplicationCommon.CNV(CStr(rs["LFN_CaptionML"]), sessionUser);
                        objButton.ToolTip = ApplicationCommon.CNV(CStr(rs["LFN_TooltipML"]), sessionUser);
                    }
                    else
                    {
                        objButton.Text = ApplicationCommon.CNV( CStr(rs["LFN_CaptionML"]), suffix);
                        objButton.ToolTip = ApplicationCommon.CNV( CStr(rs["LFN_TooltipML"]), suffix);
                    }

                    objButton.URL = CStr(rs["LFN_UrlNewPage"]);
                    objButton.OnClick = CStr(rs["LFN_OnClick"]);
                    objButton.Condition = CStr(rs["LFN_Condition"]);

                    //'-- accessibilità
                    objButton.accessKey = CStr(rs["LFN_AccessKey"]);

                    //'-- aggiungo il bottone alla toolbar
                    objHtml.Buttons.Add(objButton.Id, objButton);
                }

                rs.MoveNext();
            }
        }

        public Group LoadHtmlFunctionGroup(string nomeGruppo, string permessi)
        {


            Group objHtml = new Group();

            int nPosPermission;

            TSRecordSet dt = GetRSGroupFunction(nomeGruppo);

            if (dt.RecordCount > 0)
            {
                dt.MoveFirst();

                nPosPermission = 0;

                do
                {
                    try
                    {
                        if (dt["LFN_PosPermission"] != null)
                        {
                            nPosPermission = Convert.ToInt32(dt["LFN_PosPermission"].ToString());
                        }
                    }
                    catch (Exception)
                    {
                        nPosPermission = 0;
                    }
                    if (IsEnabled(permessi, nPosPermission))
                    {
                        GroupRow objButton = new GroupRow();
                        objButton.Icon = CStr(dt["LFN_UrlImage"]);
                        objButton.id = CStr(dt["LFN_id"]);

                        string strFunction = CStr(dt["LFN_paramTarget"]);
                        objButton.ParamTarget = strFunction;

                        string strFunction2 = strFunction.Replace("\'", "\\\'");
                        objButton.Func = $"{dt["LFN_OnClick"]}( '{strFunction2}', this);";
                        objButton.Text = ApplicationCommon.CNV((CStr(dt["LFN_CaptionML"])));
                        objButton.Code = CStr(dt["LFN_id"]);
                        objButton.Condition = CStr(dt["LFN_Condition"]);
                        objButton.accesKey = CStr(dt["LFN_AccessKey"]);

                        objHtml.Rows.Add(objButton, objButton.id);
                    }
                    dt.MoveNext();
                }
                while (!dt.EOF);
            }

            return objHtml;
        }

        public List<LightGroup> GetGroups(ISession _session)
        {
            string GruppoPadre = !string.IsNullOrEmpty(CStr(_session["GROUPS_NAME"])) ? CStr(_session["GROUPS_NAME"]) : "DashBoardMain";
            string permessi = CStr(_session["Funzionalita"]);
            string mp_Suffix = "I";

            List<Group> mp_objGroups = GetHtmlGroups(GruppoPadre, "", permessi, mp_Suffix);
            List<LightGroup> mp_objGroupsLight = new List<LightGroup>();

            if (mp_objGroups.Count > 0)
            {
                foreach (var obj in mp_objGroups)
                {
                    LightGroup lg = new LightGroup();
                    lg.subGroupList = new List<SubLightGroup>();
                    lg.id = obj.Id;
                    lg.title = obj.Caption.Text;
                    foreach (GroupRow el in obj.Rows)
                    {
                        SubLightGroup slg = new SubLightGroup();
                        slg.title = el.Text;
                        slg.link = HtmlDecode(el.Func);
                        lg.subGroupList.Add(slg);
                    }
                    mp_objGroupsLight.Add(lg);
                }
            }
            return mp_objGroupsLight;
        }

        public List<Group> GetHtmlGroups(string GruppoPadre, string Path, string permessi, string suffix, int Context = 0)
        {
            TSRecordSet dt;
            groupList = new List<Group>();

            if (string.IsNullOrWhiteSpace(GruppoPadre))
            {
                return groupList;
            }

            Dictionary<string, object?>? parcoll = new()
            {
                { "@GruppoPadre", GruppoPadre },
                { "@Context", Context }
            };
            var strSQL = "SELECT * FROM LIB_Functions with(nolock) where LFN_GroupFunction = @GruppoPadre and LFN_Context = @Context order by LFN_Order";
            dt = cdf.GetRSReadFromQuery_(strSQL, connString, parCollection: parcoll);

            if (dt.RecordCount <= 0) return groupList;

            dt.MoveFirst();

            do
            {
                var objGroup = LoadHtmlFunctionGroup(dt["LFN_Target"].ToString(), permessi);
                if (objGroup.Rows.Count > 0)
                {
                    GroupRow mp_objTitleGr = new();

                    objGroup.Caption = mp_objTitleGr;

                    mp_objTitleGr.Text = ApplicationCommon.CNV(dt["LFN_CaptionML"].ToString(), suffix);

                    string strParamTarget = dt["LFN_paramTarget"].ToString();

                    objGroup.PathIcon = dt["LFN_UrlImage"] != null ? dt["LFN_UrlImage"].ToString() : null;


                    if (!IsNull(dt["LFN_paramTarget"]))
                    {
                        objGroup.Opened = Strings.Left(strParamTarget, 4).ToUpper() == "OPEN" ? true : false;
                    }

                    if (!string.IsNullOrEmpty(Path)) { objGroup.Path = Path; }

                    string s = cdf.GetParam(strParamTarget, "BStyle");
                    if (s != "")
                    {
                        objGroup.Path = s;
                    }

                    s = cdf.GetParam(strParamTarget, "cellspacing");
                    if (s != "")
                    {
                        objGroup.cellspacing = s;
                    }

                    s = cdf.GetParam(strParamTarget, "cellpadding");
                    if (s != "")
                    {
                        objGroup.cellpadding = s;
                    }

                    s = cdf.GetParam(strParamTarget, "Style");
                    if (s != "")
                    {
                        objGroup.Style = s;
                    }

                    s = cdf.GetParam(strParamTarget, "valignHead");
                    if (s != "")
                    {
                        objGroup.valignHead = s;
                    }

                    s = cdf.GetParam(strParamTarget, "ShowMode");
                    if (s != "")
                    {
                        objGroup.ShowMode = s;
                    }

                    s = cdf.GetParam(strParamTarget, "List");
                    if (s != "")
                    {
                        objGroup.List = s;
                    }

                    objGroup.Id = dt["LFN_Target"].ToString();
                    //ColGroup.Add(objGroup, dt["LFN_Target"].ToString());
                    groupList.Add(objGroup);
   
                }
                    
                dt.MoveNext();

            } while (!dt.EOF);

            return groupList;
        }

    }
}