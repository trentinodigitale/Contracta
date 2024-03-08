using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Primitives;
using Microsoft.VisualBasic;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;


namespace eProcurementNext.CommonModule
{
    public static partial class Basic
    {

        private static DebugTrace dt = new DebugTrace();

        public const int MSG_INFO = 1; //'"info.gif"
        public const int MSG_ERR = 2; //'"err.gif"
        public const int MSG_ASK = 3; //'"ask.gif"
        public const int MSG_WARNING = 4; //'"warning.gif"
        public static string GetEncodedUTF8String(string textToEncode)
        {
            //HttpUtility.UrlEncode
            return System.Net.WebUtility.UrlEncode(textToEncode);
        }

        public static string NormalizeUrlSlashes(string url)
        {
            return Regex.Replace(url, @"/+", @"/");
        }

        public static string GetValue_FromAttrib_Filter(string strFilter, ref string strNameField)
        {
            try
            {
                string[] p;

                // rimpiazzo operatori con carattere ###
                strFilter = strFilter.Trim().ToLower();

                strFilter = strFilter.Replace("<=", "###").Replace(">=", "###").Replace("<>", "###");
                strFilter = strFilter.Replace("<", "###").Replace(">", "###").Replace("=", "###");
                strFilter = strFilter.Replace("like", "###");

                p = strFilter.Split("###");
                p[1] = p[1].Trim().Replace("'", "");
                p[1] = p[1].Replace("%", "");

                // nome del campo
                strNameField = p[0].Trim();
                // valore del campo
                return p[1];


            }
            catch (Exception ex)
            {
                throw new Exception("DashBoard.GetValue_FromAttrib_Filter( " + strFilter + " )", ex);
            }
        }

        public static string getPathRequest(HttpRequest Request)
        {
            string pathBase = CStr(Request.PathBase);
            string path = CStr(Request.Path);

            if (!string.IsNullOrEmpty(pathBase))
            {
                if (!pathBase.StartsWith("/", StringComparison.Ordinal))
                {
                    pathBase = "/" + pathBase;
                }
            }

            return pathBase + path;

        }

        public static string GetParamURL(object str, string param)
        {
            try
            {
                //TODO: Federico: introdurre meccanismo di cache ? a parità di url, recupero il valore di un parametro già richiesto da cache. si velocizza ? 
                return HttpUtility.UrlDecode(GetParam(Convert.ToString(str), param));
            }
            catch
            {
                return "";
            }
        }

        /// <summary>
        /// Prende un valore dal Recordset e controlla se è un DBNull, se è un DBNull ritorna null
        /// </summary>
        /// <param name="value"></param>
        /// <returns>value</returns>
        public static dynamic? GetValueFromRS(object value)
        {
            return value is DBNull ? null : value;
        }

        public static string GetQueryStringFromContext(QueryString queryString)
        {
            var qs = queryString.ToString();
            if (qs.Length == 0)
            {
                return string.Empty;
            }

            //Se il primo carattere è un ? lo togliamo
            return qs[..1] == "?" ? qs[1..] : qs;
        }


        public static string GetParam(string? str, string? param)
        {

            //TODO: Federico: introdurre meccanismo di cache ? a parità di url, recupero il valore di un parametro già richiesto da cache. si velocizza ? 

            if (string.IsNullOrEmpty(str) || string.IsNullOrEmpty(param))
            {
                return string.Empty;
            }
            var indexOfQuestionMark = str.IndexOf('?', StringComparison.Ordinal);

            if (indexOfQuestionMark >= 0)
            {
                if (str.Length <= indexOfQuestionMark + 1)
                {
                    return "";
                }
                str = str[(indexOfQuestionMark + 1)..];
            }

            //'-- aggiungo gli & prima dello stringone di parametri se non inizia gi� per & e prima del nome del parametro richiesto
            //'-- per evitare di prendere dei parziali
            var localStr = Strings.Left(CStr(str), 1) != "&" ? $"&{CStr(str)}" : str;

            var localParam = Strings.Left(CStr(param), 1) != "&" ? $"&{CStr(param)}" : param;

            //'-- aggiungo gli & prima dello stringone di parametri e prima del nome del parametro richiesto
            //'-- per evitare di prendere dei parziali
            var sa = Strings.UCase(localStr);
            var pa = Strings.UCase(localParam);

            var ind = Strings.InStr(1, sa, $"{pa}=");

            if (ind > 0)
            {

                var a = Strings.Mid(localStr, ind + Strings.Len(localParam) + 1);

                ind = Strings.InStr(1, a, "&");
                if (ind > 0)
                {
                    a = Strings.Left(a, ind - 1);
                }
                return a ?? string.Empty;

            }
            else
            {
                return string.Empty;
            }

        }

