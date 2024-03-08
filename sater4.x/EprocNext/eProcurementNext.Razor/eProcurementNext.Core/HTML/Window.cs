using eProcurementNext.CommonModule;

namespace eProcurementNext.HTML
{
    public class Window
    {
        public string Caption;
        public string Style;
        public string id;
        public string PathImage;
        public bool Opened;
        public string Height;
        public string width;
        //private dynamic response; // non usata in Window

        public bool PositionAbsolute;

        private int mp_BorderStyle;

        public static int NOBORDER = 0;
        public static int Letter = 1;
        public static int Cuscino = 2;
        public static int Group = 3;
        public static int Group3D = 4;
        public static int Label = 5;
        public static int NOIMAGES = 6;

        public string Path;
        public bool SubWin;
        public int Zindex;
        public string onmouseover;
        public string onmouseout;

        public string mp_accessible;

        public Window()
        {
            Style = "Window";
            width = "100%";
            PathImage = "../CTL_Library/images/window/style1/";
            Path = "../CTL_Library/images/window/style";
            mp_BorderStyle = Letter;

            Opened = true;
        }

        public void BorderStyle(int iStyle)
        {

            PathImage = $@"{Path}{iStyle}/";

            mp_BorderStyle = iStyle;

        }
        //'-- avvalora la collezione con i javascript necessari al corretto
        //'-- funzionamento del controllo
        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library/")
        {
            try
            {
                JS.Add("ShowGroup", $@"<script src=""{Path}jscript/ShowGroup.js"" ></script>");
            }
            catch { }
            try
            {
                JS.Add("getObj", $@"<script src=""{Path}jscript/getObj.js"" ></script>");
            }
            catch { }
            try
            {
                JS.Add("GetPosition", $@"<script src=""{Path}jscript/GetPosition.js"" ></script>");
            }
            catch { }
            try
            {
                JS.Add("setVisibility", $@"<script src=""{Path}jscript/setVisibility.js"" ></script>");
            }
            catch { }
            try
            {
                JS.Add("setClassName", $@"<script src=""{Path}jscript/setClassName.js"" ></script>");
            }
            catch { }
        }

        //'-- ritorna il codice html per rappresentare la riga di un gruppo
        public void Html(IEprocResponse _response, dynamic obj)
        {
            String strCssClass;

            strCssClass = "";

            //'-- nel caso di sottofinestra usata per i menu non si disegna la finestra chiusa
            if (SubWin == false)
            {

                if (Zindex != 0)
                {
                    strCssClass = "zindex_top";
                }

                //'-- se la posizione � assoluta non nasconde la finestra chiusa
                if (PositionAbsolute == false)
                {

                    strCssClass = $"{strCssClass}{(Opened ? " display_none" : "")}";

                }
                else
                {
                    strCssClass = $@"{strCssClass} position_absolute";
                }

                //'-- DISEGNO TABELLA DEL GRUPPO CHIUSA

                _response.Write($@"<div {(strCssClass != "" ? $@"class=""{strCssClass}"" " : "")}");

                _response.Write($@" onmouseover=""{onmouseover}"" ");
                _response.Write($@" onmouseout=""{onmouseout}"" ");
                _response.Write($@" id=""Group_Close_{id} "" > ");

                _response.Write($@"<table class=""Group"" width=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0""> ");

                LocalDrawGroupCaption(_response, id, Caption, 0);

                _response.Write($@"</table> ");
                _response.Write($@"</div> ");

            }

            strCssClass = "";

            strCssClass = $"{strCssClass}{(Opened ? "" : " display_none")}";
            strCssClass = $"{strCssClass}{(PositionAbsolute ? " position_absolute" : "")}";
            strCssClass = $"{strCssClass}{(Zindex != 0 ? " zindex_top" : "")}";



            _response.Write($@"<div ");


            _response.Write($@" onmouseover=""{onmouseover}"" ");
            _response.Write($@" onmouseout=""{onmouseout}"" ");

            _response.Write($@" class=""Group_Open_{id}{strCssClass}"" id=""Group_Open_{id}"" > ");


            if (obj.GetType() == typeof(string))
            {
                _response.Write($@" {obj}");
            }
            else
            {
                obj.Html(_response);
            }
            _response.Write($@" ");

            _response.Write($@"</div> ");

            //'-- mette lo script per posizionare la finestra sopra quella chiusa
            if (PositionAbsolute && SubWin == false)
            {

                _response.Write($@"     <script type=""text/javascript"" > ");
                _response.Write($@"var OldOnLoadWin{id}; ");
                _response.Write($@"function ResizeWin{id}() ");
                _response.Write($@"{{");

                _response.Write($@"        var objOpen; ");
                _response.Write($@"        var objClose; ");

                _response.Write($@"        objOpen = getObj( 'Group_Open_{id}' ); ");
                _response.Write($@"        objClose = getObj( 'Group_Close_{id}' ); ");

                _response.Write($@"        objOpen.style.top = PosTop( objClose ); ");
                _response.Write($@"        objOpen.style.left = PosLeft( objClose ); ");

                _response.Write($@"        objOpen.style.width = objClose.offsetWidth ; ");
                _response.Write($@"        try{{ OldOnLoadWin{id}(); }}catch( e ) {{}}; ");
                _response.Write($@"}} ");

                _response.Write($@"OldOnLoadWin{id} = window.onload; ");
                _response.Write($@"window.onload = ResizeWin{id}; ");
                _response.Write($@"        var objOpen; ");
                _response.Write($@"        var objClose; ");
                _response.Write($@"        objOpen = getObj( 'Group_Open_{id}' ); ");
                _response.Write($@"        objClose = getObj( 'Group_Close_{id}' ); ");

                _response.Write($@"        objOpen.style.top = PosTop( objClose ); ");
                _response.Write($@"        objOpen.style.left = PosLeft( objClose ); ");
                _response.Write($@"     </script>");

            }

        }


