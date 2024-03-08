using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.Basic;

namespace eProcurementNext.HTML
{
    public class Toolbar
    {

        int CONST_LENGTH_LINK = 40;

        public Dictionary<string, ToolbarButton> Buttons;
        public bool ShowBackGround;
        public string width;
        public string strPath;
        public string Style;

        public string id;
        //private response As Object//non usata in Toolbar
        private int levelDraw;
        private int CurButtonDraw;
        private string[] subMenuDraw = new string[10];

        private Dictionary<string, string> SubMenuId = new();

        public string mp_accessible;


        public Toolbar()
        {

            //ShowSeparetor = false; // valore non presente nella classe
            ShowBackGround = false;
            //ButtonSize = 0; // valore non presente nella classe
            //Height = ""; // valore non presente nella classe
            width = "100%";
            Style = "Toolbar";
            strPath = "../CTL_Library/images/toolbar/";
            Buttons = new Dictionary<string, ToolbarButton>();
            mp_accessible = "NO";

        }

        //'-- avvalora la collezione con i javascript necessari al corretto
        //'-- funzionamento del controllo
        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library/")
        {
            //ToolbarButton Button = new ToolbarButton();
            Window win = new Window();

            win.JScript(JS, Path);
            try
            {
                JS.Add("ExecFunction", $@"<script src=""{Path}jscript/ExecFunction.js"" ></script>");
            }
            catch { }
            try
            {
                JS.Add("OpenCloseSubMenu", $@"<script src=""{Path}jscript/OpenCloseSubMenu.js"" ></script>");
            }
            catch { }
            try
            {
                JS.Add("toolbar", $@"<script src=""{Path}jscript/toolbar/toolbar.js"" ></script>");
            }
            catch { }

            //' -- ciclo sui bottoni ed inserisco il java script collegato
            foreach (KeyValuePair<string, ToolbarButton> Button in Buttons)
            {
                if (!String.IsNullOrEmpty(Button.Value.OnClick))
                {
                    try
                    {
                        JS.Add($@"{Button.Value.OnClick}", $@"<script src=""{Path}jsapp/{Button.Value.OnClick}.js"" ></script>");
                    }
                    catch { }
                }
            }

        }



        //'-- ritorna il codice html per rappresentare la riga di un gruppo
        public void Html(IEprocResponse objResp)
        {

            if (levelDraw > 0)
            {

                bool bcontinue;
                ToolbarButton objButt = new ToolbarButton();


                bcontinue = true;

                //'-- apro la div del sotto menu
                objResp.Write($@"<div class=""{Style}_SUB""> ");
                objResp.Write($@"<ul>");

                //'-- ciclo per inserire il sottomenu
                while (CurButtonDraw < Buttons.Count && bcontinue == true)
                {

                    //'-- se il bottone � nel sottomenu lo disegno altrimenti esco
                    if (Strings.Left(Buttons.ElementAt(CurButtonDraw).Value.Text, subMenuDraw[levelDraw].Length) == subMenuDraw[levelDraw])
                    {

                        LocalDrawCellToolBarAccess(objResp, Buttons.ElementAt(CurButtonDraw).Value);

                        CurButtonDraw = CurButtonDraw + 1;

                    }
                    else
                    {

                        bcontinue = false;
                        CurButtonDraw = CurButtonDraw - 1;

                    }


                }

                //'-- chiudo la div del sotto menu
                objResp.Write($@"</ul>");
                objResp.Write($@"</div>");



            }
            else
            {



                LocalDrawToolBarAccess(objResp);


                //'-- inserisco il vettore con gli id dei sub menu
                objResp.Write($@"<script type=""text/javascript""> ");
                objResp.Write($@"var {id}_subMenu = new Array( {SubMenuId.Count} ); ");
                objResp.Write($@"var {id}_subMenuNum = {SubMenuId.Count}; ");
                objResp.Write($@"var {id}_OnMenu=''; ");
                objResp.Write($@"var {id}_OnSubMenu=''; ");
                objResp.Write($@"var {id}_TraceMenu=''; ");

                int i = 1;
                foreach (KeyValuePair<string, string> item in SubMenuId)
                {
                    objResp.Write($@"{id}_subMenu[{i}] = '{item.Value}'; ");
                    i++;
                }

                objResp.Write("</script> ");

            }


        }