        public static string ShowMessageBox(string strMsg, string strCaption, string Path = "../ctl_library/", int Icon = 1, string ActionScript = "")
        {


            string strApp = "";

            strApp = $@"{strApp}<script type=""text/javascript"" language=""javascript""> ";

            strApp = $"{strApp}    var w;";
            strApp = $"{strApp}    var h;";
            strApp = $"{strApp}    ";
            strApp = $"{strApp}    w = (screen.availWidth-400)/2;";
            strApp = $"{strApp}    h = (screen.availHeight-250)/2;";

            strApp = $@"{strApp}ExecFunction( '{Path}MessageBoxWin.asp?CAPTION={HttpUtility.UrlEncode(strCaption)}&MSG={HttpUtility.UrlEncode(TruncateMessage(strMsg))}&ICO={Icon}&ON_OK={HttpUtility.UrlEncode(ActionScript)}' , 'Message' , ',height=250,width=400,top=' + h + ',left=' + w ); ";

            strApp = $"{strApp}</script> ";

            return strApp;

        }
        public static void LoadFromFile(string Path, EprocResponse htmlToReturn, HttpContext httpContext)
        {

            using FileStream fs = new FileStream(Path, FileMode.Open, FileAccess.Read);
            byte[] b = new byte[1024];
            int len;
            int counter = 0;
            while (true)
            {
                len = fs.Read(b, 0, b.Length);
                byte[] c = new byte[len];
                b.Take(len).ToArray().CopyTo(c, 0);
                htmlToReturn.BinaryWrite(httpContext, c);
                if (len == 0 || len < 1024)
                {
                    break;
                }
                counter++;
            }


        }

        public static bool IsEnabled(string Permission, int indP)
        {

            var boolToReturn = true;

            if (indP <= 0) return boolToReturn;

            if (Strings.Mid(Permission, indP, 1) != "1")
            {
                boolToReturn = false;
            }

            return boolToReturn;

        }

        public static string JavaScript(Dictionary<string, string> JS)
        {

            StringBuilder strToReturn = new StringBuilder();
            int n;

            n = JS.Count;
            for (int i = 0; i < n; i++)
            {
                strToReturn.Append($@"{JS.ElementAt(i).Value} " + Environment.NewLine);
            }

            return strToReturn.ToString();


        }

        public static string URLEncode(string? str)
        {
            if (string.IsNullOrEmpty(str))
                return string.Empty;

            return WebUtility.UrlEncode(str);
        }

        public static void GetUTF8FromUTF16()
        {
            throw new NotSupportedException();
        }

        public static string HtmlEncode(string? str)
        {
            if (string.IsNullOrEmpty(str))
                return string.Empty;

            return WebUtility.HtmlEncode(str);
        }

        public static string HtmlDecode(string? str)
        {
            if (string.IsNullOrEmpty(str))
                return string.Empty;

            return WebUtility.HtmlDecode(str);
        }