        private void LocalDrawGroupCaption(IEprocResponse _response, string IdGruppo, string strCaption, int iOpenClose)
        {

            //'-- apertura riga  HTML della funzione
            _response.Write("<tr ");
            if (SubWin == false)
            {

                _response.Write($@" onclick=""Javascript: ShowCloseGroup( '{IdGruppo.Trim()}');""");

            }
            _response.Write(" >");

            //'-- caption
            if (mp_BorderStyle == Label)
            {

                _response.Write($@"<td width=""100%""><table width=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0"" ><tr>");


                _response.Write($@"<td id=""{id}"" valign=""top"" class=""HeadGridGroup"" ");


                _response.Write($@">");
                _response.Write($@"{strCaption}");
                _response.Write($@" </td> ");


                //'-- bitmap chiusura label
                _response.Write($@"<td> ");
                _response.Write($@"<img alt="""" src=""");
                _response.Write($@"{PathImage}{(iOpenClose == 1 ? "a1_2.jpg" : "d1_2.jpg")}""/>");
                _response.Write($@"</td> ");

                //'-- chiusura della caption
                _response.Write($@"<td valign=""top"" class=""HeadGridGroup"" width=""100%"" ");

                _response.Write($@" >&nbsp;");
                _response.Write($@"</td> ");


                _response.Write($@"</tr></table></td>");

            }
            else
            {

                _response.Write($@"<td id=""{id}"" valign=""top"" width=""100%"" ");

                if (mp_BorderStyle != NOIMAGES)
                {
                    _response.Write($@" class=""HeadGridGroup"" ");
                }
                else
                {
                    _response.Write($@" class=""{(iOpenClose == 1 ? "OpenGroup" : "CloseGroup")}""");
                }

                _response.Write($@">");
                _response.Write($@"{strCaption}");
                _response.Write($@"</td> ");

            }

            //'-- chiusura riga  HTML della funzione
            _response.Write($@"</tr> ");

        }

        //traduzione non necessaria (richiamata solo dalla versione non accessibile
        private string LocalDrawGroupRow(string objResp, dynamic obj)
        {
            return objResp;
        }

        //traduzione non necessaria (richiamata solo dalla versione non accessibile
        private void LocalDrawGroupBottom(IEprocResponse _response)
        {

            //'-- apertura riga  HTML della funzione
            _response.Write($@" <tr ");
            _response.Write($@" > ");

            //'-- bitmap lato sinistro
            _response.Write($@"<td> ");
            if (mp_BorderStyle != NOIMAGES)
            {
                _response.Write($@"<img alt="""" src=""{PathImage}a3.jpg""/>");
            }
            else
            {
                _response.Write($@"&nbsp;");
            }
            _response.Write($@"</td> ");

            _response.Write($@"<td class=""width_100_percent""");

            if (mp_BorderStyle != NOIMAGES)
            {

                _response.Write($@" ");
            }
            else
            {
                _response.Write($@">&nbsp; ");
            }
            _response.Write($@"</td> ");

            //'-- bitmap angolo destro
            _response.Write($@"<td> ");
            if (mp_BorderStyle != NOIMAGES)
            {
                _response.Write($@"<img alt="""" src=""{PathImage}c3.jpg""/>");
            }
            else
            {
                _response.Write($@"&nbsp;");
            }
            _response.Write($@"</td> ");

            //'-- chiusura riga  HTML della funzione
            _response.Write($@"</tr> ");
        }


        public void Init(string strId, string strCaption, bool bOpenClose, int border)
        {

            Caption = strCaption;
            id = strId;
            Opened = bOpenClose;
            BorderStyle(border);
            mp_accessible = "NO";

        }

    }
}

