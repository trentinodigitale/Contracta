using Microsoft.VisualBasic;
using System.Text;
using System.Web;

namespace eProcurementNext.HTML
{
    public class Group
    {
        public string Style;
        public string Id;
        public string Path;
        public string PathIcon;
        public bool Opened = false;
        private object response;
        public string cellpadding;
        public string cellspacing;
        public string valignHead;
        private string mp_ShowImage; // se 0 non vanno visualizzate immagini
        public string List;
        public string ShowMode;
        public GroupRow Caption;
        public Collection Rows;

        public Group()
        {
            Style = "";
            Path = "../CTL_Library/images/group/";
            PathIcon = "../CTL_Library/images/Domain/";
            Opened = true;

            cellpadding = "0";
            cellspacing = "0";
            valignHead = "top";

            List = "0";
            ShowMode = "";

            Rows = new Collection();
        }

        /// <summary>
        /// ritorna il codice html per rappresentare la riga di un gruppo
        /// </summary>
        /// <returns></returns>
        public StringBuilder Html()
        {
            //Group objGroup = this;
            string strOpenedBlock = this.Opened ? "style=\"display:block\"" : "";
            string strOpenedClass = this.Opened ? "" : @$" class=""display_none Group_Open_{this.Id}""";
            string strOpenedClassTab = this.Opened ? $@"class=""display_none""" : ""; // verificare 

            //GroupRow row = new GroupRow();
            StringBuilder objResp = new StringBuilder();

            // NUOVA GESTIONE PER LA GRAFICA NUOVA
            if (this.ShowMode == "DIV")
            {
                // disegno intestazione del gruppo aperto
                //objResp.Append(LocalDrawGroupCation(this.Id, this.Caption.Text, 1));
                objResp.Append(LocalDrawGroupCation(1));

                objResp.Append(Environment.NewLine);
                objResp.Append($"<div class=\"\" \"divmenufollow\"");
                objResp.Append($"<ul class=\"{this.Style}\"");
                foreach (GroupRow row in this.Rows)
                {
                    //objResp.Append(LocalDrawGroupRow(this.Id, row, 0));
                    objResp.Append(LocalDrawGroupRow(row, 0));

                }
                objResp.Append("</ul>");
                objResp.Append("</div>");
            }
            else
            {
                objResp.Append(@$"<div id=""Group_Open_{this.Id.Trim()}""");
                objResp.Append(strOpenedClass);
                objResp.Append("> ");
                objResp.Append(@$"<ul class=""ul_menu"">");
            }

            // disegno intestazione del gruppo aperto
            //objResp.Append(LocalDrawGroupCation(this.Id, this.Caption.Text, 1));
            objResp.Append(LocalDrawGroupCation(1));
            objResp.Append(" ");

            // If UCase(accessible) = "YES"
            objResp.Append(@$"<ul class=""ul_sub_menu""> ");

            // disegno tutte le righe del gruppo

            //foreach (GroupRow row in objGroup.Rows)
            foreach (GroupRow row in this.Rows)
            {
                objResp.Append(LocalDrawGroupRow(row, 0).ToString());
            }

            // If UCase(accessible) = "YES" 

            objResp.Append("</ul> ");
            objResp.Append("</li> ");  // chiudo l'elemento LI aperto nel menu padre

            objResp.Append("</ul>");
            objResp.Append("</div> ");

            //----------------------------------------------------------
            //-- DISEGNO TABELLA DEL GGRUPPO CHIUSA

            objResp.Append(@$"<div id=""Group_Close_{this.Id}"" ");
            objResp.Append(strOpenedClassTab);
            objResp.Append("> ");
            objResp.Append(@"<ul class=""ul_menu"">");

            //objResp.Append(LocalDrawGroupCation(this.Id, this.Caption.Text, 0));
            objResp.Append(LocalDrawGroupCation(0));

            objResp.Append("</li> </ul> </div> ");

            return objResp;
        }

        //'-- avvalora la collezione con i javascript necessari al corretto
        //'-- funzionamento del controllo
        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library/")
        {

            if (!JS.ContainsKey("ShowGroup"))
                JS.Add("ShowGroup", $"<script type=\"text/javascript\" src=\"{Path}jscript/ShowGroup.js\"></script>"); // "ShowGroup"
            if (!JS.ContainsKey("getObj"))
                JS.Add("getObj", $"<script type=\"text/javascript\" src=\"{Path}jscript/getObj.js\"></script>");  // "getObj"
            if (!JS.ContainsKey("setVisibility"))
                JS.Add("setVisibility", $"<script type=\"text/javascript\" src=\"{Path}jscript/setVisibility.js\"></script>"); //"setVisibility"
            if (!JS.ContainsKey("setClassName"))
                JS.Add("setClassName", $"<script type=\"text/javascript\" src=\"{Path}jscript/setClassName.js\"></script>"); //, "setClassName"
        }