        //' -- disegna la toolbar
        //traduzione non necessaria, viene richiamato solo dalla versione non accessibile
        void LocalDrawToolBar(IEprocResponse objResp)
        {

            //Dim i As Integer
            //On Error Resume Next

            //'-- apertura della tabella HTML
            //objResp.Write "<table id = """ & id & """ width=""" & width & """ cellpadding=""0"" cellspacing=""0"" class=""" & Style & """>" & vbCrLf

            //'-- apertura della riga
            //objResp.Write "<tr>"

            //'-- disegno la prima cella a sinistra
            //If ShowBackGround Then
            //    objResp.Write "<td>" & vbCrLf
            //    objResp.Write "<img alt="""" src=""" & strPath & "Left.gif" & """/>"
            //    objResp.Write "</td>" & vbCrLf
            //End If

            //' -- ciclo sui link e disegno la cella per ogni link
            //Dim Button As ToolbarButton
            //If levelDraw = 0 Then
            //    CurButtonDraw = 1
            //End If
            //While CurButtonDraw <= Buttons.Count
            //    'For Each Button In Buttons
            //    Set Button = Buttons(CurButtonDraw)

            //    LocalDrawCellToolBar objResp, Button

            //    If Not ShowBackGround Then
            //        objResp.Write "<td width=""50px"">" & vbCrLf
            //        objResp.Write "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>" & vbCrLf
            //    End If

            //    CurButtonDraw = CurButtonDraw + 1
            //Wend

            //' -- disegno la cella di separazione
            //If ShowBackGround Then
            //    objResp.Write "<td>" & vbCrLf
            //    objResp.Write "<img alt="""" src=""" & strPath & "Middle.gif" & """/>" & vbCrLf
            //    objResp.Write "</td>" & vbCrLf
            //End If

            //' -- disegno la penultima cella
            //If UCase(accessible) <> "YES" Then
            //    objResp.Write "<td width=""100%"" id=""TLB_Fill_" & id & """ "
            //Else
            //    objResp.Write "<td class=""width_100_percent"" id=""TLB_Fill_" & id & """ "
            //End If

            //If ShowBackGround Then
            //    objResp.Write "background=""" & strPath & "back.gif" & """ "
            //End If
            //objResp.Write ">"
            //objResp.Write "&nbsp;"
            //objResp.Write "</td>" & vbCrLf

            //If ShowBackGround Then
            //    objResp.Write "<td id=""TLB_Last_" & id & """ > " & vbCrLf
            //    objResp.Write "<img alt="""" src=""" & strPath & "Right.gif" & """/>"
            //    objResp.Write "</td>" & vbCrLf
            //End If

            ////'-- chiusura della riga
            //objResp.Write("</tr>");

            ////'-- chiusura della tabella HTML
            //objResp.Write("</table> ");

        }

