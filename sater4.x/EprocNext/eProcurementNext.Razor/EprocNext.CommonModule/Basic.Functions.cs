using Microsoft.VisualBasic;
using System.Globalization;

namespace eProcurementNext.CommonModule
{
    public static partial class Basic
    {
        public static bool IsNumeric(dynamic? value)
        {
            if (value is null)
            {
                return false;
            }
            else
            {
                return value is sbyte or byte or short or ushort or int or uint or long or ulong or float or double or decimal;
            }
        }
        public static bool IsNumeric(string value)
        {
            try
            {
                return Information.IsNumeric(value);
            }
            catch
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
        }

        public static int Len(string? str)
        {
            return str?.Length ?? 0;
        }

        public static string UCase(string? str)
        {
            return str is null ? string.Empty : str.ToUpper();
        }

        public static string LCase(string? str)
        {
            return str is null ? string.Empty : str.ToLower();
        }

        public static string ReplaceBr(string variabile, string i, string o)
        {
            var r = Replace(variabile, i, o);
            if (i != Environment.NewLine) return r;
            r = Replace(r, CStr(Strings.Chr(13)), "<br/>");
            r = Replace(r, CStr(Strings.Chr(10)), "<br/>");
            return r;
        }

        public static string Replace(string expression, string find, string replace, int start = 1, int count = -1, CompareMethod compare = CompareMethod.Text)
        {
            if (string.IsNullOrEmpty(expression))
            {
                return string.Empty;
            }
            var output = Strings.Replace(expression, find, replace, start, count, compare);

            return output ?? string.Empty;
        }

        public static int InStr(int start, string? string1, string? string2)
        {
            const int retDefault = -1;
            int retPos;

            //lo start non può essere minore o uguale di 1, in caso di errore forziamo la sua correzione
            if (start < 1)
            {
                start = 1;
            }

            try
            {
                if ((string1 is null) || (string2 is null)) return retDefault;

                retPos = string1.IndexOf(string2, start - 1, StringComparison.Ordinal);
            }
            catch (Exception ex) when (ex is ArgumentOutOfRangeException or ArgumentNullException)
            {
                return retDefault;
            }

            return retPos;
        }

        public static int InStrVb6(int start, string? string1, string? string2)
        {
            return InStr(start, string1, string2) + 1;
        }

        public static string MidVb6(string? stringIn, int start, int length = 0)
        {
            if (string.IsNullOrEmpty(stringIn))
            {
                return string.Empty;
            }

            start--;

            return length <= 0 ? stringIn[start..] : stringIn.Substring(start, length);
        }

        public static Int64 CLng(dynamic str)
        {
            switch (str)
            {
                case null:
                    return 0;
                case DBNull:
                    return 0;
                //Se è già del tipo utile all'output facciamo subito una return
                case long:
                    return str;
                //Se la variabile di input è un int la scaliamo immediatamente ad Int64, non serve fare convert particolari
                case int:
                    return (Int64)str;
                case string when !string.IsNullOrEmpty(str):
                    return Convert.ToInt64(str);
                case string:
                    return 0;
                default:
                    try
                    {
                        return Convert.ToInt64(str);
                    }
                    catch
                    {
                        return 0;
                    }
            }
        }

        public static int CInt(dynamic str)
        {
            try
            {
                switch (str)
                {
                    case null:
                        return 0;
                    case DBNull:
                        return 0;
                    //Se è già del tipo utile all'output facciamo subito una return
                    case int:
                        return str;
                    case string when !string.IsNullOrEmpty(str):
                        return Convert.ToInt32(str);
                    case string:
                        return 0;
                    default:
                        try
                        {
                            return Convert.ToInt32(str);
                        }
                        catch
                        {
                            return 0;
                        }
                }
            }
            catch
            {
                return 0;
            }
        }

        public static string CStr(dynamic? str)
        {
            try
            {
                return str switch
                {
                    null => string.Empty,
                    DBNull => string.Empty,
                    string => str,
                    DateTime => str.ToString("yyyy-MM-ddTHH:mm:ss.fff"),
					_ => Convert.ToString(str)
                };
            }
            catch
            {
                try
                {
                    return str is not null ? (string)str.ToString() : string.Empty;
                }
                catch
                {
                    return string.Empty;
                }
            }
        }

        public static double CDbl(dynamic? str)
        {
            switch (str)
            {
                case null:
                    return 0;
                case DBNull:
                    return 0;
                //Se è già del tipo utile all'output facciamo subito una return
                case double:
                    return str;
                //Se la variabile di input è un int la scaliamo immediatamente ad Int64, non serve fare convert particolari
                case int:
                case long:
                    return (double)str;
                default:
                    try
                    {
                        return Convert.ToDouble(str);
                    }
                    catch
                    {
                        return 0;
                    }
            }
        }

