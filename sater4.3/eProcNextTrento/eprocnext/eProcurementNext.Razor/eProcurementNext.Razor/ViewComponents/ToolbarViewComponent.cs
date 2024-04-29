using eProcurementNext.Application;
using eProcurementNext.CommonModule;
using eProcurementNext.Razor.Model;
using Microsoft.AspNetCore.Html;
using Microsoft.AspNetCore.Mvc;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.Session.SessionMiddleware;

namespace eProcurementNext.Razor.ViewComponents
{
    public class ToolbarViewComponent : ViewComponent
    {
        private IHttpContextAccessor _accessor;

        private eProcurementNext.Session.ISession _session;

        private Toolbar toolbar;
        public ToolbarViewComponent(IHttpContextAccessor Accessor, eProcurementNext.Session.ISession _Session)
        {
            _accessor = Accessor;
            _session = _Session;

            HttpContext context = this._accessor.HttpContext;

            LoadSession(context, _session);
            toolbar = new Model.Toolbar();

        }

        public IViewComponentResult Invoke(bool newStyle)
        {
            var item = GetHtmlCode(newStyle);
            HtmlString tmp = new HtmlString(item.ToString());
            toolbar.Content = tmp;
            return View(toolbar);
        }


        private System.Text.StringBuilder GetHtmlCode()
        {
            EprocResponse _out = new EprocResponse();

            _out.Write($@"

				<div class=""main_top_2"">
			");




            //dim ObjSession

            //ObjSession = session("Session")
            //set ObjSession(0) = Request.QueryString
            //set ObjSession(1) = Request.form

            ////'-- Passiamo di nuovo anche la request all'indice 3 per permettere alla classe ctldb.blacklist di recuperare l'ip
            //set ObjSession(3) = request
            //set ObjSession(5) = session
            //set ObjSession(6) = application
            //ObjSession(9) = application("Server_RDS")
            //ObjSession(10) = session("Funzionalita")' permessi utenti

            //set ObjSession(13) = objNewDizMlng("MultiLinguismo")


            if (ApplicationCommon.Application["SERVIZIO"] != "-")
            {

                //set objDB = createobject( "ctldb.Lib_dbFunction" )
                eProcurementNext.HTML.Toolbar tb = eProcurementNext.BizDB.Lib_dbFunctions.GetHtmlToolbar(CStr("TOOLBAR_HOMELIGHT"), CStr(_session["Funzionalita"]), CStr(_session["strSuffLing"]), CStr(ApplicationCommon.Application["ConnectionString"]), _session);

                _out.Write($@"<div id=""main_top_toolbar"" class=""main_top_toolbar"">");
                tb.mp_accessible = CStr(ApplicationCommon.Application["ACCESSIBLE"]).ToUpper();
                tb.Html(_out);
                _out.Write("</div>");
            }




            _out.Write($@"
				</div>

			");
            return new System.Text.StringBuilder(_out.Out());
        }

        private System.Text.StringBuilder GetHtmlCode(bool newStyle)
        {
            if (newStyle == false)
            {
                return GetHtmlCode();
            }

            EprocResponse _out = new EprocResponse();

            _out.Write($@"

				<div class=""main_top_2"">
			");




            //dim ObjSession

            //ObjSession = session("Session")
            //set ObjSession(0) = Request.QueryString
            //set ObjSession(1) = Request.form

            ////'-- Passiamo di nuovo anche la request all'indice 3 per permettere alla classe ctldb.blacklist di recuperare l'ip
            //set ObjSession(3) = request
            //set ObjSession(5) = session
            //set ObjSession(6) = application
            //ObjSession(9) = application("Server_RDS")
            //ObjSession(10) = session("Funzionalita")' permessi utenti

            //set ObjSession(13) = objNewDizMlng("MultiLinguismo")


            if (ApplicationCommon.Application["SERVIZIO"] != "-")
            {

                //set objDB = createobject( "ctldb.Lib_dbFunction" )
                eProcurementNext.HTML.Toolbar tb = eProcurementNext.BizDB.Lib_dbFunctions.GetHtmlToolbar(CStr("TOOLBAR_HOMELIGHT"), CStr(_session["Funzionalita"]), CStr(_session["strSuffLing"]), CStr(ApplicationCommon.Application["ConnectionString"]), _session);

                _out.Write($@"<div id=""main_top_toolbar"" class=""main_top_toolbar"">");
                tb.mp_accessible = CStr(ApplicationCommon.Application["ACCESSIBLE"]).ToUpper();
                tb.Html(_out);
                _out.Write("</div>");
            }




            _out.Write($@"
				</div>

			");
            return new System.Text.StringBuilder(_out.Out());
        }
    }
}