        //public String LocalDrawGroupCation(string idGruppo, string strCaption, int iOpenClose)
        public String LocalDrawGroupCation(int iOpenClose)
        {
            StringBuilder objResp = new StringBuilder();

            string strSelected = iOpenClose == 1 ? "selected" : "";
            string strOpen = Opened ? "1" : "0";
            string striOpenClose = iOpenClose == 1 ? "Group_Open" : "Group_Close";

            if (ShowMode == "DIV")
            {
                objResp.Append($@"<div class=""divmenu{strSelected}"" id=""{this.Id}divmenu"" >");
                objResp.Append("<ul> ");
                objResp.Append("<li>");
                objResp.Append($@"<button class=""{this.Style}"" onclick=""Javascript: ShowGroupDIV( '{this.Id}divmenufollow' ,  {strOpen}  , '{this.Id}divmenu'); "" ");
                //objResp.Append($" id=\"button_{idGruppo}_{striOpenClose})");
                objResp.Append($" id=\"button_{this.Id}_{striOpenClose})");
                //objResp.Append($@"id=""button_{idGruppo}_{striOpenClose}"" ");
                objResp.Append($@"id=""button_{this.Id}_{striOpenClose}"" ");
                objResp.Append(">");

                if (!String.IsNullOrEmpty(PathIcon))
                {
                    objResp.Append($@"<img src=""{PathIcon}"" />");
                }
                //objResp.Append(strCaption);
                objResp.Append(this.Caption.Text);


                objResp.Append("</button>");
                objResp.Append("</li>");
                objResp.Append("</ul> ");
                objResp.Append("</div> ");
            }
            else
            {
                //string strOnClick = $@" onclick =""Javascript: ShowGroup( '{idGruppo.Trim()}' , {iOpenClose} );return false;""";
                string strOnClick = $@" onclick =""Javascript: ShowGroup( '{this.Id.Trim()}' , {iOpenClose} );return false;""";
                objResp.Append("<li>");
                //objResp.Append($@"<a href=""#"" id=""button_{idGruppo.Trim()}_{striOpenClose}"" {strOnClick} class=""button_link"">");
                objResp.Append($@"<a href=""#"" id=""button_{this.Id.Trim()}_{striOpenClose}"" {strOnClick} class=""button_link"">");
                //objResp.Append(strCaption);
                objResp.Append(this.Caption.Text);
                objResp.Append("</a>");
            }

            return objResp.ToString();
        }

        //protected String LocalDrawGroupRow(string idGruppo, GroupRow row, int numRead)
        protected String LocalDrawGroupRow(GroupRow row, int numRead)
        {
            StringBuilder objResponse = new StringBuilder();
            string strOnClik = string.Empty;
            string strRowCaption = row.Text;

            if (this.ShowMode == "DIV")
            {

                objResponse.Append("<li>");
                objResponse.Append($@"<button class=""{Style}"" onclick=""Javascript:{CommonModule.Basic.GetEncodedUTF8String(row.Func)}"" ");
                if (!String.IsNullOrEmpty(row.accesKey))
                {
                    objResponse.Append($@"accesskey=""{HttpUtility.HtmlEncode(row.accesKey)}"" ");
                }
                objResponse.Append(">");
                objResponse.Append(strRowCaption);
                objResponse.Append("</button></li>");
            }
            else
            {
                if (row.Disable != "1")
                {
                    strOnClik = $@" onclick=""Javascript:{row.Func};return false;"" ";
                }
                objResponse.Append("<li> ");
            }

            if (!String.IsNullOrEmpty(row.Icon))
            {
                objResponse.Append($@"<img alt="""" id=""GroupImg_{row.id}""  src=""");
                objResponse.Append($@"{PathIcon}{row.Icon}""/>");
            }

            if (this.List != "0")
            {
                objResponse.Append("<li> ");
            }
            objResponse.Append($@"<a href=""#"" class=""button_link"" ");
            objResponse.Append(strOnClik);

            if (!String.IsNullOrEmpty(row.accesKey))
            {
                objResponse.Append($@"accesskey=""{HttpUtility.HtmlEncode(row.accesKey)}"" ");
            }

            objResponse.Append("> ");
            objResponse.Append(strRowCaption);
            objResponse.Append($@"</a>");
            objResponse.Append("</li> ");


            return objResponse.ToString();
        }

    }

    public class LightGroup
    {
        public string id { get; set; }
        public string title { get; set; }

        public List<SubLightGroup> subGroupList { get; set; }

    }

    public class SubLightGroup
    {
        public string title { get; set; }

        public string link { get; set; }
    }

}