        public static bool CBool(dynamic? str)
        {

            switch (str)
            {
                case null:
                    return false;
                case DBNull:
                    return false;
                //Se è già del tipo utile all'output facciamo subito una return
                case bool:
                    return str;
                case int when str == 1:
                    return true;
                case int:
                    return false;
                default:
                    try
                    {
                        return Convert.ToBoolean(str);
                    }
                    catch
                    {
                        try
                        {
                            return Convert.ToBoolean(CInt(str));
                        }
                        catch
                        {
                            return false;

                        }
                    }

                    break;
            }
        }

        public static string Trim(string? str)
        {
            return string.IsNullOrEmpty(str) ? string.Empty : str.Trim();
        }

        public static bool IsNull(dynamic? value)
        {
            return value is null;
        }

        public static bool IsDbNull(object value)
        {
            return value is DBNull;
        }

        public static bool IsEmpty(dynamic value)
        {
            switch (value)
            {
                case null:
                case string when string.IsNullOrEmpty(value):
                    return true;
                default:
                    return false;
            }
        }

        public static dynamic IIF(bool condition, object valIfTrue, object valIfFalse)
        {
            return condition ? valIfTrue : valIfFalse;
        }

        public static string bonificaHtmlDaXSS(string Value)
        {
            var strDesc = Value;

            //'-- Null breaks up
            strDesc = strDesc.Replace(@"\0", @"");
            //'-- impedisco xss con tentativi di Encoded URI Schemes
            strDesc = strDesc.Replace(@"&#", @"");
            strDesc = strDesc.Replace(@".fromCharCode", @"");
            strDesc = strDesc.Replace(@"\x", @"");
            strDesc = strDesc.Replace(@"\u", @"");
            //'-- impedisco tag injection
            strDesc = strDesc.Replace(@"<script", @"");
            //'strDesc = MyReplace(strDesc, "<meta", "") -- Creava un problema alle email(intranet e/o infomail)
            strDesc = strDesc.Replace(@"</script>", @"");
            //'strDesc = MyReplace(strDesc, "</meta>", "") -- Creava un problema alle email(intranet e/o infomail)
            strDesc = strDesc.Replace(@"<iframe", @"");
            strDesc = strDesc.Replace(@"<frame", @"");
            strDesc = strDesc.Replace(@"<frameset", @"");
            //'strDesc = MyReplace(strDesc, "<body", "")  -- pu� servire nelle email
            strDesc = strDesc.Replace(@"<link", @"");
            //'strDesc = MyReplace(strDesc, "<style", "") -- pu� servire agli RTE
            strDesc = strDesc.Replace(@"<base", @"");
            strDesc = strDesc.Replace(@"<object", @"");
            strDesc = strDesc.Replace(@"<embed", @"");
            strDesc = strDesc.Replace(@"url(", @"");
            strDesc = strDesc.Replace(@"expression(", @"");
            //'strDesc = MyReplace(strDesc, "STYLE=", "") -- pu� servire agli RTE
            strDesc = strDesc.Replace(@"CONTENT=", @"C_O_N_T_E_N_T_=_");
            strDesc = strDesc.Replace(@"DYNSRC=", @"D_Y_N_S_R_C_=_");
            //'-- impedisco l'esecuzione di codice da eventi
            strDesc = strDesc.Replace(@"onclick", @"o_n_c_l_i_c_k");
            strDesc = strDesc.Replace(@"onblur", @"o_n_b_l_u_r");
            strDesc = strDesc.Replace(@"onload", @"o_n_l_o_a_d");
            strDesc = strDesc.Replace(@"onkeypress", @"o_n_k_e_y_p_r_e_s_s");
            strDesc = strDesc.Replace(@"onmouseover", @"o_n_m_o_u_s_e_o_v_e_r");
            strDesc = strDesc.Replace(@"onerror", @"");
            strDesc = strDesc.Replace(@"onAbort", @"");
            strDesc = strDesc.Replace(@"onActivate", @"");
            strDesc = strDesc.Replace(@"onAfterPrint", @"");
            strDesc = strDesc.Replace(@"onAfterUpdate", @"");
            strDesc = strDesc.Replace(@"onBeforeActivate", @"");
            strDesc = strDesc.Replace(@"onBeforeCopy", @"");
            strDesc = strDesc.Replace(@"onBeforeCut", @"");
            strDesc = strDesc.Replace(@"onBeforeDeactivate", @"");
            strDesc = strDesc.Replace(@"onBeforeEditFocus", @"");
            strDesc = strDesc.Replace(@"onBeforePaste", @"");
            strDesc = strDesc.Replace(@"onBeforePrint", @"");
            strDesc = strDesc.Replace(@"onBeforeUpdate", @"");
            strDesc = strDesc.Replace(@"onBeforeUnload", @"");
            strDesc = strDesc.Replace(@"onBegin", @"");
            strDesc = strDesc.Replace(@"onBlur", @"o_n_B_l_u_r");
            strDesc = strDesc.Replace(@"onBounce", @"");
            strDesc = strDesc.Replace(@"onCellChange", @"");
            strDesc = strDesc.Replace(@"onChange", @"o_n_C_h_a_n_g_e");
            strDesc = strDesc.Replace(@"OnClick", @"O_n_C_l_i_c_k");
            strDesc = strDesc.Replace(@"onContextMenu", @"");
            strDesc = strDesc.Replace(@"onControlSelect", @"");
            strDesc = strDesc.Replace(@"onCopy", @"");
            strDesc = strDesc.Replace(@"onCut", @"");
            strDesc = strDesc.Replace(@"onDataAvailable", @"");
            strDesc = strDesc.Replace(@"onDataSetChanged", @"");
            strDesc = strDesc.Replace(@"onDataSetComplete", @"");
            strDesc = strDesc.Replace(@"onDblClick", @"");
            strDesc = strDesc.Replace(@"onDeactivate", @"");
            strDesc = strDesc.Replace(@"onDrag", @"");
            strDesc = strDesc.Replace(@"onDragEnd", @"");
            strDesc = strDesc.Replace(@"onDragLeave", @"");
            strDesc = strDesc.Replace(@"onDragEnter", @"");
            strDesc = strDesc.Replace(@"onDragOver", @"");
            strDesc = strDesc.Replace(@"onDragDrop", @"");
            strDesc = strDesc.Replace(@"onDragStart", @"");
            strDesc = strDesc.Replace(@"onDrop", @"");
            strDesc = strDesc.Replace(@"onEnd", @"");
            strDesc = strDesc.Replace(@"onError", @"");
            strDesc = strDesc.Replace(@"onErrorUpdate", @"");
            strDesc = strDesc.Replace(@"onFilterChange", @"");
            strDesc = strDesc.Replace(@"onFinish", @"");
            strDesc = strDesc.Replace(@"onFocus", @"o_n_F_o_c_u_s");
            strDesc = strDesc.Replace(@"onFocusIn", @"");
            strDesc = strDesc.Replace(@"onFocusOut", @"");
            strDesc = strDesc.Replace(@"onHashChange", @"");
            strDesc = strDesc.Replace(@"onHelp", @"");
            strDesc = strDesc.Replace(@"onInput", @"");
            strDesc = strDesc.Replace(@"onKeyDown", @"o_n_K_e_y_D_o_w_n");
            strDesc = strDesc.Replace(@"onKeyPress", @"o_n_K_e_y_P_r_e_s_s");
            strDesc = strDesc.Replace(@"onKeyUp", @"o_n_K_e_y_U_p");
            strDesc = strDesc.Replace(@"onLayoutComplete", @"");
            strDesc = strDesc.Replace(@"onLoad", @"");
            strDesc = strDesc.Replace(@"onLoseCapture", @"");
            strDesc = strDesc.Replace(@"onMediaComplete", @"");
            strDesc = strDesc.Replace(@"onMediaError", @"");
            strDesc = strDesc.Replace(@"onMessage", @"");
            strDesc = strDesc.Replace(@"onMouseDown", @"");
            strDesc = strDesc.Replace(@"onMouseEnter", @"");
            strDesc = strDesc.Replace(@"onMouseLeave", @"");
            strDesc = strDesc.Replace(@"onMouseMove", @"");
            strDesc = strDesc.Replace(@"onmouseout", @"");
            strDesc = strDesc.Replace(@"onmouseover", @"");
            strDesc = strDesc.Replace(@"onMouseUp", @"");
            strDesc = strDesc.Replace(@"onMouseWheel", @"");
            strDesc = strDesc.Replace(@"onMove", @"");
            strDesc = strDesc.Replace(@"onMoveEnd", @"");
            strDesc = strDesc.Replace(@"onMoveStart", @"");
            strDesc = strDesc.Replace(@"onOffline", @"");
            strDesc = strDesc.Replace(@"onOnline", @"");
            strDesc = strDesc.Replace(@"onOutOfSync", @"");
            strDesc = strDesc.Replace(@"onPaste", @"");
            strDesc = strDesc.Replace(@"onPause", @"");
            strDesc = strDesc.Replace(@"onPopState", @"");
            strDesc = strDesc.Replace(@"onProgress", @"");
            strDesc = strDesc.Replace(@"onPropertyChange", @"");
            strDesc = strDesc.Replace(@"onReadyStateChange", @"");
            strDesc = strDesc.Replace(@"onRedo", @"");
            strDesc = strDesc.Replace(@"onRepeat", @"");
            strDesc = strDesc.Replace(@"OnReset", @"");
            strDesc = strDesc.Replace(@"onResize", @"");
            strDesc = strDesc.Replace(@"onResizeEnd", @"");
            strDesc = strDesc.Replace(@"onResizeStart", @"");
            strDesc = strDesc.Replace(@"onResume", @"");
            strDesc = strDesc.Replace(@"onReverse", @"");
            strDesc = strDesc.Replace(@"onRowsEnter", @"");
            strDesc = strDesc.Replace(@"onRowExit", @"");
            strDesc = strDesc.Replace(@"onRowDelete", @"");
            strDesc = strDesc.Replace(@"onRowInserted", @"");
            strDesc = strDesc.Replace(@"onScroll", @"");
            strDesc = strDesc.Replace(@"onSeek", @"");
            strDesc = strDesc.Replace(@"onSelect", @"");
            strDesc = strDesc.Replace(@"onSelectionChange", @"");
            strDesc = strDesc.Replace(@"onSelectStart", @"");
            strDesc = strDesc.Replace(@"onStart", @"");
            strDesc = strDesc.Replace(@"onStop", @"");
            strDesc = strDesc.Replace(@"onStorage", @"");
            strDesc = strDesc.Replace(@"onSyncRestored", @"");
            strDesc = strDesc.Replace(@"OnSubmit", @"");
            strDesc = strDesc.Replace(@"onTimeError", @"");
            strDesc = strDesc.Replace(@"onTrackChange", @"");
            strDesc = strDesc.Replace(@"onUndo", @"");
            strDesc = strDesc.Replace(@"onUnload", @"");
            strDesc = strDesc.Replace(@"onURLFlip", @"");
            strDesc = strDesc.Replace(@"seekSegmentTime", @"");
            strDesc = strDesc.Replace(@"background-Image:", ""); //'unicoded XSS exploit
            strDesc = strDesc.Replace(@"script:", @"");
            strDesc = strDesc.Replace(@"pt:", @"");
            strDesc = strDesc.Replace(@"vbscript:", @"");
            strDesc = strDesc.Replace(@"livescript:", @"");
            strDesc = strDesc.Replace(@"com:time", @"");
            strDesc = strDesc.Replace(@"xss", @"");
            strDesc = strDesc.Replace(@"#exec", @"");
            strDesc = strDesc.Replace(@".js", @"");

            return strDesc;
        }

