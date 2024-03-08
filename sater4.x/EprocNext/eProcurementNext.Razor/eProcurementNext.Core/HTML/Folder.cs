using eProcurementNext.Application;
using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.Basic;

namespace eProcurementNext.HTML
{
    public class Folder
    {

        public static int CONST_LENGTH_LINK = 30;

        public Dictionary<string, ToolbarButton> Buttons = new Dictionary<string, ToolbarButton>();


        public bool ShowBackGround;
        public string width;
        public string strPath;
        public string Style;

        public int LabelSelected;
        public int MaxLabelLen;
        //private response As Object
        private string ShowImage; //'--ShowImage=0 senza immagini,altrimeti si

        public string indexFolder;

        public bool PrintMode;

        //'-- avvalora la collezione con i javascript necessari al corretto
        //'-- funzionamento del controllo
        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library/")
        {

            //ToolbarButton Button;

            if (!JS.ContainsKey("ExecFunction"))
            {
                JS.Add("ExecFunction", $@"<script type=""text/javascript"" src=""{Path}jscript/ExecFunction.js"" ></script>");
            }

            //' -- ciclo sui bottoni ed inserisco il java script collegato

            foreach (KeyValuePair<string, ToolbarButton> Button in Buttons)
            {
                if (!string.IsNullOrEmpty(Button.Value.OnClick))
                {
                    if (!JS.ContainsKey(Button.Value.OnClick))
                    {
                        JS.Add(Button.Value.OnClick, $@"<script type=""text/javascript"" src=""{Path}jsapp/{Button.Value.OnClick}.js"" ></script>");
                    }
                }
            }


        }