        /// <summary>
        /// Questa funzione serve per fare l'htmlencode di una stringa in modalità "legacy"/"light" così come veniva fatto per il codice vb6. quindi lato backend.
        /// l'html encode eseguito nella funzione 'HtmlEncode' utilizza la 'WebUtility.HtmlEncode' che porta come "side effect" l'encode dei caratteri accentati.
        /// Questa differenza rispetto alla versione vb6 portava nelle stampe ad alcuni problemi di visualizzazione ( usciva l'html a video per i caratteri accentati )
        /// </summary>
        /// <param name="str">Stringa da sottoporre ad html encode "light", simil vb6 lato backend</param>
        /// <returns></returns>
        public static string HtmlEncodeMinimal(string? str)
        {
            if (string.IsNullOrEmpty(str))
                return string.Empty;

            string outEncode = str;
            outEncode = Replace(outEncode, "&", "&amp;");
            outEncode = Replace(outEncode, "<", "&lt;");
            outEncode = Replace(outEncode, ">", "&gt;");
            outEncode = Replace(outEncode, @"""", "&quot;");
            outEncode = Replace(outEncode, "'", "&#39;");

            return outEncode;
        }

        public static string Title(string strTitle)
        {
            return $"<title>{HtmlEncode(strTitle)}</title>" + Environment.NewLine;
        }

        public static string TitleFolder(string sTitle)
        {
            string strTitle;


            strTitle = sTitle.Replace(@"\", @"\\");
            strTitle = strTitle.Replace(@"'", @"''");
            string strToReturn;

            strToReturn = $@"<script type=""text/javascript"" language=""javascript"">" + Environment.NewLine;
            strToReturn = strToReturn + "try{ parent.frames['intestazione'].getObj('DescFolder').innerText = '" + strTitle + "'; }catch(e){};" + Environment.NewLine;
            strToReturn = strToReturn + "</script>" + Environment.NewLine;
            return strToReturn;

        }

        public static bool User_CheckPermission(string strFunz, int pos)
        {
            if (MidVb6(strFunz, pos, 1) == "1")
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public static string DOC_GetNewID(dynamic sessionASP)
        {
            //TODO: Federico, rimuovere il dynamic in favore del tipo nativo session. c'è un problema di using ? 
            sessionASP["DocumentCounterNew"] = CLng(sessionASP["DocumentCounterNew"]) + 1;
            return "new" + sessionASP["DocumentCounterNew"];  //'"NEW"

        }

        public static string GetParamExt(string str, string param, string sep = "#@#", string uguale = "#=#")
        {
            int ind;
            string A;
            ind = InStr(1, str, param + uguale);
            if (ind > 0)
            {
                A = MidVb6(str, ind + param.Length + 1);
                ind = InStr(1, A, sep);
                if (ind > 0)
                {
                    A = Strings.Left(A, ind - 1);
                }
                return A;

            }
            else
            {
                return string.Empty;
            }

        }

        public static Dictionary<string, string> GetCollectionExt(string str, string sep = "#@#", string uguale = "#=#")
        {

            Dictionary<string, string> Coll = new Dictionary<string, string>();
            string[] arr;
            string[] val;

            if (string.IsNullOrEmpty(str))
            {
                return Coll;
            }
            arr = str.Split(sep);

            for (int i = 0; i < arr.Length; i++)
            {
                val = arr[i].Split(uguale);

                if (Strings.Left(val[1], 1) == "\"")
                {
                    Coll.Add(val[0], MidVb6(val[1], 2, val[1].Length - 2));
                }
                else
                {
                    Coll.Add(val[0], val[1]);
                }
            }

            return Coll;

        }

        //'-- carica nella collezione passata i JS legatia alla toolbar
        public static void JS_LoadFromToolbar(Dictionary<string, string> JS, dynamic mp_objToolbar, string strPath)
        {

            string Path;

            if (!strPath.Contains("/jscript/", StringComparison.Ordinal))
            {
                Path = strPath + "jsapp/";
            }
            else
            {
                Path = strPath;
            }

            foreach (dynamic Button in mp_objToolbar.Buttons)
            {
                if (!string.IsNullOrEmpty(Button.OnClick) && !JS.ContainsKey(Button.OnClick))
                {
                    JS.Add(Button.OnClick, $@"<script src=""" + Path + Button.OnClick + $@".js"" ></script>");
                }
            }




        }

        public static dynamic? GetCollectionValue(Dictionary<string, string>? c, string Key)
        {
            if (c is not null)
            {
                if (c.ContainsKey(Key))
                {
                    return c[Key];
                }
                else
                {
                    return string.Empty;
                }
            }
            else
            {
                return string.Empty;
            }
        }

        /// <summary>
        /// da utilizzare per inserire il valore negli attributi dei tag html
        /// </summary>
        /// <param name="str">Valore da encodare</param>
        /// <returns>Valore encodato</returns>
        public static string htmlEncodeValue(string? str)
        {
            if (string.IsNullOrEmpty(str))
                return string.Empty;

            return str.Replace(@"""", @"&#34");
        }

        public static string? UrlDecode(string? str)
        {
            if (string.IsNullOrEmpty(str))
                return string.Empty;

            return WebUtility.UrlDecode(str);
        }


        public static string? Hex2Char(string? str)
        {

            string c1;
            string c2;
            int v1;
            int v2;
            c1 = MidVb6(str, 1, 1);
            c2 = MidVb6(str, 2, 1);
            if (CInt(c1) >= 0 && CInt(c1) <= 9)
            {
                v1 = Strings.Asc(c1) - 48;
            }
            else
            {
                v1 = Strings.Asc(UCase(c1)) - 55;
            }
            if (CInt(c2) >= 0 && CInt(c2) <= 9)
            {
                v2 = Strings.Asc(c2) - 48;
            }
            else
            {
                v2 = Strings.Asc(UCase(c2)) - 55;
            }
            v1 = v1 * 16 + v2;


            return CStr(Strings.Chr(v1));


        }



        public static int Hex2I(string s)
        {

            string A;

            A = Strings.Right("00" + s, 2).ToUpper();

            return VH(Strings.Left(A, 1).ToCharArray().ElementAt(0)) * 16 + VH(Strings.Right(A, 1).ToCharArray().ElementAt(0));

        }

        public static int VH(char s)
        {
            //On Error Resume Next
            if (s >= 'A' && s <= 'F')
            {
                return 10 + Strings.Asc(s) - Strings.Asc('A');
            }
            else
            {
                return CInt(s);
            }

        }


        /// <summary>
        /// '--recupera il nome file da un path completo
        /// </summary>
        /// <param name="s"></param>
        public static string GetNameAttach(string s)
        {
            return Path.GetFileName(s);
        }



        //'-- Funzione che controlla se un dato valore (potenzialmente arrivato da form) non contenta tag pericolosi per una successiva visualizzazione
        public static bool isFormValid(string Value)
        {
            bool boolToReturn;
            try
            {
                boolToReturn = true;

                string val;
                val = Value.Trim().ToUpper();

                if (val.Contains("<SCRIPT>", StringComparison.Ordinal) || val.Contains("<META>", StringComparison.Ordinal) || val.Contains("<IFRAME>", StringComparison.Ordinal) || val.Contains("<FRAME>", StringComparison.Ordinal) || val.Contains(" ONLOAD", StringComparison.Ordinal) || val.Contains(" ONCLICK", StringComparison.Ordinal) || val.Contains("<OBJECT>", StringComparison.Ordinal) || val.Contains("<APPLET>", StringComparison.Ordinal) || val.Contains("<EMBED>", StringComparison.Ordinal) || val.Contains("<A", StringComparison.Ordinal) || val.Contains("<FORM>", StringComparison.Ordinal) || val.Contains(" ONMOUSEOVER", StringComparison.Ordinal) || val.Contains(" ONKEYUP", StringComparison.Ordinal) || val.Contains(" ONKEYDOWN", StringComparison.Ordinal) || val.Contains(" SELF.LOCATION", StringComparison.Ordinal))
                {
                    boolToReturn = false;
                }

                return boolToReturn;
            }
            catch
            {
                return true;
            }


        }

        /// <summary>
        /// Funzione utile ad invocare un url http/s con method GET
        /// </summary>
        /// <param name="url">Url che si desidera invocare. L'endpoint deve essere completo</param>
        /// <param name="timeoutMilliseconds">Parametro opzionale, il default è 100000 ( 100 secondi ). Indica il tempo di timeout </param>
        /// <returns>Stringa contenente la risposta dell'url richiesto</returns>
        /// <exception cref="Exception">Eccezione ritornata in caso di http status error o in caso di mancata risposta</exception>
        public static string invokeUrl(string url, int timeoutMilliseconds = 100000)
        {

            dt.Write($"Url chiamata: {url}", "CommonModule.Basic", "invokeUrl");
            try
            {
                HttpResponseMessage response;

                using (HttpClient client = new())
                {
                    client.Timeout = new TimeSpan(0, 0, 0, 0, timeoutMilliseconds);
                    response = client.GetAsync(url).Result;
                }

                string ret;

                try
                {
                    //Sia in caso di status http OK, sia in caso di errore, recuperiamo l'output. così da ottenere più informazioni possibili
                    ret = response.Content.ReadAsStringAsync().Result;
                }
                catch
                {
                    ret = string.Empty;
                }

                if (response is null)
	                throw new NullReferenceException("Response null");

				//in caso di esito http negativo lanciamo un eccezione con lo status code e l'eventuale output ottenuto
				if (response is not { IsSuccessStatusCode: true })
                {
					dt.Write($"ResponseStatusCode:  {response.StatusCode}", "CommonModule.Basic", "invokeUrl");
                    throw new Exception($"ResponseStatusCode: {response.StatusCode} - Output: {ret}");
                }

                return ret;
            }
            catch (Exception ex)
            {
                dt.Write($"Richiesta invokeUrl({url}) fallita. Exception: {ex.Message}", "CommonModule.Basic", "invokeUrl");
                throw new Exception($"Richiesta invokeUrl({url}) fallita. Exception: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Funzione utile ad invocare un url http/s con method POST
        /// </summary>
        /// <param name="url">Url che si desidera invocare. L'endpoint deve essere completo</param>
        /// <param name="PostData">Dati da passare in post ( il form. chiave/valore )</param>
        /// <returns>Stringa contenente la risposta dell'url richiesto</returns>
        /// <exception cref="Exception">Eccezione ritornata in caso di http status error o in caso di mancata risposta</exception>
        public static string invokePageInPost(string url, string PostData, int timeoutMilliseconds = 100000)
        {

            try
            {
                HttpResponseMessage response;

                using (HttpClient client = new())
                {
                    client.Timeout = new TimeSpan(0, 0, 0, 0, timeoutMilliseconds);

                    PostData = Replace(PostData, Environment.NewLine, "%0d");     //'-- replace forzata dello carriege return
                    var content = new StringContent(PostData);

                    response = client.PostAsync(url, content).Result;

                }

                string ret;

                try
                {
                    //Sia in caso di status http OK, sia in caso di errore, recuperiamo l'output. così da ottenere più informazioni possibili
                    ret = response.Content.ReadAsStringAsync().Result;
                    ret ??= ""; //se il result è null lo facciamo diventare stringa vuota
                }
                catch
                {
                    ret = "";
                }

                //in caso di esito http negativo lanciamo un eccezione con lo status code e l'eventuale output ottenuto
                if (response == null || !response.IsSuccessStatusCode)
                {
                    if (response == null)
                        throw new Exception("Response null");
                    else
                        throw new Exception($"ResponseStatusCode: {response.StatusCode} - Output: {ret}");
                }

                return ret;
            }
            catch (Exception ex)
            {
                throw new Exception($"Richiesta invokeUrl({url}) fallita. Exception: {ex.Message}", ex);
            }

        }

        public static string ReplacePlaceholders(string? str)
        {
            if (str == null)
            {
                return "";
            }

            string pattern = @"[<][#]\w+[:]\w+[#][>]";
            RegexOptions options = RegexOptions.Multiline;
            IEnumerable<Match> listOfMatches = Regex.Matches(str, pattern, options).DistinctBy((elem) => elem.Value);
            foreach (Match m in listOfMatches)
            {
                string key = m.Value.Replace("<#", "").Replace("#>", "");
                string valueKey = ConfigurationServices.GetKey(key);
                str = str.Replace($"<#{key}#>", valueKey);
            }
            if (listOfMatches.Any())
            {
                return str;
            }

            pattern = @"[<][#]\w+[#][>]";
            listOfMatches = Regex.Matches(str, pattern, options).DistinctBy((elem) => elem.Value);
            foreach (Match m in listOfMatches)
            {
                string key = m.Value.Replace("<#", "").Replace("#>", "");
                string valueKey = ConfigurationServices.GetKey(key);
                str = str.Replace($"<#{key}#>", valueKey);
            }

            return str;

        }

        public static string TruncateMessage(string message, int maxLength = 0)
        {
            if (string.IsNullOrEmpty(message))
                return string.Empty;

            int maxLenMsg = maxLength;
            if (maxLenMsg == 0)
            {
                maxLenMsg = Convert.ToInt32(ConfigurationServices.GetKey("MaxUrlLength", "1024"));
            }

            if (message.Length > maxLenMsg)
            {
                message = message[..maxLenMsg] + "..."; //Se il msg supera la dimensione configurata tronchiamo ad aggiungiamo i 3 puntini per far capire che continuava
            }
            return message;
        }

        public static string ShowMessageBoxModale(string strMsg, string strCaption, string Path = "../ctl_library/", int Icon = MSG_INFO, string ActionScript = "")
        {

            strMsg = TruncateMessage(strMsg);

            string strApp = "";

            strApp = strApp + @"<script type=""text/javascript"">" + Environment.NewLine;

            //'-- se si è chiesto un messaggio modale sull'opener
            if (UCase(CStr(ActionScript)) == "OPENER")
            {
                ActionScript = "";
                strApp = strApp + "window.opener.";
            }

            //'-- se si è chiesto un messaggio modale sull'opener
            if (UCase(CStr(ActionScript)) == "PARENT")
            {
                ActionScript = "";
                strApp = strApp + "window.parent.";
            }

            if (string.IsNullOrEmpty(ActionScript))
            {
                strApp = strApp + "ExecFunctionModale( 'ctl_library/MessageBoxWin.asp?MODALE=YES&CAPTION=" + URLEncode(strCaption) + "&MSG=" + URLEncode(TruncateMessage(strMsg)) + "&ICO=" + Icon + "&ON_OK=" + URLEncode(ActionScript) + "' , 'Message' , '250','400', '');" + Environment.NewLine;
            }
            else
            {
                strApp = strApp + "ExecFunctionModaleConfirm( 'ctl_library/MessageBoxWin.asp?MODALE=YES&CAPTION=" + URLEncode(strCaption) + "&MSG=" + URLEncode(TruncateMessage(strMsg)) + "&ICO=" + Icon + "&ON_OK=" + URLEncode(ActionScript) + "' , 'Message' , '250','400', '', '" + (!string.IsNullOrEmpty(ActionScript) ? EncodeJSValue(ActionScript) : "") + "');" + Environment.NewLine;
            }

            strApp = strApp + "</script>" + Environment.NewLine;

            return strApp;
        }

        //'--da utilizzare per inserire il valore in una stringa javascript
        public static string EncodeJSValue(string? str)
        {

            if (string.IsNullOrEmpty(str))
                return "";
            string? s;

			s = str.Replace(@"\", @"\\");
            s = s.Replace(@"'", @"\'");
            s = s.Replace(@"""", @"\""");
			s = s.Replace(@"\r\n", @"\n");

			return s != null ? s : "";

        }


        public static string GetNewGuid()
        {
            return Guid.NewGuid().ToString().ToUpper();
        }


        public static DateTime CDate(dynamic date)
        {

            if (date is null)
                throw new ArgumentNullException("date", "Invalid use of Null: 'cdate'");

            //Se l'input è già della tipologia richiesta ritorniamo la variabile senza fare nulla
            if (date is DateTime)
                return date;

            if (date is double)
                return DateTime.FromOADate(date);

            if (date is string)
            {
                if (string.IsNullOrEmpty(date))
                    throw new ArgumentNullException("date", "Invalid use of string.empty: 'cdate'");

                return DateTime.Parse(date);
            }

            return DateTime.FromOADate(CDbl(date));
        }

        public static string GetValueFromForm(HttpRequest Request, string key)
        {
            StringValues temp;
            StringValues outvalue;

			try
            {
                if (Request.HasFormContentType && Request.Form.TryGetValue(key, out temp))
                {
					outvalue= temp.First();
                }
                else
                {
					outvalue= "";
                }
            }
            catch
            {
				outvalue = "";
			}
            return outvalue;
        }

        public static string GetValueFromForm(IFormCollection? Request_Form, string key)
        {
            StringValues temp;
			StringValues outvalue ;

			try
			{
				if (Request_Form != null && Request_Form.TryGetValue(key, out temp))
                {
					outvalue = temp.First();
                }
                else
                {
					outvalue = "";
				}
			}
			catch
			{
				outvalue = "";
			}
			return outvalue;
		}



        public static int TypeEnabled(string Permission, int indP)
        {
            int intToReturn = 1;

            //TypeEnabled = 1

            if (indP > 0)
            {

                intToReturn = CInt(Strings.Mid(Permission, indP, 1));


            }

            return intToReturn;
        }

        public static T[,] ResizeArray<T>(T[,] original, int rows, int cols)
        {

            if (original == null)
                return new T[rows, cols];

            rows++;
            cols++;
            var newArray = new T[rows, cols];
            int minRows = Math.Min(rows, original != null ? original.GetLength(0) : 0);
            int minCols = Math.Min(cols, original != null ? original.GetLength(1) : 0);
            for (int i = 0; i < minRows; i++)
                for (int j = 0; j < minCols; j++)
                    newArray[i, j] = original[i, j];

            return newArray;
        }

        public static double Fix(double num)
        {
            return Math.Truncate(num);
        }

        //'--ordinamento SELECTION SORT di Long
        public static void SelSortL(long l, long R, long[] A)
        {

            long i;
            long j;
            long Min;
            long tmp;

            for (i = l; i <= R - 1; i++)
            {// To R - 1

                Min = i;

                for (j = i + 1; j <= R; j++)
                {// To R
                    if (A[j] < A[Min])
                    {
                        Min = j;
                    }
                }

                tmp = A[i];
                A[i] = A[Min];
                A[Min] = tmp;

            }
        }

        /// <summary>
        /// Metodo che applica la Replace ad una stringa in modalità case insensitive.
        /// </summary>
        /// <param name="str"></param>
        /// <param name="oldValue"></param>
        /// <param name="newValue"></param>
        /// <returns></returns>
        public static string ReplaceInsensitive(string str, string oldValue, string newValue)
        {
            int indexOfOldValue = str.ToLower().IndexOf(oldValue.ToLower(), StringComparison.Ordinal);
            if (oldValue == string.Empty)
            {
                return str;
            }
            if (indexOfOldValue == -1)
            {
                return str;
            }
            else
            {
                string substr1 = str[..indexOfOldValue];
                string substr2 = newValue;
                string substr3 = str[(indexOfOldValue + oldValue.Length)..];
                return ReplaceInsensitive(substr1 + substr2 + substr3, oldValue, newValue);
            }
        }

        public static bool IsUrlValid(string url)
        {
            return Uri.IsWellFormedUriString(url, UriKind.Absolute);
        }
        /// <summary>
        /// Funzione EncodeBase64
        /// </summary>
        /// <param name="array"></param>
        /// <returns></returns>
        public static string EncodeBase64(char[] array)
        {
            return Convert.ToBase64String(Encoding.ASCII.GetBytes(array));
        }

        public static double ConvertTicksToMilliSeconds(long timeElapsed)
        {
            return TimeSpan.FromTicks(timeElapsed).TotalMilliseconds;
        }

        public static double ComputeEval(string strExpression)
        {
            object objToReturn = new System.Data.DataTable().Compute(strExpression, "");
            return CDbl(objToReturn);
        }

        public static bool IsMasterPageNew()
        {
            try
            {
                string strTemp = ConfigurationServices.GetKey("LayoutVersion", "");
                if(strTemp == "_masterPageNew")
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch
            {
                return false;
            }
        }

        public static string ExtractTextFromHtml(string? Value)
        {
            string stringToReturn = CStr(Value);

            if (stringToReturn.Contains("<img src=\"../images/Domain/State_ERR.gif\">"))
            {
                return "Error";
            }

            if (stringToReturn.Contains("<img src=\"../images/Domain/State_OK.gif\">"))
            {
                return "Success";
            }

            if (stringToReturn.Contains('>') && stringToReturn.Contains("</"))
            {
                string pattern = @">([^<]+)</";
                Match match = Regex.Match(stringToReturn, pattern);
                if (match.Success)
                {
                    try
                    {
                        string completedText = match.Groups[1].Value.Trim();
                        return HtmlEncode(completedText);
                    }
                    catch { }

                }
            }

            return HtmlEncode(stringToReturn);
        }

    }


}