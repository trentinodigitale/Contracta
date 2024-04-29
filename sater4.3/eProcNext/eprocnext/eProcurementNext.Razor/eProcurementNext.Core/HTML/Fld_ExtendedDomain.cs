using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class Fld_ExtendedDomain : Field, IField
    {


        public string SelectDescription;        //'-- stringa per l'elemento ' -- Effettuare una selezione --
        public int Height;                      //'-- determina l'altezza della finestra per la selezione
        //private response As Object
        private string mp_strFilter;
        private string mp_strSepFilter;
        private bool mp_InOutFilter;
        public string PrintDescription;         //'-- stringa per l'elemento 'Vedi allegato xxx' nella stampa quando multivalue
        public string SelezionatiDescription;   //'-- stringa per l'elemento 'N Selezionati' per il multivalore
        public string senzaModali;              //'-- 1 i nuovi multivalore si aprono in un popup, 0 si aprono in una modale
        public string mp_caption;               //'--Stringa per la caption del field
        private bool PrintMode;

        public Fld_ExtendedDomain()
        {
            /* nel costruttore di tutti i field va inizializzato l'mp_itype con il proprio tipo di riferimento */
            this.mp_iType = 8;
            PathImage = "../../CTL_Library/images/Domain/";
            Style = "FldExtDom";
            Editable = true;
            SelectDescription = "-- Effettuare una selezione --";
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
                if (strFormat != null && !strFormat.Contains("T", StringComparison.Ordinal) && mp_iType == 5)
                {
                    objResp.Write($@" for=""" + HtmlEncodeValue(Name) + @"""");
                }
            }
        }
        public override void Html(IEprocResponse objResp, bool? pEditable = null)
        {
            bool? vEditable;
            DomElem? elem;
            string auI;
            string Search;
            string funzioneJS;
            string strDesc;

            auI = "";
            Search = "";

            if (strFormat.Contains('I', StringComparison.Ordinal))
            {
                auI = "1";
            }
            if (strFormat.Contains('S', StringComparison.Ordinal))
            {
                Search = Domain.Id;
            }

            vEditable = Editable;
            if (pEditable != null)
            {
                vEditable = pEditable;
            }

            string strDescDominio;
            int iZ;

            if (strFormat.ToUpper().Contains('M', StringComparison.Ordinal))
            {
                MultiValue = 1;
            }

            if (vEditable == false)
            {

                if (this.Value == null || (this.Value.GetType() == typeof(string) && string.IsNullOrEmpty(CStr(this.Value))))
                {

                    objResp.Write($@"<input type=""hidden"" id=""" + HtmlEncodeValue(Name) + $@""" name=""" + HtmlEncodeValue(Name) + $@""" value=""""/>" + Environment.NewLine);

                    objResp.Write($@"<span id=""" + HtmlEncodeValue(Name) + $@"_label"">");
                    objResp.Write($@"&nbsp;");
                    objResp.Write($@"</span>");

                }
                else
                {

                    //On Error Resume Next

                    if (MultiValue == 0 && !strFormat.Contains('M', StringComparison.Ordinal))
                    {

                        if (strFormat.Contains('T', StringComparison.Ordinal))
                        {

                            //'-- disegno il controllo nascosto NON messo a disabled (lo mando in post)
                            objResp.Write($@"<input");


                            objResp.Write($@" type=""hidden"" ");


                            objResp.Write($@" class=""display_none attrib_base""");


                            objResp.Write($@" id=""" + HtmlEncodeValue(Name) + $@""" name=""" + HtmlEncodeValue(Name) + $@""" value=""" + HtmlEncodeValue(CStr(Value)) + $@"""/>" + Environment.NewLine);

                            //'-- inserisco un input hidden contenente informazioni tecniche di varia natura. questo per eliminare
                            //'-- attributi non esistenti nello standard w3c. Gli attributi estesi saranno presenti come value
                            //'-- della input hidden nella forma nomeAttributo#=#valoreAttributo#@#nomeAttributo#=#valoreAttributo
                            objResp.Write($@"<input type=""hidden"" id=""" + Name + $@"_extraAttrib"" value=""search#=#" + HtmlEncodeValue(CStr(Search)) + $@"#@#strformat#=#" + HtmlEncodeValue(CStr(strFormat)) + $@"#@#autoincrement#=#" + HtmlEncodeValue(CStr(auI)) + $@"#@#filter#=#" + HtmlEncodeValue(CStr(Domain.Filter)) + $@"""/>");

                        }

                        elem = Domain != null ? (DomElem?)Domain.FindCode(CStr(Value)) : null;

                        if (elem != null)
                        {

                            //'-- controllo se mettere il tooltip
                            int nC;

                            iZ = InStrVb6(1, strFormat, "Z");
                            if (iZ > 0)
                            {
                                nC = CInt(MidVb6(strFormat, iZ + 1, 2));
                            }
                            else
                            {
                                nC = 32000;
                            }


                            strDesc = FormattedElem("", elem.CodExt, elem.Desc, strFormat);


                            if (strDesc.Length > nC)
                            {


                                objResp.Write($@"<span ");


                                objResp.Write($@"id=""" + HtmlEncodeValue(Name) + $@"_label"" title=""" + HtmlEncodeValue(strDesc) + $@""" ");


                                objResp.Write($@" class=""Fld_ExtendedDomain_label""");


                                objResp.Write($@">");

                                strDesc = Left(strDesc, nC - 1) + $@"...";

                                objResp.Write(HtmlEncode(strDesc).Replace($@"&lt;br/&gt;", $@"<br/>"));


                                objResp.Write($@"</span>");


                            }
                            else
                            {


                                objResp.Write($@"<span ");


                                objResp.Write($@"id=""" + HtmlEncodeValue(Name) + $@"_label"" title=""" + HtmlEncodeValue(strDesc) + $@""" ");

                                objResp.Write($@">");

                                objResp.Write(HtmlEncode(strDesc).Replace("&lt;br/&gt;", "<br/>"));


                                objResp.Write($@"</span>");


                            }

                        }
                        else
                        {

                            iZ = InStrVb6(1, strFormat, "V");
                            if (iZ > 0 || auI == "1")
                            {
                                objResp.Write(HtmlEncode(CStr(Value)).Replace($@"&lt;br/&gt;", $@"<br/>"));
                            }
                            else
                            {
                                objResp.Write($@"N.C.");
                            }

                        }

                    }
                    else
                    {

                        string strAttrDisabled;


                        if (strFormat.Contains('T', StringComparison.Ordinal))
                        {
                            //'-- disegno il controllo nascosto NON messo a disabled (lo mando in post)
                            strAttrDisabled = "";
                        }
                        else
                        {
                            //'-- disegno il controllo nascosto per� messo disabled (non lo mando in post)
                            strAttrDisabled = $@" disabled=""disabled"" ";
                        }

                        //'-- disegno il controllo nascosto NON messo a disabled (lo mando in post)
                        objResp.Write($@"<input" + strAttrDisabled);

                        objResp.Write($@" type=""hidden"" ");


                        objResp.Write($@" class=""display_none attrib_base""");


                        objResp.Write($@" id=""" + HtmlEncodeValue(Name) + $@""" name=""" + HtmlEncodeValue(Name) + $@""" value=""" + HtmlEncodeValue(CStr(Value)) + $@"""/>" + Environment.NewLine);

                        //'-- inserisco un input hidden contenente informazioni tecniche di varia natura. questo per eliminare
                        //'-- attributi non esistenti nello standard w3c. Gli attributi estesi saranno presenti come value
                        //'-- della input hidden nella forma nomeAttributo#=#valoreAttributo#@#nomeAttributo#=#valoreAttributo
                        objResp.Write($@"<input type=""hidden"" id=""" + Name + $@"_extraAttrib"" value=""search#=#" + HtmlEncodeValue(CStr(Search)) + $@"#@#strformat#=#" + HtmlEncodeValue(CStr(strFormat)) + $@"#@#autoincrement#=#" + HtmlEncodeValue(CStr(auI)) + $@"#@#filter#=#" + HtmlEncodeValue(CStr(Domain.Filter)) + $@"""/>");

                        strDesc = "";//FormattedElem("", elem.CodExt, elem.Desc, strFormat);

                        //'-- Se format a L faccio vedere al posto di 'N selezionati' la lista dei valori scelti
                        iZ = InStrVb6(1, strFormat, "L");
                        if (iZ > 0 && (MultiValue == 1 || strFormat.Contains('M', StringComparison.Ordinal)))
                        {
                            strDescDominio = DescMultivalue();
                        }
                        else
                        {
                            strDescDominio = getMultivalueDesc(strFormat);
                        }

                        //'-- lascio questa hidden _edit per la retrocompatibilit�
                        objResp.Write($@"<input type=""hidden"" name=""" + Name + $@"_edit"" id=""" + Name + $@"_edit"" value=""" + Replace(HtmlEncodeValue(strDescDominio), $@"&lt;br/&gt;", "<br/>") + $@"""  class=""" + Style + $@"_edit"" />");

                        objResp.Write($@"<table width=""100%"">");
                        objResp.Write($@"<tr>");
                        objResp.Write($@"<td width=""100%"" align=""right"">");


                        objResp.Write($@"<span ");


                        objResp.Write($@"id=""" + HtmlEncodeValue(Name) + $@"_label"" title=""" + HtmlEncodeValue(strDesc) + $@""" ");


                        objResp.Write($@" class=""Fld_ExtendedDomain_label_width""");


                        objResp.Write($@">");

                        objResp.Write(HtmlEncode(strDescDominio).Replace($@"&lt;br/&gt;", $@"<br/>"));


                        objResp.Write($@"</span>");


                        objResp.Write($@"</td>");
                        objResp.Write($@"<td align=""left"">");

                        if (senzaModali == "1")
                        {

                            funzioneJS = "openExtDomPopup";

                        }
                        else
                        {

                            funzioneJS = "extDom_openDocModal";

                        }

                        string srcFrame;
                        string strClassTmp;

                        strClassTmp = "";

                        srcFrame = $@"./LoadExtendedAttrib.asp?MultiValue=" + MultiValue + $@"&titoloFinestra=" + UrlEncode(mp_caption) + $@"&TypeAttrib=8&IdDomain=" + UrlEncode(Domain.Id) + $@"&Attrib=" + UrlEncode(Name) + $@"&Format=" + UrlEncode(strFormat) + $@"&Editable=" + vEditable + $@"&Suffix=&Filter=" + UrlEncode(Domain.Filter);

                        //'-- link per aprire la lightbox/modale con il dominio gerarchico
                        objResp.Write($@"<input type=""button"" alt=""Inserisci valore"" ");


                        strClassTmp = " float_right";


                        objResp.Write($@"class=""FldExtDom_button" + strClassTmp + $@""" value=""...""  id=""" + Name + $@"_button"" name=""" + Name + $@"_button"" onclick=""" + funzioneJS + "('" + EscapeSequenceJS(Name) + "','" + EscapeSequenceJS(HtmlEncodeValue(srcFrame)) + $@"', 'dialog-iframe-" + Domain.Id + $@"');"" />" + Environment.NewLine);

                        objResp.Write($@"</td>");
                        objResp.Write($@"</tr>");
                        objResp.Write($@"</table>");

                    }

                }

            }
            else
            {    //'-- il campo è editabile

                if (string.IsNullOrEmpty(CStr(Value)))
                {
                    strDescDominio = "";
                }
                else
                {

                    if (MultiValue == 0 && !strFormat.Contains("M", StringComparison.Ordinal))
                    {

                        elem = Domain != null ? (DomElem?)Domain.FindCode(CStr(Value)) : null;

                        //'Quando il dominio è editable e non ci sta la format per mostrare i DELETED ed il valore è deleted viene rimosso
                        if (elem != null && elem.Deleted == 1)
                        {
                            if (!strFormat.Contains("Y", StringComparison.Ordinal))
                            {
                                Value = "";
                            }
                        }

                        if (elem != null)
                        {
                            strDescDominio = HtmlEncodeValue(FormattedElem("", elem.CodExt, elem.Desc, strFormat));
                        }
                        else
                        {
                            if (auI == "1")
                            {
                                strDescDominio = HtmlEncodeValue(UCase(CStr(Value)));
                            }
                            else
                            {
                                strDescDominio = ""; //'"N.C."
                            }
                        }


                    }
                    else
                    {

                        strDescDominio = getMultivalueDesc(strFormat);

                    }

                }


                //'-- disegno il controllo nascosto
                objResp.Write($@"<input");


                objResp.Write($@" type=""hidden"" ");


                objResp.Write($@"class=""display_none attrib_base""");



                objResp.Write($@" id=""" + HtmlEncodeValue(Name) + $@""" name=""" + HtmlEncodeValue(Name) + $@""" value=""" + HtmlEncodeValue(CStr(Value)) + $@"""/>" + Environment.NewLine);

                string? domFilter = string.Empty;
                string? domID = string.Empty;

                if (Domain != null)
                {
                    domFilter = Domain.Filter;
                    domID = Domain.Id;
                }


                //'-- inserisco un input hidden contenente informazioni tecniche di varia natura. questo per eliminare
                //'-- attributi non esistenti nello standard w3c. Gli attributi estesi saranno presenti come value
                //'-- della input hidden nella forma nomeAttributo#=#valoreAttributo#@#nomeAttributo#=#valoreAttributo
                objResp.Write($@"<input type=""hidden"" id=""{Name}_extraAttrib"" value=""search#=#{HtmlEncodeValue(Search)}#@#strformat#=#{HtmlEncodeValue(strFormat)}#@#autoincrement#=#{HtmlEncodeValue(auI)}#@#filter#=#{HtmlEncodeValue(domFilter)}""/>");



                string oldDescMulti;
                oldDescMulti = strDescDominio;

                //'-- lascio questa hidden _edit per la retrocompatibilit�
                objResp.Write($@"<input type=""hidden"" name=""" + HtmlEncodeValue(Name) + $@"_edit"" id=""" + HtmlEncodeValue(Name) + $@"_edit"" value=""" + HtmlEncodeValue(oldDescMulti) + $@""" class=""" + HtmlEncodeValue(Style) + $@"_V"" ");

                if (!string.IsNullOrEmpty(mp_OnChange))
                {
                    objResp.Write($@" onchange=""" + mp_OnChange + $@""" ");
                }

                objResp.Write($@"/>");

                iZ = InStrVb6(1, strFormat, "L");
                if (iZ > 0 && (MultiValue == 1 || strFormat.Contains('M', StringComparison.Ordinal)))
                {
                    strDescDominio = DescMultivalue();
                }
                else
                {

                    if (MultiValue == 0 && !strFormat.Contains("M", StringComparison.Ordinal))
                    {
                        strDesc = strDescDominio;

                    }
                    else
                    {

                        strDescDominio = getMultivalueDesc(strFormat);

                    }

                }

                string srcFram;
                string funzOnClick;

                srcFram = $@"./LoadExtendedAttrib.asp?MultiValue=" + MultiValue + $@"&titoloFinestra=" + UrlEncode(mp_caption) + $@"&TypeAttrib=8&IdDomain=" + UrlEncode(domID) + $@"&Attrib=" + UrlEncode(Name) + $@"&Format=" + UrlEncode(strFormat) + $@"&Editable=" + Editable + $@"&Suffix=&Filter=" + UrlEncode(domFilter);

                if (senzaModali == "1")
                {
                    funzioneJS = "openExtDomPopup";
                }
                else
                {
                    funzioneJS = "extDom_openDocModal";
                }

                funzOnClick = funzioneJS + $@"('" + EscapeSequenceJS(Name) + "','" + EscapeSequenceJS(HtmlEncodeValue(srcFram)) + $@"', 'dialog-iframe-" + domID + "');";

                objResp.Write($@"<table>");
                objResp.Write($@"<tr>");
                objResp.Write($@"<td align=""right"">");

                //objResp.Write($@"<input type=""text"" autocomplete=""off"" name=""" + HtmlEncodeValue(Name) + $@"_edit_new"" id=""" + HtmlEncodeValue(Name) + $@"_edit_new"" class=""Date"" ");
                //objResp.Write($@"size=""" + width + $@""" value=""" + HtmlEncodeValue(strDescDominio) + $@""" ");

                objResp.Write($@"<input type=""text"" autocomplete=""off"" name=""" + HtmlEncodeValue(Name) + $@"_edit_new"" id=""" + HtmlEncodeValue(Name) + $@"_edit_new"" title= """ + HtmlEncode(Strings.Replace(Strings.Replace(strDescDominio, ";", Environment.NewLine), "<br/>", Environment.NewLine)) + $@""" class=""" + Style + $@"_edit_new"" ");
                
                if (IsMasterPageNew())
                {
                    objResp.Write($@"value=""" + HtmlEncodeValue(Strings.Replace(CStr(strDescDominio), "<br/>", ";")) + $@""" ");
                }
                else
                {
                    objResp.Write($@"size=""" + width + $@""" value=""" + HtmlEncodeValue(Strings.Replace(CStr(strDescDominio), "<br/>", ";")) + $@""" ");
                }


                objResp.Write($@" onchange=""extDom_onChangeBase('" + EscapeSequenceJS(Name) + "','', '" + EscapeSequenceJS(domID) + $@"','" + EscapeSequenceJS(domFilter) + $@"');"" ");
                objResp.Write($@" onfocus=""extDom_focus('" + EscapeSequenceJS(Name) + $@"','');"" ");
                objResp.Write($@" onblur=""extDom_lostFocus('" + EscapeSequenceJS(Name) + $@"','', false);"" ");
                objResp.Write($@" onkeydown=""extDom_keyDown(event,'" + EscapeSequenceJS(Name) + $@"' );"" ");
                objResp.Write($@" onKeyUp=""extDom_keyUp('" + EscapeSequenceJS(Name) + $@"','', event, '" + EscapeSequenceJS(domID) + $@"','" + EscapeSequenceJS(domFilter) + $@"');"" />");

                objResp.Write($@"</td>");
                objResp.Write($@"<td align=""left"">");


                //'-- link per aprire la lightbox/modale (o il popup) con il dominio gerarchico
                objResp.Write($@"<input type=""button"" class=""FldExtDom_button"" alt=""Inserisci valore"" ");
                objResp.Write($@" onblur=""extDom_lostFocus('" + EscapeSequenceJS(Name) + $@"','', true);"" ");
                objResp.Write($@" value="" ... ""  id=""" + Name + $@"_button"" name=""" + Name + $@"_button"" ");


                objResp.Write($@" onclick=""");


                objResp.Write(funzOnClick + $@""" ");
                objResp.Write($@"/>" + Environment.NewLine);

                objResp.Write($@"</td>");
                objResp.Write($@"</tr>");
                objResp.Write($@"</table>");

            }
        }
        public override void HtmlExtended(IEprocResponse objResp, dynamic? Request = null) { }
        public override void HtmlExtended2(IEprocResponse objResp, dynamic? Request = null, dynamic? session = null)
        {
            //DomElem e;
            string vf = "";

            if (Request != null)
            {
                mp_OnChange = GetParamURL(Request, "ONCHANGE");
            }

            objResp.Write($@"<select onload=""javascript:me.close();"" id=""" + HtmlEncodeValue(Name) + $@"_sel"" size=""10"" name=""" + HtmlEncodeValue(Name) + $@"_sel"" ");
            objResp.Write($@" class=""" + HtmlEncodeValue(Style) + $@"_Select"" ");
            objResp.Write($@" onchange=""javascript:FldExtDomChangeSelect( this , '" + HtmlEncodeValue(HtmlEncodeJSValue(Name)) + $@"' );"" ");
            objResp.Write($@" onblur=""javascript:FldExtDomOnBlur( this , '" + HtmlEncodeValue(HtmlEncodeJSValue(Name)) + $@"' );"" ");
            objResp.Write($@" onresize=""javascript:FldExtDomOnResize( this , '" + HtmlEncodeValue(HtmlEncodeJSValue(Name)) + $@"' );"" ");
            objResp.Write($@">" + Environment.NewLine);

            if ((Domain != null ? Domain.GetRsElem() : null) == null)
            {

                foreach (KeyValuePair<string, dynamic> e in Domain.Elem)
                {
                    objResp.Write($@"<option ");
                    objResp.Write($@" value=""" + e.Value.id + @""" >");

                    objResp.Write(e.Value.Desc);

                    objResp.Write($@"</option>" + Environment.NewLine);

                }

            }
            else
            {

                TSRecordSet? rsElem;
                bool bIns;

                rsElem = Domain != null ? Domain.GetRsElem() : null;
                if (rsElem != null)
                {

                    rsElem.MoveFirst();
                    //On Error Resume Next
                    while (rsElem.EOF == false)
                    {
                        bIns = true;
                        try
                        {
                            if (CInt(rsElem.Fields["DMV_Deleted"]) == 1)
                            {
                                if (strFormat != null && !strFormat.Contains('Y', StringComparison.Ordinal))
                                {
                                    bIns = false;
                                }
                            }
                        }
                        catch
                        {

                        }

                        if (bIns == true)
                        {
                            try
                            {
                                vf = CStr(rsElem.Fields["DMV_Cod"]);
                            }
                            catch
                            {

                            }

                            objResp.Write($@"<option ");
                            objResp.Write($@" value=""" + vf + $@""" ");
                            objResp.Write($@">");
                            try
                            {
                                objResp.Write(CStr(rsElem.Fields["DMV_DescML"]));

                            }
                            catch
                            {

                            }

                            objResp.Write($@"</option>");
                        }
                        rsElem.MoveNext();
                    }
                }
            }


            objResp.Write($@"</select>" + Environment.NewLine);
        }
        public override void HtmlExtended3(IEprocResponse objResp, dynamic? Request = null, dynamic? session = null)
        {
            //DomElem e;
            string vf = "";
            string dataAttrib;
            string visValue;

            TSRecordSet rsElem;
            rsElem = Domain.GetRsElem();

            if (Request != null)
            {
                mp_OnChange = GetParamURL(Request, "ONCHANGE");
            }

            strFormat = CStr(strFormat).ToLower();

            objResp.Write($@"<ul>" + Environment.NewLine);

            if (rsElem == null)
            {
                foreach (KeyValuePair<string, dynamic> e in Domain.Elem)
                {

                    visValue = "";

                    objResp.Write($@"<li id=""" + HtmlEncodeValue(CStr(e.Value.id)) + $@""" title=""");

                    //'-- Se nella format non c'� ne la C ne la D, lascio il default che visualizza la descrizione e basta
                    if (!strFormat.Contains('C', StringComparison.Ordinal) && !strFormat.Contains('D', StringComparison.Ordinal))
                    {
                        visValue = CStr(e.Value.Desc);
                    }

                    if (strFormat.Contains('C', StringComparison.Ordinal))
                    {
                        visValue = CStr(e.Value.CodExt);
                    }

                    if (strFormat.Contains('D', StringComparison.Ordinal))
                    {

                        if (!string.IsNullOrEmpty(visValue))
                        {
                            visValue = visValue + " - ";
                        }

                        visValue = visValue + CStr(e.Value.Desc);

                    }

                    objResp.Write(HtmlEncodeValue(visValue));

                    objResp.Write($@""" ");

                    objResp.Write($@"Data = """ + getDataAttrib(e.Value, false) + @""">" + HtmlEncode(CStr(visValue).ToUpper()) + Environment.NewLine);

                }

            }
            else
            {

                bool bIns;

                if (rsElem != null)
                {

                    rsElem.MoveFirst();
                    //On Error Resume Next
                    while (rsElem.EOF == false)
                    {

                        visValue = "";

                        bIns = true;
                        try
                        {
                            if (CInt(rsElem.Fields["DMV_Deleted"]) == 1)
                            {
                                if (!strFormat.Contains("Y", StringComparison.Ordinal))
                                {
                                    bIns = false;
                                }
                            }
                        }
                        catch { }

                        if (bIns == true)
                        {

                            vf = CStr(rsElem.Fields["DMV_Cod"]);

                            //'-- Se nella format non c'� ne la C ne la D, lascio il default che visualizza la descrizione e basta
                            if (!strFormat.Contains('C', StringComparison.Ordinal) && !strFormat.Contains('D', StringComparison.Ordinal))
                            {
                                visValue = CStr(rsElem.Fields["DMV_DescML"]);
                            }

                            if (strFormat.Contains('C', StringComparison.Ordinal))
                            {

                                try
                                {
                                    visValue = CStr(rsElem.Fields["DMV_CodExt"]);
                                }
                                catch
                                {
                                    visValue = "";
                                }

                            }

                            if (strFormat.Contains('D', StringComparison.Ordinal))
                            {

                                if (!string.IsNullOrEmpty(visValue))
                                {
                                    visValue = visValue + " - ";
                                }

                                visValue = visValue + CStr(rsElem.Fields["DMV_DescML"]);

                            }

                            objResp.Write($@"<li id=""" + HtmlEncodeValue(CStr(vf)) + $@""" title=""" + HtmlEncodeValue(UCase(visValue)) + $@""" Data = """ + getDataAttrib(rsElem, true) + $@""">" + HtmlEncode(visValue.ToUpper()) + Environment.NewLine);

                        }

                        rsElem.MoveNext();

                    }

                }
            }

            objResp.Write("</ul>");
        }
        public override void Init(int iType, string oName = "", object? oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false)
        {
            base.Init(iType, oName, oValue, oDom, oumDom, oFormat, oEditable, oObbligatory, oValidazioneFormale);
            MultiValue = 0;
            mp_caption = "";


            if (strFormat != null && strFormat.Contains("M", StringComparison.Ordinal))
            {

                MultiValue = 1;
            }
        }
        public override void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/")
        {
            if (!js.ContainsKey("getObj"))
            {
                js.Add("getObj", @"<script src=""" + Path + @"jscript/getObj.js"" ></script>");
            }
            if (!js.ContainsKey("GetPosition"))
            {
                js.Add("GetPosition", @"<script src=""" + Path + @"jscript/GetPosition.js"" ></script>");
            }
            if (!js.ContainsKey("setVisibility"))
            {
                js.Add("setVisibility", @"<script src=""" + Path + @"jscript/setVisibility.js"" ></script>");
            }
            if (!js.ContainsKey("setClassName"))
            {
                js.Add("setClassName", @"<script src=""" + Path + @"jscript/setClassName.js"" ></script>");
            }
            if (!js.ContainsKey("FldExtDom"))
            {
                js.Add("FldExtDom", @"<script src=""" + Path + @"jscript/Field/FldExtDom.js"" ></script>");
            }
            if (!js.ContainsKey("SearchDocumentForExtendeAttrib"))
            {
                js.Add("SearchDocumentForExtendeAttrib", @"<script src=""" + Path + @"jscript/Field/SearchDocumentForExtendeAttrib.js"" ></script>");
            }
        }
        public override dynamic? RSValue()
        {
            Value = base.RSValue();
            return this.Value;
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
            Value = base.SQLValue();
            return @"'" + CStr(this.Value).Replace(@"'", @"''") + @"'";
        }
        public override string TechnicalValue()
        {
            return IIF(IsNull(this.Value), "", CStr(this.Value));
        }
        public override void toPrint(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;
            base.toPrint(objResp);
            dynamic strVal = IIF(IsNull(Value), "", Value);
            bool? vEditable = (pEditable == null) ? Editable : pEditable;

            if (Obbligatory == true && string.IsNullOrEmpty(CStr(strVal)) && vEditable == true)
            {
                strVal = Domain.GetSingleValue();
            }

            if (mp_row != null)
            {
                this.Name = mp_row.Replace("_", " ") + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            }


            this.Value = strVal;
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

                if ((MultiValue == 0))
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

                        string listaDescs;
                        listaDescs = DescMultivalue();

                        objResp.Write(HtmlEncode(listaDescs).Replace($@"&lt;br/&gt;", $@"<br/>"));

                    }

                }

            }


            this.Name = originaleName;

        }
        public override void toPrintExtraContent(IEprocResponse objResp, dynamic OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {
            string originaleName = this.Name;
            string strVal = IIF(IsNull(Value), "", Value);
            bool? vEditable = false;

            if (Obbligatory = true && string.IsNullOrEmpty(strVal) && vEditable == true)
            {
                strVal = Domain.GetSingleValue();
            }

            if (mp_row != null)
            {
                this.Name = mp_row.Replace("_", " ") + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            }


            this.Value = strVal;
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
            string htmlHeader;
            string htmlFooter;
            string[] arr;
            int totRows;
            int rowsForPage;
            string keyHeader;
            int totPagine = 0;
            bool bFirstPage;

            bFirstPage = true;

            if ((MultiValue == 1 || strFormat.Contains("M", StringComparison.Ordinal)) && !string.IsNullOrEmpty(CStr(Value)))
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

                            if (elem != null)
                            {

                                if (totRows == 0)
                                {
                                    startPage = CStr(CInt(startPage) + 1);
                                }

                                //'-- Stampo l'header quando contaPagina non � attivo e stiamo stampando una nuova pagina
                                if (contaPagine == false && totRows == 0)
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


                                    objResp.Write($@"<tr width=""100%"">");


                                    objResp.Write($@"<td height=""100%"" width=""100%"">");

                                    objResp.Write($@"<font class=""PrintCols""><strong>");

                                    if (IsNull(mp_caption) || string.IsNullOrEmpty(CStr(mp_caption)))
                                    {
                                        objResp.Write(HtmlEncode(this.Name));
                                    }
                                    else
                                    {
                                        objResp.Write(HtmlEncode(mp_caption));
                                    }

                                    objResp.Write($@"</strong></font></br>");

                                    objResp.Write($@"<table>"); //'-- tabella per le righe del contenuto

                                }


                                //'-- Righe
                                if ((contaPagine == false))
                                {
                                    strDesc = elem.Desc;
                                    objResp.Write($@"<tr class=""""><td ><font class=""PrintValues"">" + HtmlEncode(strDesc) + "</font></td></tr>");
                                }


                                totRows = totRows + 1;

                                if (totRows == rowsForPage)
                                {

                                    totRows = 0;

                                    if ((contaPagine == false))
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

                    if ((contaPagine == false))
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
            string strToReturn;
            Value = base.TxtValue();
            DomElem? elem;
            int iZ;
            string tmpStrDesc;


            //'-- Verifico se il field � multivalue sia dall'attributo field sia dalla FORMAT
            if (MultiValue == 0 && !strFormat.Contains("M", StringComparison.Ordinal))
            {

                elem = Domain != null ? (DomElem?)Domain.FindCode(CStr(Value)) : null;
                if (elem != null)
                {
                    strToReturn = FormattedElem("", elem.CodExt, elem.Desc, strFormat);
                }
                else
                {
                    strToReturn = "";
                }

                //' se la formattazione lo prevede mette il codice in caso di elemento non trovato nel dominio
                if (strFormat.Contains("V", StringComparison.Ordinal) && strToReturn.Trim() == "")
                {
                    strToReturn = CStr(Value);
                }

            }
            else
            {

                iZ = InStrVb6(1, strFormat, "L");
                if (iZ > 0)
                {
                    tmpStrDesc = DescMultivalue();
                    strToReturn = Replace(HtmlEncode(CStr(tmpStrDesc)), "&lt;br/&gt;", "<br/>");
                }
                else
                {
                    dynamic tempValue = getMultivalueDesc(strFormat);
                    strToReturn = HtmlEncode(CStr(tempValue));
                }

            }
            return strToReturn;
        }
        public override void ValueExcel(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;
            base.ValueExcel(objResp);

            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            this.Value = IIF(IsNull(Value), "", Value);

            this.Excel(objResp, (pEditable == null) ? Editable : pEditable);

            this.Name = originaleName;

        }
        public override void ValueHtml(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;
            base.ValueHtml(objResp);
            dynamic strVal = IIF(IsNull(Value), "", Value);
            bool? vEditable = (pEditable == null) ? Editable : pEditable;
            if (Obbligatory == true && string.IsNullOrEmpty(strVal) && vEditable == true)
            {
                strVal = Domain.GetSingleValue(strFormat);


                if (!string.IsNullOrEmpty(strVal))
                {

                    if (MultiValue == 1 || strFormat.Contains("M", StringComparison.Ordinal))
                    {

                        strVal = $@"###" + strVal + $@"###";

                    }

                }

            }

            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            this.Value = IIF(IsNull(Value), "", Value);
            this.mp_caption = Caption;


            this.Html(objResp, vEditable);


            this.Name = originaleName;
        }
        public override void xml(IEprocResponse objResp, string tipo)
        {
            objResp.Write($@"<" + XmlEncode(UCase(Name)) + $@" desc=""" + XmlEncode(Caption) + $@""" type=""" + getFieldTypeDesc(mp_iType) + $@"""");
            objResp.Write($@" MultiValue = """ + XmlEncode(CStr(this.MultiValue)) + $@"""");
            objResp.Write($@">");

            //On Error Resume Next

            DomElem? elem;
            int iZ;
            string tmp;

            if ((!IsNull(Value)))
            {

                if (!string.IsNullOrEmpty(CStr(Value)))
                {

                    elem = Domain != null ? (DomElem?)Domain.FindCode(CStr(Value)) : null;

                    if (elem != null && !IsEmpty(elem))
                    {

                        objResp.Write($@"<" + Name.ToUpper() + @"_VALUE codice=""" + Value + @"""");

                        tmp = "";

                        //'-- Se � presente il codice esterno sul domElem
                        if (!string.IsNullOrEmpty(CStr(elem.CodExt)))
                        {
                            tmp = @" codext=""" + Trim(elem.CodExt) + @"""";
                        }

                        objResp.Write(tmp + ">" + XmlEncode(elem.Desc) + "</" + UCase(Name) + "_VALUE>" + Environment.NewLine);

                    }
                    else
                    {

                        objResp.Write($@"<" + Name.ToUpper() + @"_VALUE codice=""" + Value + @""">");

                        iZ = InStrVb6(1, strFormat, "V");
                        tmp = "";

                        if (iZ > 0)
                        {
                            tmp = XmlEncode(CStr(Value));
                        }
                        else
                        {
                            tmp = "N.C.";
                        }

                        objResp.Write(tmp + "</" + Name.ToUpper() + @"_VALUE>" + Environment.NewLine);

                    }

                }

            }

            objResp.Write($@"</" + XmlEncode(UCase(Name)) + $@">" + Environment.NewLine);
        }
        public override void UpdateFieldVisual(IEprocResponse objResp, string strDocument = "")
        {
            string originaleName = this.Name;
            base.UpdateFieldVisual(objResp, strDocument);


            DomElem? elem;
            string strDescDominio;

            elem = Domain != null ? (DomElem?)Domain.FindCode(CStr(Value)) : null;
            if (elem != null)
            {
                strDescDominio = elem.Desc.ToUpper();  //'HtmlEncodeValue(UCase(elem.Desc))
            }
            else
            {
                strDescDominio = "N.C.";
            }

            objResp.Write($@"<script type=""text/javascript"">" + Environment.NewLine);

            if (!string.IsNullOrEmpty(strDocument))
            {
                strDocument = strDocument + ".";
            }

            objResp.Write($@"try{{" + strDocument + $@"getObj('" + HtmlEncodeJSValue(Name) + $@"').className='" + HtmlEncodeJSValue(Style) + $@"'}}catch(e){{}};" + Environment.NewLine);
            objResp.Write($@"try{{" + strDocument + $@"getObj('" + HtmlEncodeJSValue(Name) + $@"_V').className='" + HtmlEncodeJSValue(Style) + $@"'}}catch(e){{}};" + Environment.NewLine);

            //'--per la label (campo non editabile)
            objResp.Write($@"try{{" + strDocument + $@"getObj('" + HtmlEncodeJSValue(Name) + $@"_label').innerTEXT='" + HtmlEncodeJSValue(strDescDominio) + $@"'}}catch(e){{}};" + Environment.NewLine);
            objResp.Write($@"try{{" + strDocument + $@"getObj('" + HtmlEncodeJSValue(Name) + $@"_label').innerHTML='" + HtmlEncodeJSValue(strDescDominio) + $@"'}}catch(e){{}};" + Environment.NewLine);

            //'--per i campi testo
            objResp.Write($@"try{{" + strDocument + $@"getObj('" + HtmlEncodeJSValue(Name) + $@"_edit_new').value='" + HtmlEncodeJSValue(strDescDominio) + $@"'}}catch(e){{}};" + Environment.NewLine);
            objResp.Write($@"try{{" + strDocument + $@"getObj('" + HtmlEncodeJSValue(Name) + $@"_edit').value='" + HtmlEncodeJSValue(strDescDominio) + $@"'}}catch(e){{}};" + Environment.NewLine);
            objResp.Write($@"try{{" + strDocument + $@"getObj('" + HtmlEncodeJSValue(Name) + $@"_edit1').value='" + HtmlEncodeJSValue(strDescDominio) + $@"'}}catch(e){{}};" + Environment.NewLine);
            objResp.Write($@"try{{" + strDocument + $@"getObj('" + HtmlEncodeJSValue(Name) + $@"').value='" + HtmlEncodeJSValue(CStr(Value)) + $@"'}}catch(e){{}};" + Environment.NewLine);

            objResp.Write($@"</script>");


            this.Name = originaleName;
        }
        public override void Excel(CommonModule.IEprocResponse objResp, bool? pEditable = null)
        {
            objResp.Write(TxtValue());
        }

        private string getMultivalueDesc(string strFormat = "")
        {
            string strToReturn;

            string[] aInfo;
            int i;
            int n;
            string strDesc = "";
            DomElem? elem;
            int totElem;

            totElem = 0;

            //On Error Resume Next


            strToReturn = "";

            if (string.IsNullOrEmpty(Value))
            {
                strToReturn = "0 " + SelezionatiDescription;
                return strToReturn;
            }

            aInfo = CStr(Value).Split("###");

            n = aInfo.Length - 1;

            for (i = 1; i <= n - 1; i++)
            {
                
                if (!string.IsNullOrEmpty(CStr(aInfo[i])))
                {
                   
                    totElem = totElem + 1;

                    if(Domain is not null)
                    {
                        elem = (DomElem?)Domain.FindCode(CStr(aInfo[i]));
                    }
                    else
                    {
                        elem = null;
                    }
                    //'Quando il dominio � editable e non ci sta la format per mostrare i DELETED ed il valore � deleted viene rimosso

                    if (elem is not null && elem.Deleted == 1)
                    {
                        if (!strFormat.Contains('Y', StringComparison.Ordinal) && this.Editable)
                        {
                            Value = CStr(Value).Replace("###" + CStr(aInfo[i]) + "###", "###");
                        }
                    }

                    if (elem is not null)
                    {
                        strDesc = FormattedElem("", elem.CodExt, elem.Desc, strFormat);
                    }
                }
            }

            //'-- Se c'� un solo elemento selezionato uscir� la sua descrizione altrimenti
            //'-- N Selezionati dove N � il numero di elementi selezionati
            if (totElem > 1)
            {
                strDesc = CStr(totElem) + " " + SelezionatiDescription;
            }
            else if (totElem == 0)
            {
                strDesc = "0 " + SelezionatiDescription;
            }

            strToReturn = strDesc;

            return strToReturn;
        }

        private string getDataAttrib(dynamic curelem, bool isRecordset = false)
        {
            string dataAttrib;
            string img = "";
            string Key = "";

            if (isRecordset)
            {
                //On Error Resume Next
                try
                {
                    img = CStr(curelem.Fields["DMV_Image"]);
                    Key = CStr(curelem.Fields["DMV_Cod"]);
                }
                catch
                {

                }

                //err.Clear
                //On Error GoTo 0
            }
            else
            {
                Key = curelem.id;

                if (!string.IsNullOrEmpty(curelem.Image))
                {
                    img = curelem.Image;
                }
            }

            dataAttrib = $@" key: '" + EscapeSequenceJS(Key) + $@"'";

            if (!string.IsNullOrEmpty(img))
            {
                dataAttrib = dataAttrib + $@",icon: '" + EscapeSequenceJS(img) + $@"'";
            }

            dataAttrib = dataAttrib + $@", unselectable:false ";

            return dataAttrib;
        }

        private string DescMultivalue()
        {
            string strToReturn = String.Empty;
            string[] aInfo;
            int i;
            int n;
            string strDesc = "";
            DomElem? elem;
            string tmpDesc;

            //On Error Resume Next

            if (string.IsNullOrEmpty(Value))
            {
                return strToReturn;
            }

            aInfo = Value.Split("###");

            n = aInfo.Length - 1;

            for (i = 1; i <= n - 1; i++)
            {
                elem = Domain != null ? (DomElem?)Domain.FindCode(CStr(aInfo[i])) : null;

                if (elem is not null)
                {
                    tmpDesc = FormattedElem("", elem.CodExt, elem.Desc, strFormat);
                    strDesc = IIF((strDesc == ""), tmpDesc, strDesc + "<br/>" + tmpDesc);
                }
            }

            strToReturn = strDesc;

            return strToReturn;
        }

        private string FormattedElem(string Image, string CodExt, string Desc, string format)
        {
            string strApp;
            int i;
            int l;
            string c;
            int iZ;

            if (string.IsNullOrEmpty(CStr(format)))
            {
                format = "D";
            }

            //'-- Se nella format non c'� una format che preveda la forma visuale ( C, I, D ) aggiungo in automatico la D alla format
            if (!format.Contains("D", StringComparison.Ordinal) && !format.Contains("C", StringComparison.Ordinal) && !format.Contains("I", StringComparison.Ordinal))
            {
                format = format + "D";
            }

            strApp = "";

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
                            strApp = strApp + " - ";
                        }
                        strApp = strApp + CodExt;

                        break;

                    case "D":
                        if (!string.IsNullOrEmpty(strApp))
                        {
                            strApp = strApp + " - ";

                        }

                        //'-- se � stato chiesto che gli elementi del dominio siano tutti MAIUSCOLI
                        if (format.ToUpper().Contains("U", StringComparison.Ordinal))
                        {
                            strApp = strApp + UCase(CStr(Desc));
                        }
                        else if (format.ToUpper().Contains("P", StringComparison.Ordinal))
                        { //'-- la L e la M erano gi� occupate
                            strApp = strApp + CStr(Desc).ToLower();
                        }
                        else
                        {
                            strApp = strApp + CStr(Desc);
                        }
                        break;
                    default:
                        break;
                }


            }

            return strApp;

        }


    }

}


