using eProcurementNext.Application;
using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class ScrollDate
    {
        public string URL;          //'-- indirizzo da chiamare per il salto pagina
        public string Target;       //'-- pagina di destinazione
        public string AnnoMese;
        public string MesiShow;


        public string Style;
        public string strPath;
        private string strPathJS;

        public string id;

        //Private response As Object

        private Session.ISession mp_session;

        //'-- avvalora la collezione con i javascript necessari al corretto
        //'-- funzionamento del controllo
        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library/")
        {

            strPathJS = Path;

            //'-- questi java script vengono messi staticamente nella pagina per consentire il corretto funzionamento
            if (!JS.ContainsKey("getObj"))
            {
                JS.Add("getObj", $@"<script src=""{Path}jscript/getObj.js"" ></script>");
            }

        }

        //'-- ritorna il codice html per rappresentare la riga di un gruppo
        public void Html(IEprocResponse objResp, Session.ISession session)
        {

            string StrUrl;
            mp_session = session;

            //'-- questa operazione viene fatta perch� la barra di paginazione viene disegnata lato client
            //'-- la stringa che contiene l'url sebbene abbia gi� subito una trasformazione sull'apice
            //'-- quando scrive il codice la to client l'apice viene ritrasformato in singolo carattere e crea problemi

            StrUrl = URL;
            //'-- creazione della div che conterr� la barra di paginazione
            objResp.Write($@"<div id=""{id}"" >");
            objResp.Write($@"</div> ");
            objResp.Write($@"<script type=""text/javascript""> ");
            objResp.Write($@"   SD_Anno = {Strings.Left(AnnoMese, 4)}; ");
            objResp.Write($@"   SD_Mese = {CInt(MidVb6(AnnoMese, 6, 2))}; ");
            objResp.Write($@"   SD_URL = '{StrUrl}'; ");
            objResp.Write($@"   SD_Target = '{Target}'; ");
            objResp.Write($@"   SD_MesiShow = '{MesiShow}'; ");
            objResp.Write($@"    ");
            objResp.Write($@"   function GoPageSD(   ) ");
            objResp.Write($@"   {{ ");
            objResp.Write($@"         var ap = '00' + SD_Mese;ap = ap.substr( ap.length - 2 , 2 );");
            objResp.Write($@"         self.location = SD_URL + '&DATA_CALENDAR=' + SD_Anno + '/' + ap + '&MESI_CALENDAR=' + SD_MesiShow; ");
            objResp.Write($@"   }} ");
            objResp.Write($@"   function GoPageSD_M( p ) ");
            objResp.Write($@"   {{ ");
            objResp.Write($@"         SD_Mese = SD_Mese + p; ");
            objResp.Write($@"         if ( SD_Mese > 12 )  ");
            objResp.Write($@"         {{ ");
            objResp.Write($@"             SD_Mese = SD_Mese - 12; SD_Anno = SD_Anno +1; ");
            objResp.Write($@"         }} ");
            objResp.Write($@"         if ( SD_Mese < 1 )  ");
            objResp.Write($@"         {{ ");
            objResp.Write($@"             SD_Mese = SD_Mese + 12; SD_Anno = SD_Anno -1; ");
            objResp.Write($@"         }} ");
            objResp.Write($@"         GoPageSD(); ");
            objResp.Write($@"   }} ");
            objResp.Write($@"</script> ");

            //'//-- apro la tabella della barra di paginazione
            objResp.Write($@"<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" ><tr><td class=""SCROLL_DATA{Style}"" align=""center"">");
            objResp.Write($@"<table class=""{Style}_Bar"" border=""0"" cellspacing=""0"" cellpadding=""0"" ><tr>");
            objResp.Write($@"<td class=""{Style}_Button"" onclick=""javascript:GoPageSD_M( -12 );"" ><img src=""{strPath}AllRewind.gif""/></td>");
            objResp.Write($@"<td class=""{Style}_Button"" onclick=""javascript:GoPageSD_M( -1 );"" ><img src=""{strPath}Rewind.gif""/></td>");
            objResp.Write($@"<td><select class=""{Style}_select"" name=""{id}_mese"" onchange=""SD_Mese=this.value;GoPageSD();"" >");

            int i;
            int m;
            m = CInt(MidVb6(AnnoMese, 6, 2));

            for (i = 1; i <= 12; i++)
            {
                objResp.Write($@"<option value=""{i}""  {IIF(i == m, @"selected=""selected""", "")}>{ApplicationCommon.CNV(FMese(i), mp_session)}</option>");
            }

            objResp.Write($@"</select></td>");
            objResp.Write($@"<td>&nbsp</td>");

            objResp.Write($@"<td><select class=""{Style}_select"" name=""{id}_anno"" onchange=""SD_Anno=this.value;GoPageSD();"" >");

            m = CInt(Strings.Left(AnnoMese, 4));

            for (i = m - 4; i <= m + 4; i++)
            {
                objResp.Write($@"<option value =""{i}""  {IIF(i == m, @"selected=""selected""", "")} >{i}</option>");
            }

            objResp.Write($@"</select></td>");
            objResp.Write($@"<td class=""{Style}_Button"" onclick=""javascript:GoPageSD_M( 1 );"" ><img src=""{strPath}Forward.gif""/></td>");
            objResp.Write($@"<td class=""{Style}_Button"" onclick=""javascript:GoPageSD_M( 12 );"" ><img src=""{strPath}AllForward.gif""/></td>");
            objResp.Write($@"</table> ");
            objResp.Write($@"</td></tr></table>");

        }



        public ScrollDate()
        {

            Style = "SP";
            id = "ScrollPage";
            Target = "";
            URL = "";
            strPath = "../CTL_Library/images/ScrollPage/";
			if (IsMasterPageNew())
			{
				strPath = "../CTL_Library/images/ScrollPageFaseII/";
			}

		}



        public void SetScrollDate(string StrUrl, string strQueryString, string strTarget = "self")
        {

            int numCol;
            int c;
            //Dim col As Collection
            long mp_NumeroPagina;

            //Set col = GetCollection(strQueryString)


            Target = strTarget;


            URL = StrUrl + "?" + strQueryString;
            //URL = StrUrl + "?" + strQueryString;

            if (GetParamURL(strQueryString, "DATA_CALENDAR") != "")
            {
                AnnoMese = GetParamURL(strQueryString, "DATA_CALENDAR");//col("DATA_CALENDAR")
                URL = MyReplace(URL, "&DATA_CALENDAR=" + GetParamURL(strQueryString, "DATA_CALENDAR"), "");
            }
            else
            {
                AnnoMese = DateAndTime.Year(DateAndTime.Now) + "/" + Strings.Right("00" + DateAndTime.Month(DateAndTime.Now), 2);
            }

            if (GetParamURL(strQueryString, "MESI_CALENDAR") != "")
            {
                MesiShow = GetParamURL(strQueryString, "MESI_CALENDAR");
                URL = MyReplace(URL, "&MESI_CALENDAR=" + GetParamURL(strQueryString, "MESI_CALENDAR"), "");
            }
            else
            {
                MesiShow = "1";
            }



        }



    }
}

