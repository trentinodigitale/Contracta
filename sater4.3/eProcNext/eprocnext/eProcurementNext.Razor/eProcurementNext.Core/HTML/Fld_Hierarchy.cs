using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using System.Net;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class Fld_Hierarchy : Field, IField
    {
        public string SelectDescription;        //'-- stringa per l'elemento ' -- Effettuare una selezione --

        public int Height;                      //'-- determina l'altezza della finestra per la selezione

        public bool SelectOnlyChild;            //'-- indica se solo i nodi figli possono essere selezionati
        public bool SelectNoRoot;               //'-- indica se la radice � selezionabile

        //private response As Object//Non viene usato nella classe

        private string mp_strFilter;
        private string mp_strSepFilter;
        private bool mp_InOutFilter;

        private long mp_indexToDraw;
        private long mp_MaxIndexToDraw;
        private CommonModule.IEprocResponse mp_objResp;

        public string PrintDescription;//'-- stringa per l'elemento 'Vedi allegato xxx' nella stampa quando multivalue
        public string SelezionatiDescription;//'-- stringa per l'elemento 'N Selezionati' per il multivalore
        public string senzaModali;//'-- 1 i nuovi multivalore si aprono in un popup, 0 si aprono in una modale
        public string mp_caption;//'--Stringa per la caption del field

        private bool PrintMode;

        private readonly CommonDbFunctions cdf = new();

        public Fld_Hierarchy()
        {
            /* nel costruttore di tutti i field va inizializzato l'mp_itype con il proprio tipo di riferimento */
            this.mp_iType = 5;
            PathImage = "../CTL_Library/images/Domain/";
            Style = "FldHier";
            Editable = true;
            SelectDescription = "-- Effettuare una selezione --";
            SelectOnlyChild = true;
            SelectNoRoot = true;
            MultiValue = 0;
            PrintDescription = "Vedi allegato";
            SelezionatiDescription = "Selezionati";
            PrintMode = false;
        }

        public override void CaptionHtmlCenter(CommonModule.IEprocResponse objResp)
        {
            if (Editable)
            {
                objResp.Write($@" for=""" + HtmlEncodeValue(Name) + @"_edit_new""");
            }
            else
            {
                if (!string.IsNullOrEmpty(strFormat) && !strFormat.Contains("T", StringComparison.Ordinal) && mp_iType == 5)
                {
                    objResp.Write($@" for=""" + HtmlEncodeValue(Name) + @"""");
                }
            }
        }
        public override void Html(IEprocResponse objResp, bool? pEditable = null)
        {
            DomElem? elem;
            int iZ;
            int nC;
            string strTmpWidth;
            string funzioneJS;

            bool? vEditable = Editable;

            if (pEditable != null)
            {
                vEditable = pEditable;
            }

            if (strFormat is null)
            {
                strFormat = string.Empty;
            }

            string strDescDominio = string.Empty;

            if (vEditable == false)
            {
                if (!strFormat.Contains('H', StringComparison.Ordinal))
                {
                    if (strFormat.Contains('T', StringComparison.Ordinal))
                    {
                        //'-- disegno il controllo nascosto NON messo a disabled (lo mando in post)
                        objResp.Write($@"<input type=""hidden"" name=""{Name}""  id=""{Name}"" ");

                        objResp.Write($@" class=""display_none attrib_base""");

                        objResp.Write($@" value=""" + HtmlEncodeValue(CStr(this.Value)) + @""" ");
                        objResp.Write($@"/>" + Environment.NewLine);
                    }
                    else
                    {
                        objResp.Write($@"<input disabled=""disabled"" type=""text"" name=""" + Name + @"""  id=""" + Name + @""" ");

                        objResp.Write($@" class=""display_none""");

                        objResp.Write($@" value=""" + HtmlEncodeValue(CStr(this.Value)) + @""" ");
                        objResp.Write($@"/>" + Environment.NewLine);
                    }
                }

                if (string.IsNullOrEmpty(CStr(this.Value)))
                {
                    if (IsMasterPageNew())
                    {
                        objResp.Write("<span>&nbsp;</span>");
                    }
                    else
                    {
                        objResp.Write("&nbsp;");

                    }
                }
                else
                {
                    //'-- Verifico se il field è multivalue sia dall'attributo field sia dalla FORMAT
                    if (MultiValue == 0 && !strFormat.Contains('M', StringComparison.Ordinal))
                    {
                        elem = Domain != null ? (DomElem?)Domain.FindCode(CStr(Value)) : null;
                        if (elem != null)
                        {
                            //'-- controllo se mettere il tooltip
                            iZ = InStrVb6(1, strFormat, "Z");
                            if (iZ > 0)
                            {
                                nC = CInt(MidVb6(strFormat, iZ + 1, 2));
                            }
                            else
                            {
                                nC = 32000;
                            }

                            string strDesc;

                            strDesc = FormattedElem("", elem.CodExt, elem.Desc, strFormat);

                            if (strDesc.Length > nC)
                            {
                                objResp.Write($@"<span ");

                                objResp.Write($@"title=""" + HtmlEncodeValue(strDesc.Replace("<br/>", Environment.NewLine)) + @"""");

                                objResp.Write($@" class=""Fld_Hierarchy_label"">");

                                strDesc = $"{Left(strDesc, nC - 1)}...";

                                objResp.Write(HtmlEncode(strDesc));

                                objResp.Write($@"</span>");
                            }
                            else
                            {
                                if (IsMasterPageNew())
                                {
                                    objResp.Write($@" <span class=""Text"" title=""" + HtmlEncodeValue(strDesc) + $@""">" + HtmlEncodeValue(strDesc) + "</span>");
                                }
                                else
                                {
                                    objResp.Write(HtmlEncodeValue(strDesc));
                                }

                            }
                        }
                        else
                        {
                            iZ = InStrVb6(1, strFormat, "V");
                            if (iZ > 0)
                            {
                                objResp.Write(HtmlEncode(CStr(Value)));
                            }
                            else
                            {
                                objResp.Write($@"N.C.");
                            }

                        }
                    }
                    else
                    {
                        //'-- gestione multivalore non editabile
                        string strParam = "SelectOnlyChild=" + IIF(SelectOnlyChild, "1", "0") + "&SelectNoRoot=" + IIF(SelectNoRoot, "1", "0") + "&PathImage=" + WebUtility.UrlEncode(PathImage);

                        //'-- lascio questa hidden _edit per la retrocompatibilit�
                        objResp.Write($@"<input type=""hidden"" name=""" + Name + @"_edit"" id=""" + Name + @"_edit"" value=""" + HtmlEncodeValue(strDescDominio) + @"""  class=""" + Style + @"_edit""/>");

                        if (!string.IsNullOrEmpty(Value))
                        {
                            if (IsMasterPageNew())
                            {
                                objResp.Write($@"<table>");
                                objResp.Write($@"<tr>");
                                objResp.Write($@"<td class=""p0important"">");
                            }
                            else
                            {
                                objResp.Write($@"<table width=""100%"">");
                                objResp.Write($@"<tr>");
                                objResp.Write($@"<td width=""100%"" align=""right"">");
                            }

                            objResp.Write($@"<span ");

                            objResp.Write($@"id=""" + Name + @"_edit_new"" title=""" + HtmlEncodeValue(strDescDominio.Replace(";", Environment.NewLine)) + @""" ");

                            objResp.Write($@" class=""Fld_Hierarchy_label_width"">");

                            //'-- Se format a L faccio vedere al posto di 'N selezionati' la lista dei valori scelti
                            iZ = InStrVb6(1, strFormat, "L");
                            if (iZ > 0)
                            {
                                string tmpStrDesc;
                                tmpStrDesc = DescMultivalue();
                                objResp.Write(HtmlEncode(CStr(tmpStrDesc)).Replace(@"&lt;br/&gt;", @"<br/>"));
                            }
                            else
                            {
                                string tempValue = getMultivalueDesc(strFormat);
                                objResp.Write(HtmlEncode(tempValue));
                            }

                            objResp.Write($@"</span>");

                            objResp.Write($@"</td>");
                            if (IsMasterPageNew())
                            {
                                objResp.Write($@"<td class=""p0important"">");
                            }
                            else
                            {
                                objResp.Write($@"<td align=""left"">");
                            }

                            string srcFram;
                            srcFram = @"./LoadExtendedAttrib.asp?MultiValue=" + MultiValue + @"&titoloFinestra=" + UrlEncode(mp_caption) + @"&TypeAttrib=5&IdDomain=" + UrlEncode(Domain.Id) + @"&Attrib=" + UrlEncode(Name) + @"&Format=" + UrlEncode(strFormat) + @"&Editable=" + vEditable + @"&Suffix=&Filter=" + Domain.Filter + @"&" + strParam + @"&Value=";

                            if (senzaModali == "1")
                            {
                                funzioneJS = "openHierarchyPopup";
                            }
                            else
                            {
                                funzioneJS = "openDocModal";
                            }

                            //'-- link per aprire la lightbox/modale con il dominio gerarchico
                            if (IsMasterPageNew())
                            {
                                objResp.Write($@"<input type=""button"" class=""FldExtDom_button DomGerFaseII"" alt=""Inserisci valore"" value="" ... ""  id=""" + Name + @"_button"" name=""" + Name + @"_button"" onclick=""" + HtmlEncode(funzioneJS + @"('" + EscapeSequenceJS(Name) + @"','" + EscapeSequenceJS(HtmlEncodeValue(srcFram)) + @"', 'dialog-if (rame-" + Domain.Id + "');") + @"""/>" + Environment.NewLine);
                            }
                            else
                            {
                                objResp.Write($@"<input type=""button"" class=""FldExtDom_button"" alt=""Inserisci valore"" value="" ... ""  id=""" + Name + @"_button"" name=""" + Name + @"_button"" onclick=""" + HtmlEncode(funzioneJS + @"('" + EscapeSequenceJS(Name) + @"','" + EscapeSequenceJS(HtmlEncodeValue(srcFram)) + @"', 'dialog-if (rame-" + Domain.Id + "');") + @"""/>" + Environment.NewLine);
                            }

                            objResp.Write($@"</td>");
                            objResp.Write($@"</tr>");
                            objResp.Write($@"</table>");
                        }
                    }
                }
            }
            else
            {
                //On Error Resume Next

                if (string.IsNullOrEmpty(Value))
                {
                    strDescDominio = SelectDescription;
                }
                else
                {
                    if (MultiValue == 0 && strFormat != null && !strFormat.Contains("M", StringComparison.Ordinal))
                    {
                        elem = Domain != null ? (DomElem?)Domain.FindCode(CStr(Value)) : null;
                        if (elem != null)
                        {
                            strDescDominio = FormattedElem("", elem.CodExt, elem.Desc, strFormat);
                        }
                        else
                        {
                            strDescDominio = "N.C.";
                        }
                    }
                    else
                    {
                        strDescDominio = DescMultivalue();
                        if (!string.IsNullOrEmpty(strDescDominio))
                        {
                            strDescDominio = HtmlEncodeValue(strDescDominio);
                        }
                        else
                        {
                            strDescDominio = "N.C.";
                        }
                    }
                }

                string param = "SelectOnlyChild=" + IIF(SelectOnlyChild, "1", "0") + "&SelectNoRoot=" + IIF(SelectNoRoot, "1", "0") + "&PathImage=" + UrlEncode(PathImage);

                //'-- disegna il controllo nascosto
                objResp.Write(Environment.NewLine);
                //'-- disegno il controllo nascosto
                objResp.Write($@"<input");

                objResp.Write($@" type=""hidden"" ");

                objResp.Write($@" class=""display_none attrib_base""");

                objResp.Write($@" id=""" + HtmlEncodeValue(Name) + @""" name=""" + HtmlEncodeValue(Name) + @""" value=""" + HtmlEncodeValue(CStr(Value)) + @"""/>" + Environment.NewLine);

                //'-- inserisco un input hidden contenente informazioni tecniche di varia natura. questo per eliminare
                //'-- attributi non esistenti nello standard w3c. Gli attributi estesi saranno presenti come value
                //'-- della input hidden nella forma nomeAttributo#=#valoreAttributo#@#nomeAttributo#=#valoreAttributo
                objResp.Write($@"<input type=""hidden"" id=""" + Name + @"_extraAttrib"" value=""strformat#=#" + HtmlEncodeValue(CStr(strFormat)) + @"#@#filter#=#" + HtmlEncodeValue(CStr(Domain.Filter)) + "#@#multivalue#=#" + HtmlEncodeValue(CStr(MultiValue)) + @"""/>");

                objResp.Write($@"<table>");
                objResp.Write($@"<tr>");
                objResp.Write($@"<td align=""right"">");
                dynamic tempValue = "";
                //'primo campo contiene esito della selezione
                if (MultiValue == 1 || strFormat.Contains("M", StringComparison.Ordinal))
                {
                    tempValue = getMultivalueDesc(strFormat);

                    //'-- lascio questa hidden _edit per la retrocompatibilit�
                    objResp.Write($@"<input type=""hidden"" name=""" + Name + @"_edit"" id=""" + Name + @"_edit"" value=""" + HtmlEncodeValue(strDescDominio) + @"""  class=""" + Style + @"_edit"" ");

                    if (!string.IsNullOrEmpty(mp_OnChange))
                    {
                        objResp.Write($@" onchange=""" + mp_OnChange + @""" ");
                    }

                    objResp.Write($@"/>");

                    //'-- Se format a L faccio vedere al posto di 'N selezionati' la lista dei valori scelti
                    iZ = InStrVb6(1, strFormat, "L");
                    if (iZ > 0)
                    {
                        tempValue = strDescDominio;
                    }

                    objResp.Write($@"<input type=""text"" autocomplete=""off"" name=""" + HtmlEncodeValue(Name) + @"_edit_new"" id=""" + HtmlEncodeValue(Name) + @"_edit_new"" title= """ + HtmlEncode(Replace(Replace(strDescDominio, ";", Environment.NewLine), "</br>", Environment.NewLine)) + @""" class=""" + Style + @"_edit_new"" ");
                    if (IsMasterPageNew())
                    {
                        objResp.Write($@"value=""" + HtmlEncodeValue(CStr(tempValue)) + @"""  ");
                    }
                    else
                    {
                        objResp.Write($@"size=""" + width + @""" value=""" + HtmlEncodeValue(CStr(tempValue)) + @"""  ");

                    }

                    //'-- se � presente il paramtro che attiva la ricerca dal campo text
                    if (strFormat.Contains("R", StringComparison.Ordinal))
                    {
                        objResp.Write($@" onchange=""hierarchy_onChangeBase('" + EscapeSequenceJS(Name) + @"','');"" ");
                        objResp.Write($@" onfocus=""hierarchy_focus('" + EscapeSequenceJS(Name) + @"','');"" ");
                        objResp.Write($@" onblur=""hierarchy_lostFocus('" + EscapeSequenceJS(Name) + @"','', false);"" ");
                        objResp.Write($@" onkeydown=""hierarchy_keyDown(event,'" + EscapeSequenceJS(Name) + @"' );"" ");
                        objResp.Write($@" onkeyup=""hierarchy_keyUp('" + EscapeSequenceJS(Name) + @"','', event, '" + EscapeSequenceJS(CStr(Domain.Id)) + "','" + EscapeSequenceJS(CStr(Domain.Filter)) + @"');"" />");
                    }
                    else
                    {
                        //'-- di default la ricerca sui gerarchici non � attiva (dobbiamo prima gestire
                        //'-- il problema dei nodi non selezionabili anche tramite la ricerca)
                        objResp.Write($@" readonly=""readonly"" />");
                    }
                }
                else
                {
                    //'-- Per la retro-compatibilit�
                    objResp.Write($@"<input type=""hidden"" name=""" + Name + @"_edit"" id=""" + Name + @"_edit"" value=""" + HtmlEncodeValue(strDescDominio) + @"""  class=""" + Style + @"_edit"" ");

                    if (!string.IsNullOrEmpty(mp_OnChange))
                    {
                        objResp.Write($@" onchange=""" + mp_OnChange + @""" ");
                    }

                    objResp.Write($@"/>");

                    objResp.Write($@"<input type=""text"" autocomplete=""off"" name=""" + HtmlEncodeValue(Name) + @"_edit_new"" id=""" + HtmlEncodeValue(Name) + @"_edit_new"" title=""" + HtmlEncode(Replace(strDescDominio, ";", Environment.NewLine)) + @""" class=""" + Style + @"_edit_new"" ");
                    if (IsMasterPageNew())
                    {
                        objResp.Write($@"value=""" + HtmlEncodeValue(CStr(strDescDominio)) + @""" ");
                    }
                    else
                    {
                        objResp.Write($@"size=""" + width + @""" value=""" + HtmlEncodeValue(CStr(strDescDominio)) + @""" ");

                    }

                    //'-- se � presente il paramtro che attiva la ricerca dal campo text
                    if (strFormat.Contains("R", StringComparison.Ordinal))
                    {

                        objResp.Write($@" onchange=""hierarchy_onChangeBase('" + EscapeSequenceJS(Name) + @"','');"" ");
                        objResp.Write($@" onfocus=""hierarchy_focus('" + EscapeSequenceJS(Name) + @"','');"" ");
                        objResp.Write($@" onblur=""hierarchy_lostFocus('" + EscapeSequenceJS(Name) + @"','', false);"" ");
                        objResp.Write($@" onkeydown=""hierarchy_keyDown(event,'" + EscapeSequenceJS(Name) + @"' );"" ");
                        objResp.Write($@" onkeyup=""hierarchy_keyUp('" + EscapeSequenceJS(Name) + @"','', event, '" + EscapeSequenceJS(CStr(Domain.Id)) + @"','" + EscapeSequenceJS(CStr(Domain.Filter)) + @"');"" />");
                    }
                    else
                    {
                        //'-- di default la ricerca sui gerarchici non � attiva (dobbiamo prima gestire
                        //'-- il problema dei nodi non selezionabili anche tramite la ricerca)
                        objResp.Write($@" readonly=""readonly"" />");
                    }
                }

                objResp.Write($@"</td>");
                objResp.Write($@"<td align=""left"">");

                string srcFrame;
                srcFrame = @"./LoadExtendedAttrib.asp?MultiValue=" + MultiValue + "&titoloFinestra=" + UrlEncode(mp_caption) + "&TypeAttrib=5&IdDomain=" + UrlEncode(Domain.Id) + "&Attrib=" + UrlEncode(Name) + "&Format=" + UrlEncode(strFormat) + "&Editable=" + vEditable + "&Suffix=&Filter=" + Domain.Filter + "&" + param + "&Value=";

                if (senzaModali == "1")
                {

                    funzioneJS = "openHierarchyPopup";
                }
                else
                {
                    funzioneJS = "openDocModal";
                }

                //'-- link per aprire la lightbox/modale con il dominio gerarchico
                objResp.Write($@"<input type=""button"" class=""FldExtDom_button"" alt=""Inserisci valore"" ");
                objResp.Write($@" onblur=""hierarchy_lostFocus('" + EscapeSequenceJS(Name) + @"','', true);"" ");
                objResp.Write($@" value="" ... ""  id=""" + Name + @"_button"" name=""" + HtmlEncodeValue(Name) + @"_button"" ");

                objResp.Write($@" onclick=""");

                objResp.Write(funzioneJS + "('" + EscapeSequenceJS(Name) + "','" + HtmlEncode(EscapeSequenceJS(HtmlEncodeValue(srcFrame))) + @"', 'dialog-if (rame-" + Domain.Id + @"');"" />" + Environment.NewLine);

                objResp.Write($@"</td>");
                objResp.Write($@"</tr>");
                objResp.Write($@"</table>");
            }
        }

        public override void HtmlExtended(IEprocResponse objResp, dynamic? Request = null) { }
        public override void HtmlExtended2(IEprocResponse objResp, dynamic? Request = null, dynamic? session = null)
        {
            if (Domain.GetRsElem() == null)
            {
                mp_MaxIndexToDraw = Domain.Elem.Count;
            }
            else
            {
                mp_MaxIndexToDraw = Domain.GetRsElem().RecordCount;
            }
            mp_indexToDraw = 0;

            string FORMATO;
            int indW;
            int iWinHeight;
            iWinHeight = 0;
            long identity;
            identity = 0;

            if (Request != null)
            {
                SelectOnlyChild = GetParamURL(Request, "SelectOnlyChild");
                SelectNoRoot = GetParamURL(Request, "SelectNoRoot");
                PathImage = GetParamURL(Request, "PathImage");
                FORMATO = GetParamURL(Request, "STRFORMAT");
                indW = InStrVb6(1, FORMATO, "W");
                if (indW > 0)
                {
                    iWinHeight = CInt(MidVb6(FORMATO, indW + 1, 3));
                }
                identity = GetParamURL(Request, "Num");
            }

            double MaxH = 200;
            //On Error Resume Next
            int hRow = 30;

            MaxH = mp_MaxIndexToDraw * hRow;

            if (iWinHeight > 0)
            {
                MaxH = iWinHeight;
            }

            if (MultiValue == 1 || strFormat.Contains("M", StringComparison.Ordinal))
            {
                MaxH = MaxH + 130;
            }
            //err.Clear
            //On Error GoTo 0
            if (MaxH > 500)
            {
                Height = 500;
            }
            else
            {
                Height = CInt(MaxH);
            }

            //'-- disegna un frame nascosto dove invocare i comandi del controllo per continaure il disegno della gerarchia
            objResp.Write($@"<div id=""ObjectAttribExtended"" name=""ObjectAttribExtended"" style=""width: 100%; height: " + Height + @""" >");
            objResp.Write($@"<table border=0 width=""100%"" height=""" + Height + @"""  cellspacing=""0"" cellpadding=""0"" class=""" + Style + @"_border"" ");

            if (MultiValue == 0 && !strFormat.Contains("M", StringComparison.Ordinal))
            {
                objResp.Write($@" onblur=""javascript:FldExtHierarchyOnBlur( this , '" + Name + @"' );"" >");
            }
            else
            {
                objResp.Write($@" >");
            }

            objResp.Write($@"<tr><td width=""100%"" height=""100%"" valign=""top"" >");
            objResp.Write($@"<div id=""ObjectAttribExtended_int"" name=""ObjectAttribExtended_int"" style=""width: 100%; height: 100%; overflow: auto;"">");
            objResp.Write($@"<table width=""100%"" height=""100%"" >");

            //'-- se non � multivalore disegna la riga per la selezione
            if (MultiValue == 0 && !strFormat.Contains("M", StringComparison.Ordinal))
            {
                objResp.Write($@"<tr>");
                objResp.Write($@"<td class=""" + Style + @"_selectable"" id=""" + Name + "_" + @""" name=""" + Name + "_" + @""" onclick=""javascript:HierarchySelectNode( '" + Name + @"' ,'' );"" ");
                objResp.Write($@" onMouseOver=""setClassName(this, '" + Style + @"_selectableMouseOver');"" ");
                objResp.Write($@" onMouseOut=""setClassName(this, '" + Style + @"_selectable');"" ");
                objResp.Write($@" >" + SelectDescription);
                objResp.Write($@"</td></tr>");
            }

            objResp.Write($@"<tr><td width=""100%"" height=""100%"" valign=""top"" >");

            mp_objResp = objResp;
            DrawRamo("", "", 0);

            objResp.Write($@"</table>");
            objResp.Write($@"</div>");
            objResp.Write($@"</td></tr>");

            //'-- se � multivalore disegno l'area delle selezioni
            if (MultiValue == 1 || strFormat.Contains("M", StringComparison.Ordinal))
            {
                objResp.Write($@"<tr><td width=""100%"" valign=""top"" >");
                displayMultivalueEditable(objResp, session);
                objResp.Write($@"</td></tr>");
                if (identity > 0)
                {
                    objResp.Write($@"<script>FirstLoad( '" + GetParamURL(Request, "Attrib") + @"' , '" + Domain.Id + @"','5' , " + identity + @" );</script>");
                }
            }

            objResp.Write($@"</table></div>");
        }
        public override void HtmlExtended3(IEprocResponse objResp, dynamic? Request = null, dynamic? session = null)
        {
            if (Domain.GetRsElem() == null)
            {
                mp_MaxIndexToDraw = Domain.Elem.Count;
            }
            else
            {
                mp_MaxIndexToDraw = Domain.GetRsElem().RecordCount;
            }

            mp_indexToDraw = 0;

            string FORMATO;
            int indW;
            int iWinHeight;
            iWinHeight = 0;
            long identity = 0;

            if (Request is not null)
            {
                SelectOnlyChild = cdf.ParseBool(GetParamURL(Request, "SelectOnlyChild"));
                SelectNoRoot = cdf.ParseBool(GetParamURL(Request, "SelectNoRoot"));
                PathImage = GetParamURL(Request, "PathImage");
                FORMATO = GetParamURL(Request, "STRFORMAT");
                indW = InStrVb6(1, FORMATO, "W");
                if (indW > 0)
                {
                    iWinHeight = CInt(MidVb6(FORMATO, indW + 1, 3));
                }
                identity = CLng(GetParamURL(Request, "Num"));
            }

            //'-- Sovrascrivo il pathImage. Imposto il percorso corretto. La pagina non cambia mai quindi non serve recuperare pathImage
            PathImage = "../CTL_Library/images/Domain/";

            double MaxH;
            MaxH = 200;
            //On Error Resume Next
            int hRow;
            hRow = 30;

            MaxH = mp_MaxIndexToDraw * hRow;

            if (iWinHeight > 0)
            {
                MaxH = iWinHeight;
            }

            if (MultiValue == 1 || strFormat.Contains("M", StringComparison.Ordinal))
            {
                MaxH = MaxH + 130;
            }
            //err.Clear
            //On Error GoTo 0
            if (MaxH > 500)
            {
                Height = 500;
            }
            else
            {
                Height = CInt(MaxH);
            }

            //'-- se non � multivalore disegna la riga per la selezione
            if (MultiValue == 0 && !strFormat.Contains("M", StringComparison.Ordinal))
            {

                //'---

            }

            mp_objResp = objResp;

            DrawRamoNew("", "", 0);

            //'-- se � multivalore disegno l'area delle selezioni
            if (MultiValue == 1 || strFormat.Contains("M", StringComparison.Ordinal))
            {

            }
        }
        public override void Init(int iType, string oName = "", object? oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false)
        {
            base.Init(iType, oName, oValue, oDom, oumDom, oFormat, oEditable, oObbligatory, oValidazioneFormale);

            Domain = oDom;
            strFormat = oFormat;
            Editable = oEditable;
            mp_caption = "";

            if (strFormat.Contains("A", StringComparison.Ordinal))
            {
                SelectOnlyChild = false;
            }

            if (strFormat.Contains("R", StringComparison.Ordinal))
            {
                SelectNoRoot = false;
            }

            if (strFormat.Contains("M", StringComparison.Ordinal))
            {
                MultiValue = 1;
            }
        }
        public override void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/")
        {
            if (!js.ContainsKey("replaceExtended"))
            {
                js.Add("replaceExtended", $@"<script src=""" + Path + $@"jscript/replaceExtended.JS"" ></script>");
            }
            if (!js.ContainsKey("getObj"))
            {
                js.Add("getObj", $@"<script src=""" + Path + $@"jscript/getObj.js"" ></script>");
            }
            if (!js.ContainsKey("GetPosition"))
            {
                js.Add("GetPosition", $@"<script src=""" + Path + $@"jscript/GetPosition.js"" ></script>");
            }
            if (!js.ContainsKey("setVisibility"))
            {
                js.Add("setVisibility", $@"<script src=""" + Path + $@"jscript/setVisibility.js"" ></script>");
            }
            if (!js.ContainsKey("setClassName"))
            {
                js.Add("setClassName", $@"<script src=""" + Path + $@"jscript/setClassName.js"" ></script>");
            }
            if (!js.ContainsKey("FldHierarchy"))
            {
                js.Add("FldHierarchy", $@"<script src=""" + Path + $@"jscript/Field/FldHierarchy.js"" ></script>");
            }
            if (!js.ContainsKey("SearchDocumentForExtendeAttrib"))
            {
                js.Add("SearchDocumentForExtendeAttrib", $@"<script src=""" + Path + $@"jscript/Field/SearchDocumentForExtendeAttrib.js"" ></script>");
            }
        }
        public override dynamic? RSValue()
        {
            Value = base.RSValue();
            return Value;
        }
        public override void SetFilterDomain(string strFilter, string strSep = ",", bool InOut = true)
        {
            mp_strFilter = strFilter;
            mp_strSepFilter = strSep;
            mp_InOutFilter = InOut;
        }
        public override void SetPrintDescription(string str)
        {
            this.PrintDescription = str;
        }
        public override void SetSelectDescription(string str)
        {
            this.SelectDescription = str;
        }
        public override void SetSelezionatiDescription(string str)
        {
            this.SelezionatiDescription = str;
        }
        public override void SetSenzaModali(string str)
        {
            this.senzaModali = str;
        }
        public override string SQLValue()
        {
            this.Value = base.SQLValue();
            return "'" + CStr(this.Value).Replace("'", "''") + "'";
        }
        public override string TechnicalValue()
        {
            return IIF(IsNull(this.Value), "", CStr(this.Value));
        }
        public override void toPrint(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.toPrint(objResp, pEditable);
            if (mp_row != null)
            {
                this.Name = mp_row.Replace("_", " ") + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            }

            this.Value = IIF(IsNull(Value), "", Value);

            if (mp_row != null)
            {
                this.mp_caption = mp_row.Replace("_", " ") + " " + Caption;
            }
            else
            {
                this.mp_caption = " " + Caption;
            }

            PrintMode = true;

            if (!string.IsNullOrEmpty(CStr(this.Value)))
            {

                if (MultiValue == 0 && !strFormat.Contains("M", StringComparison.Ordinal))
                {
                    this.Html(objResp, pEditable);
                }
                else
                {
                    int indice;
                    int limite;

                    limite = 0;
                    indice = 0;
                    indice = InStrVb6(1, this.strFormat, "S");
                    //'--SE NON TROVA LA S provo a vedere la E, lasciamo la S per compatibilit� con il vecchio ma si deve usare la E
                    if (indice == 0)
                    {
                        indice = InStrVb6(1, this.strFormat, "E");
                    }
                    //On Error Resume Next

                    if (indice > 0)
                    {
                        try
                        {
                            //'-- mi aspetto un limite sulla numerosit� del tipo :
                            //'-- S20 oppure S05 (zero cinque)
                            if (IsNumeric(MidVb6(strFormat, indice + 1, 2)))
                            {
                                limite = CInt(MidVb6(strFormat, indice + 1, 2));
                            }
                        }
                        catch
                        {
                            indice = 0;
                        }
                    }

                    //On Error GoTo 0

                    //'-- se il limite non � stato richiesto oppure la numerosit� degli elementi selezionati non supera il limite
                    if (limite == 0 || ((Value.Split("###").Length - 1) > limite))
                    {

                        if (IsNull(mp_caption) || string.IsNullOrEmpty(CStr(mp_caption)))
                        {
                            objResp.Write(HtmlEncode(PrintDescription + " '" + this.Name + "'"));
                        }
                        else
                        {
                            objResp.Write(HtmlEncode(PrintDescription + " '" + mp_caption.Replace(" ", "") + "'"));
                        }
                    }
                    else
                    {
                        string listaDescs = DescMultivalue();

                        objResp.Write(HtmlEncode(listaDescs).Replace(@"&lt;br/&gt;", @"<br/>"));
                    }
                }
            }

            this.Name = originaleName;
        }
        public override void toPrintExtraContent(IEprocResponse objResp, dynamic OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {
            string originaleName = this.Name;

            if (mp_row != null)
            {
                this.Name = mp_row.Replace("_", " ") + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            }

            this.Value = IIF(IsNull(Value), "", Value);

            if (mp_row != null)
            {
                this.mp_caption = mp_row.Replace("_", " ") + " " + Caption;
            }
            else
            {
                this.mp_caption = " " + Caption;
            }

            DomElem? elem;
            string strDesc;
            int i;
            string htmlHeader = "";
            string htmlFooter = "";
            string[] arr;
            int totRows;
            int rowsForPage;
            string keyHeader = "";
            int totPagine = 0;
            bool bFirstPage;

            bFirstPage = true;

            if (((MultiValue == 1 || strFormat.Contains("M", StringComparison.Ordinal)) && !string.IsNullOrEmpty(CStr(Value))))
            {
                int indice = 0;
                int limite = 0;

                indice = InStrVb6(1, this.strFormat, "S");
                //'--SE NON TROVA LA S provo a vedere la E, lasciamo la S per compatibilit� con il vecchio ma si deve usare la E
                if (indice == 0)
                {
                    indice = InStrVb6(1, this.strFormat, "E");
                }

                //On Error Resume Next

                if (indice > 0)
                {
                    try
                    {
                        if (IsNumeric(MidVb6(strFormat, indice + 1, 2)))
                        {
                            limite = CInt(MidVb6(strFormat, indice + 1, 2));
                        }
                    }
                    catch
                    {
                        indice = 0;
                    }

                }

                //On Error GoTo 0

                //'-- se il limite non � stato richiesto oppure la numerosit� degli elementi selezionati non supera il limite
                if (limite == 0 || (Value.Split("###").Length - 1) > limite)
                {
                    if (!string.IsNullOrEmpty(params_))
                    {
                        rowsForPage = CInt(GetParamURL(params_, "ROWS_FOR_PAGE"));
                        totPagine = CInt(GetParamURL(params_, "TOT_PAGINE"));
                    }
                    else
                    {
                        rowsForPage = 20;
                    }

                    totRows = 0;

                    if (string.IsNullOrEmpty(startPage))
                    {
                        startPage = "0";
                    }

                    arr = Value.Split("###");

                    for (i = 1; i <= arr.Length - 1; i++)
                    {
                        if (!string.IsNullOrEmpty(CStr(arr[i])))
                        {
                            elem = Domain != null ? (DomElem?)Domain.FindCode(CStr(arr[i])) : null;

                            if (elem is not null)
                            {
                                if (totRows == 0)
                                {
                                    startPage = CStr(CInt(startPage) + 1);
                                }

                                //'-- Stampo l'header quando contaPagina non � attivo e stiamo stampando una nuova pagina
                                if (!contaPagine && totRows == 0)
                                {
                                    objResp.Write($@"<br/><table class=""GridPrintProducts"" width=""100%""><tr width=""100%"" class="""">" + Environment.NewLine);
                                    objResp.Write($@"<td class=""CellIntestGrid"">");

                                    //'-- header
                                    if (!string.IsNullOrEmpty(params_))
                                    {
                                        if (!string.IsNullOrEmpty(strHtmlHeader))
                                        {
                                            htmlHeader = strHtmlHeader;
                                        }
                                        else
                                        {
                                            keyHeader = GetParamURL(params_, "KEY_ML_HEADER_PRINT");
                                            htmlHeader = Application.ApplicationCommon.CNV(keyHeader, OBJSESSION);
                                        }

                                        htmlHeader = htmlHeader.Replace("@@@TOT-PAGE@@@", CStr(totPagine));
                                        htmlHeader = htmlHeader.Replace("@@@CURRENT-PAGE@@@", CStr(startPage));

                                        objResp.Write(htmlHeader);
                                    }

                                    objResp.Write($@"</td></tr>");

                                    //'-- Corpo
                                    objResp.Write($@"<tr height=""100%"" width=""100%"">");
                                    objResp.Write($@"<td height=""100%"" width=""100%"">");

                                    objResp.Write($@"<font class=""PrintCols""> <strong>");

                                    if (IsNull(mp_caption) || string.IsNullOrEmpty(CStr(mp_caption)))
                                    {
                                        objResp.Write(HtmlEncode(this.Name));
                                    }
                                    else
                                    {
                                        objResp.Write(HtmlEncode(mp_caption));
                                    }

                                    objResp.Write($@"</strong> </font></br>");

                                    objResp.Write($@"<table>"); //'-- tabella per le righe del contenuto
                                }

                                //'-- Righe
                                if (!contaPagine)
                                {
                                    strDesc = elem.Desc;
                                    objResp.Write($@"<tr class=""""><td ><font class=""PrintValues"">" + HtmlEncode(strDesc) + "</font></td></tr>");
                                }

                                totRows = totRows + 1;

                                if (totRows == rowsForPage)
                                {

                                    totRows = 0;

                                    if (!contaPagine)
                                    {
                                        objResp.Write($@"</td></tr>"); //' chiusura del corpo
                                        objResp.Write($@"<tr><td>"); //' apertura footer

                                        //'-- footer
                                        if (!string.IsNullOrEmpty(params_))
                                        {
                                            if (!string.IsNullOrEmpty(strHtmlHeader))
                                            {
                                                htmlFooter = strHtmlFooter;
                                            }
                                            else
                                            {
                                                keyHeader = GetParamURL(params_, "KEY_ML_FOOTER_PRINT");
                                                htmlFooter = Application.ApplicationCommon.CNV(keyHeader, OBJSESSION);
                                            }

                                            htmlFooter = htmlFooter.Replace("@@@TOT-PAGE@@@", CStr(totPagine));
                                            htmlFooter = htmlFooter.Replace("@@@CURRENT-PAGE@@@", CStr(startPage));

                                            objResp.Write(htmlFooter);
                                        }

                                        objResp.Write($@"</td></tr>"); //' chiusura footer
                                        objResp.Write($@"</table>");

                                        objResp.Write(saltoPagina());
                                    }
                                }
                            }
                        }
                    }

                    if (!contaPagine)
                    {
                        objResp.Write($@"</table>"); //'-- Chiusura tabella per le righe del contenuto

                        objResp.Write($@"</td></tr>"); //' chiusura del corpo
                        objResp.Write($@"<tr><td>");   //' apertura footer

                        //'-- footer
                        if (!string.IsNullOrEmpty(params_))
                        {
                            if (!string.IsNullOrEmpty(strHtmlHeader))
                            {
                                htmlFooter = strHtmlFooter;
                            }
                            else
                            {
                                keyHeader = GetParamURL(params_, "KEY_ML_FOOTER_PRINT");
                                htmlFooter = Application.ApplicationCommon.CNV(keyHeader, OBJSESSION);
                            }

                            htmlFooter = htmlFooter.Replace("@@@TOT-PAGE@@@", CStr(totPagine));
                            htmlFooter = htmlFooter.Replace("@@@CURRENT-PAGE@@@", CStr(startPage));

                            objResp.Write(htmlFooter);
                        }

                        objResp.Write($@"</td></tr>"); //' chiusura footer
                        objResp.Write($@"</table>");

                        objResp.Write(saltoPagina());
                    }
                }
            }

            this.Name = originaleName;
        }
        public override string TxtValue()
        {
            string stringToReturn;
            //On Error Resume Next
            DomElem? elem;
            int iZ;
            string tmpStrDesc;

            //'-- Verifico se il field � multivalue sia dall'attributo field sia dalla FORMAT
            if (MultiValue == 0 && !strFormat.Contains("M", StringComparison.Ordinal))
            {
                elem = Domain != null ? (DomElem?)Domain.FindCode(CStr(Value)) : null;

                if (elem != null)
                {
                    stringToReturn = FormattedElem("", elem.CodExt, elem.Desc, strFormat);
                }
                else
                {
                    stringToReturn = "";
                }
            }
            else
            {
                iZ = InStrVb6(1, strFormat, "L");
                if (iZ > 0)
                {
                    tmpStrDesc = DescMultivalue();
                    stringToReturn = HtmlEncode(CStr(tmpStrDesc)).Replace(@"&lt;br/&gt;", @"<br/>");
                }
                else
                {
                    dynamic tempValue = getMultivalueDesc(strFormat);
                    stringToReturn = HtmlEncode(CStr(tempValue));
                }

            }
            return stringToReturn;
        }
        public override void ValueExcel(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.ValueExcel(objResp, pEditable);
            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            this.Value = IIF(IsNull(Value), "", Value);

            this.Excel(objResp, (pEditable == null) ? Editable : pEditable);

            this.Name = originaleName;
        }
        public override void ValueHtml(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.ValueHtml(objResp, pEditable);
            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            this.Value = IIF(IsNull(Value), "", Value);
            this.mp_caption = Caption;


            this.Html(objResp, (pEditable == null) ? Editable : pEditable);
            this.Name = originaleName;
        }
        public override void xml(IEprocResponse objResp, string tipo)
        {
            objResp.Write($@"<" + XmlEncode(UCase(Name)) + @" desc=""" + XmlEncode(Caption) + @""" type=""" + getFieldTypeDesc(mp_iType) + @"""");
            objResp.Write($@" MultiValue = """ + XmlEncode(CStr(this.MultiValue)) + @"""");
            objResp.Write($@">");

            string[] aInfo;
            int i;
            int n;
            DomElem? elem;
            int iZ;

            objResp.Write(Environment.NewLine);
            bool jump = false;
            if (string.IsNullOrEmpty(Value))
            {
                jump = true;
            }

            if (!jump)
            {
                if (MultiValue == 0 && !strFormat.Contains("M", StringComparison.Ordinal))
                {
                    elem = Domain != null ? (DomElem?)Domain.FindCode(CStr(Value)) : null;

                    if (elem != null)
                    {
                        objResp.Write($@"<" + UCase(Name) + @"_VALUE codice=""" + Value + @"""");

                        //'-- Se � presente il codice esterno sul domElem
                        if (!string.IsNullOrEmpty(CStr(elem.CodExt)))
                        {
                            objResp.Write($@" codext=""" + Trim(elem.CodExt) + @"""");
                        }

                        objResp.Write($@">" + XmlEncode(elem.Desc) + "</" + UCase(Name) + "_VALUE>" + Environment.NewLine);
                    }
                    else
                    {
                        objResp.Write($@"<" + UCase(Name) + @"_VALUE codice=""" + Value + @""">");

                        iZ = InStrVb6(1, strFormat, "V");

                        if (iZ > 0)
                        {
                            objResp.Write(XmlEncode(CStr(Value)));
                        }
                        else
                        {
                            objResp.Write($@"N.C.");
                        }

                        objResp.Write($@"</" + UCase(Name) + "_VALUE>" + Environment.NewLine);
                    }
                }
                else
                { //'-- per gerarchici multivalore
                    aInfo = Value.Split("###");

                    n = aInfo.Length - 1;

                    //' es. di output : <MERCEOLOGIA_VALUE codice="001EXT110"> desc aaa </MERCEOLOGIA_VALUE>

                    for (i = 1; i <= n - 1; i++)
                    {
                        elem = Domain != null ? (DomElem?)Domain.FindCode(CStr(aInfo[i])) : null;

                        if (elem != null)
                        {
                            objResp.Write($@"<" + UCase(Name) + @"_VALUE codice=""" + aInfo[i] + @"""");

                            //'-- Se � presente il codice esterno sul domElem
                            if (!string.IsNullOrEmpty(CStr(elem.CodExt)))
                            {
                                objResp.Write($@" codext=""" + Trim(elem.CodExt) + @"""");
                            }

                            objResp.Write($@">" + XmlEncode(elem.Desc) + "</" + UCase(Name) + "_VALUE>" + Environment.NewLine);
                        }
                        else
                        {
                            objResp.Write($@"<" + UCase(Name) + @"_VALUE codice=""" + Value + @""">");

                            iZ = InStrVb6(1, strFormat, "V");

                            if (iZ > 0)
                            {
                                objResp.Write(XmlEncode(CStr(Value)));
                            }
                            else
                            {
                                objResp.Write($@"N.C.");
                            }

                            objResp.Write($@"</" + UCase(Name) + "_VALUE>" + Environment.NewLine);
                        }
                    }
                }
            }

            objResp.Write($@"</" + XmlEncode(UCase(Name)) + ">" + Environment.NewLine);
        }
        public override void UpdateFieldVisual(string objResp, string strDocument = "") { }
        public override void Excel(CommonModule.IEprocResponse objResp, bool? pEditable = null)
        {
            objResp.Write(TxtValue());
        }

        private void DrawRamo(string Path, string id, int lev)
        {
            mp_objResp.Write($@"<div id=""" + Name + @"_sel_" + id + @""" name=""" + Name + @"_sel_" + id + @""" path=""" + PathImage + @""" ");

            if (mp_indexToDraw == 0)
            {
                mp_objResp.Write($@" width=""100%"" height=""100%"" style=""width: 100%; height: 100%; overflow: auto;"" >" + Environment.NewLine);
            }
            else
            {
                if (strFormat == "X")
                {
                    mp_objResp.Write($@" visible=""1"" >" + Environment.NewLine);
                }
                else
                {
                    mp_objResp.Write($@" visible=""0"" style=""display:none;"" >" + Environment.NewLine);
                }
            }

            mp_objResp.Write($@"<table class=""" + Style + @"_path""  cellpadding=""0"" cellspacing=""0"" >" + Environment.NewLine);

            while (mp_indexToDraw < mp_MaxIndexToDraw)
            {
                if (string.IsNullOrEmpty(Path))
                {
                    DrawNodo(lev);
                }
                else
                {
                    if (Strings.Left(Domain.index((int)mp_indexToDraw).Father, Len(Path)) == Path)
                    {
                        DrawNodo(lev);
                    }
                    else
                    {
                        //'-- chiudo il ramo e risalgo
                        mp_objResp.Write($@"</table></div>" + Environment.NewLine);
                        return;
                    }
                }
            }

            mp_objResp.Write($@"</table></div>" + Environment.NewLine);
        }

        private void DrawNodo(int lev)
        {
            bool bFigli = false;
            DomElem curelem;
            bool bselectable;

            curelem = (DomElem)Domain.index((int)mp_indexToDraw);

            string Path = curelem.Father;

            //'-- controlla se il nodo ha figli
            if (mp_indexToDraw < mp_MaxIndexToDraw - 1 && Left(Domain.index((int)mp_indexToDraw + 1).Father, Path.Length) == Path)
            {
                bFigli = true;
            }

            //'-- apertura della riga per rappresentare un nodo
            mp_objResp.Write($@"<tr><td><table class=""" + Style + @"_node""  cellpadding=""0"" cellspacing=""0"" ><tr  ><td ");

            //'-- icona apri chiudi altrimenti nodo
            if (bFigli)
            {
                mp_objResp.Write($@" ><img alt=""""  class=""" + Style + @"_PlusMinus""  onclick=""javascript:HierarchyOpenNode( '" + Name + "' , '" + JSString(curelem.id) + @"' );"" src=""" + PathImage + IIF(strFormat == "X", "Hminus.gif", "Hplus.gif") + @""" id=""" + Name + "_img_" + curelem.id + @""" name=""" + Name + "_img_" + curelem.id + @""" ></td><td>");
            }
            else
            {
                mp_objResp.Write($@"><img alt="""" src=""" + PathImage + @"nochild.gif"" ></td><td>");
            }

            //'-- icona del ramo
            if (!string.IsNullOrEmpty(curelem.Image))
            {
                mp_objResp.Write($@"<img alt="""" src=""" + PathImage + curelem.Image + @""" ></td>");
            }
            else
            {
                mp_objResp.Write($@"</td>");
            }

            //'-- verifica se il nodo � selezionabile
            bselectable = false;
            if (SelectOnlyChild)
            {
                if (!bFigli)
                {
                    bselectable = true;
                }
            }
            else
            {
                bselectable = true;
            }

            if (lev == 0 && SelectNoRoot)
            {
                bselectable = false;
            }

            if (curelem.Deleted == 1 && !strFormat.Contains("Y", StringComparison.Ordinal))
            {
                mp_objResp.Write($@"<td class=""" + Style + @"_deleted"" >");
            }
            else
            {
                //'-- descrittiva
                if (bselectable)
                {
                    mp_objResp.Write($@"<td class=""" + Style + @"_selectable"" id=""" + Name + "_" + curelem.id + @""" name=""" + Name + "_" + curelem.id + @""" onclick=""javascript:HierarchySelectNode( '" + Name + "' ,'" + JSString(curelem.id) + @"' );"" ");
                    mp_objResp.Write($@" onMouseOver=""setClassName(this, '" + Style + @"_selectableMouseOver');"" ");
                    mp_objResp.Write($@" onMouseOut=""setClassName(this, '" + Style + @"_selectable');"" ");
                    mp_objResp.Write($@" >");
                }
                else
                {
                    mp_objResp.Write($@"<td class=""" + Style + @"_unselectable"" >");
                }
            }

            mp_objResp.Write(curelem.Desc);

            mp_objResp.Write($@"</td></tr></table></td></tr>" + Environment.NewLine);

            //'-- incremento i nodi disegnati
            mp_indexToDraw = mp_indexToDraw + 1;

            //'-- se il nodo successivo � un ramo figlio disegno il ramo
            if (bFigli)
            {
                mp_objResp.Write($@"<tr><td>" + Environment.NewLine);
                DrawRamo(Path, curelem.id, lev + 1);
                mp_objResp.Write($@"</td></tr>" + Environment.NewLine);
            }
        }

        /// <summary>
        /// //'--recupera le descrizioni di un gerarchico multivalore
        /// //'-- il valore tecnico � nel formato: ###val1###....###valN### dove ### � il separatore
        /// </summary>
        /// <returns></returns>
        private string DescMultivalue()
        {
            string stringToReturn = string.Empty;
            string[] aInfo;
            int i;
            int n;
            string strDesc = string.Empty;
            DomElem? elem;
            string tmpDesc;

            //On Error Resume Next

            if (string.IsNullOrEmpty(Value))
            {
                return stringToReturn;
            }

            if (!Value.Contains("###", StringComparison.Ordinal))
            {
                strDesc = Value;
            }

            //'--se il dominio NO MEM oppure FILTERED_ONLY devo recuperare le desc dal DB
            //'--e lo faccio con FindDescMultiValue che lo fa con un solo statement invece di usare la findoce che lo fa uno alla volta
            if (Domain != null && Domain.DynamicReload != null && Domain.DynamicReload.ToUpper() == "NO MEM" || (Strings.Left(Domain.DynamicReload.ToUpper(), 13) == "FILTERED ONLY" && string.IsNullOrEmpty(Domain.Filter)))
            {
                stringToReturn = Domain.FindDescMultiValue(this, CStr(Value));
            }
            else
            {
                aInfo = Value.Split("###");

                n = aInfo.Length - 1;

                for (i = 1; i <= n - 1; i++)
                {
                    elem = (DomElem?)Domain.FindCode(CStr(aInfo[i]));

                    if (elem != null)
                    {
                        tmpDesc = FormattedElem("", elem.CodExt, elem.Desc, strFormat);

                        strDesc = IIF(string.IsNullOrEmpty(strDesc), tmpDesc, strDesc + "<br/>" + tmpDesc);
                    }
                }

                stringToReturn = strDesc;
            }

            return stringToReturn;
        }

        void displayMultivalueEditable(IEprocResponse objResp, Session.ISession session)
        {
            string[] aInfo;
            int nelem;
            int i;
            DomElem? elem;
            Fld_Button btnRemove;
            Fld_Button btnClose;

            btnRemove = new Fld_Button();
            btnClose = new Fld_Button();

            objResp.Write($@"<table width=""100%"" height=""100%""  cellspacing=""0"" cellpadding=""0"" class="""" >");
            objResp.Write($@"<tr><td class=""" + Style + @"_unselectable"" width=""100%"" valign=""top"" >");
            objResp.Write(Application.ApplicationCommon.CNV("Elementi selezionati", session));
            objResp.Write($@"</td></tr>");
            objResp.Write($@"<tr><td width=""100%"" height=""100%"" valign=""top"" >");

            objResp.Write($@"<select multiple  style=""width:100%;"" class=""FldMultiValue"" id=""Sel_" + Name + @""" size=""5"" name=""Sel_" + Name + @""" > ");

            if (!string.IsNullOrEmpty(Value))
            {
                aInfo = Value.Split("###");
                nelem = aInfo.Length - 1;
                for (i = 1; i <= nelem - 1; i++)
                {
                    elem = Domain != null ? (DomElem?)Domain.FindCode(CStr(aInfo[i])) : null;

                    if (elem != null)
                    {
                        objResp.Write($@"<option ");

                        objResp.Write($@" value=""" + aInfo[i] + @""" >");
                        objResp.Write(HtmlEncodeValue(elem.Desc));

                        objResp.Write($@"</option>");
                    }
                }
            }

            objResp.Write($@"</select>");
            objResp.Write($@"</td></tr>");

            objResp.Write($@"<tr><td width=""100%"" height=""100%"" valign=""bottom"">");

            //'--bottone per rimuovere gli elementi
            btnRemove.Init(Name + "_Rimuovi", Application.ApplicationCommon.CNV("rimuovi selezione", session));
            btnRemove.setOnClick("RemoveElementMultiValueHierarchy('" + Name + "');");
            btnRemove.Html(objResp);

            btnClose.Init(Name + "_Close", Application.ApplicationCommon.CNV("Chiudi", session));
            btnClose.setOnClick("CloseHierarchy('" + Name + "');");
            btnClose.Html(objResp);

            objResp.Write($@"</td>");
            objResp.Write($@"</tr>");

            objResp.Write($@"</table>");
        }

        private void DrawRamoNew(string Path, string id, int lev)
        {
            if (!isLazy)
            {
                mp_objResp.Write($@"<ul>" + Environment.NewLine);  //'-- Apro il ramo

                while (mp_indexToDraw < mp_MaxIndexToDraw)
                {
                    if (string.IsNullOrEmpty(Path))
                    {
                        DrawNodoNew(lev);
                    }
                    else
                    {
                        //'-- Se stiamo scendendo di livello rispetto al ramo
                        if (Strings.Left(Domain.index((int)mp_indexToDraw).Father, Len(Path)) == Path)
                        {
                            DrawNodoNew(lev);
                        }
                        else
                        {
                            //'-- chiudo il ramo e risalgo
                            mp_objResp.Write($@"</ul>" + Environment.NewLine);
                            return;
                        }
                    }
                }

                mp_objResp.Write($@"</ul>");
            }
            else
            {
                string pathRadice;
                pathRadice = Path;

                mp_objResp.Write($@"<ul>" + Environment.NewLine);

                //'-- Se il dominio gerarchico � stato richiesto LAZY, disegno solo il nodo ( o i nodi ) radice
                while (mp_indexToDraw < mp_MaxIndexToDraw)
                {
                    //'-- Se sono su una radice
                    if (string.IsNullOrEmpty(pathRadice) || Strings.Left(Domain.index((int)mp_indexToDraw).Father, Len(pathRadice)) != pathRadice)
                    {
                        pathRadice = Domain.index((int)mp_indexToDraw).Father;
                        if (Domain.index((int)mp_indexToDraw).Level != null)
                        {
                            DrawNodoNew((int)Domain.index((int)mp_indexToDraw).Level);
                        }
                    }

                    mp_indexToDraw = mp_indexToDraw + 1;
                }

                mp_objResp.Write($@"</ul>" + Environment.NewLine);
            }
        }

        private void DrawNodoNew(int lev)
        {
            bool bFigli = false;
            DomElem? curelem;
            bool bselectable;
            bool bDeleted = false;
            string dataAttrib = string.Empty;  //'-- Stringa contenente l'attributo html 'data' utilizzato dal dynatree per i parametri del nodo
            string visValue = string.Empty;

            curelem = Domain != null ? (DomElem?)Domain.index((int)mp_indexToDraw) : null;

            if (curelem is not null && curelem.Deleted == 1 && !strFormat.Contains("Y", StringComparison.Ordinal))
            {
                bDeleted = true;
            }

            string Path = curelem.Father;

            //'-- controlla se il nodo ha figli
            if (mp_indexToDraw < mp_MaxIndexToDraw - 1 && Left(Domain.index((int)mp_indexToDraw + 1).Father, Path.Length) == Path)
            {
                bFigli = true;
            }

            //'-- apertura della riga per rappresentare un nodo
            if (!bDeleted)
            {
                mp_objResp.Write($@"<li id=""" + HtmlEncodeValue(curelem.id) + @""" title=""");

                //'-- Se nella format non c'� ne la C ne la D, lascio il default che visualizza la descrizione e basta
                if (!strFormat.Contains("C", StringComparison.Ordinal) && !strFormat.Contains("D", StringComparison.Ordinal))
                {
                    visValue = CStr(curelem.Desc);
                }

                if (strFormat.Contains("C", StringComparison.Ordinal))
                {
                    visValue = CStr(curelem.CodExt);
                }

                if (strFormat.Contains("D", StringComparison.Ordinal))
                {
                    if (!string.IsNullOrEmpty(visValue))
                    {
                        visValue = $"{visValue} - ";
                    }

                    visValue = $"{visValue}{curelem.Desc}";
                }

                mp_objResp.Write(HtmlEncodeValue(visValue));

                mp_objResp.Write($@""" ");

                dataAttrib = $" key: '{EscapeSequenceJS(curelem.id)}'";

                //'-- icona del ramo
                if (!string.IsNullOrEmpty(curelem.Image))
                {
                    dataAttrib = dataAttrib + @",icon: '" + EscapeSequenceJS(curelem.Image) + "'";
                }

                if (isLazy || strFormat.Contains("J", StringComparison.Ordinal))
                {
                    dataAttrib = dataAttrib + @",isLazy: true";
                }

                dataAttrib = dataAttrib + @",level: " + CStr(lev);
                dataAttrib = dataAttrib + @",father: '" + EscapeSequenceJS(CStr(Path)) + "'";
            }

            //'-- verifica se il nodo � selezionabile
            bselectable = false;
            if (SelectOnlyChild)
            {
                if (!bFigli)
                {
                    bselectable = true;
                }
            }
            else
            {
                bselectable = true;
            }

            if (lev == 0 && SelectNoRoot)
            {
                bselectable = false;
            }

            if (!bDeleted && !bselectable)
            {

                if (!string.IsNullOrEmpty(dataAttrib))
                {
                    dataAttrib = dataAttrib + ", unselectable:true ";
                }
                else
                {
                    dataAttrib = dataAttrib + " unselectable:true ";
                }
            }

            if (!string.IsNullOrEmpty(dataAttrib))
            {
                dataAttrib = @" Data = """ + dataAttrib + @""" ";
            }

            if (!bDeleted)
            {
                mp_objResp.Write(dataAttrib + ">" + Environment.NewLine);
                mp_objResp.Write(HtmlEncode(visValue) + Environment.NewLine);
            }

            //'-- incremento i nodi disegnati
            if (!isLazy)
            {
                mp_indexToDraw = mp_indexToDraw + 1;
            }

            //'-- se il nodo successivo � un ramo figlio disegno il ramo
            if (bFigli && !isLazy)
            {
                DrawRamoNew(Path, curelem.id, lev + 1);
            }
        }

        private string getMultivalueDesc(string strFormat = "")
        {
            string stringToReturn = string.Empty;
            string[] aInfo;
            int i;
            int n;
            string strDesc = "";
            DomElem? elem;
            int totElem;
            string strUnicoValore = "";
            totElem = 0;

            //On Error Resume Next

            if (string.IsNullOrEmpty(Value))
            {
                stringToReturn = $"0 {SelezionatiDescription}";
                return stringToReturn;
            }

            aInfo = Value.Split("###");

            n = aInfo.Length - 1;

            for (i = 1; i <= n - 1; i++)
            {// To n - 1

                if (!string.IsNullOrEmpty(CStr(aInfo[i])))
                {
                    totElem = totElem + 1;

                    strUnicoValore = CStr(aInfo[i]);
                }
            }

            //'-- Se c'� un solo elemento selezionato uscir� la sua descrizione altrimenti
            //'-- N Selezionati dove N � il numero di elementi selezionati
            if ((totElem > 1))
            {
                strDesc = $"{CStr(totElem)} {SelezionatiDescription}";
            }
            else if ((totElem == 0))
            {
                strDesc = $"0 {SelezionatiDescription}";
            }

            //'--se esite un solo codice recupero la sua desc
            if (totElem == 1)
            {
                elem = Domain is not null ? (DomElem?)Domain.FindCode(strUnicoValore) : null;

                if (elem is not null)
                {
                    strDesc = FormattedElem("", elem.CodExt, elem.Desc, strFormat);
                }
            }

            stringToReturn = strDesc;

            return stringToReturn;
        }

        public string FormattedElem(string Image, string CodExt, string Desc, string format)
        {
            string strApp = string.Empty;
            int i;
            int l;
            string c;

            if (string.IsNullOrEmpty(CStr(format)))
            {
                format = "D";
            }

            //'-- Se nella format non c'� una format che preveda la forma visuale ( C, I, D ) aggiungo in automatico la D alla format
            if (!format.Contains("D", StringComparison.Ordinal) && !format.Contains("C", StringComparison.Ordinal) && !format.Contains("I", StringComparison.Ordinal))
            {
                format = $"{format}D";
            }

            //'-- nel caso non sia specificato il formato per default � solo descrizione
            l = format.Length;

            //'-- ciclo sulla formattazione
            for (i = 1; i <= l; i++)
            {
                c = MidVb6(format, i, 1);

                switch (c)
                {
                    case "C":
                        if (!string.IsNullOrEmpty(strApp))
                        {
                            strApp = $"{strApp} - ";
                        }
                        strApp = $"{strApp}{CodExt}";
                        break;
                    case "D":
                        if (!string.IsNullOrEmpty(strApp))
                        {
                            strApp = $"{strApp} - ";
                        }

                        //'-- se � stato chiesto che gli elementi del dominio siano tutti MAIUSCOLI
                        if (UCase(format).Contains("U", StringComparison.Ordinal))
                        {
                            strApp = $"{strApp}{UCase(CStr(Desc))}";
                        }
                        else if (UCase(format).Contains("P", StringComparison.Ordinal))
                        { //'-- la L e la M erano gi� occupate
                            strApp = $"{strApp}{LCase(CStr(Desc))}";
                        }
                        else
                        {
                            strApp = $"{strApp}{CStr(Desc)}";
                        }
                        break;
                }
            }

            return strApp;
        }
    }
}