        //'-- ritorna il codice html per rappresentare la riga di un gruppo
        public void Html(IEprocResponse objResp)
        {

            if (IsMasterPageNew())
            {
                objResp.Write($@"<div class=""containerTabsVapor"" style=""padding: unset;"">");
                
                objResp.Write($@"<div class=""leftArrowTabsVapor"" style=""display: none;""><i class=""fa fa-arrow-left"" aria-hidden=""true""></i></div>");
                objResp.Write($@"<div class=""rightArrowTabsVapor"" style=""display: none;""><i class=""fa fa-arrow-right"" aria-hidden=""true""></i></div>");

                //'---- disegno la Folder con tutti i link
                LocalDrawFolder(objResp);
                objResp.Write($@"
                    <script>
                        var findFolderShowed = (coll) => {{
                            for(let i = 0; i < coll.length; i++){{
                                if (($(coll[i]).closest("".containerTabsVapor"").parent().css(""display"") != 'none')) {{
                                    return coll[i];
                                }}
                            }}
                        }}
                        var checkTabsScrollSize = (tabsList) => {{
                            if(findFolderShowed(tabsList).offsetWidth < findFolderShowed(tabsList).scrollWidth){{
                                $("".leftArrowTabsVapor"").show();                                
                                $("".rightArrowTabsVapor"").show();
                                for(let i=0; i < tabsList.length; i++){{
                                    tabsList[i].style.overflowX = ""scroll"";
                                    $(tabsList[i]).closest("".containerTabsVapor"").css(""padding"",""0 40px"");
                                    tabsList[i].style.border = ""none"";
                                }}
                                

                            }}else{{
                                $("".leftArrowTabsVapor"").hide();                                
                                $("".rightArrowTabsVapor"").hide();
                                for(let i=0; i < tabsList.length; i++){{
                                    tabsList[i].style.overflowX = ""unset"";
                                    $(tabsList[i]).closest("".containerTabsVapor"").css(""padding"",""unset"");
                                    tabsList[i].style.borderBottom = ""1px solid var(--main-color)"";
                                }}
                            }}
                        }}

                        $(document).ready(function() {{ 

                            const tabsList = document.getElementsByClassName(""Folder"");
                            $("".leftArrowTabsVapor"").off().on(""click"", function(){{
                                for(let i=0; i < tabsList.length; i++){{
                                    tabsList[i].scrollLeft -= 200;
                                }}
                            }})
                            $("".rightArrowTabsVapor"").off().on(""click"", function(){{
                                for(let i=0; i < tabsList.length; i++){{
                                    tabsList[i].scrollLeft += 200;
                                }}
                            }})
                            checkTabsScrollSize(tabsList);
                            $(window).resize(function(){{
                                checkTabsScrollSize(tabsList);
                            }});

                        }});

                        
                    </script>
                ");
                objResp.Write("</div>");
            }
            else
            {
                //'---- disegno la Folder con tutti i link
                LocalDrawFolder(objResp);
            }

        }


        public Folder()
        {

            //ShowSeparetor = false;
            ShowBackGround = false;
            //ButtonSize = 0;
            //Height = "";
            width = "100%";
            Style = "Folder";
            strPath = "../CTL_Library/images/Folder/";
            LabelSelected = 1;

            Buttons = new Dictionary<string, ToolbarButton>();

            MaxLabelLen = CONST_LENGTH_LINK;

            indexFolder = "";

            PrintMode = false;

        }


        //' -- disegna la Folder
        void LocalDrawFolder(IEprocResponse objResp)
        {

            //'-- apertura della tabella HTML
            objResp.Write($@"<table border=""0"" width=""{width}"" cellpadding=""0"" cellspacing=""0"" class=""{Style}""> ");
            
            //'-- apertura della riga
            if (ShowImage == "0")
            {


                objResp.Write($@"<tr class=""folder_height_5"">");

                objResp.Write($@"<td colspan=""5""></td></tr><tr>");

            }
            else
            {

                objResp.Write($@"<tr>");

            }

            //'-- disegno la prima cella a sinistra
            objResp.Write($@"<td>");
            if (ShowImage != "0")
            {
                objResp.Write($@"<img alt="""" src=""{strPath}limite_sinistro.gif""/>");
            }
            else
            {
                if (IsMasterPageNew())
                {

                }
                else
                {
                    objResp.Write($@"&nbsp;");

                }
            }
            objResp.Write($@"</td>");

            //'-- disegno il bordo della prima label
            objResp.Write($@"<td>");
            if (ShowImage != "0")
            {
                objResp.Write($@"<img alt="""" src=""{strPath}{IIF(LabelSelected == 1, "e1_1.gif", "e2_1.gif")}""/>");
            }
            else
            {
                if (IsMasterPageNew())
                {

                }
                else
                {
                    objResp.Write($@"&nbsp;");

                }
            }
            objResp.Write($@"</td>");

            //' -- ciclo sui link e disegno la cella per ogni link
            ToolbarButton Button;
            int numLabel;
            int i;
            string strImg;
            numLabel = Buttons.Count;

            for (i = 1; i <= numLabel; i++)
            {

                Button = Buttons.ElementAt(i - 1).Value;

                //'-- disegno il contenuto della label
                LocalDrawCellFolder(objResp, Button, IIF(i == LabelSelected, true, false));


                //'-- disegna il bordo destrodella label
                if (i == LabelSelected)
                {  //'-- se la label � quella selezionata
                    if (i == numLabel)
                    {   //'-- se � l'ultima
                        strImg = "e2_3.gif";
                    }
                    else
                    {
                        strImg = "e1_2.gif";
                    }
                }
                else
                {
                    if (i == numLabel)
                    {  //'-- se � l'ultima
                        strImg = "e1_3.gif";
                    }
                    else
                    {
                        if (i + 1 == LabelSelected)
                        { //'-- se quella successiva � selezionata
                            strImg = "e2_2.gif";
                        }
                        else
                        {
                            strImg = "e1_2b.gif";
                        }
                    }
                }


                objResp.Write($@"<td>");
                if (ShowImage != "0")
                {
                    objResp.Write($@"<img alt="""" src=""{strPath}{strImg}""/>");
                }
                else
                {
                    if (IsMasterPageNew())
                    {

                    }
                    else
                    {
                        objResp.Write($@"&nbsp;");
                    }
                }
                objResp.Write($@"</td>");


            }

            //' -- disegno la cella di separazione

            objResp.Write(@"<td class=""width_100_percent""");

            if (ShowImage != "0")
            {


                objResp.Write($@" class=""folder_label_sfondobase"">");

            }
            else
            {
                objResp.Write($@">&nbsp;");
            }

            objResp.Write($@"</td>");

            //' -- disegno l'ultima cella di chiusura
            objResp.Write("<td>");

            if (ShowImage != "0")
            {
                objResp.Write($@"<img alt="""" src=""{strPath}label_limite_destro.gif""/>");
            }
            else
            {
                objResp.Write($@"&nbsp;");
            }

            objResp.Write(@"</td>");
            
            //'-- chiusura della riga
            objResp.Write(@"</tr>");

            //'-- chiusura della tabella HTML
            objResp.Write(@"</table> ");

        }

        //' -- disegna la cella di separazione e la cella che contiene il link
        void LocalDrawCellFolder(IEprocResponse objResp, ToolbarButton Button, bool bCurrent)
        {

            string strTooltip;
            string CaptionControl;
            string strOnClick;
            string[] aInfo;

            if (Button.Text.Contains("#", StringComparison.Ordinal))
            {

                aInfo = Button.Text.Split("#");
                CaptionControl = aInfo[0];
                if (aInfo.Length == 2)
                {
                    MaxLabelLen = CInt(aInfo[1]);
                }

            }
            else
            {

                CaptionControl = Button.Text;

            }

            //'-- setto caption e tooltip
            strTooltip = Button.ToolTip;
            if (!string.IsNullOrEmpty(Button.Text))
            {
                if (Button.Text.Length > MaxLabelLen)
                {
                    CaptionControl = Strings.Left(Button.Text, MaxLabelLen - 3) + "...";
                    strTooltip = Button.Text;
                }
            }

            //'-- bitmap del bottone
            if (!string.IsNullOrEmpty(Button.Icon))
            {

                objResp.Write($@"<td id=""{Button.Id}{indexFolder}_ICO"" class=""{Style}_Label{IIF(bCurrent == true, "Selected", "")}"" ");

                if (!string.IsNullOrEmpty(Button.OnClick))
                {
                    strOnClick = $@" onclick=""Javascript:{Button.OnClick}();""return false; ";
                }
                else
                {
                    strOnClick = $@" onclick=""Javascript:ExecFunction('{HtmlEncode(Button.URL)}','{Button.Target}','{Button.paramTarget}');return false;"" ";
                }

                if (PrintMode == false)
                {
                    objResp.Write(strOnClick);
                }

                if (ShowImage != "0")
                {

                    objResp.Write("> ");

                    objResp.Write($@"<img alt="""" src=""");
                    objResp.Write($@"{strPath}{Button.Icon}""/>&nbsp;");
                }
                else
                {
                    objResp.Write($@">&nbsp;");
                }

                objResp.Write($@"</td>");

            }

            objResp.Write($@"<td id=""{Button.Id}{indexFolder}"" class=""{Style}_Label{IIF(bCurrent == true, "Selected", "")}"" title=""{strTooltip}"" ");


            if (!string.IsNullOrEmpty(Button.OnClick))
            {
                strOnClick = $@" onclick=""Javascript:{Button.OnClick}();return false;"" ";
            }
            else
            {
                strOnClick = $@" onclick=""Javascript:ExecFunction('{Button.URL}','{Button.Target}','{Button.paramTarget}');return false;"" ";
            }

            if (PrintMode == false)
            {
                objResp.Write(strOnClick);
            }

            if (ShowImage != "0")
            {


                objResp.Write("> ");
            }
            else
            {
                if (IsMasterPageNew())
                {
                    objResp.Write(">");
                }
                else
                {
                    objResp.Write(">&nbsp;");

                }
            }


            objResp.Write($@"<button type=""button"" class="""" name=""folder_button_{HtmlEncodeValue(Button.Id)}"" ");

            if (PrintMode == false)
            {
                objResp.Write(strOnClick);
            }

            if (!string.IsNullOrEmpty(CStr(Button.accessKey)))
            {
                objResp.Write($@" accesskey=""{HtmlEncodeValue(Button.accessKey)}"" ");
            }

            objResp.Write($@">");


            objResp.Write(CStr(CaptionControl));

            objResp.Write($@"</button>");


            if (ShowImage == "0")
            {
                if (IsMasterPageNew())
                {

                }
                else
                {
                    objResp.Write($@" &nbsp;");
                }
            }

            objResp.Write("</td> ");

        }

        public void Init(Session.ISession session)
        {

            ShowImage = ApplicationCommon.Application["ShowImages"];
        }


    }
}

