using Microsoft.Extensions.Primitives;
using Microsoft.VisualBasic;
using System.Web;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.HTML
{
    public class Field : IField, ICloneable
    {
        public string Name { get; set; } = "";           //'-- Identificativo del field
        public string? Caption { get; set; }        //'-- nome del campo

        protected int mp_iType = default;     //'-- tipologia del campo, è in stretta relazione con il campo del db DZT_Type della tabella LIB_Dictionary

        private dynamic? _value; //Backing field

        public dynamic? Value //'-- valore tecnico del campo
        {
            get
            {
                return _value;
            }
            set
            {
                try
                {
                    if (value is null || value is DBNull)
                    {
                        _value = null;
                    }
                    else if (value is StringValues)
                    {
                        StringValues temp = new();
                        temp = value;
                        _value = temp.First();
                    }
                    else
                    {
                        _value = value;
                    }
                }
                catch (Exception)
                {
                    _value = value;
                }

            }
        }

        public dynamic? DefaultValue { get; set; }        //'-- in caso di valore assente o vuoto viene usato questo valore nella visualizzazione

        public ClsDomain? Domain { get; set; } = null; //'-- per i domini chiusi contiene la collezione di valori
        public ClsDomain? umDomain { get; set; } = null; //'-- per i campi con unità di misura

        protected bool Editable = false;
        public bool Obbligatory = false;

        public string? Style;          //'-- style associato al campo

        public string? _strFormat; //Backing field strFormat

        public string? strFormat
        {
            get
            {
                return _strFormat;
            }
            set
            {
                //Codice per retrocompatibilità con il metabase
                if (value == "dd/mm/yyyy")
                {
                    _strFormat = "dd/MM/yyyy";
                }
                else if (value == "dd/mm/yyyy HH:MM:SS") //Codice per retrocompatibilità con il metabase
                {
                    _strFormat = "dd/MM/yyyy HH:mm:ss";
                }
                else if (value == "dd/mm/yyyy hh:mm:ss")//Codice per retrocompatibilità con il metabase
                {
                    _strFormat = "dd/MM/yyyy HH:mm:ss";
                }
                else if (value == "dd/mm/yyyy hh:mm") //Codice per retrocompatibilità con il metabase
                {
                    _strFormat = "dd/MM/yyyy HH:mm";
                }
                else if (value == "DD/MM/YYYY")
                {
                    _strFormat = "dd/MM/yyyy";
                }
                else
                {
                    _strFormat = value;
                }

            }
        }     /* '-- formato di visualizzazione
                                        '-- modalit� di visualizzazione per i domini chiusi vale
                                        '-- "" or "D" = solo descrizione
                                        '-- "C" = solo codice esterno
                                        '-- "CD" = codice + descrizione
                                        '-- "I" = solo immagine
                                        '-- "ID" = immaggine + descrizione
                                        '-- "IC" = immaggine + codice
                                        '-- "ICD" = immaggine + codice + descrizione*/

        //'- per i numerici e le date si applica la funzione FORMAT del VB
        public string? PathImage { get; set; }          //'-- percorso delle immaggini

        public string? ClassStyleCaption;  //'-- percorso degli style sheet
        public string? ClassStyleValue;    //'-- percorso degli style sheet

        //'-- contengono il nome della funzione JS da chiamare sul campo per l'evento considerato
        protected string? mp_OnFocus;
        protected string? mp_OnBlur;
        protected string? mp_OnChange;
        protected string? mp_OnClick;

        protected string? mp_row;              //'-- nel caso in cui il field viene usato in una griglia conterr� un valore diverso da vuoto

        public int? MaxLen { get; set; }             //'-- determina il numero massimo di caratteri
        public int? numDecimal { get; set; }         //'-- determina il numero massimo di decimali se il campo li prevede
        public string? sepDecimal { get; set; }          //'-- separatore dei decimali


        public int width { get; set; }               //'-- determina la larghezza del campo
        public string? Condition { get; set; }          //'-- Condizione da applicare alle ricerche

        public int? Position { get; set; }          //'-- contiene la posizione del campo in genere � la order nel modello
                                                    //'-- viene usata dai modelli per determinare in quale colonna posizionare l'attributo
        public int? colspan { get; set; }           //'-- indica sui modelli verticali se l'attributo raggruppa pi� celle
        public string? Help { get; set; }               //'-- aiuto sul campo , nei modeli verticali viene visualizzato sulla destra dell'attributo

        private int? _Error = 0;
        public int? Error
        {
            get
            {
                return _Error;
            }
            set
            {
                _Error = value;
            }
        }             //'-- contiene 1 per indicare errore, 2 per warning, 0 non c'� errore
        public string? ErrDescription { get; set; }     //'-- contiene il messaggio che viene mostrato sull'icona dell'errore

        public string? Path { get; set; }               //'-- percorso di base per tornare alla ROOT dell'applicazione ad esempio "../"

        public string? Language { get; set; }           //'-- contiene il prefisso della linga utilizzata: es.. "I" per italiano

        public string? ConnectionString { get; set; }   //'-- contiene la stringa di connessione

        public string? PredefiniteVisualDescription { get; set; } //'-- descrizioni visuali per il field desc1#~desc2#~...#~descn
        private int? mp_Rows; //'--num righe per visualizzare il controllo
        public int? MultiValue { get; set; } //'--1 attributo multivalore,0 no

        public bool validazioneFormale { get; set; } = false; //'--Identifica se il field deve essere validato formalmente per essere considerato valido (ad es: validazione email, piva, etc)
        public string? regExp { get; set; }              //'--Espressione regolare per la validazione formale del field
        public string msg_errore_validate { get; set; } = "";
        public bool? disattivaValidazioneFormale { get; set; }

        public bool isLazy { get; set; } = false;     //'-- true, se si vuole che il dominio gerarchico sia caricato in modalit� lazy. false (default). altrimenti

        public int indexInModel { get; set; }

        public int getType()
        {
            return mp_iType;
        }

        public void SetRow2(string indRow)
        {
            mp_row = $"R{indRow}_";
        }

        public void SetRow(long indRow)
        {
            mp_row = $"R{indRow}_";
        }

        public Field()
        {
            PathImage = "../CTL_Library/images/Domain/";
            Editable = true;
            Obbligatory = false;
            ClassStyleCaption = "FldCaption";
            Condition = " = ";
            sepDecimal = ",";
            DefaultValue = "";
            Path = "../";
            Language = "I";
            ConnectionString = "";
            PredefiniteVisualDescription = "";
            validazioneFormale = false;
        }

        public string GetPredefiniteVisualDescription()
        {
            //ritorniamo stringa vuota di default, se la classe che estende FIELD necessità di una specifica implementazione ne farà l'override
            return string.Empty;
        }

        public void SetPredefiniteVisualDescription(string strValue)
        {
            //di default non fa unlla, se la classe che estende FIELD necessità di una specifica implementazione ne farà l'override
        }

        public void SetEditable(bool p)
        {
            this.Editable = p;
        }

        public virtual void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/")
        {
        }

        public virtual void Init(int iType, string oName = "", object? oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false)
        {

            this.mp_iType = iType;
            this.Value = oValue;
            Name = oName;
            this.Domain = oDom;
            this.umDomain = oumDom;
            strFormat = oFormat;
            Editable = oEditable;
            Obbligatory = oObbligatory;
            Caption = oName;
            validazioneFormale = oValidazioneFormale;

        }

        /// <summary>
        /// ritorna il codice html della caption
        /// </summary>
        /// <param name="objResp"></param>
        public void umCaptionHtml(CommonModule.IEprocResponse objResp)
        {

            if (umDomain is not null)
            {

                objResp.Write($@"<div id=""cap_{Name}"" ");
                if (!string.IsNullOrEmpty(ClassStyleCaption))
                {
                    objResp.Write($@"class = ""{ClassStyleCaption}""");
                }
                objResp.Write($@">");
                objResp.Write($@"{(HttpUtility.HtmlEncode(umDomain.Desc))}");
                objResp.Write($@"</div>");

            }

        }
        /// <summary>
        /// ritrona il codice html del vettore
        /// </summary>
        /// <param name="objResp"></param>
        /// <param name="pEditable"></param>
        public void umValueHtml(CommonModule.IEprocResponse objResp, bool? pEditable = null)
        {

            bool? vEditable;
            vEditable = Editable;

            if (umDomain is not null)
            {
                string strValue = Convert.ToString(Value);

                if (string.IsNullOrEmpty(strValue))
                {
                    strValue = DefaultValue;
                }

                if (pEditable is not null)
                {
                    vEditable = pEditable;
                }

                if (vEditable == false)
                {
                    int ind;
                    dynamic vet;

                    ind = Strings.InStr(1, strValue, "#");
                    if (strValue.Contains('#', StringComparison.Ordinal))
                    {
                        vet = Strings.Split(strValue, "#");
                        objResp.Write($@"{umDomain.Elem[vet(0)].Desc} ");
                    }

                }

            }

        }

        public virtual void Html(CommonModule.IEprocResponse objResp, bool? pEditable = null)
        {
        }

        public virtual void CaptionHtmlCenter(CommonModule.IEprocResponse objResp)
        {
        }

        /// <summary>
        /// ritorna il codice html della caption
        /// </summary>
        /// <param name="objResp"></param>
        public void CaptionHtml(CommonModule.IEprocResponse objResp)
        {

            objResp.Write($@"<label id=""cap_{Name}""");

            if (!string.IsNullOrEmpty(ClassStyleCaption))
            {
                objResp.Write($@" class=""{ClassStyleCaption}""");
            }

            CaptionHtmlCenter(objResp); //metodo che sarà specializzato/override dalla classe figlia

            objResp.Write($@">");

            if (this.Error is not null && this.Error != 0)
            {

                string strGifErr = "";
                string strAlt = "";

                if (this.Error == 1)
                {
                    strGifErr = "State_Err.gif";
                    strAlt = "Errore";
                }

                if (this.Error == 2)
                {
                    strGifErr = "State_Warning.gif";
                    strAlt = "Attenzione";
                }

                if (this.Error == 3)
                {
                    strGifErr = "info.gif";
                    strAlt = "Informazione";
                }

                objResp.Write($@"<img alt=""{strAlt}"" src=""{HttpUtility.HtmlEncode($"{PathImage}{strGifErr}")}"" title=""{HttpUtility.HtmlEncode(ErrDescription)}""/>");
            }

            objResp.Write($@"{Caption}");
            objResp.Write($@"</label>");


        }

        //'-- ritorna il codice html della caption
        public void CaptionExcel(CommonModule.IEprocResponse objResp)
        {
            objResp.Write($@"{Caption}");
        }

        public virtual void ValueHtml(CommonModule.IEprocResponse objResp, bool? pEditable = null)
        {
            dynamic strVal = "";
            string strCause = "";
            bool? vEditable;

            try
            {
                vEditable = Editable;
                strCause = "Entro nel metodo ValueHtml di Field";

                if (pEditable is not null)
                {
                    vEditable = pEditable;
                }

                strCause = "Setto me.value con il defaultvalue";
                if ((Value is null) || CStr(Value) == "")
                {
                    Value = DefaultValue;
                }

                if (umDomain is not null)
                {
                    int ind = InStrVb6(1, CStr(Value), "#");
                    strVal = MidVb6(CStr(Value), ind + 1);
                }
                else
                {
                    strCause = "Setto strVal con il valore del field";
                    strVal = IIF(IsNull(Value), "", Value);
                }

                strVal = (this.Value is null) ? "" : this.Value;
            }
            catch (Exception ex)
            {
                throw new Exception(strCause + " - " + ex.Message, ex);
            }

        }

        //'-- ritorna il codice html del valore
        public virtual void ValueExcel(CommonModule.IEprocResponse objResp, bool? pEditable = null)
        {
            dynamic strVal = "";
            string strCause = "";
            bool? vEditable;

            try
            {
                vEditable = Editable;
                strCause = "Entro nel metodo ValueHtml di Field";

                if (pEditable is not null)
                {
                    vEditable = pEditable;
                }

                strCause = "Setto me.value con il defaultvalue";
                if ((Value is null) || CStr(Value) == "")
                {
                    Value = DefaultValue;
                }

                if (umDomain is not null)
                {
                    int ind = InStrVb6(1, CStr(Value), "#");
                    strVal = MidVb6(CStr(Value), ind + 1);
                }
                else
                {
                    strCause = "Setto strVal con il valore del field";
                    strVal = IIF(IsNull(Value), "", Value);
                }


            }
            catch (Exception ex)
            {
                throw new Exception(strCause + " - " + ex.Message, ex);
            }
        }

        public virtual void Excel(CommonModule.IEprocResponse objResp, bool? pEditable = null)
        {
            //verrà sempre sovrascritto dalla classe figlia
        }

        private void Class_Initialize()
        {

            PathImage = "../CTL_Library/images/Domain/";
            Editable = true;
            Obbligatory = false;
            ClassStyleCaption = "FldCaption";
            Condition = " = ";
            sepDecimal = ",";
            DefaultValue = "";
            Path = "../";
            Language = "I";
            ConnectionString = "";
            PredefiniteVisualDescription = "";
            validazioneFormale = false;

        }

        public virtual string SQLValue()
        {

            if (string.IsNullOrEmpty(Value))
            {
                Value = DefaultValue;
            }

            return Value;
        }

        public void setOnFocus(string JS)
        {
            mp_OnFocus = JS;
        }

        public void setOnBlur(string JS)
        {
            mp_OnBlur = JS;
        }


        public void setOnChange(string JS)
        {
            mp_OnChange = JS;
        }


        public virtual void setOnClick(string JS)
        {
            mp_OnClick = JS;
        }

        public object Clone()
        {
            return MemberwiseClone();
        }

        public virtual void SetSelectDescription(string str)
        {
        }

        public virtual string TxtValue()
        {
            if (this.Value is null || string.IsNullOrEmpty(CStr(Value)))
                this.Value = DefaultValue;

            return CStr(this.Value);
        }

        public bool GetEditable()
        {
            return this.Editable;
        }

        public virtual void SetFilterDomain(string strFilter, string strSep = ",", bool InOut = true)
        {
        }


        public virtual void HtmlExtended(CommonModule.IEprocResponse objResp, dynamic? Request = null)
        {

        }

        public virtual dynamic? RSValue()
        {

            if (Value == null || (Value is not null && Value.GetType() == typeof(string) && Value == ""))
            {
                this.Value = DefaultValue;
            }

            return this.Value;
        }

        //'-- ritorna il codice html del valore
        public string ValueExport(dynamic? valore = null)
        {
            dynamic strVal;

            if (valore is not null)
            {
                strVal = valore;
            }
            else
            {
                strVal = Value;
            }

            if ((strVal is null) || strVal == "")
            {
                strVal = DefaultValue;
            }

            //'-- se il campo prevede l'unità di misura si scompone il valore
            if (umDomain is not null)
            {
                int ind = InStrVb6(1, CStr(Value), "#");
                strVal = MidVb6(CStr(Value), ind + 1);
            }

            //'-- ritorno sempre una stringa per la lunghezza massima definita
            strVal = $"{strVal}{Strings.Space(width)}";
            strVal = Strings.Left(strVal, width);

            return strVal;
        }

        public dynamic GetVetInfo(ref dynamic[] vetInfo)
        {


            vetInfo[FIELD_mp_iType] = mp_iType;
            vetInfo[FIELD_Name] = Name;
            vetInfo[FIELD_Value] = Value;
            vetInfo[FIELD_Domain] = Domain is not null ? Domain.Id : "";
            vetInfo[FIELD_umDomain] = umDomain is not null ? umDomain.Id : "";
            vetInfo[FIELD_DomainFilter] = Domain is not null ? Domain.Filter : "";
            vetInfo[FIELD_strFormat] = strFormat;
            vetInfo[FIELD_Editable] = Editable;
            vetInfo[FIELD_Obbligatory] = Obbligatory;
            vetInfo[FIELD_Caption] = Caption;
            vetInfo[FIELD_PathImage] = PathImage;
            vetInfo[FIELD_ClassStyleCaption] = ClassStyleCaption;
            vetInfo[FIELD_ClassStyleValue] = ClassStyleValue;
            vetInfo[FIELD_mp_OnFocus] = mp_OnFocus;
            vetInfo[FIELD_mp_OnBlur] = mp_OnBlur;
            vetInfo[FIELD_mp_OnChange] = mp_OnChange;
            vetInfo[FIELD_mp_OnClick] = mp_OnClick;
            vetInfo[FIELD_MaxLen] = MaxLen;
            vetInfo[FIELD_numDecimal] = numDecimal;
            vetInfo[FIELD_sepDecimal] = sepDecimal;
            vetInfo[FIELD_width] = width;
            vetInfo[FIELD_Condition] = Condition;
            vetInfo[FIELD_Position] = Position;
            vetInfo[FIELD_colspan] = colspan;
            vetInfo[FIELD_Help] = Help;
            vetInfo[FIELD_Error] = Error;
            vetInfo[FIELD_ErrDescription] = ErrDescription;
            vetInfo[FIELD_DefaultValue] = DefaultValue;
            vetInfo[FIELD_Language] = Language;
            vetInfo[FIELD_ConnectionString] = ConnectionString;
            vetInfo[FIELD_GetPredefiniteVisualDescription] = GetPredefiniteVisualDescription();
            vetInfo[FIELD_Style] = Style;
            vetInfo[FIELD_mp_objFieldStyle] = Style;
            vetInfo[FIELD_mp_OnChange] = mp_OnChange;
            vetInfo[FIELD_Path] = Path;
            vetInfo[FIELD_Rows] = mp_Rows;
            vetInfo[FIELD_Multivalue] = MultiValue;
            vetInfo[FIELD_ValidazioneFormale] = validazioneFormale;
            vetInfo[FIELD_RegExp] = regExp;

            return vetInfo;


        }

        public void ClearRow()
        {
            mp_row = "";
        }

        public virtual void SetRows(int nNumRows)
        {
            mp_Rows = nNumRows;
        }

        public virtual void UpdateFieldVisual(CommonModule.IEprocResponse objResp, string strDocument = "")
        {
            this.Name = mp_row + Name;
        }

        public virtual void HtmlExtended2(CommonModule.IEprocResponse objResp, dynamic? Request = null, dynamic? session = null)
        {

        }

        public virtual string TechnicalValue()
        {
            return CStr(Value);
        }

        public virtual void xml(CommonModule.IEprocResponse objResp, string tipo)
        {
            //deve essere implementato sempre dalla classe figlia
        }

        public virtual void HtmlExtended3(CommonModule.IEprocResponse objResp, dynamic? Request = null, dynamic? session = null)
        {

        }

        public virtual void toPrint(CommonModule.IEprocResponse objResp, bool? pEditable = null)
        {

            dynamic strVal;
            bool? vEditable;
            vEditable = Editable;
            if (pEditable is not null)
            {
                vEditable = pEditable;
            }

            if ((Value is null) || CStr(Value) == "")
            {
                Value = DefaultValue;
            }

            //'-- se il campo prevede l'unit� di misura si scompone il valore
            if (umDomain is not null)
            {
                int ind = InStrVb6(1, CStr(Value), "#");
                strVal = MidVb6(CStr(Value), ind + 1);
            }
            else
                strVal = ((Value is null) ? "" : Value);
        }


        //'-- ritorna il codice html del valore per la stampa della parte finale ( gli 'allegati' alla stampa)
        public virtual void toPrintExtraContent(CommonModule.IEprocResponse objResp, object OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {


            string strVal;

            if ((Value is null) || CStr(Value) == "")
            {
                Value = DefaultValue;
            }

            //'-- se il campo prevede l'unit� di misura si scompone il valore
            if (umDomain is not null)
            {
                int ind = InStrVb6(1, CStr(Value), "#");
                strVal = MidVb6(CStr(Value), ind + 1);
            }
            else
            {
                strVal = ((Value is null) ? "" : CStr(Value));
            }

        }

        public virtual void SetPrintDescription(string str)
        {
        }

        public virtual void SetSelezionatiDescription(string str)
        {
        }

        public virtual void SetSenzaModali(string str)
        {
        }


        /// <summary>
        /// Funzione per la validazione formale dei campi.
        // Ritorna stringa vuota se tutto OK, viceversa il messaggio di errore
        /// </summary>
        /// <param name="params_"></param>
        /// <returns></returns>
        public virtual string validateField()
        {
            if (this.validazioneFormale && !validate())
            {
                return msg_errore_validate;
            }

            return "";
        }

        public virtual bool validate()
        {
            return true;
        }

        public virtual void UpdateFieldVisual(string objResp, string strDocument = "")
        {

        }
    }
}