        public static string Left(string input, int len)
        {
            if (string.IsNullOrEmpty(input))
                return string.Empty;

            if (len > input.Length)
                len = input.Length;

            return input[..len];
        }
        public static string Right(string input, int count)
        {
            return input.Substring(Math.Max(input.Length - count, 0), Math.Min(count, input.Length));
        }

        public static long DateDiff(string interval, DateTime date1, DateTime date2)
        {
            return DateAndTime.DateDiff(interval, date1, date2);
        }
        /// <summary>
        /// Metodo redim preserve  
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="original">Matrice</param>
        /// <param name="cols">colonne</param>
        /// <param name="rows">righe </param>
        /// <returns>Nuova Matrice con i Valori  Riassagnati</returns>
        public static T[,] ArrayRedimPreserve<T>(T[,] original, int cols, int rows)
        {
            var newArray = new T[rows, cols];
            var minRows = Math.Min(rows, original.GetLength(0));
            var minCols = Math.Min(cols, original.GetLength(1));
            for (var i = 0; i < minRows; i++)
            {
                for (var j = 0; j < minCols; j++)
                {
                    newArray[i, j] = original[i, j];
                }
            }
            return newArray;
        }
        public static bool IsDate(dynamic? Value)
        {
            DateTime dateTime;
            bool isDateTime = false;
            string[] format = new string[] { "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd" };

            if (Value is null)
            {
                return false;
            }

            if (Value is string)
            {
                if (string.IsNullOrEmpty(Value))
                {
                    return false;
                }

                isDateTime = DateTime.TryParseExact(Value, format, System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.NoCurrentDateDefault, out dateTime);

                return isDateTime;
            }

            if (Value is DateTime)
            {
                isDateTime = true;
            }

            return isDateTime;
        }

        public static string ValueToString(dynamic value)
        {
            if (value == null)
            {
                return "";
            }

            if (IsNumeric(value))
            {
                return String.Format("{0:N}", value.ToString());
                //return value.ToString("#,###.##", CultureInfo.InvariantCulture).Replace(",", "");
                
            }
            else if (value.GetType() == typeof(DateTime))
            {
                return value.ToString("yyyy-MM-dd HH:mm:ss.fff");
            }

            return value.ToString();
        }

    }
}