        //' -- disegna la cella di separazione e la cella che contiene il link
        //traduzione non necessaria, viene richiamato solo dalla versione non accessibile
        void LocalDrawCellToolBar(IEprocResponse objResp, ToolbarButton Button)
        {


            //On Error Resume Next

            //Dim strTooltip
            //Dim CaptionControl
            //string strOnClick;
            //bool bSubMenu;
            //string[] aInfo;
            //int nMaxLengthDesc;

            //nMaxLengthDesc = CONST_LENGTH_LINK;

            //aInfo = Strings.Split(Button.ToolTip, "#")
            //strTooltip = aInfo[0];
            //if (aInfo.Length == 1) {
            //    nMaxLengthDesc = aInfo[1];
            //}

            ////' -- disegno la cella di separazione
            //if (ShowBackGround && levelDraw == 0) {
            //    objResp.Write($@"<td> ");
            //    objResp.Write($@"<img alt="""" border=""0"" src=""{strPath}Middle.gif"" > ");
            //    objResp.Write($@"</td> ");
            //}

            ////'-- verifico se la funzione successiva � un ramo di quella corrente
            //if(CurButtonDraw < Buttons.Count){
            //    if (Strings.Left(Buttons(CurButtonDraw + 1).Text, Button.Text.Length + 1) == $@"{Button.Text}\") {
            //        bSubMenu = true;
            //    }
            //}


            //string Caption;

            //Caption = Strings.Split(Button.Text, $@"\")[levelDraw];

            //if (bSubMenu == true){

            //    //' -- disegno la cella con il link per il sotto menu
            //    if (ShowBackGround){
            //        objResp.Write($@"<td nowrap background=""{strPath}back.gif""  ");
            //    }else{
            //        objResp.Write($@"<td nowrap ");
            //    }
            //    objResp.Write($@" Title=""{strTooltip}"" ");
            //    objResp.Write($@" OpenSub=""0"" valign=""middle"" ");

            //    strOnClick = @" onclick=""Javascript:OpenCloseSubMenuToolbar( '{id}' , '{id}_{Button.id}' );"" ";

            //    //'-- conservo il sottomenu
            //    SubMenuId.Add($@"{id}_{Button.id}_SUB", $@"{id}_{Button.id}_SUB");

            //    objResp.Write(strOnClick);

            //    objResp.Write($@" class=""{Style}_button"" id=""{id}_{Button.id}"" name=""{id}_{Button.id}"" > ");

            //    objResp.Write($@"<div ");

            //    objResp.Write($@" onmouseover=""MenuOn( '{id}' ,  '{id}_{Button.id}', '{Replace(Button.Text, @"\", @"\\") }' );"" ");
            //    objResp.Write($@" onmouseout=""MenuOut( '{id}' , '{id}_{Button.id}' , '{Replace(Button.Text, @"\", @"\\") }');"" ");

            //    objResp.Write($@">");


            //    //'-- bitmap del bottone
            //    if (!String.IsNullOrEmpty(Button.Icon)) {
            //        objResp.Write(@"<img alt="""" border=""0"" src=""");
            //        objResp.Write($@"{strPath}{Button.Icon}"" >");
            //    }

            //    //'-- setto caption e tooltip

            //    CaptionControl = Caption; //'Button.Text
            //    if (!String.IsNullOrEmpty(Button.Text)){

            //        if (CaptionControl.Length > nMaxLengthDesc){
            //            CaptionControl = $@"{Strings.Left(CaptionControl, nMaxLengthDesc - 3)}...";
            //        }
            //    }

            //    if(!String.IsNullOrEmpty(Button.Icon) && !String.IsNullOrEmpty(CaptionControl)){
            //        objResp.Write("&nbsp;");
            //    }

            //    objResp.Write(CaptionControl);

            //    objResp.Write(@"<img alt="""" border=""0"" src=""");
            //    objResp.Write($@"{strPath}PopupMenu.gif"" >");


            //    //'-- disegno la finestra ed il suo sub menu. To dic subbt � nu burdell
            //    Window objSubWin = new Window();

            //    //'-- cambia il path se necessario
            //    if (strPath != "../CTL_Library/images/toolbar/"){
            //        objSubWin.Path = strPath.Replace("/toolbar/", "/window/style");
            //    }

            //    objSubWin.Init($@"{id}_{Button.id}_SUB", "", false, Cuscino);
            //    objSubWin.PositionAbsolute = true;
            //    objSubWin.SubWin = true;
            //    objSubWin.Height = "10";
            //    objSubWin.width = "100";
            //    objSubWin.Zindex = levelDraw + 10;
            //    CurButtonDraw = CurButtonDraw + 1;
            //    levelDraw = levelDraw + 1;
            //    subMenuDraw(levelDraw) = Button.Text;

            //    objSubWin.Html(objResp, this);

            //    levelDraw = levelDraw - 1;

            //    //'-- chiudo la div con dentro il sub menu'
            //    objResp.Write("</div>");

            //    objResp.Write("</td> ");

            //}else{

            //    //' -- disegno la cella con il link
            //    if (ShowBackGround){
            //        objResp.Write($@"<td nowrap background=""{strPath}back.gif""  ");
            //    }else{
            //        objResp.Write(@"<td nowrap ");
            //    }


            //    objResp.Write($@" Title=""{strTooltip}"" ");

            //    objResp.Write($@" valign=""middle"" ");

            //    if (Button.Enabled){

            //        if(!String.IsNullOrEmpty(Button.OnClick)){
            //            strOnClick = $@" onclick=""Javascript:try{{ CloseAllSub( '{id}' ); }}catch(e){{}};{Button.OnClick}( '{Button.paramTarget}');"" ";
            //        }else{
            //            strOnClick = $@" onclick=""Javascript:try{{ CloseAllSub( '{id}' ); }}catch(e){{}}; ExecFunction('{Button.URL}','{Button.Target}' ,'{Button.paramTarget}');"" ";
            //        }
            //        objResp.Write(strOnClick);

            //        objResp.Write($@" class=""{Style}_button"" id=""{id}_{Button.id}"" name=""{id}_{Button.id}"" title=""{strTooltip}"" > ");
            //    }else{
            //        objResp.Write($@" class=""{Style}_buttonDisabled"" id=""{id}_{Button.id}"" name=""{id}_{Button.id}"" title=""{strTooltip}"" > ");
            //    }

            //    //'-- bitmap del bottone
            //    if (!String.IsNullOrEmpty(Button.Icon)) {
            //        objResp.Write(@"<img alt="""" border=""0"" src=""");
            //        objResp.Write($@"{strPath}{Button.Icon}"" >");
            //    }

            //    //'-- setto caption e tooltip
            //    CaptionControl = Caption; //'Button.Text
            //    if (!String.IsNullOrEmpty(Button.Text)) {
            //        if (CaptionControl.Length) > nMaxLengthDesc){
            //            CaptionControl = $@"{Strings.Left(CaptionControl, nMaxLengthDesc - 3)}...";
            //        }
            //    }

            //    if (!String.IsNullOrEmpty(Button.Icon) && !String.IsNullOrEmpty(CaptionControl)) {
            //        objResp.Write("&nbsp;");
            //    }

            //    objResp.Write(CaptionControl);

            //    objResp.Write("</td> ");


            //}

            //LocalDrawCellToolBar = i

        }

