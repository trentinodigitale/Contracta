using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.HTML
{
    public static partial class Basic
    {
        public static string? DateToStr(DateTime dt, string format = "yyyy-MM-ddTHH:mm:ss")
        {
            string str;
            try
            {
                str = Strings.Format(dt, format);
                str = str.Replace(".", ":");
                return str;
            }
            catch
            {
                return dt.ToString() != null ? dt.ToString() : "";
            }
        }

        /// <summary>
        /// dalla forma tecnica stringa ritorna un tipo data
        /// </summary>
        /// <param name="str"></param>
        /// <returns></returns>        
        public static DateTime StrToDate(string str)
        {
            DateTime dtToReturn = new DateTime(1900, 1, 1);
            try
            {
                str = Trim(str);
                if (!str.Contains('T', StringComparison.Ordinal) && Len(Trim(str)) == 10)
                {
                    str = str + "T00:00:00";
                }

                if (!string.IsNullOrEmpty(str))
                {

                    dtToReturn = DateAndTime.DateSerial(CInt(Left(str, 4)), CInt(MidVb6(str, 6, 2)), CInt(MidVb6(str, 9, 2)));
                    dtToReturn = new DateTime(dtToReturn.Ticks + DateAndTime.TimeSerial(CInt(MidVb6(str, 12, 2)), CInt(MidVb6(str, 15, 2)), CInt(MidVb6(str, 18, 2))).Ticks);
                }
                return dtToReturn;
            }
            catch
            {
                return DateAndTime.DateSerial(1900, 1, 1);
            }
        }


        public static string HTML_HiddenField(IEprocResponse response, string strFieldName, string strvalue)
        {
            Fld_Hidden obj = new Fld_Hidden();
            obj.Init(strFieldName, strvalue);
            return obj.Html(response);
        }

        public static string HTML_iframeTR(string NomeFrame, string height, string url, int border = 0, string altro = "")
        {
            string s;

            s = $@"<tr><td width=""100%"" height=""{height}"" style=""height:{height}"" >";
            s = $@"{s}<div id=""Div{NomeFrame}"" style=""height:100%;"" width=""100%"" >";
            s = $@"{s}<iframe frameborder=""{border}"" width=""100%"" height=""100%""  id=""{NomeFrame}"" name=""{NomeFrame} src=""{url} "" {altro}  style=""border:none;""> </iframe>";
            s = $@"{s}</div>";
            s = $@"{s}</td></tr>";

            return s;

        }

        public static string HTML_iframe(string NomeFrame, string url, int border = 0, string altro = "", string height = "100%", string width = "100%")
        {
            string s = "";
            string style;

            if (altro.Contains("style", StringComparison.Ordinal))
            {
                style = Strings.Replace(altro, @"style=""", $@"style=""border:none;height:{height};");
            }
            else
            {
                style = $@"style=""height:{height}""";
            }

            s = $@"{s}<div id=""Div{NomeFrame}"" {style} width=""{width}"" >";
            s = $@"{s}<iframe frameborder=""{border}"" width=""{width}"" height=""{height}"" id=""{NomeFrame}"" name=""{NomeFrame}"" src=""{url}"" marginheight=""0"" marginwidth=""0"" {altro}";

            if (!altro.Contains("style", StringComparison.Ordinal))
            {
                s = $@"{s} style=""border:none;""></iframe>";
            }
            else
            {
                s = $"{s}></iframe>";
            }

            s = $"{s}</div>";

            return s;

        }

        /// <summary>
        /// da utilizzare per inserire il valore negli attributi dei tag html
        /// </summary>
        /// <param name="str"></param>
        /// <returns></returns>
        public static string HtmlEncodeValue(string? str)
        {
            return eProcurementNext.CommonModule.Basic.htmlEncodeValue(str);
        }

        /// <summary>
        /// da utilizzare per inserire il valore in una stringa javascript
        /// </summary>
        /// <param name="str"></param>
        /// <returns></returns>
        public static string HtmlEncodeJSValue(string? str)
        {

            if (string.IsNullOrEmpty(str))
                return "";
            string? s;

            str = str.Replace(@"\", @"\\");
            s = str.Replace(@"'", @"\'");

            return s != null ? s : "";

        }

        public static void HTML_SinteticHelp(IEprocResponse _response, string strTitle, string Icon = "", string strAction = "", string strPath = "../images/")
        {

            Fld_Label obj = new Fld_Label();
            obj.PathImage = strPath;
            obj.Style = "SinteticHelp";

            obj.Value = strTitle;
            obj.Image = Icon;

            obj.setOnClick(strAction);
            obj.Html(_response);
        }

        public static void HTML_Button(IEprocResponse _response, string strFieldName, string strTitle, string strAction)
        {
            Fld_Button obj = new Fld_Button();
            obj.Init(strFieldName, strTitle);
            obj.setOnClick(strAction);
            obj.Html(_response);
        }

        public static void HTML_CheckField(IEprocResponse _response, string strFieldName, string strvalue)
        {
            Fld_CheckBox obj = new Fld_CheckBox();
            obj.Init(eProcurementNext.CommonModule.Basic.CInt(strFieldName), strvalue);
            obj.Html(_response);
        }


        /// <summary>
        /// ritorna i javascript collezionati all'interno di una stringa
        /// </summary>
        /// <param name="session"></param>
        /// <param name="Path"></param>
        /// <param name="response"></param>
        /// <param name="JS"></param>
        /// <returns></returns>
        /// <exception cref="NotImplementedException"></exception>
        public static string JavaScriptInPage(Session.ISession session, string Path, IEprocResponse response, Dictionary<string, string> JS)
        {
            throw new NotImplementedException();
        }


    }
}