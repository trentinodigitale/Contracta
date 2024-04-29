using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using StackExchange.Redis;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class Fld_Domain : Field, IField
    {



        /*
		Public strFormat As String      
                '-- A,
                '-- D la descrizione
                '-- H orizzionate , verticale
                '-- I aggiunge una image
                '-- L tutto minuscolo
                '-- M multivalue
                '-- O come option
                '-- T aggiunge il campo tecnico
                '-- U tutto maiuscolo
                '-- V aggiunge nella descerizione il value (il codice)
                '-- Z aggiunge tooltip se supera il numero caratteri successivo a Z
                '-- Y aggiunge i cancellati logici
                '-- S esclude elemento seleziona
                '-- C aggiunge nella descerizione il codice esteso
                '-- P aggiunge tooltip a prescindere dalla colonna del dominio DMV_Tooltip (solo per i domini dinamici per ora)

        */
		public string SelectDescription;  //'-- stringa per l'elemento ' -- Effettuare una selezione --


        private string mp_strFilter;
        private string mp_strSepFilter;
        private bool mp_InOutFilter;
        public int Rows; //'--righe per visualizzare il controllo

        public string PrintDescription;  //'-- stringa per l'elemento 'Vedi allegato xxx' nella stampa quando multivalue
        public string SelezionatiDescription;  //'-- stringa per l'elemento 'N Selezionati' per il multivalore
        public string senzaModali; //'-- 1 i nuovi multivalore si aprono in un popup, 0 si aprono in una modale
        public string mp_caption; //'--Stringa per la caption del field

        private bool PrintMode;

        public Fld_Domain()
        {
            /* nel costruttore di tutti i field va inizializzato l'mp_itype con il proprio tipo di riferimento */
            this.mp_iType = 4;
            PathImage = "../CTL_Library/images/Domain/";
            Style = "FldDomainValue";
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
                if (this.MultiValue == 1 || this.strFormat.Contains("M", StringComparison.Ordinal))
                {
                    objResp.Write(@" for=""" + HtmlEncodeValue(Name) + @"_edit_new""");
                }
                else
                {
                    objResp.Write(@" for=""" + HtmlEncode(this.Name) + @"""");
                }
            }


        }
        public override void Html(IEprocResponse objResp, bool? pEditable = null)
        {
            bool? vEditable;
            string strDescDominio;
            string strWidth;
            string srcFram;
            string funzioneJS;



            vEditable = Editable;

            if (pEditable != null)
            {
                vEditable = pEditable;
            }

            if (strFormat.Length > 0)
            {
                if (Strings.Left(strFormat, 1).ToUpper() == "O")
                {
                    HtmlOptionDraw(objResp, vEditable);
                    return;
                }
            }


            // apertura del controllo
            if (string.IsNullOrEmpty(CStr(this.Value)) && vEditable == false)
            {

                if (MultiValue == 1 || strFormat.Contains("M", StringComparison.Ordinal))
                {

                    strDescDominio = getMultivalueDesc();

                    objResp.Write(@"<span ");

                    objResp.Write(@"id=""" + Name + @"_edit_new"" ");

                    objResp.Write(@" class=""Fld_Domain_label"">");

                    objResp.Write(HtmlEncode(CStr(strDescDominio)));

                    objResp.Write("</span>");


                    if (PrintMode == false)
                    {

                        srcFram = @"./LoadExtendedAttrib.asp?MultiValue=1&titoloFinestra=" + UrlEncode(mp_caption) + @"&TypeAttrib=4&titoloFinestra=" + UrlEncode(mp_caption) + @"&IdDomain=" + UrlEncode(Domain.Id) + @"&Attrib=" + UrlEncode(Name) + @"&Format=" + UrlEncode(strFormat) + @"&Editable=" + vEditable + @"&Suffix=&Filter=" + UrlEncode(Domain.Filter) + @"&Value=";

                        if (senzaModali == "1")
                        {

                            funzioneJS = "openDomPopup";
                        }
                        else
                        {

                            funzioneJS = "dom_openDocModal";
                        }


                        string strTmpClass;


                        strTmpClass = "";


                        //'-- link per aprire la lightbox/modale con il dominio gerarchico
                        objResp.Write($@"<input ");



                        strTmpClass = " float_right";

                        objResp.Write($@"type=""button"" class=""FldExtDom_button" + strTmpClass + @""" alt=""Inserisci valore"" value=""...""  id=""" + Name + @"_button"" name=""" + Name + @"_button"" ");

                        if (PrintMode == false)
                        {
                            objResp.Write($@"onclick=""" + funzioneJS + @"('" + EscapeSequenceJS(Name) + @"','" + EscapeSequenceJS(HtmlEncodeValue(srcFram)) + @"', 'dialog-iframe-" + Domain.Id + @"');""");
                        }

                        objResp.Write($@"/>" + Environment.NewLine);

                    }

                    objResp.Write($@"<input type=""hidden"" ");

                    objResp.Write($@" class=""display_none attrib_base""");


                    objResp.Write($@" id=""" + HtmlEncodeValue(Name) + @""" name=""" + HtmlEncodeValue(Name) + @""" value=""" + HtmlEncodeValue(CStr(Value)) + @"""/>" + Environment.NewLine);

                }
                else
                {

                    //'-- inserisco un input hidden contenente informazioni tecniche di varia natura. questo per eliminare
                    //'-- attributi non esistenti nello standard w3c. Gli attributi estesi saranno presenti come value
                    //'-- della input hidden nella forma nomeAttributo#=#valoreAttributo#@#nomeAttributo#=#valoreAttributo
                    objResp.Write($@"<input type=""hidden"" id=""val_" + HtmlEncodeValue(Name) + @"_extraAttrib"" value=""value#=#" + HtmlEncodeValue(CStr(this.Value)) + @"""/>");

                    objResp.Write($@"<div id=""val_" + HtmlEncodeValue(Name) + @""" ");

                    if (!string.IsNullOrEmpty(Style))
                    {
                        objResp.Write($@" class=""" + HtmlEncodeValue(Style) + @""" ");
                    }

                    objResp.Write($@">");


                    objResp.Write($@"&nbsp;");
                    objResp.Write($@"</div>" + Environment.NewLine);

                    //'-- Se richiesto dalla format, metto il campo tecnico
                    if (vEditable == false && strFormat.Contains("T", StringComparison.Ordinal))
                    {
                        objResp.Write($@"<input type=""hidden"" name=""" + Name + @"""  id=""" + Name + @""" ");
                        objResp.Write($@" value=""" + HtmlEncodeValue(CStr(Value)) + @""" ");
                        objResp.Write($@"/>" + Environment.NewLine);
                    }


                }


            }
            else
            {

                if (MultiValue == 1 || strFormat.Contains("M", StringComparison.Ordinal))
                {

                    strDescDominio = getMultivalueDesc();


                    if (vEditable == false)
                    {


                        objResp.Write($@"<span ");


                        objResp.Write($@"id=""" + Name + @"_edit_new"" ");

                        objResp.Write($@" class=""Fld_Domain_label2""");

                        objResp.Write($@">");


                        objResp.Write(HtmlEncode(CStr(strDescDominio)));


                        objResp.Write($@"</span>");


                    }
                    else
                    {
                        if (IsMasterPageNew())
                        {
                            objResp.Write($@"<input type=""text"" name=""" + HtmlEncodeValue(Name) + @"_edit_new"" id=""" + HtmlEncodeValue(Name) + @"_edit_new"" class=""Date DateFaseII"" ");
                        }
                        else
                        {
                            objResp.Write($@"<input type=""text"" name=""" + HtmlEncodeValue(Name) + @"_edit_new"" id=""" + HtmlEncodeValue(Name) + @"_edit_new"" class=""Date"" ");

                        }
                        if (IsMasterPageNew())
                        {
                            objResp.Write($@"value=""" + HtmlEncodeValue(CStr(strDescDominio)) + @""" readonly=""readonly""/>");
                        }
                        else
                        {
                            objResp.Write($@" size=""" + width + @""" value=""" + HtmlEncodeValue(CStr(strDescDominio)) + @""" readonly=""readonly""/>");

                        }
                    }

                    srcFram = "./LoadExtendedAttrib.asp?MultiValue=1&TypeAttrib=4&titoloFinestra=" + UrlEncode(mp_caption) + @"&IdDomain=" + UrlEncode(Domain.Id) + @"&Attrib=" + UrlEncode(Name) + @"&Format=" + UrlEncode(strFormat) + @"&Editable=" + vEditable + @"&Suffix=&Filter=" + UrlEncode(Domain.Filter) + @"&Value=";


                    if (senzaModali == "1")
                    {

                        funzioneJS = "openDomPopup";


                    }
                    else
                    {

                        funzioneJS = "dom_openDocModal";


                    }


                    string strClassTmp;


                    strClassTmp = "";


                    if (vEditable == true)
                    {
                        if (IsMasterPageNew())
                        {
                            objResp.Write($@"<input type=""button"" class=""FldExtDom_button DateFaseII"" alt=""Inserisci valore"" value="" ... ""  id=""" + Name + @"_button"" name=""" + Name + @"_button"" onclick=""" + funzioneJS + @"('" + EscapeSequenceJS(Name) + @"','" + EscapeSequenceJS(HtmlEncodeValue(srcFram)) + @"', 'dialog-iframe-" + Domain.Id + @"');"" />" + Environment.NewLine);
                        }
                        else
                        {
                            objResp.Write($@"<input type=""button"" class=""FldExtDom_button"" alt=""Inserisci valore"" value="" ... ""  id=""" + Name + @"_button"" name=""" + Name + @"_button"" onclick=""" + funzioneJS + @"('" + EscapeSequenceJS(Name) + @"','" + EscapeSequenceJS(HtmlEncodeValue(srcFram)) + @"', 'dialog-iframe-" + Domain.Id + @"');"" />" + Environment.NewLine);

                        }
                    }
                    else
                    {


                        objResp.Write($@"<input ");


                        strClassTmp = " float_right";

                        objResp.Write($@"type=""button"" class=""FldExtDom_button" + strClassTmp + @""" alt=""Inserisci valore"" value=""...""  id=""" + Name + @"_button"" name=""" + Name + @"_button"" onclick=""" + funzioneJS + @"('" + EscapeSequenceJS(Name) + @"','" + EscapeSequenceJS(HtmlEncodeValue(srcFram)) + @"', 'dialog-iframe-" + Domain.Id + @"');"" />" + Environment.NewLine);


                    }


                    objResp.Write($@"<input type=""hidden"" ");



                    objResp.Write($@" class=""display_none attrib_base""");

                    objResp.Write($@" id=""" + HtmlEncodeValue(Name) + @""" name=""" + HtmlEncodeValue(Name) + @""" value=""" + HtmlEncodeValue(CStr(Value)) + @""" ");


                    if (!string.IsNullOrEmpty(mp_OnChange))
                    {
                        objResp.Write($@" onchange=""" + mp_OnChange + @""" ");
                    }


                    objResp.Write($@"/>");

                }
                else
                {

                    //'-- inserisco un input hidden contenente informazioni tecniche di varia natura. questo per eliminare
                    //'-- attributi non esistenti nello standard w3c. Gli attributi estesi saranno presenti come value
                    //'-- della input hidden nella forma nomeAttributo#=#valoreAttributo#@#nomeAttributo#=#valoreAttributo
                    objResp.Write($@"<input type=""hidden"" id=""val_" + HtmlEncodeValue(Name) + @"_extraAttrib"" value=""value#=#" + HtmlEncodeValue(CStr(this.Value)) + @"""/>");



                    objResp.Write($@"<div id=""val_" + HtmlEncodeValue(Name) + @""" ");


                    if (!string.IsNullOrEmpty(Style))
                    {
                        objResp.Write($@" class=""" + HtmlEncodeValue(Style) + @""" ");
                    }

                    objResp.Write($@">");

                    FormattedField(objResp, vEditable);


                    objResp.Write($@"</div>" + Environment.NewLine);


                    //'-- Se non editabile e se richiesto alla format, metto il campo tecnico

                    if (vEditable == false && strFormat.Contains("T", StringComparison.Ordinal))
                    {
                        objResp.Write($@"<input type=""hidden"" name=""" + Name + @"""  id=""" + Name + @""" ");
                        //objResp.Write($@" value=""" + HtmlEncodeValue(CStr(Value)) + @""" ");
                        objResp.Write($" value=\"{HtmlEncodeValue(CStr(Value))}\"");
                        objResp.Write($@"/>" + Environment.NewLine);
                    }

                }


            }
        }
        private void HtmlOptionDraw(IEprocResponse objResp, bool? pEditable)
        {
            string sep;
            bool ba;
            string strDesc;
            DomElem? elem;
            DomElem? e;
            int l;
            bool bIns;
            string vf;
            
            Boolean bMultiValore;
            string strImageSel;
            string strImageUnSel;
            string strOnchange_MultiValue;
            string NameOrigin;
            int nCurrElem;
            int nElem_Is_Checked;
            string NameDesc;


			NameOrigin = Name;

            bMultiValore = false;

            strOnchange_MultiValue = "";

			//se la format contiene la M allora devo trattare come multivalore
			if (strFormat.Contains("M", StringComparison.Ordinal))
			{
                bMultiValore = true;
                strOnchange_MultiValue = "OnChangeDom_CheckMultiValue('" + HtmlEncodeJSValue(NameOrigin) + "');";
			}

			if (strFormat.Contains("H", StringComparison.Ordinal))
            {
                sep = "TD";
            }
            else
            {
                sep = "TR";
            }


            if (strFormat.Contains("A", StringComparison.Ordinal))
            {
                ba = true;
            }
            else
            {
                ba = false;
            }

			//'If pEditable = False And InStr(1, strFormat, "B") > 0 Then
			//if (pEditable == false)
			//se campo non editabile oppure multivalore disegno il campo nascosto
			if (pEditable == false || bMultiValore == true )
			{
                objResp.Write($@"<input type=""hidden"" name=""" + HtmlEncodeValue(Name) + @"""  id=""" + HtmlEncodeValue(Name) + @""" ");
                objResp.Write($@" value=""" + HtmlEncodeValue(CStr(this.Value)) + @"""/>");
            }



            objResp.Write($@"<table border=""0"" celpadding=""0"" celspacing=""0"" class=""" + HtmlEncodeValue(Style) + @"_OptionTAB"" >");


            if (sep == "TD")
            {
                objResp.Write($@"<tr>");
            }
            else
            {
            }


            if (Domain == null || Domain.GetRsElem() == null)
            {

            }
            else
            {

                string strI;
                string strA;
                TSRecordSet rsElem;

                nCurrElem = 0;

                rsElem = Domain.GetRsElem();
                if (rsElem != null)
                {

                    rsElem.MoveFirst();

                    while (rsElem.EOF == false)
                    {

                        //indica se un valore è selezionato
                        nElem_Is_Checked = 0;

                        //indice elemento corrente che mi serve se devo disegnare i checkbox per il mutivalore
                        nCurrElem++;

                        bIns = true;
                        if (!string.IsNullOrEmpty(mp_strFilter))
                        {
                            if ((InStrVb6(1, mp_strSepFilter + mp_strFilter + mp_strSepFilter, mp_strSepFilter + rsElem.Fields["DMV_Cod"] + mp_strSepFilter) > 0).ToString() != mp_InOutFilter.ToString())
                            {
                                bIns = false;
                            }
                        }


                        if (bIns == true)
                        {


                            //'-- determina la descrizione dell'elemento
                            vf = CStr(rsElem.Fields["DMV_Cod"]);
                            strI = "";
                            strI = CStr(rsElem.Fields["DMV_Image"]);
                            strA = "";
                            strA = CStr(rsElem.Fields["DMV_CodExt"]);

                            strDesc = FormattedElem(strI, strA, CStr(rsElem.Fields["DMV_DescML"]));

                            NameDesc = NameOrigin + "_Desc";

                            if ( bMultiValore)
							{
								NameDesc = NameOrigin + "_" + nCurrElem.ToString() + "_Desc";
							}


							if (sep == "TD")
                            {
                                objResp.Write($@"<td class=""DOM_OPT"">");
                                if (ba == false)
                                {
                                    objResp.Write(  "<div class=\"DOM_Desc_MultiValue\" id=\"" + NameDesc  + "\">" + HtmlEncode(strDesc) + "</div>" );
                                    objResp.Write("<br/>");
                                }
                            }
                            else
                            {
                                objResp.Write($@"<tr><td class=""DOM_OPT"" >");
                                if (ba == false)
                                {
									//objResp.Write(HtmlEncode(strDesc));
									objResp.Write("<div class=\"DOM_Desc_MultiValue\" id=\"" + NameDesc + "\">" + HtmlEncode(strDesc) + "</div>");
								}
                            }


                            if (pEditable == false)
                            {

                                //--CAMPO NON EDITABILE

                                strImageSel = "radioSel.gif";
                                strImageUnSel = "radioUnSel.gif";

                                //se multivalore disegno i checkbox e quindi metto immagine diversa se non editabile
                                if ( bMultiValore )
								{
									strImageSel = "checked.gif";
									strImageUnSel = "unchecked.gif";
								}

                                //determino se elemento corrente è selezionato
                                if ( bMultiValore == false )
								{
									//per singolo valore come prima il valore corrente deve coincidere con l'unico valore selezionato
									//if (vf == Value)
									//{
									//    objResp.Write($@"<img alt="""" src=""" + HtmlEncodeValue(PathImage) + @"radioSel.gif""/>");
									//}
									//else
									//{
									//    objResp.Write($@"<img alt="""" src=""" + HtmlEncodeValue(PathImage) + @"radioUnSel.gif""/>");
									//}
									if (vf == Value)
									{
										nElem_Is_Checked = 1;
									}
								}
                                else
								{
                                    //per i multivalore l'elemento corrente deve essere tra quelli selezionati (###....###...###)
                                    if ( InStrVb6(1,"###" + Value + "###", "###" + vf + "###") > 0 )
									{
                                        nElem_Is_Checked = 1;
									}
								}

                                if (nElem_Is_Checked == 1)
                                {
									objResp.Write($@"<img alt="""" src=""" + HtmlEncodeValue(PathImage) + strImageSel + @"""/>");
									//objResp.Write("<img alt=\"\" src=\"" + HtmlEncodeValue(PathImage) + strImageSel + "\">" );

								}
                                else
                                {
									objResp.Write($@"<img alt="""" src=""" + HtmlEncodeValue(PathImage) + strImageUnSel + @"""/>");
									//objResp.Write("<img alt=\"\" src=\"" + HtmlEncodeValue(PathImage) + strImageUnSel + "\">");

								}

                            }
							else
                            {

                                //--CAMPO EDITABILE

                                if ( bMultiValore == false )
								{
									//'-- mette il radio button agg. classe di stile
									objResp.Write($@"<input type=""radio"" class=""DomRadio_Opt"" ");
								}
                                else
								{
									// -- mette il checkbox agg. classe di stile
									objResp.Write($@"<input type=""checkbox"" class=""DomCheck_Opt""  ");
								}

                                //--nel caso di multivalore i checkbox devono avere tutti un nome e id differente
                                if ( bMultiValore == true )
								{
                                    Name = NameOrigin + "_" + nCurrElem.ToString() + "_V";
								}

								objResp.Write($@" value=""" + HtmlEncodeValue(vf) + @""" id=""" + HtmlEncodeValue(Name) + @"""  name=""" + HtmlEncodeValue(Name) + @""" ");
                                
                                //--determino se elemento corrente è selezionato
                                if ( bMultiValore == false )
								{
                                    //--per singolo valore come prima il valore corrente deve coincidere con l'unico valore selezionato
									if (vf == Value)
									{
                                        nElem_Is_Checked = 1;
									}
								}
                                else
								{
									//per i multivalore l'elemento corrente deve essere tra quelli selezionati (###....###...###)
									if ( InStrVb6(1, "###" + Value + "###", "###" + vf + "###") > 0 )
									{
										nElem_Is_Checked = 1;
									}
								}

							    //if (vf == Value)
                                if (nElem_Is_Checked == 1)
                                {
                                    objResp.Write($@" checked=""checked"" ");
                                }


                                //if (pEditable == true)
                                //{
                                if ( bMultiValore == false)
								{
									if (!string.IsNullOrEmpty(mp_OnChange))
                                    {
                                        objResp.Write($@" onchange=""javascript:" + HtmlEncodeValue(mp_OnChange) + @""" ");
                                    }
								}
                                else
								{

									//--aggiungo funzione onchange per aggiornare il valore del campo tecnico
									objResp.Write($@" onchange=""javascript:" + HtmlEncodeValue(strOnchange_MultiValue) );

                                    //--aggiungo se configurata funzione di onchange aggiuntiva
									if (!string.IsNullOrEmpty(mp_OnChange))
									{
										objResp.Write ( HtmlEncodeValue(mp_OnChange) );
									}

                                    //chiudo onchange
                                    objResp.Write( @" "" " );
								}
								//}


								//if (pEditable == false)
								//{
								//    objResp.Write($@" onfocus=""this.blur();"" ");
								//}

								objResp.Write(">");
                            }

                            if (sep == "TD")
                            {
                                if (ba == true)
                                {
                                    objResp.Write("<br/>");
									objResp.Write("<div class=\"DOM_Desc_MultiValue_AFTER\" id=\"" + NameDesc + "\">" + HtmlEncode(strDesc) + "</div>");
									//objResp.Write(HtmlEncode(strDesc));
								}
                                objResp.Write("</td>");
                            }
                            else
                            {
                                if (ba == true)
                                {
									objResp.Write("<div class=\"DOM_Desc_MultiValue_AFTER\" id=\"" + NameDesc + "\">" + HtmlEncode(strDesc) + "</div>");
									//objResp.Write(HtmlEncode(strDesc));
								}
                                objResp.Write("</td></tr>");
                            }



                        }


                        rsElem.MoveNext();
                    }
                }
            }

            if (sep == "TD")
            {
                objResp.Write("</tr>");
            }
            else
            {
            }


            objResp.Write("</table>");
        }

        public override void HtmlExtended(IEprocResponse objResp, dynamic? Request = null) { }
        public override void HtmlExtended2(IEprocResponse objResp, dynamic? Request = null, dynamic? session = null) { }
        public override void HtmlExtended3(IEprocResponse objResp, dynamic? Request = null, dynamic? session = null)
        {
            //DomElem? e;
            string vf;
            string dataAttrib;

            if (Request != null)
            {
                mp_OnChange = GetParamURL(Request, "ONCHANGE");
            }

            objResp.Write($@"<ul>" + Environment.NewLine);

            if (Domain != null && Domain.GetRsElem() == null)
            {

                foreach (KeyValuePair<string, dynamic> e in Domain.Elem)
                {
                    objResp.Write($@"<li id=""" + HtmlEncodeValue(CStr(e.Value.Id)) + $@""" title=""" + HtmlEncodeValue(CStr(e.Value.Desc)) + $@""" Data = """ + getDataAttrib(e.Value, false) + $@""">" + HtmlEncode(UCase(CStr(e.Value.Desc))) + Environment.NewLine);
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
                            objResp.Write($@"<li id=""" + HtmlEncodeValue(CStr(vf)) + $@""" title=""" + HtmlEncodeValue(CStr(rsElem.Fields["DMV_DescML"]).ToUpper()) + $@""" Data = """ + getDataAttrib(rsElem, true) + $@""">" + HtmlEncode(CStr(rsElem.Fields["DMV_DescML"]).ToUpper()) + Environment.NewLine);

                        }
                        rsElem.MoveNext();
                    }
                }
            }

            objResp.Write($@"</ul>");
        }
        public override void Init(int iType, string oName = "", object? oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false)
        {
            base.Init(iType, oName, oValue, oDom, oumDom, oFormat, oEditable, oObbligatory, oValidazioneFormale);

            Rows = 1;

            if (strFormat.Contains("M", StringComparison.Ordinal))
            {
                MultiValue = 1;
            }
            else
            {
                MultiValue = 0;
            }


            mp_caption = "";

        }
        public override void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/")
        {
            if (!js.ContainsKey("FldDom"))
                js.Add("FldDom", $@"<script src=""" + Path + $@"jscript/Field/FldDom.js"" ></script>");
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
            Value = base.SQLValue();
            return "'" + CStr(this.Value).Replace("'", "''") + "'";
        }
        public override string TechnicalValue()
        {
            if (this.Value == null)
            {
                return null;
            }
            else
            {
                return CStr(this.Value);
            }
            //return IIF(IsNull(this.Value), "", this.Value.ToString());
        }
        public override void toPrint(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;
            base.toPrint(objResp, pEditable);
            dynamic? strVal = IIF(IsNull(Value), "", Value);
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
                    if (limite == 0 || (Value.Split("###").Length - 1) > limite)
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

                        objResp.Write(HtmlEncode(listaDescs).Replace("&lt;br/&gt;", "<br/>"));

                    }

                }

            }


            this.Name = originaleName;
        }
        public override void toPrintExtraContent(IEprocResponse objResp, dynamic OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {
            string originaleName = this.Name;
            string? strVal = IIF(IsNull(Value), "", CStr(Value));
            bool? vEditable = false;

            if (Obbligatory == true && string.IsNullOrEmpty(strVal) && vEditable == true && Domain != null)
            {
                strVal = Domain.GetSingleValue();
            }

            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
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
                if (limite == 0 || Value.Split("###").Length - 1 > limite)
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

                    if (startPage == "")
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
                                if (contaPagine = false && totRows == 0)
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
            //On Error Resume Next
            DomElem? elem;
            try
            {
                elem = Domain != null ? Domain.FindCode(CStr(Value)) : null;
            }
            catch
            {
                elem = null;
            }
            if (elem != null)
            {
                return FormattedElem("", elem.CodExt, elem.Desc);
            }
            else
            {
                return "";
            }
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
            string? strVal = IIF(IsNull(Value.ToString()), "", Value.ToString());
            bool? vEditable = (pEditable == null) ? Editable : pEditable;
            if (Obbligatory == true && string.IsNullOrEmpty(strVal.ToString()) && vEditable == true)
            {

                strVal = Domain != null ? Domain.GetSingleValue(strFormat) : null;

                if (!string.IsNullOrEmpty(strVal))
                {

                    if (MultiValue == 1 || strFormat.Contains("M", StringComparison.Ordinal))
                    {

                        strVal = "###" + strVal + "###";

                    }

                }

            }

            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            this.Value = strVal;
            this.mp_caption = Caption;

            this.Html(objResp, vEditable);

            this.Name = originaleName;
        }
        public override void xml(IEprocResponse objResp, string tipo)
        {
            objResp.Write($@"<{XmlEncode(UCase(Name))} desc=""{XmlEncode(CStr(Caption))}"" type=""{getFieldTypeDesc(mp_iType)}"">");

            //On Error Resume Next

            DomElem? elem;
            int iZ;
            string tmp;

            if ((!IsNull(Value)))
            {

                if (!string.IsNullOrEmpty(CStr(Value)))
                {

                    //'-- Contenuto xml tra l'apertura e la chiusura del tag del field

                    elem = Domain != null ? Domain.FindCode(CStr(Value)) : null;

                    if (elem != null && !IsEmpty(elem))
                    {

                        objResp.Write($@"<" + XmlEncode(UCase(Name)) + $@"_VALUE codice=""" + XmlEncode(CStr(Value)) + $@"""");

                        tmp = "";
                        //'-- Se � presente il codice esterno sul domElem
                        if ((!string.IsNullOrEmpty(elem.CodExt)))
                        {
                            tmp = $@" codext=""" + XmlEncode(CStr(elem.CodExt)) + $@"""";
                        }

                        objResp.Write(tmp + ">");
                        objResp.Write(XmlEncode(CStr(elem.Desc)));
                        objResp.Write($@"</" + XmlEncode(UCase(Name)) + $@"_VALUE>" + Environment.NewLine);

                    }
                    else
                    {

                        objResp.Write($@"<" + XmlEncode(UCase(Name)) + $@"_VALUE codice=""" + XmlEncode(CStr(Value)) + $@""">");

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

                        objResp.Write(tmp);
                        objResp.Write($@"</" + XmlEncode(CStr(UCase(Name))) + "_VALUE>" + Environment.NewLine);

                    }

                    //ScopeLayer.flush

                    //Set elem = Nothing

                }

            }

            //err.Clear

            objResp.Write($@"</{XmlEncode(UCase(Name))}>");
        }
        public override void UpdateFieldVisual(IEprocResponse objResp, string strDocument = "")
        {
            string originaleName = this.Name;
            base.UpdateFieldVisual(objResp, strDocument);

            string strObjHTML;
            DomElem? elem;
            int iZ;

            objResp.Write($@"<script type=""text/javascript"">" + Environment.NewLine);

            //On Error Resume Next
            elem = Domain != null ? Domain.FindCode(CStr(Value)) : null;

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

                if (elem.Desc.Length > nC)
                {

                    string strDesc;
                    strDesc = elem.Desc;
                    strObjHTML = $@"<label  title=""" + HtmlEncodeValue(strDesc) + $@""">";
                    strDesc = Strings.Left(strDesc, nC - 1) + "...";

                    strObjHTML = strObjHTML + FormattedElem(elem.Image, elem.CodExt, strDesc);

                    strObjHTML = strObjHTML + "</label>";

                }
                else
                {
                    strObjHTML = FormattedElem(elem.Image, elem.CodExt, elem.Desc);

                }

            }
            else
            {

                iZ = InStrVb6(1, strFormat, "V");
                if (iZ > 0)
                {
                    strObjHTML = HtmlEncode(CStr(Value));
                }
                else
                {
                    strObjHTML = "N.C.";
                }

            }


            //'-- rimpiazzo il contenuto dell'oggetto a video

            if (!string.IsNullOrEmpty(strDocument))
            {
                objResp.Write($@"try{{ " + strDocument + $@".getObj('" + HtmlEncodeJSValue(Name) + $@"').value = '" + HtmlEncodeJSValue(CStr(Value)) + $@"';");
                objResp.Write($@"try{{" + strDocument + $@".getObj('val_" + HtmlEncodeJSValue(Name) + $@"').innerHTML ='" + Replace(strObjHTML, $@"'", $@"\'") + $@"'}}catch(e){{}};" + Environment.NewLine);
                objResp.Write($@"}}catch(e){{}};" + Environment.NewLine);

            }
            else
            {

                objResp.Write($@"try{{ getObj('" + HtmlEncodeJSValue(Name) + "').value = '" + HtmlEncodeJSValue(CStr(Value)) + "';");
                objResp.Write($@"try{{getObj('val_" + HtmlEncodeJSValue(Name) + "').innerHTML ='" + Replace(strObjHTML, $@"'", $@"\'") + $@"'}}catch(e){{}};" + Environment.NewLine);
                objResp.Write($@"}}catch(e){{}};" + Environment.NewLine);

            }
            objResp.Write($@"</script>");


            this.Name = originaleName;
        }
        public override void Excel(CommonModule.IEprocResponse objResp, bool? pEditable = null)
        {
            string oldstrFormat;
            string Value;

            oldstrFormat = strFormat;
            strFormat = strFormat.Replace("I", "");

            if (MultiValue == 1 || strFormat.Contains("M", StringComparison.Ordinal))
            {

                Value = getMultivalueDesc(strFormat);
                objResp.Write(HtmlEncode(CStr(Value)));

            }
            else
            {

                FormattedField(objResp, false);

            }
            strFormat = oldstrFormat;
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

            aInfo = Value.Split("###");

            n = aInfo.Length - 1;

            for (i = 1; i <= n - 1; i++)
            {

                if (!string.IsNullOrEmpty(CStr(aInfo[i])))
                {

                    totElem = totElem + 1;

                    elem = Domain != null ? (DomElem?)Domain.FindCode(CStr(aInfo[i])) : null;
                    //'Quando il dominio � editable e non ci sta la format per mostrare i DELETED ed il valore � deleted viene rimosso

                    if (elem != null)
                    {
                        strDesc = elem.Desc;
                    }

                }

            }

            //'-- Se c'� un solo elemento selezionato uscir� la sua descrizione altrimenti
            //'-- N Selezionati dove N � il numero di elementi selezionati
            if ((totElem > 1))
            {

                strDesc = CStr(totElem) + " " + SelezionatiDescription;

            }
            else if ((totElem == 0))
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

            if ((isRecordset))
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

            string strToReturn;

            string[] aInfo;
            int i;
            int n;
            string strDesc = "";
            DomElem? elem;
            string tmpDesc;

            //On Error Resume Next

            strToReturn = "";

            if (string.IsNullOrEmpty(Value))
            {
                return strToReturn;
            }

            aInfo = Value.Split("###");

            n = aInfo.Length - 1;

            for (i = 1; i <= n - 1; i++)
            {

                elem = (DomElem?)Domain.FindCode(CStr(aInfo[i]));

                if (elem != null)
                {
                    tmpDesc = FormattedElem("", elem.CodExt, elem.Desc);
                    strDesc = IIF((strDesc == ""), tmpDesc, strDesc + "<br/>" + tmpDesc);
                }

            }


            strToReturn = strDesc;


            return strToReturn;

        }

        private string FormattedElem(string Image, string CodExt, string Desc)
        {

            string strApp = "";
            int i;
            int l;
            string c;
            string format = strFormat;
            int iZ;

            iZ = Strings.InStr(1, strFormat, "Z");
            if (iZ > 0)
            {

                int nC;

                nC = CInt(Strings.Mid(strFormat, iZ + 1, 2));
                format = Strings.Replace(format, Strings.Mid(format, iZ, 3), "");

            }

            //'-- Se nella format non c'� una format che preveda la forma visuale ( C, I, D ) aggiungo in automatico la D alla format
            if (!format.Contains('D', StringComparison.Ordinal) && !format.Contains('C', StringComparison.Ordinal) && !format.Contains('I', StringComparison.Ordinal))
            {
                format = format + "D";
                strFormat = format;
            }

            l = format.Length;

            //'-- nel caso non sia specificato il formato per default � solo descrizione
            if (l == 0)
            {
                l = 1;
                strFormat = "D";
                format = "D";
            }

            //'-- ciclo sulla formattazione
            for (i = 1; i <= l; i++)
            {

                c = Strings.Mid(format, i, 1);

                switch (c)
                {
                    case "I":
                        if (!string.IsNullOrEmpty(strApp))
                        {
                            strApp += " - ";
                        }

                        strApp += $@"<img alt=""";

                        if (!string.IsNullOrEmpty(Desc))
                        {
                            strApp += Desc;
                        }


                        strApp += $@""" src=""" + HtmlEncodeValue(PathImage + Image) + $@"""/>";
                        break;

                    case "C":
                        if (!string.IsNullOrEmpty(strApp))
                        {
                            strApp += " - ";
                        }
                        strApp += CodExt;

                        break;

                    case "D":
                        if (!string.IsNullOrEmpty(strApp))
                        {
                            strApp += " - ";

                        }

                        //'-- se è stato chiesto che gli elementi del dominio siano tutti MAIUSCOLI
                        if (strFormat != null && strFormat.ToUpper().Contains('U', StringComparison.Ordinal))
                        {
                            strApp += HtmlEncodeMinimal(Desc).ToUpper();
                        }
                        else if (strFormat != null && strFormat.ToUpper().Contains('P', StringComparison.Ordinal))
                        { //'-- la L e la M erano già occupate
                            strApp += HtmlEncodeMinimal(Desc).ToLower();
                        }
                        else
                        {
                            strApp += HtmlEncodeMinimal(Desc);
                        }
                        break;
                    default:
                        break;
                }


            }

            return strApp;

        }

        private void FormattedField(IEprocResponse objResp, bool? Editable)
        {

            //'Dim strApp As String
            DomElem? elem;
            //DomElem? e;
            int l;
            bool bIns;
            string vf;
            int iZ;
            int iP;
            string strDescTooltip;


            //On Error Resume Next

            //'-- nel caso non sia specificato il formato per default � solo descrizione
            try
            {
                l = strFormat.Length;
            }
            catch
            {
                l = 1;
                strFormat = "D";
            }
            if (l == 0)
            {
                l = 1;
                strFormat = "D";
            }

            //'-- Se nella format non c'� una format che preveda la forma visuale ( C, I, D ) aggiungo in automatico la D alla format
            if (!strFormat.Contains('D', StringComparison.Ordinal) && !strFormat.Contains('C', StringComparison.Ordinal) && !strFormat.Contains('I', StringComparison.Ordinal))
            {
                strFormat = strFormat + "D";
            }

            if (Editable == true)
            {

                objResp.Write($@"<select id=""" + HtmlEncode(Name) + $@""" size=""" + Rows + $@""" name=""" + HtmlEncodeValue(Name) + $@""" ");
                if (!string.IsNullOrEmpty(mp_OnFocus))
                {
                    objResp.Write($@" onfocus=""javascript:" + HtmlEncodeValue(mp_OnFocus) + $@""" ");
                }

                if (!string.IsNullOrEmpty(Style))
                {
                    objResp.Write($@" class=""" + HtmlEncodeValue(Style) + $@""" ");
                }
                if (width < 0)
                {
                    objResp.Write($@" style=""width: " + (-width) + $@""" ");
                }

                if (!string.IsNullOrEmpty(mp_OnChange))
                {
                    objResp.Write($@"onchange=""javascript:" + HtmlEncodeValue(mp_OnChange) + $@""" ");
                }
                objResp.Write($@">");


                //'-- aggiungo l'elemento vuoto per consentire la selezione del dominio - la format S lo esclude
                objResp.Write($@"<option value="""" >");
                if (!strFormat.Contains('S', StringComparison.Ordinal))
                {
                    objResp.Write(SelectDescription);
                }
                objResp.Write($@"</option>");

                l = 0;

                if (Domain != null && Domain.GetRsElem() == null)
                {

                    foreach (KeyValuePair<string, dynamic> e in Domain.Elem)
                    {
                        bIns = true;
                        if (!string.IsNullOrEmpty(mp_strFilter))
                        {
                            if ((Strings.InStr(1, mp_strSepFilter + mp_strFilter + mp_strSepFilter, mp_strSepFilter + e.Value.id + mp_strSepFilter) > 0) != mp_InOutFilter)
                            {
                                bIns = false;
                            }
                        }


                        if (bIns == true)
                        {
                            objResp.Write($@"<option ");
                            objResp.Write($@" value=""" + e.Value.id + $@""" id=""" + HtmlEncode(Name) + "_" + e.Value.id + $@""" ");
                            if (e.Value.id == CStr(Value))
                            {
                                objResp.Write($@"selected=""selected""");
                            }


                            //'--se richiesto aggiunto tooltip con codice esterno
                            if (strFormat.Contains('P', StringComparison.Ordinal))
                            {
                                objResp.Write($@" title = """ + HtmlEncodeValue(e.Value.ToolTip) + $@"""");
                            }

                            objResp.Write($@">");



                            objResp.Write(FormattedElem(e.Value.Image, e.Value.CodExt, e.Value.Desc));


                            objResp.Write($@"</option>");
                        }


                    }
                }
                else
                {
                    string strI;
                    string strA;
                    TSRecordSet? rsElem;
                    rsElem = Domain != null ? Domain.GetRsElem() : null;
                    if (rsElem != null)
                    {

                        rsElem.MoveFirst();

                        while (rsElem.EOF == false)
                        {
                            bIns = true;
                            if (!string.IsNullOrEmpty(mp_strFilter))
                            {

                                if ((Strings.InStr(1, mp_strSepFilter + mp_strFilter + mp_strSepFilter, mp_strSepFilter + CStr(GetValueFromRS(rsElem.Fields["DMV_Cod"])) + mp_strSepFilter) > 0) != mp_InOutFilter)
                                {
                                    bIns = false;
                                }


                            }
                            try
                            {
                                if (CInt(GetValueFromRS(rsElem.Fields["DMV_Deleted"])) == 1)
                                {
                                    if (!strFormat.Contains('Y', StringComparison.Ordinal))
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
                                vf = CStr(rsElem.Fields["DMV_Cod"]);
                                objResp.Write($@"<option ");
                                objResp.Write($@" value=""" + HtmlEncodeValue(vf) + $@""" id=""" + HtmlEncode(Name) + "_" + HtmlEncodeValue(vf) + $@""" ");
                                if (vf == CStr(Value))
                                {
                                    objResp.Write($@"selected=""selected""");
                                }

                                //'--se richiesto aggiunto tooltip dalla colonna DMV_ToolTip
                                if (strFormat.Contains('P', StringComparison.Ordinal))
                                {
                                    try
                                    {
                                        objResp.Write($@" title = """ + HtmlEncodeValue(CStr(rsElem.Fields["DMV_ToolTip"])) + $@"""");
                                    }
                                    catch
                                    {

                                    }

                                }


                                objResp.Write($@">");

                                strI = "";
                                if (rsElem.ColumnExists("DMV_Image"))
                                {
                                    strI = CStr(rsElem.Fields["DMV_Image"]);
                                }
                                strA = "";
                                if (rsElem.ColumnExists("DMV_CodExt"))
                                {
                                    strA = CStr(rsElem.Fields["DMV_CodExt"]);
                                }
                                //err.Clear

                                objResp.Write(FormattedElem(strI, strA, CStr(rsElem.Fields["DMV_DescML"])));

                                objResp.Write($@"</option>");
                            }

                            rsElem.MoveNext();
                        }
                    }


                }

                objResp.Write($@"</select>");


            }
            else
            { //'-- campo non editabile
                //On Error Resume Next
                elem = Domain != null ? Domain.FindCode(CStr(Value)) : null;

                if (elem != null)
                {

                    //'-- controllo se mettere il tooltip
                    int nC;

                    iZ = Strings.InStr(1, strFormat, "Z");
                    if (iZ > 0)
                    {
                        nC = CInt(Strings.Mid(strFormat, iZ + 1, 2));
                    }
                    else
                    {
                        nC = 32000;
                    }

                    string strDesc = String.Empty;

                    if (!String.IsNullOrEmpty(elem.Desc))
                    {
                        strDesc = elem.Desc;
                    }

                    iP = Strings.InStr(1, strFormat, "P");

                    if (strDesc.Length > nC)
                    {

                        strDescTooltip = strDesc;

                        //'--se richiesto tooltip aggiuntivo aggiungo il codice esterno al tooltip
                        if (iP > 0)
                        {
                            strDescTooltip = elem.ToolTip;
                        }

                        objResp.Write($@"<label  title=""" + HtmlEncodeValue(strDescTooltip) + $@""" >");

                        strDesc = Strings.Left(strDesc, nC - 1) + "...";

                        objResp.Write(FormattedElem(elem.Image, elem.CodExt, strDesc));

                        objResp.Write($@"</label>");

                    }
                    else
                    {
                        if (IsMasterPageNew())
                        {
							
							objResp.Write($@"<span  title=""" + ExtractTextFromHtml(strDesc) + $@""" >");
							
							objResp.Write(FormattedElem(elem.Image, elem.CodExt, strDesc));

							objResp.Write($@"</span>");
							
						}
                        else
                        {
                            //'--se richiesto tooltip lo aggiungo con codice esterno
                            if (iP > 0)
                            {
                                objResp.Write($@"<label  title=""" + HtmlEncodeValue(elem.ToolTip) + $@""" >");
                            }

                            objResp.Write(FormattedElem(elem.Image, elem.CodExt, strDesc));

                            if (iP > 0)
                            {
                                objResp.Write($@"</label>");
                            }

                        }


                    }

                }
                else
                {

                    iZ = Strings.InStr(1, strFormat, "V");
                    if (iZ > 0)
                    {
                        objResp.Write(HtmlEncode(CStr(Value)));
                    }
                    else
                    {
                        if (!strFormat.Contains('I', StringComparison.Ordinal))
                        {

                            if (!IsNull(Value))
                            {
                                objResp.Write($@"N.C.");
                            }

                        }
                        else
                        {
                            objResp.Write($@"&nbsp;");
                        }
                    }

                }

            }

        }

        public override void SetRows(int nNumRows)
        {
            base.SetRows(nNumRows);
            this.Rows = nNumRows;
        }


    }
}