        //' -- disegna la toolbar accessibile
        void LocalDrawToolBarAccess(IEprocResponse objResp)
        {
            //'-- apertura della lista
            objResp.Write($@"<ul class=""{Style}"" > ");

            //' -- ciclo sui link e disegno la cella per ogni link
            //ToolbarButton Button = new ToolbarButton();
            if (levelDraw == 0)
            {
                CurButtonDraw = 0;
            }

            while (CurButtonDraw < Buttons.Count)
            {
                LocalDrawCellToolBarAccess(objResp, Buttons.ElementAt(CurButtonDraw).Value);

                CurButtonDraw = CurButtonDraw + 1;
            }

            //'-- chiusura della lista
            objResp.Write("</ul> ");
        }

        //' -- disegna la cella di separazione e la cella che contiene il link in versione accessibile
        void LocalDrawCellToolBarAccess(IEprocResponse objResp, ToolbarButton Button)
        {

            string strTooltip;
            string CaptionControl;
            string strOnClick;
            bool bSubMenu = false;
            string[] aInfo;
            int nMaxLengthDesc;

            nMaxLengthDesc = CONST_LENGTH_LINK;

            aInfo = Strings.Split(Button.ToolTip, "#");
            strTooltip = aInfo[0];
            if (aInfo.Length == 2)
            {
                try
                {
                    nMaxLengthDesc = Convert.ToInt32(aInfo[1]);
                }
                catch
                {
                    nMaxLengthDesc = CONST_LENGTH_LINK;
                }
            }

            //'-- verifico se la funzione successiva � un ramo di quella corrente
            if (CurButtonDraw < Buttons.Count - 1)
            {
                if (Strings.Left(Buttons.ElementAt(CurButtonDraw + 1).Value.Text, Button.Text.Length + 1) == $@"{Button.Text}\")
                {
                    bSubMenu = true;
                }
            }

            string Caption;
            string onmouseover;
            string onmouseout;
            string strAlternate;

            onmouseover = "";
            onmouseout = "";

            Caption = Strings.Split(Button.Text, @"\")[levelDraw];

            if (bSubMenu == true)
            {

                objResp.Write("<li ");

                strOnClick = $@" onclick=""Javascript:OpenCloseSubMenuToolbar( '{id}' , '{id}_{Button.Id}' );return false;"" ";

                //'-- conservo il sottomenu
                SubMenuId.TryAdd($@"{id}_{Button.Id}_SUB", $@"{id}_{Button.Id}_SUB");

                objResp.Write($@" class=""{Style}_button");

                if (CurButtonDraw == Buttons.Count - 1)
                {
                    objResp.Write($@" last");   //'-- metto una classe in pi� sull'ultima LI
                }

                objResp.Write($@"""> ");

                objResp.Write($@"<div id=""{Button.Id}_div_sub_menu"" class=""div_sub_menu"" ");

                onmouseover = @" """;
                onmouseover = $@"{onmouseover}MenuOn( '{id}' ,  '{id}_{Button.Id}', '{Button.Text.Replace(@"\", @"\\")}' );";
                onmouseover = $@"{onmouseover}"" ";

                onmouseout = @" """;
                onmouseout = $@"{onmouseout}MenuOut( '{id}' , '{id}_{Button.Id}' , '{Button.Text.Replace(@"\", @"\\")}'); ";
                onmouseout = $@"{onmouseout}"" ";

                objResp.Write($@" onmouseover={onmouseover}");
                objResp.Write($@" onmouseout={onmouseout}");

                objResp.Write($@">");

                //'-- bitmap del bottone
                //'If Button.Icon <> "" Then
                //'    objResp.Write "<img alt=""" & HtmlEncodeValue(CStr(Button.ToolTip)) & """ src="""
                //'    objResp.Write strPath & Button.Icon & """/>"
                //'End If

                //'-- setto caption e tooltip
                CaptionControl = Caption;
                if (!String.IsNullOrEmpty(Button.Text))
                {

                    if (CaptionControl.Length > nMaxLengthDesc)
                    {
                        CaptionControl = $@"{Strings.Left(CaptionControl, nMaxLengthDesc - 3)}...";
                    }
                }

                if (!String.IsNullOrEmpty(CStr(Button.ToolTip)))
                {
                    strAlternate = CStr(Button.ToolTip);
                }
                else
                {
                    strAlternate = CStr(CaptionControl);
                }

                objResp.Write($@"<a id=""{id}_{Button.Id}"" ");

                objResp.Write(strOnClick);

                if (!String.IsNullOrEmpty(Button.URL))
                {

                    objResp.Write($@" rel=""external"" href=""{HtmlEncodeValue(CStr(Button.URL))}""");

                }
                else
                {

                    objResp.Write($@" href=""#""");

                }

                objResp.Write($@" class=""button_link""");
                objResp.Write($@" onfocus={onmouseover}");

                objResp.Write($@" title=""{HtmlEncodeValue(strAlternate)}""");

                if (!String.IsNullOrEmpty(CStr(Button.accessKey)))
                {
                    objResp.Write($@" accesskey=""{HtmlEncodeValue(Button.accessKey)}"" ");
                }

                objResp.Write($@">");

                if (!String.IsNullOrEmpty(Button.Icon))
                {
                    objResp.Write($@"<img alt=""{HtmlEncodeValue(CStr(Button.ToolTip))}"" src=""");
                    objResp.Write($@"{strPath}{Button.Icon}""/>");
                }

                objResp.Write($@"{CStr(CaptionControl)}");

                objResp.Write("</a>");

                objResp.Write(@"<img alt="""" src=""");
                objResp.Write($@"{strPath}PopupMenu.gif""/>");

                //'-- disegno la finestra ed il suo sub menu. To dic subbt � nu burdell
                Window objSubWin = new Window();

                //'-- cambia il path se necessario
                if (strPath != "../CTL_Library/images/toolbar/")
                {
                    objSubWin.Path = strPath.Replace("/toolbar/", "/window/style");
                }

                objSubWin.Init($@"{id}_{Button.Id}_SUB", "", false, Window.Cuscino);
                objSubWin.PositionAbsolute = true;
                objSubWin.SubWin = true;
                objSubWin.Height = "10";
                objSubWin.width = "100";
                objSubWin.Zindex = levelDraw + 10;
                objSubWin.mp_accessible = mp_accessible;
                CurButtonDraw = CurButtonDraw + 1;
                levelDraw = levelDraw + 1;
                subMenuDraw[levelDraw] = Button.Text;

                objSubWin.Html(objResp, this);

                levelDraw = levelDraw - 1;

                objResp.Write("</div>");

                objResp.Write("</li> ");

            }
            else
            {

                //' -- disegno un nuovo LI
                objResp.Write("<li");

                strOnClick = "";

                if (Button.Enabled)
                {

                    if (!String.IsNullOrEmpty(Button.OnClick))
                    {
                        strOnClick = $@" onclick=""Javascript:try{{ CloseAllSub( '{id}' ); }}catch(e){{}};{Button.OnClick}( '{Button.paramTarget}');return false;"" ";
                    }
                    else
                    {
                        strOnClick = $@" onclick=""Javascript:try{{ CloseAllSub( '{id}' ); }}catch(e){{}}; ExecFunction('{Button.URL}','{Button.Target}' ,'{Button.paramTarget}');return false;"" ";
                    }

                    objResp.Write($@" class=""{Style}_button");

                    if (CurButtonDraw == Buttons.Count - 1)
                    {
                        objResp.Write($@" last");   //'-- metto una classe in pi� sull'ultima LI
                    }

                    objResp.Write(@"""> ");

                }
                else
                {

                    objResp.Write($@" class=""{Style}_buttonDisabled""> ");

                }

                onmouseover = @" """;
                onmouseover = $@"{onmouseover}MenuOn( '{id}' ,  '{id}_{Button.Id}', '{Button.Text.Replace(@"\", @"\\")}' );";
                onmouseover = $@"{onmouseover}"" ";

                onmouseout = @" """;
                onmouseout = $@"{onmouseout}MenuOut( '{id}' , '{id}_{Button.Id}' , '{Button.Text.Replace(@"\", @"\\")}'); ";
                onmouseout = $@"{onmouseout}"" ";

                //'-- setto caption e tooltip
                CaptionControl = Caption;
                if (!String.IsNullOrEmpty(Button.Text))
                {
                    if (CaptionControl.Length > nMaxLengthDesc)
                    {
                        CaptionControl = $@"{Strings.Left(CaptionControl, nMaxLengthDesc - 3)}...";
                    }
                }

                if (!String.IsNullOrEmpty(CStr(Button.ToolTip)))
                {
                    strAlternate = CStr(Button.ToolTip);
                }
                else
                {
                    strAlternate = CStr(CaptionControl);
                }

                if (Button.Enabled)
                {

                    objResp.Write($@"<a id=""{id}_{Button.Id}"" class=""button_link"" ");

                    objResp.Write(strOnClick);

                    if (!String.IsNullOrEmpty(Button.URL))
                    {

                        objResp.Write($@" rel=""external"" href=""{HtmlEncodeValue(CStr(Button.URL))}""");

                    }
                    else
                    {

                        objResp.Write($@" href=""#""");

                    }

                    if (!String.IsNullOrEmpty(CStr(Button.accessKey)))
                    {
                        objResp.Write($@" accesskey=""{HtmlEncodeValue(Button.accessKey)}"" ");
                    }

                    objResp.Write($@" title=""{HtmlEncodeValue(strAlternate)}""");

                    objResp.Write($@">");

                    //'-- bitmap del bottone
                    if (!String.IsNullOrEmpty(Button.Icon))
                    {
                        objResp.Write($@"<img alt=""{HtmlEncodeValue(CStr(Button.ToolTip))}"" src=""");
                        objResp.Write($@"{strPath}{Button.Icon}""/>");
                    }

                    objResp.Write(CStr(CaptionControl));

                    objResp.Write("</a>");

                }
                else
                {


                    objResp.Write($@"<a id=""{id}_{Button.Id}"" class=""button_link_disabled"" ");
                    objResp.Write($@" title=""{HtmlEncodeValue(strAlternate)}""");
                    objResp.Write($@">");

                    objResp.Write(CStr(CaptionControl));

                    objResp.Write("</a>");

                }

                objResp.Write("</li> ");


            }


        }


    }
}

