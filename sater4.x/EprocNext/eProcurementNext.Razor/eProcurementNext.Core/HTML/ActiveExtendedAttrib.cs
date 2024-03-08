using eProcurementNext.CommonModule;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.HTML
{
    public class ActiveExtendedAttrib
    {
        //'Public Style    As String
        private EprocResponse response;
        private string mp_strPath;

        public ActiveExtendedAttrib()
        {
            mp_strPath = "../../CTL_Library/";
        }

        //'-- avvalora la collezione con i javascript necessari al corretto
        //'-- funzionamento del controllo
        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library/")
        {
            //On Error Resume Next

            if (!JS.ContainsKey("ExecFunction"))
            {
                JS.Add("ExecFunction", @"<script src=""" + Path + @"jscript/ExecFunction.js"" ></script>");
            }
            if (!JS.ContainsKey("getObj"))
            {
                JS.Add("getObj", @"<script src=""" + Path + @"jscript/getObj.js"" ></script>");
            }
            if (!JS.ContainsKey("ExtendedAttrib"))
            {
                JS.Add("ExtendedAttrib", @"<script src=""" + Path + @"jscript/Field/ExtendedAttrib.js"" ></script>");
            }
            if (!JS.ContainsKey("SearchDocumentForExtendeAttrib"))
            {
                JS.Add("SearchDocumentForExtendeAttrib", @"<script src=""" + Path + @"jscript/Field/SearchDocumentForExtendeAttrib.js"" ></script>");
            }

            //'-- js di jquery
            if (!JS.ContainsKey("jquery"))
            {
                JS.Add("jquery", @"<script src=""" + Path + @"jscript/jquery/jquery-1.9.1.js"" ></script>");
            }
            if (!JS.ContainsKey("jqueryUI"))
            {
                JS.Add("jqueryUI", @"<script src=""" + Path + @"jscript/jquery/jquery-ui-1.10.1.custom.min.js"" ></script>");
            }

            mp_strPath = Path;
        }


        /// <summary>
        /// '-- ritorna il codice html per rappresentare la riga di un gruppo
        /// </summary>
        public void Html(EprocResponse objResp)
        {

            objResp.Write(Environment.NewLine + @"<div class=""dialog-iframe display_none"" id=""dialog-iframe-modale""  title=""Dominio"" ");


            objResp.Write($@">" + Environment.NewLine);


            objResp.Write($@"</div>" + Environment.NewLine);
            objResp.Write($@"<input type=""hidden"" value=""" + HtmlEncode(mp_strPath) + @""" id=""path_x_extended""/>" + Environment.NewLine);

            //'-- Funzione invocata dai nuovi multivalore
            objResp.Write($@"     <script type=""text/javascript"">" + Environment.NewLine);
            objResp.Write($@"         function testActiveExtendedAttrib(){{" + Environment.NewLine);
            objResp.Write($@"             return 'OK'; " + Environment.NewLine);
            objResp.Write($@"         }}; " + Environment.NewLine);
            objResp.Write($@"     </script>" + Environment.NewLine);

            //'--- ******** Lascio disegnare il vettore di iFrame per permettere una maggiore retrocompatiblit�
            //'-- con vecchie funzione javascript  (come la updateFieldVisual) ****************

            //'-- dichiara le variabili per gestire gli attributi estesi
            objResp.Write($@"     <script type=""text/javascript"">" + Environment.NewLine);
            objResp.Write($@"        var vetObjAttrib = new Array(20);" + Environment.NewLine);
            objResp.Write($@"        var vetObjExt = new Array(20);" + Environment.NewLine);
            objResp.Write($@"        var vetObjExtUser = new Array(20);" + Environment.NewLine);

            //'--vettore dei nomi dei controlli che hanno attivato i domini
            objResp.Write($@"        var vetObjControlName = new Array(20);" + Environment.NewLine);
            objResp.Write($@"        var numObjAttrib = 0;" + Environment.NewLine);
            objResp.Write($@"        var strPathExtObj = '" + mp_strPath + "';" + Environment.NewLine);
            objResp.Write($@"        var inLoad = 0;" + Environment.NewLine);
            objResp.Write($@"     </script>" + Environment.NewLine);



            //'-- prepara le div per contenerli
            for (int i = 1; i <= 10; i++)
            {
                objResp.Write($@"<div id=""ExtAttrib_" + i + @"_div"" name=""ExtAttrib_" + i + @"_div"" class=""ActiveExtendedAttrib_div display_none"">" + Environment.NewLine);
                objResp.Write($@"<iframe id=""ExtAttrib_" + i + @""" src=""""></iframe>" + Environment.NewLine);
                objResp.Write($@"</div>" + Environment.NewLine);
            }



        }




    }
}

