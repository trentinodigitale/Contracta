using eProcurementNext.Application;
using eProcurementNext.Razor.Model;
using Microsoft.AspNetCore.Html;
using Microsoft.AspNetCore.Mvc;
using static eProcurementNext.Session.SessionMiddleware;

namespace eProcurementNext.Razor.ViewComponents
{
    public class ChatViewComponent : ViewComponent
    {
        private IHttpContextAccessor _accessor;

        private eProcurementNext.Session.ISession _session;

        private Chat chat;
        public ChatViewComponent(IHttpContextAccessor Accessor, eProcurementNext.Session.ISession _Session)
        {
            _accessor = Accessor;
            _session = _Session;

            HttpContext context = this._accessor.HttpContext;

            LoadSession(context, _session);
            chat = new Model.Chat();

        }

        public IViewComponentResult Invoke(dynamic obj)
        {
            var item = GetHtmlCode(obj.pathRoot);
            HtmlString tmp = new HtmlString(item.ToString());
            chat.Content = tmp;
            return View(chat);
        }


        private System.Text.StringBuilder GetHtmlCode(dynamic pathRoot)
        {
            System.Text.StringBuilder righe = new System.Text.StringBuilder();

            string tmp = $@"

                <div id=""AF_CHAT_ICO"" class=""AF_CHAT_ICO"" onclick=""AF_CHAT_OpenWin()""  style=""display:none"" ><img src=""{pathRoot}ctl_library/Chat/Chat.png"" alt=""Apri finestra delle conversazioni"" ><div id=""AF_CHAT_NUM_MSG_NOT_READ""  style=""display:none"" ></div></div>


                <div id=""AF_CHAT_WIN"" title=""{ApplicationCommon.CNV("Conversazioni Presenti", _session)}"" class=""AF_CHAT_WIN"" onresize=""AF_CHAT_Resize(this);"" style=""display:none"" >

                    <table class=""AF_CHAT_TAB"" >
                        <tr>
                            <td rowspan=2>
                                <div id=""AF_CHAT_ROOMS""></div>
                            </td>
                            <td>
                                <div id=""AF_CHAT_ROOM"">{ApplicationCommon.CNV("Selezionare una Conversazione dall'elenco", _session)}</div>
                            </td> 
                        </tr>
                        <tr>
                            <td height=""0"">
                                <div id=""AF_CHAT_MSG"" style=""display:none"" >
                                    <form id=""AF_CHAT_NEW_MSG"" name=""AF_CHAT_NEW_MSG""  >
                                        <textarea rows=""4"" cols=""50"" id=""AF_CHAT_MESSAGE"" name=""AF_CHAT_MESSAGE""> </textarea>
                                    </form>

                                    <div id=""AF_CHAT_BUTTON""   ><input type=""button"" class=""AF_CHAT_SEND_MSG"" value=""Aggiungi testo alla conversazione""  onclick=""AF_CHAT_NewMSG()"" ></div>
                                    <div name=""AF_CHAT_RESULT"" id=""AF_CHAT_RESULT"" style=""display:none""  ></div>
                
                                </div>
                            </td>
                        </tr>
                    </table>
    
                </div>
			";
            righe.Append(tmp);
            return righe;
        }
    }
}

