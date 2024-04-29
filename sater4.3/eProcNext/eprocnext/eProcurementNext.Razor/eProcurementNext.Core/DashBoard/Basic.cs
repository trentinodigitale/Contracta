using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using Microsoft.VisualBasic;
using System.Text.RegularExpressions;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.DashBoard
{
    public static class Basic
    {
        // JavaScript è in HTML.BasicFunction

        // GetCollection è in HTML.BasicFunction

        // HtmlEncode è in HTML.BasicFunction

        // UrlEncode è in HTML.BasicFunction

        // GetCollection è in HTML.BasicFunction

        // CNV è in ApplicationCommon

        private static CommonDbFunctions cdf = new CommonDbFunctions();

        public static string ShowMessage(string strMsg, string path = "../basic/")
        {
            string strApp = "";
            strApp = strApp + @"<script type=""text/javascript"" language=""javascript"">" + Environment.NewLine;
            strApp = strApp + "ExecFunction( '" + path + "Message.asp?MSG=" + BasicFunction.UrlEncode(strMsg) + "' , 'Message' , ',height=250,width=400' );" + Environment.NewLine;
            strApp = strApp + "</script>" + Environment.NewLine;
            return strApp;
        }

        public static string Table2C(string c1, string c2, string c1w, string c2w)
        {
            string s = "";
            s = s + @"<table width=""100%"" height=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0""><tr>";
            s = s + @"<td width=""" + c1w + @""" >" + c1 + "</td>";
            s = s + @"<td width=""" + c2w + @""" align=""right"" >" + c2 + "</td>";
            s = s + "</tr></table>";
            return s;
        }

        public static void ReleaseCollection<TKey, TValue>(Dictionary<TKey, TValue> col)
        {
            col.Clear();
        }

        //'-- disegna la caption utilizzata sulle pagine dedicate al negozio
        public static void DrawShopCaption(IEprocResponse Response)
        {
            Response.Write(@"<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">");

            Response.Write("<tr>");

            //'-- logo azienda
            Response.Write(@"<td><img border=""0"" src=""..\images\logoslim.jpg"" ></td>");

            //'-- scritta lista di nozze
            Response.Write(@"<td width=""100%""  align=""center"" ><img border=""0"" src=""..\images\listenozze.jpg"" ></td>");

            //'-- disegno di chiususa caption
            Response.Write(@"<td><img border=""0"" src=""..\images\ring.jpg"" ></td>");


            Response.Write("</tr></table>");

            Response.Write("<hr>");
        }




        //Funzione che permette di verificare se una data stringa è valida rispetto a un'espressione regolare
        //passata come parametro o rispetto a un tipo di validazione noto
        //PARAMETRI :
        // strValue = valore da validare
        // tipo = tipo di controllo :
        //    * 1 = Formato table like, valori attesi : stringa compresa tra 1 e 100 caratteri e possiede solo caratteri minuscoli e maiuscoli, numeri e il caratteri underscore "_"
        //    * 2 = Formato sort like, valori attesi  : decimali,caratteri dalla a alla z, underscore e virgole e spazi,
        //    * 3 = Formato sql filter
        //    * 4 = Formato che permette solo numeri e virgole
        // strRegExp, se diverso da stringa vuota allora usiamo questa espressione regolare passata per validare il parametro strValue
        public static bool isValid(string strValue, int tipo, string? strRegExp = null, bool ignoreCase = true, string strConnectionString = "")
        {

            bool _isValid;
            Regex regex;
            if (string.IsNullOrEmpty(strValue))
            {
                return true;
            }

            if (string.IsNullOrEmpty(strRegExp))
            {

                switch (tipo)
                {
                    case 1:
                        regex = new Regex(@"[\d_,\-a-zA-Z]{1,300}", RegexOptions.Compiled | RegexOptions.IgnoreCase);
                        break;
                    case 2:
                        regex = new Regex(@"[\d_,\- a-zA-Z]{1,250}", RegexOptions.Compiled | RegexOptions.IgnoreCase);
                        break;
                    case 3:
                        _isValid = isValidaSqlFilter(strValue);
                        return _isValid;
                    case 4:
                        strValue = strValue.Replace("-", ",");
                        regex = new Regex(@"[\d,]{1,9000}", RegexOptions.Compiled | RegexOptions.IgnoreCase); // '-- Non limitiamo il numero massimo di caratteri
                        break;
                    case 5:
                        string? SECURITY_WHITELIST_ONSUBMIT = Application.ApplicationCommon.Application["SECURITY_WHITELIST_ONSUBMIT"];
                        if (!string.IsNullOrEmpty(SECURITY_WHITELIST_ONSUBMIT))
                        {
						    string[] arrayOfSECURITY_WHITELIST_ONSUBMIT = Strings.Split(SECURITY_WHITELIST_ONSUBMIT, "@@@");
						    string pattern = "^(" + string.Join("|", Array.ConvertAll(arrayOfSECURITY_WHITELIST_ONSUBMIT, s => Regex.Escape(s))) + ")$";
						    regex = new Regex(pattern, RegexOptions.Compiled | RegexOptions.IgnoreCase);
                        }
						else
                        {
							regex = new Regex("^$", RegexOptions.Compiled | RegexOptions.IgnoreCase);
						}
						break;
					default:
                        regex = new Regex(@"[\d_\-a-zA-Z]{1,300}", RegexOptions.Compiled | RegexOptions.IgnoreCase); 
                        break;
                }
            }
            else
            {
                regex = new Regex($@"{strRegExp}");
            }

            MatchCollection mc = regex.Matches(strValue.Replace(".", ","));
            if (mc.Count == 0)
            {
                _isValid = false;
            }
            else
            {
                if (mc[0].Value != strValue.Replace(".", ","))
                {
                    _isValid = false;
                }
                else
                {
                    _isValid = true;
                }
            }
            return _isValid;
        }

        public static bool isValidaSqlFilter(string strFilter, string parametroInutile = "")
        {

            bool test = true;
            int totParentesi = 0;
            int i, n;
            string Char = string.Empty;
            bool isCostante = false;
            string strTempFilter = string.Empty;

            if (strFilter != "")
            {
                strTempFilter = strFilter.ToUpper();
                strTempFilter = $" {strTempFilter} ";
                strTempFilter = strTempFilter.Replace(";", " ");
                strTempFilter = strTempFilter.Replace(",", " ");
                strTempFilter = strTempFilter.Replace("*", " * ");
                strTempFilter = strTempFilter.Replace("(", " ");
                strTempFilter = strTempFilter.Replace(")", " ");
				strTempFilter = strTempFilter.Replace("+", " ");
				strTempFilter = strTempFilter.Replace("[", " ");
                strTempFilter = strTempFilter.Replace("]", " ");
                strTempFilter = strTempFilter.Replace(".", " ");
                strTempFilter = strTempFilter.Replace(Environment.NewLine, " ");    // conversione vbCrLf
                strTempFilter = strTempFilter.Replace("\r", " ");                                 // conversione vbCR           
                strTempFilter = strTempFilter.Replace("\n", " ");                                // conversione vbLf
                strTempFilter = strTempFilter.Replace("\0", " ");                                // conversione vbNullChar to null
                strTempFilter = strTempFilter.Replace("\t", " ");                                 // conversione vbTab 
                strTempFilter = strTempFilter.Replace("\b", " ");                                // conversione vbBack to null
                strTempFilter = strTempFilter.Replace("\f", " ");                                 // conversione vbFormFeed to null
                strTempFilter = strTempFilter.Replace("\v", " ");                                // conversione vbVerticalTab to null

                if (strTempFilter.IndexOf("--", StringComparison.Ordinal) > -1) test = false;
                if (strTempFilter.IndexOf("/ *", StringComparison.Ordinal) > -1) test = false;
                if (strTempFilter.IndexOf("* /", StringComparison.Ordinal) > -1) test = false;
                if (strTempFilter.IndexOf("@@", StringComparison.Ordinal) > -1) test = false;
                if (strTempFilter.IndexOf(" SYS.", StringComparison.Ordinal) > -1) test = false;
                if (strTempFilter.IndexOf("<SCRIPT", StringComparison.Ordinal) > -1) test = false;

                if (!test) return test;  // equivale a
                                         // If isValidSqlFilter = False Then
                                         // Exit Function
                                         // End If

                bool bTabella = false;
                string strSql = string.Empty;
                TSRecordSet? rs = null;

               strSql = $@"select value from CTL_CHECK_SECURITY with(nolock) where tipo = 'KEYS_TO_BLOCK_IN_FILTER' and @strTempFilter like '% ' + value + ' %'";

                Dictionary<string, object?> sqlP = new();
                sqlP.Add("@strTempFilter", strTempFilter);

               rs = cdf.GetRSReadFromQuery_(strSql, Application.ApplicationCommon.Application["ConnectionString"], sqlP);

                test = true;

                if (rs != null && rs.RecordCount > 0)
                    test = false;

              

                if (test)
                {
                    totParentesi = 0;
                    n = strFilter.Length;
                    isCostante = false;

                    for (i = 1; i <= n; i++)
                    {
                        Char = Strings.Mid(strFilter, i, 1);
                        if (Char == "'") isCostante = !isCostante;

                        if (!isCostante)
                        {
                            if (Char == "(")
                            {
                                totParentesi++;
                            }
                            else if (Char == ")")
                            {
                                totParentesi--;
                            }
                        }

                        if (totParentesi < 0)
                        {
                            test = false;
                            return test;
                        }
                    }

                    if (totParentesi != 0) test = false;
                }
            }
            return test;
        }

        public static bool IsNumeric(string value)
        {

            try
            {
                return int.TryParse(value, out _);
            }
            catch
            {
                return false;
            }
        }

        public static string GetDefaultQueryTimeOut()
        {
            string result = string.Empty;


            result = Application.ApplicationCommon.getAflinkRegistryKey("CurrentVersion");

            return result;
        }

        public static bool checkPermission(string strSqlTable, dynamic session, string strConnection)
        {
            bool result = false;

            string strSql = string.Empty;
            bool ret = false;
            string strConnectionString = string.Empty;
            string strCause = string.Empty;
            TSRecordSet rs = new TSRecordSet();

            string strPermission = string.Empty;
            string permesso = string.Empty;

            ret = true;

            strPermission = session[Session.SessionProperty.SESSION_PERMISSION];
            if (string.IsNullOrEmpty(strPermission))
            {
                result = true;
                return result;
            }

            if (!string.IsNullOrEmpty(strSqlTable))
            {
                strSql = "select lfn_paramtarget + '&' as params, ISNULL(lfn_pospermission,'-1') as permesso from lib_functions where lfn_paramtarget like '%TABLE=" + strSqlTable.Replace("'", "''") + "&%' Union select mpclink + '&' as params , ISNULL(mpcuserfunz,'-1') as permesso from mpcommands  where mpclink like '%TABLE=" + strSqlTable.Replace("'", "''") + "&%'";
                strConnectionString = strConnection;
                CommonDbFunctions cdf = new CommonDbFunctions();
                rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString);

                if (rs.RecordCount == 0)
                {
                    ret = false;
                }
                else
                {
                    rs.Filter("permesso = '-1'");

                    if (rs.RecordCount == 0)
                    {
                        rs.Filter("permesso <> '-1'");
                        rs.MoveFirst();
                        ret = false; //'fino a che non trovo un permesso per l'utente rispetto all'oggetto sql a cui vuole accedere, lo considero non autorizzato

                        while (!rs.EOF)
                        {
                            permesso = CStr(rs.Fields["permesso"]);
                            if (CLng(permesso) > 0)
                            {
                                if (MidVb6(strPermission, CInt(permesso), 1) != "0")
                                {
                                    ret = true;
                                    rs.MoveLast();
                                }
                            }
                            else
                            {
                                ret = true;
                                rs.MoveLast(); // forzo l'uscita dal ciclo
                            }

                            rs.MoveNext();
                        }

                    }


                }
            }
            return ret;
        }

        public static bool isValidSortSql(string strFilter, string strConnectionString = "")
        {
            int totParentesi = 0;
            int i = 0;
            int n = 0;
            string Char = string.Empty;
            bool isCostante = false;

            bool result = true;

            if (String.IsNullOrEmpty(strFilter))
            {
                return result;
            }

            strFilter = " " + strFilter.ToUpper() + " ";
            strFilter = strFilter.Replace(";", " ").Replace(",", " ").Replace("*", " ").Replace("(", " ");
            strFilter = strFilter.Replace(")", " ").Replace("+", " ").Replace("[", " ").Replace("]", " ");
            strFilter = strFilter.Replace(".", " ").Replace(Environment.NewLine, " ");
            strFilter = strFilter.Replace(".", " ");
            strFilter = strFilter.Replace(Environment.NewLine, " ");             // conversione vbCrLf
            strFilter = strFilter.Replace("\r", " ");                    // conversione vbCR           
            strFilter = strFilter.Replace("\n", " ");                    // conversione vbLf
            strFilter = strFilter.Replace(Convert.ToChar(0), (char)32);     // conversione vbNullChar to null
            strFilter = strFilter.Replace("\t", " ");                    // conversione vbTab 
            strFilter = strFilter.Replace((char)8, (char)32);             // conversione vbBack to null
            strFilter = strFilter.Replace((char)12, (char)0);             // conversione vbFormFeed to null
            strFilter = strFilter.Replace((char)10, (char)0);             // conversione vbVerticalTab to null


            if (strFilter.Contains("--", StringComparison.Ordinal))
            {
                result = false;
            }
            if (strFilter.Contains("/ *", StringComparison.Ordinal))
            {
                result = false;
            }
            if (strFilter.Contains("* /", StringComparison.Ordinal))
            {
                result = false;
            }
            if (strFilter.Contains("@@", StringComparison.Ordinal))
            {
                result = false;
            }
            if (strFilter.Contains(" SYS.", StringComparison.Ordinal))
            {
                result = false;
            }

            if (!result)
            {
                return result;
            }

            TSRecordSet rs = new TSRecordSet();
            string strSql = string.Empty;

            bool bTabella = false;

            if (String.IsNullOrEmpty(strConnectionString))
            {
                bTabella = false;
            }
            else
            {
                try
                {
                    CommonDbFunctions cdf = new CommonDbFunctions();
                    bTabella = true;
                    rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString);
                }
                catch (Exception ex)
                {
                    bTabella = false;
                }
            }

            // '-- se la tabella CTL_CHECK_SECURITY non esiste, utilizzo la vecchia gestione con le parole chiave elencate di seguito
            if (!bTabella)
            {
                if (strFilter.Contains(" UPDATE ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" DELETE ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" DROP ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" ALTER ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" UNION ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" EXEC ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" EXECUTE ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" CREATE ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" TRUNCATE ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" KILL ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" INTERSECT ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" AUTHORIZATION ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" SHUTDOWN ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" SCHEMA ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" DENY ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" GO ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" GOTO ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" WAIT ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" WAITFOR ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" DBCC ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" OPENDATASOURCE ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" OPENQUERY ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" OPENROWSET ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" OPENXML ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" RESTORE ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" WHILE ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" SYSOBJECTS ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" SYSDATABASES ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" SYS.OBJECTS ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" SYS.DATABASES ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" SYSCOLUMNS ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" SYS.COLUMNS ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" INFORMATION_SCHEMA ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" SYSUSERS ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" DECLARE ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" DB_NAME ", StringComparison.Ordinal)) result = false;
                if (strFilter.Contains(" DB_ID ", StringComparison.Ordinal)) result = false;
            }
            else
            {
                if (rs.RecordCount > 0)
                {
                    result = false;
                }
                else
                {
                    result = true;
                }
            }

            i = 1;
            n = strFilter.Length;
            isCostante = false;

            for (i = 1; i < n; i++)
            {
                Char = CommonModule.Basic.MidVb6(strFilter, i, 1);

                // se nel filtro sql si sta aprendo una stringa non dobbiamo contare le parentesi contenute in costante stringa
                if (Char == "'")
                {
                    isCostante = !isCostante;
                }

                // se non stiamo in una stringa
                if (!isCostante)
                {
                    if (Char == "(")
                    {
                        totParentesi++;
                    }
                    if (Char == "(")
                    {
                        totParentesi--;
                    }
                }

                // se le parentesi chiuse diventano maggiori di quelle aperte vuol dire che si sta tentanto un sql injection
                if (totParentesi < 0)
                {
                    result |= false;
                    return result;
                }
            }

            if (totParentesi != 0)
            {
                result = false;
            }
            return result;
        }

    }
}
