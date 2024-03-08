using eProcurementNext.Application;
using eProcurementNext.CommonModule;
using eProcurementNext.Razor.Model;
using Microsoft.AspNetCore.Html;
using Microsoft.AspNetCore.Mvc;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.Session.SessionMiddleware;

namespace eProcurementNext.Razor.ViewComponents
{
    public class BreadcrumbViewComponent : ViewComponent
    {
        private IHttpContextAccessor _accessor;

        private eProcurementNext.Session.ISession _session;

        private Breadcrumb breadcrumb;
        public BreadcrumbViewComponent(IHttpContextAccessor Accessor, eProcurementNext.Session.ISession _Session)
        {
            _accessor = Accessor;
            _session = _Session;

            HttpContext context = this._accessor.HttpContext;

            LoadSession(context, _session);
            breadcrumb = new Model.Breadcrumb();

        }

        public IViewComponentResult Invoke(dynamic obj)
        {
            System.Text.StringBuilder item;
            if (IsMasterPageNew())
            {
                item = GetHtmlCode(obj.pathRoot, obj.firstElement, CStr(obj.durataSessione));
            }
            else
            {
                item = GetHtmlCode(obj.pathRoot);

            }
            HtmlString tmp = new HtmlString(item.ToString());
            breadcrumb.Content = tmp;
            return View(breadcrumb);
        }


        private System.Text.StringBuilder GetHtmlCode(dynamic pathRoot)
        {
            EprocResponse _out = new EprocResponse();

            if (IsEmpty(_session["stack_path"]))
            {
                _out.Write("");
                return new System.Text.StringBuilder(_out.Out().ToString());
            }



            dynamic[,] mp_stackMatrix = _session["stack_path"];

            int posCorrente = CInt(_session["stack_index"]);


            for (int i = 0; i <= posCorrente - 1; i++)
            {


                if (!string.IsNullOrEmpty(CStr(mp_stackMatrix[i, 2]).Trim()))
                {


                    _out.Write($@" &gt; ");


                    string url = pathRoot + $@"ctl_library/path.asp?url=" + URLEncode(CStr(mp_stackMatrix[i, 1])) + "&KEY=" + CStr(mp_stackMatrix[i, 3]);


                    _out.Write($@"<a href=""{HtmlEncode(url)}""");



                    //'-- facciamo uscire ad ogni click sulle molliche di pane il grigiato di carimento in corso

                    _out.Write($@" onclick=""try{{ShowWorkInProgress();}}catch(e){{}}""");



                    //'-- se siamo sull'ultimo elemento aggiunto una classe che me lo identifica in modo univoco

                    if (i == posCorrente - 1)
                    {


                        _out.Write($@" id=""last_breadcrumb""");


                    }
                    else
                    {

                        _out.Write($@" class=""breadcrumb_element""");


                    }


                    _out.Write($@">{ApplicationCommon.CNV(CStr(mp_stackMatrix[i, 2]))}</a> ");


                }


            }


            return new System.Text.StringBuilder(_out.Out().ToString());
        }

        private System.Text.StringBuilder GetHtmlCode(dynamic pathRoot, string firstElement, string durataSessione)
        {
            EprocResponse _out = new EprocResponse();

            if (IsEmpty(_session["stack_path"]))
            {
                _out.Write("");
                return new System.Text.StringBuilder(_out.Out().ToString());
            }

            dynamic[,] mp_stackMatrix = _session["stack_path"];

            int posCorrente = CInt(_session["stack_index"]);
            _out.Write(@"<div style=""display:flex;justify-content: space-between"">");

            #region breadCrumb

            _out.Write($@"<ul class=""vapor-breadcrumbs"">");
            _out.Write($@"<li>");
            _out.Write($@"{firstElement}");
            _out.Write($@"
                <span>
                    <i class=""fas fa-caret-right""></i>
                </span>
            ");
            _out.Write($@"</li>");

            for (int i = 0; i <= posCorrente - 1 + 1; i++)
            {


                if (!string.IsNullOrEmpty(CStr(mp_stackMatrix[i, 2]).Trim()))
                {
                    string url = pathRoot + $@"ctl_library/path.asp?url=" + URLEncode(CStr(mp_stackMatrix[i, 1])) + "&KEY=" + CStr(mp_stackMatrix[i, 3]);
                    _out.Write($@"<li>");

                    _out.Write($@"<a 
                        href=""{HtmlEncode(url)}""
                        onclick=""try{{ShowWorkInProgress();}}catch(e){{}}""
                        ");

                    

                    //'-- se siamo sull'ultimo elemento aggiunto una classe che me lo identifica in modo univoco

                    if (i == posCorrente - 1 )
                    {
                        string testMain;
                        try
                        {
                            testMain = mp_stackMatrix[i + 1, 2];
                        }
                        catch
                        {
                            testMain = "";
                        }
                        if(mp_stackMatrix[i, 2] == testMain)
                        {
                            continue;
                        }
                        _out.Write($@" id=""last_breadcrumb""");
                        _out.Write($@">{ApplicationCommon.CNV(CStr(mp_stackMatrix[i, 2]))}</a> ");
                        _out.Write($@"
                            <span>
                              <i class=""fas fa-caret-right""></i>
                            </span>
                        ");

                    }
                    else if(i == posCorrente)
                    {
                        _out.Write($@" class=""breadcrumb_element current""");
                        _out.Write($@">{ApplicationCommon.CNV(CStr(mp_stackMatrix[i, 2]))}</a> ");
                        
                    }
                    else
                    {

                        _out.Write($@" class=""breadcrumb_element""");
                        _out.Write($@">{ApplicationCommon.CNV(CStr(mp_stackMatrix[i, 2]))}</a> ");
                        _out.Write($@"
                            <span>
                              <i class=""fas fa-caret-right""></i>
                            </span>
                        ");
                    }



                }


            }

            _out.Write($@"</ul>");

            #endregion

            #region info minuti/ore session/server

            _out.Write(@"<div class=""mr-5 span_footer_datetime containerInfoSessionServerHours"">");
            _out.Write(@"<div style=""text-align: end;"">");
            _out.Write($@"<span class=""mr-2 font-weight-bold"">{ApplicationCommon.CNV("Ora Server", _session)}:</span><span id=""DateTime""></span>");
            
            _out.Write(@"</div>");

            _out.Write(@"<div style=""text-align: end;"">");

            _out.Write($@"<span class=""ml-3 mr-2 font-weight-bold"">{ApplicationCommon.CNV("Tempo stimato di sessione rimanente", _session)}:</span><span id=""tempo_di_sessione"">{CStr(durataSessione)}:00 m</span>");
            _out.Write(@"</div>");

            _out.Write(@"</div>");
            #endregion

            _out.Write(@"</div>");


            return new System.Text.StringBuilder(_out.Out().ToString());
        }

    }
}

