using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using Microsoft.VisualBasic.CompilerServices;
using System.Web;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.HTML
{
    public partial class BasicFunction
    {
        public const int WIDTH_CHAR = 7;

        public const string GridCol_Link = "GridCol_Link";

        //Global accessible As String 


        // '-- formatta le informazioni per l'errore
        public static string ShowErr(long number, string source, string description)
        {
            string strApp = "";
            string Style = "";

            Style = "Error";


            //'-- apertura della tabella HTML
            dynamic mywidth;
            mywidth = "100%";
            strApp = @"<table width=""" + mywidth + @""" cellpadding=""0"" cellspacing=""0"" class=""" + Style + @"_Bar"" >" + Environment.NewLine;


            strApp = strApp + "<tr><td>";
            strApp = strApp + "Error numer = " + number;
            strApp = strApp + "</td></tr>";

            strApp = strApp + "<tr><td>";
            strApp = strApp + "Source = " + source;
            strApp = strApp + "</td></tr>";

            strApp = strApp + "<tr><td>";
            strApp = strApp + "Description = " + description;
            strApp = strApp + "</td></tr>";


            //'-- chiusura della tabella HTML
            strApp = strApp + "</table>" + Environment.NewLine;

            return strApp;

        }

        public static string UrlEncode(string? str)
        {
            if (string.IsNullOrEmpty(str))
                return string.Empty;

            return HttpUtility.UrlEncode(str);
        }

        public static Dictionary<string, string> GetCollection(string str)
        {
            var comparer = StringComparer.OrdinalIgnoreCase;
            var coll = new Dictionary<string, string>(comparer);
            string[] arr;
            string[] val;
            int n;
            int i;


            arr = Strings.Split(str, "&");

            n = arr.Length;
            try
            {
                for (i = 0; i < n; i++)
                {
                    val = arr[i].Split("=");
                    if (!coll.ContainsKey(val[0]))
                    {
                        if (val.Length > 0)
                        {
                            if (Left(val[1], 1) == @"""")
                            {
                                coll.Add(val[0], Strings.Mid(val[1], 2, Strings.Len(val[1]) - 2));
                            }
                            else
                            {
                                coll.Add(val[0], val[1]);
                            }
                        }
                        else
                        {
                            coll.Add(val[0], val[1]);
                        }
                    }
                }
            }
            catch
            {

            }
            return coll;
        }


        //'ritorna i javascript collezionati all'interno di una stringa
        public static string JavaScript(Dictionary<string, string> JS)
        {
            string strToReturn = "";
            int n;

            n = JS.Count;
            for (int i = 0; i < n; i++)
            {
                strToReturn += $@"{strToReturn}{JS.ElementAt(i).Value} " + Environment.NewLine;
            }

            return strToReturn;
        }


        public static string JSString(string s)
        {
            string strToReturn;
            strToReturn = s.Replace(@"\", @"\\");
            strToReturn = strToReturn.Replace(@"'", @"\'");
            strToReturn = strToReturn.Replace(@"""", @"\""");
            return strToReturn;
        }


        public static void HTML_HiddenField(eProcurementNext.CommonModule.EprocResponse response, string strFieldName, string strValue)
        {
            response.Write($"<input type=\"hidden\" name=\"{strFieldName}\"  id=\"{strFieldName}\" ");
            response.Write(" value=\"" + Basic.HtmlEncodeValue(strValue) + "\" ");
            response.Write("/>" + Environment.NewLine);
        }


        public static void ReloadUnfilteredDomain(Dictionary<string, Field> collAttrib, bool Editable)
        {
            ClsDomain newDom;
            Field objField;
            int i;
            int n;

            n = collAttrib.Count;
            for (i = 1; i <= n; i++)
            {// To n

                objField = collAttrib.ElementAt(i - 1).Value;

                //'-- se l'attributo possiede un dominio ed il campo non � editabile
                if (objField.Domain != null && (Editable == false || objField.GetEditable() == false))
                {

                    objField.SetEditable(false);

                    //'-- si ricarica il dominio senza filtro
                    if (!string.IsNullOrEmpty(objField.Domain.Filter))
                    {

                        BizDB.LibDBDomains objDB = new BizDB.LibDBDomains();
                        newDom = objDB.GetDom(objField.Domain.Id, objField.Domain.Suffix, 0, objField.ConnectionString);

                        //'-- sosituisce il dominio nel campo
                        if (newDom != null)
                        {
                            objField.Domain = newDom;
                        }

                    }
                }
            }

        }

        public static string UrlDecode(string str)
        {
            return HttpUtility.UrlEncode(str);
        }

        public char Hex2Char(string str)
        {
            return System.Convert.ToChar(System.Convert.ToUInt32(str, 16));
        }

        public static string EscapeSequenceJS(string? str)
        {
            if (string.IsNullOrEmpty(str))
                return string.Empty;

            string strTemp;
            strTemp = str;

            //'--quella del \ deve essere la 1a sostituzione
            strTemp = strTemp.Replace(@"\", @"\\");
            strTemp = strTemp.Replace(@"'", @"\'");
            strTemp = strTemp.Replace(@"""", @"\""");
            strTemp = strTemp.Replace(Environment.NewLine, @"\n");

            return strTemp;
        }

        public static string FMese(int i)
        {
            switch (i)
            {
                case 1:
                    return "Gennaio";
                case 2:
                    return "Febbraio";
                case 3:
                    return "Marzo";
                case 4:
                    return "Aprile";
                case 5:
                    return "Maggio";
                case 6:
                    return "Giugno";
                case 7:
                    return "Luglio";
                case 8:
                    return "Agosto";
                case 9:
                    return "Settembre";
                case 10:
                    return "Ottobre";
                case 11:
                    return "Novembre";
                case 12:
                    return "Dicembre";
                default:
                    return "";
            }

        }

        //'--da utilizzare per inserire il valore in una stringa javascript
        // HtmlEncodeJSValue è in CommonModule.Basic

        public static string saltoPagina()
        {

            return @"<div style=""page-break-after : always""></div>";

        }

        //'-- prende in input una dimensione e ritorniamo un valore utile per la classe css arrotodando il valore
        public static string getWidthAccessibile(string dimensione, string css_suffix)
        {
            if (IsMasterPageNew())
            {
                return "";
            }
            string getWidthAccessibileRet = "";

            if (string.IsNullOrEmpty(dimensione))
            {
                return getWidthAccessibileRet;
            }

            string @out;
            int incremento;
            long valore;
            long calcolato;
            int limite;
            if (Information.IsNumeric(dimensione))
            {
                valore = Conversions.ToLong(dimensione);
            }
            else
            {
                getWidthAccessibileRet = " width_100_percent";
                return getWidthAccessibileRet;
            }

            calcolato = valore;
            limite = 11;
            incremento = 0;

            // -- Calcolo il numero più vicino alla decina successiva
#warning TODO: da ottimizzare
            while (calcolato % 10L != 0L & limite > 0) // --limite>0 per evitare loop
            {
                calcolato = valore + 1L;
                limite = limite - 1;
            }

            getWidthAccessibileRet = " access_" + css_suffix + "_" + calcolato.ToString();
            return getWidthAccessibileRet;
        }

        public dynamic GetValueFromCollection(Dictionary<string, dynamic> c, string key)
        {
            if (c.ContainsKey(key))
            {
                return c[key];
            }
            else
            {
                return null;
            }
        }

        public dynamic GetValueFromCollection<TKey, TValue>(Dictionary<TKey, TValue> c, TKey key)
        {
            if (c.ContainsKey(key))
            {
                return c[key];
            }
            else
            {
                return null;
            }
        }

        // bonificaHtmlDaXSS è in security

        public string NL_To_BR(string Value)
        {
            Value = Replace(Value, Environment.NewLine, "</br>");

            Value = Replace(Value, Constants.vbCr, "</br>");
            Value = Replace(Value, "\n", "</br>");
            return Value;
        }




        public static Field getNewField(int fieldType)
        {
            switch (fieldType)
            {
                case 1:
                    return new Fld_Text();

                case 2:
                    return new Fld_Number();
                case 3:
                    return new Fld_TextArea();
                case 4:
                    return new Fld_Domain();
                case 5:
                    return new Fld_Hierarchy();
                case 6:
                    return new Fld_Date();
                case 7:
                    return new Fld_Number();
                case 8:
                    return new Fld_ExtendedDomain();
                case 9: //checkbox
                    return new Fld_CheckBox();
                case 10:
                    return new Fld_RadioButton();
                case 11:
                    return new Fld_Label();
                //case 12: //Foto
                //    return new Fld_Foto();
                case 13:
                    return new Fld_Url();
                case 14:
                    return new Fld_Mail();
                case 15:
                    return new Fld_Static();
                case 16: //HR
                    return new Fld_HR();
                case 18:
                    return new Fld_Attach();
                case 20:
                    return new Fld_PubLeg();
                case 22:
                    return new Fld_Date();
                default:
                    return new Fld_Text();
            }

            //return new Field();
            return new Fld_Text();
        }



        //public Fld_Label HTML_SynteticHelp( string strTitle, string Icon = "", string strAction = "", string strPath = "../images/")
        //{
        //    //Fld_Label obj = new Fld_Label();
        //    //obj.PathImage = strPath;
        //    //obj.Style = "SinteticHelp";

        //    //obj.Value = strTitle;
        //    //obj.Image = Icon;

        //    //obj.setOnClick(strAction);
        //    //obj.Html(_response);
        //    //return obj;
        //}

        public static string getFieldTypeDesc(int fieldType)
        {
            return XmlUtil.getFieldTypeDesc(fieldType);
        }

        public static string XmlEncode(string str)
        {
            return XmlUtil.XmlEncode(str);
        }

    }
}