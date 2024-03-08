using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Http;
using Microsoft.VisualBasic;
using System.Data;
using System.Web;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class Model
    {

        public string id;
        public string Caption;//'-- Titolo del modello

        public string Style = "VerticalModel";//'-- Classe associata al modello

        public bool Editable = true;//'-- indica se il modello � editabile per default lo �

        private Dictionary<string, Field> _Fields = new Dictionary<string, Field>(StringComparer.OrdinalIgnoreCase);

        public Dictionary<string, Field> Fields
        {
            get { return _Fields; }
            set
            {
                var oldDictionary = value;
                var comparer = StringComparer.OrdinalIgnoreCase;
                if (value == null)
                {
                    _Fields = value;
                }
                else
                {
                    Dictionary<string, Field> tempDict = new Dictionary<string, Field>(oldDictionary, comparer);
                    _Fields.Clear();
                    foreach (KeyValuePair<string, Field> field in tempDict)
                    {
                        _Fields.Add(field.Key, (Field)field.Value.Clone());
                    }
                }
            }
        }


        public Dictionary<string, Grid_ColumnsProperty> PropFields;//'-- ogni elemento della collezione � una super collezione che contiene le propiet� sull'attributo in nome,valore

        public int NumberColumn = 1;//'-- determina per i modelli verticali su quante colonn epresentare gli attributi per default 1
        private dynamic response;

        public int DrawMode = 1;//'-- indica la modalit� di disegno del modello 1 = caption a sinistra, 2 = caption sopra
        public string param;
        public string Template;
        public int UseNameOnField;

        public bool PrintMode = false;//'-- indica che il modello � visualizzato per una stampa
        public bool disattivaValidazioneFormale = false;//'-- Booleano utile per esempio sui modelli di filtro per non effettuare una validazione formale sui campi

        private string defaultBootstrapCols = "col-12 col-md-6 col-lg-6 col-xl-4 col-xxl-3";

        public Model()
        {
            Style = "VerticalModel";
            NumberColumn = 1;
            DrawMode = 1;
            Editable = true;
            PrintMode = false;
            disattivaValidazioneFormale = false;
        }


        //'-- avvalora la collezione con i javascript necessari al corretto
        //'-- funzionamento del controllo
        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library/")
        {

            int numCol;
            int c;

            //'-- aggiungo i js dei campi utilizzati sulla griglia
            numCol = Fields.Count;

            //for (c = 1; c < numCol; c++)
            //{
            //    Fields[c].JScript(JS, Path);
            //}

            foreach (KeyValuePair<string, Field> fld in Fields)
            {
                fld.Value.JScript(JS, Path);
            }

            if (!JS.ContainsKey("UpdateFieldVisual"))
            {
                JS.Add("UpdateFieldVisual", $@"<script src=""{Path}JScript/Field/UpdateFieldVisual.js"" ></script>");
            }

        }

        //'-- ritorna il codice html per rappresentare il modello verticale
        private void DrawVertical(CommonModule.IEprocResponse objResp)
        {

            //Field fld;
            string strApp;
            int numR;
            int? numC;
            bool bOpenRow = false;
            bool bFieldInserted;
            string PathImage;
            string Path;
            Grid_ColumnsProperty prop;
            bool bShow;
            string strStyleClass;
            string no_closure;

            PathImage = GetParam(param, "PathImage");
            Path = GetParam(param, "Path");
            no_closure = GetParam(param, "NO_CLOSURE"); //'-- parametro che toglie la td 100% di 'tappo' sulla tabella. per impedire che i campi si restringano
            strStyleClass = "";


            //'-- inserisco tutti i campi non editabili
            string strValue;
            foreach (KeyValuePair<string, Field> fld in Fields)
            {

                if (PropFields.ContainsKey(fld.Value.Name))
                {
                    prop = PropFields[fld.Value.Name];
                    if (prop.Hide == true)
                    {
                        strValue = "";
                        //'If Not IsNull(fld.Value) Then strValue = CStr(fld.Value)
                        if (!IsNull(fld.Value.Value))
                        {
                            strValue = CStr(fld.Value.TechnicalValue());
                        }
						if (string.IsNullOrEmpty(strValue))
						{
                            strValue = fld.Value.DefaultValue;
                        }
                        HTML_HiddenField(objResp, fld.Value.Name, strValue);
                    }
                }

            }
            
            if (IsMasterPageNew()) 
            {
                objResp.Write($@"<table class=""{Style}_Tab FaseIIVerticalModel"" id=""{id.ToLower()}"" border=""0"" cellspacing=""0"" cellpadding=""0"" > ");
            }
            else
            {
                objResp.Write($@"<table class=""{Style}_Tab"" id=""{id}"" border=""0"" cellspacing=""0"" cellpadding=""0"" > ");
            }
            numC = 1;
            numR = 0;


            //'-- per ogni attributo del modello
            foreach (KeyValuePair<string, Field> fld in Fields)
            {
                bFieldInserted = false;

                if (!string.IsNullOrEmpty(PathImage))
                {
                    fld.Value.PathImage = PathImage;
                }

                if (!string.IsNullOrEmpty(Path))
                {
                    fld.Value.Path = Path;
                }

                if (UseNameOnField == 1)
                {
                    fld.Value.SetRow2(id);
                }

                //'-- controlla se visualizzare il campo
                bShow = true;

                try
                {
                    if (PropFields.ContainsKey(fld.Value.Name))
                    {
                        prop = PropFields[fld.Value.Name];
                        if (prop.Hide == true)
                        {
                            bShow = false;
                        }
                    }
                }
                catch
                {

                }

                //'Set prop = Nothing

                if (bShow)
                {
                    //'-- ciclo sul campo per posizionarlo correttamente in funzione della posizione scelta
                    //'-- si presuppone che il modello sia ordinato correttamente
                    do
                    {

                        //'-- apro la riga se necessario
                        if (numC == 1)
                        {
                            if (IsMasterPageNew())
                            {
								objResp.Write(@"<tr class=""row gx-0"">");
                            }
                            else
                            {
                                objResp.Write("<tr>");
							}
							bOpenRow = true;
                        }


                        //'-- controllo se il campo � nella posizione corretta
                        if (fld.Value.Position == numR * NumberColumn + numC)
                        {

                            if (fld.Value.getType() == 15)
                            { //'-- static

                                //'-- nome attributo
                                if (IsMasterPageNew())
                                {
									objResp.Write($@"<td class=""{defaultBootstrapCols} {Style}_StaticCaption"" ");
                                }
                                else
                                {
                                    objResp.Write($@"<td class=""{Style}_StaticCaption"" ");
								}

								if (fld.Value.colspan > 1)
                                {

                                    numC = numC + (fld.Value.colspan - 1);
                                    objResp.Write($@" colspan=""{(1 + (fld.Value.colspan - 1) * 2)}"" ");

                                }

                                objResp.Write($@"width=""10%"">");


                                fld.Value.CaptionHtml(objResp);
                                objResp.Write($@"</td>");

                                objResp.Write($@"<td class=""display_none""></td>");

                            }
                            else if (fld.Value.getType() == 16)
                            { //'-- HR

                                numC = 0;
                                numR = numR + 1;

                                //'-- chiudo riga
                                if (IsMasterPageNew())
                                {
                                    objResp.Write($@"<td class=""col align-self-center""><hr/></td></tr> ");
                                }
                                else
                                {
									objResp.Write($@"<td colspan=""120""><hr/></td></tr> ");
								}
								bOpenRow = false;


                            }
                            else
                            {

                                //'-- nome attributo
                                if (IsMasterPageNew())
                                {
									objResp.Write($@"<td class=""{defaultBootstrapCols}""> ");
                                }
                                else
                                {
                                    objResp.Write($@"<td> ");
								}
								objResp.Write($@"<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">");
                                objResp.Write($@"<tr> ");
                                objResp.Write($@"<td");


                                objResp.Write($@" class=""{Style}");

                                if (fld.Value.Obbligatory == true)
                                {
                                    objResp.Write($@"_ObbligCaption"" width=""10%"">");
                                }
                                else
                                {
                                    objResp.Write($@"_Caption"" width=""10%"">");
                                }

                                fld.Value.CaptionHtml(objResp);

                                objResp.Write($@"</td></tr></table></td>");

                                //'-- valore
                                if (GetParam(param, "Style") == "")
                                {
                                    strStyleClass = $"{Style}_Value";
                                }
                                else
                                {
                                    strStyleClass = $"{Style}_{fld.Value.Style}";
                                }


                                if (fld.Value.getType() == 3)
                                {
                                    //'-- per i text area setta la larghezza
                                    strStyleClass = $"{strStyleClass}{getWidthAccessibile(GetFieldWidth(fld.Value), "width")}";
                                }

                                objResp.Write($@"<td class=""{strStyleClass}"" ");

                                if (fld.Value.colspan > 1)
                                {

                                    numC = numC + (fld.Value.colspan - 1);
                                    objResp.Write($@" colspan=""{(1 + (fld.Value.colspan - 1) * 2)}"" ");

                                }

                                objResp.Write($@">");

                                if (!string.IsNullOrEmpty(fld.Value.Help))
                                {
                                    objResp.Write($@"<table border=""0"" cellspacing=""0"" cellpadding=""0"" ><tr><td width=""100%"" height=""100%"">");
                                }

                                //'-- per i campi non editabili si mette una tabella come bordo
                                if ((Editable == false || fld.Value.GetEditable() == false) && fld.Value.getType() != 11)
                                {

                                    objResp.Write($@"<table height=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" class=""{Style}_ReadOnlyField {getWidthAccessibile(GetFieldWidth(fld.Value), "width")}""><tr><td id=""Cell_{fld.Value.Name}"" width=""100%"" height=""100%"" {(fld.Value.getType() == 2 || fld.Value.getType() == 7 ? @" align=""right"" " : "")}");



                                    objResp.Write($@">");

                                }

                                //'-- scrivo il valore
                                if (PrintMode)
                                {
                                    fld.Value.toPrint(objResp, false);
                                }
                                else
                                {

                                    if (Editable == false)
                                    {
                                        fld.Value.umValueHtml(objResp, false);
                                        fld.Value.ValueHtml(objResp, false);
                                    }
                                    else
                                    {
                                        fld.Value.umValueHtml(objResp);
                                        fld.Value.ValueHtml(objResp);
                                    }

                                }

                                //'-- chiudo la tabella dei soli non editabili
                                if ((Editable == false || fld.Value.GetEditable() == false) && fld.Value.getType() != 11)
                                {
                                    objResp.Write($@"</td></tr></table>");
                                }

                                //'-- help sul campo
                                if (!string.IsNullOrEmpty(fld.Value.Help))
                                {
                                    objResp.Write($@"</td><td ");

                                    objResp.Write($@">");


                                    objResp.Write($@"<span class=""{Style}_Help"">");
                                    objResp.Write($@"{fld.Value.Help}");
                                    objResp.Write($@"</span>");


                                    objResp.Write($@"</td></tr></table>");
                                }

                                objResp.Write($@"</td>");

                            }

                            bFieldInserted = true;

                        }
                        else
                        {

                            //'-- creo le celle vuote nel caso per quella posizione non ci sia l'attributo
                            objResp.Write($@"<td>&nbsp;</td><td></td>");

                            //'-- controllo che il campo non sia superato per evitare un ciclo infinito
                            if (fld.Value.Position < numR * NumberColumn + numC)
                            {
                                break;
                            }
                        }


                        numC = numC + 1;
                        if (numC > NumberColumn)
                        {
                            numC = 1;
                            numR = numR + 1;

                            //'-- chiudo riga


                            if (Strings.UCase(CStr(no_closure)) != "YES")
                            {
                                objResp.Write($@"<td class=""width_100_percent""></td> ");
                            }
                            else
                            {
                                objResp.Write($@"<td class=""hidden""></td> ");
                            }

                            objResp.Write($@"</tr>");


                            bOpenRow = false;

                        }

                    } while (bFieldInserted != true);
                }

            }

            if (bOpenRow == true)
            {
                objResp.Write($@"</tr> ");
            }

            objResp.Write($@"</table> ");


        }

        //'-- ritorna il codice html per rappresentare la riga di un gruppo
        public void Html(CommonModule.IEprocResponse objResp)
        {

            if (!String.IsNullOrEmpty(Template))
            {
                DrawTemplate(objResp);
            }
            else
            {
                if (DrawMode == 2)
                {
                    DrawHorizontal(objResp);
                }
                else
                {
                    DrawVertical(objResp);
                }
            }

        }

        //'-- ritorna il codice html per rappresentare la riga di un gruppo
        public void Excel(CommonModule.IEprocResponse objResp)
        {

            if (!string.IsNullOrEmpty(Template))
            {
                DrawTemplateExcel(objResp);
            }
            else
            {
                DrawVerticalExcel(objResp);
            }

        }

        public void SetFieldsValue(DataRow col)
        {
            SetFilteredFieldsValue(col);
        }

        public void SetFieldsValue(Dictionary<dynamic, dynamic> col)
        {
            SetFilteredFieldsValue(col);
        }

        public void SetFieldsValue(Dictionary<string, dynamic> col)
        {
            SetFilteredFieldsValue(col);
        }

        public void SetFieldsValue(IFormCollection col)
        {
            SetFilteredFieldsValue(col);
        }

        public void SetFieldValue(string Name, object Value)
        {
            if (Fields.Count != 0)
            {
                Field obj;

                if (Fields.ContainsKey(Name))
                {
                    obj = Fields[Name];
                    int t;

                    t = obj.getType();

                    if (t == 1 || t == 3)
                    {
                        /* Se il field è una stringa e la trim del suo valore da stringa vuota
                            setto vuoto sul campo. altrimenti lo lascio inalterato */
                        if (Value is string s && s.Trim() == "")
                        {
                            Value = string.Empty;
                        }
                    }

                    if (t == 2 || t == 7)
                    {
                        if (Value is string s)
                        {
                            string strNewVal;
                            string caratteriValidi;

                            //'-- PRENDO SOLO I CARATTERI CONSENTITI
                            caratteriValidi = "+,.0123456789-";
                            strNewVal = string.Empty;

                            foreach (char c in s)
                            {
                                //'-- se il carattere rientra nel subset consentito lo aggiunto al newVal
                                if (caratteriValidi.Contains(c, StringComparison.Ordinal))
                                {
                                    strNewVal = $"{strNewVal}{c}";
                                }
                            }

                            Value = strNewVal;

                            if (CStr(0.5).Contains(',', StringComparison.Ordinal))
                            {
                                obj.Value = s.Replace('.', ',');
                                return;
                            }
                        }
                        else
                        {
                            if (Value is bool tmpV)
                            {
                                if (tmpV) //Se value è true
                                {
                                    Value = 1;
                                }
                                else
                                {
                                    Value = 0;
                                }
                            }
                        }
                    }

                    obj.Value = Value;
                }

            }
        }


        //'-- ritorna la condizione di where sql dei campi contenuti nel modello
        //'-- non tiene conto delle possibili relazioni fra tabelle ma banalmente ragiona sui valori dei campi
        public string GetSqlWhere()
        {
            int nf;
            int i;
            string strWhere = "";
            string v;
            int k;
            string[] alistvalue;
            int FType;

            foreach (KeyValuePair<string, Field> fld in Fields)
            {

                if (!string.IsNullOrEmpty(CStr(fld.Value.Value)))
                {

                    if (!string.IsNullOrEmpty(strWhere))
                    {
                        strWhere = $"{strWhere} and ";
                    }

                    FType = fld.Value.getType();

                    //'-- Se � un dominio normale, esteso o gerarchico ed � multivalue
                    if ((FType == 4 || FType == 5 || FType == 8) && (fld.Value.MultiValue == 1 || fld.Value.strFormat.Contains("M", StringComparison.Ordinal)))
                    {

                        //'--per i multivalore faccio tanti OR sui valori selezionati
                        string tempvale;
                        tempvale = fld.Value.SQLValue().Replace("'", "");
                        alistvalue = Strings.Split(tempvale, "###");
                        alistvalue = tempvale.Split("###");

                        string strSql1;
                        string stroperator;
                        string strcondition;
                        string strFieldName;

                        strcondition = fld.Value.Condition;
                        if (fld.Value.Condition.ToLower().Trim().Contains("like", StringComparison.Ordinal))
                        {
                            strcondition = " like ";
                        }
                        strSql1 = "";
                        stroperator = " OR ";

                        if (fld.Value.Condition.ToLower().Trim() == "likeand")
                        {
                            stroperator = " AND ";
                        }

                        for (k = 0; k < alistvalue.Length; k++)
                        {

                            if (!string.IsNullOrEmpty(alistvalue[k]))
                            {

                                strFieldName = fld.Value.Name;

                                if (strcondition.Trim() == "like" || strcondition.Trim() == "=")
                                {

                                    strFieldName = $@" '###' + {strFieldName} + '###' ";

                                }

                                if (strSql1 == "")
                                {
                                    strSql1 = $@"{strSql1}{strFieldName} {strcondition} ";
                                }
                                else
                                {
                                    strSql1 = $@"{strSql1}{stroperator}{strFieldName} {strcondition} ";
                                }

                                if (strcondition.Trim() == "like")
                                {
                                    v = alistvalue[k].Replace("*", "%");
                                    v = $"'%###{v.Replace("'", "''")}###%'";
                                    strSql1 = $"{strSql1}{v}";
                                }
                                else
                                {
                                    strSql1 = $"{strSql1}'###{alistvalue[k].Replace("'", "''")}###'";
                                }
                            }

                        }

                        strWhere = $"{strWhere} ( {strSql1} ) ";


                    }
                    else if (FType == 6 || FType == 22)
                    {
                        //'-- per gli attributi di tipo data se la formattazione della data � dd/mm/yyyy si taglia l'orario
                        if (fld.Value.strFormat.ToLower() == "dd/mm/yyyy" || fld.Value.strFormat.ToLower() == "mm/dd/yyyy")
                        {

                            strWhere = $"{strWhere} convert( varchar(10) , {fld.Value.Name} , 121 ) ";
                            strWhere = $"{strWhere} {fld.Value.Condition} ";
                            strWhere = $"{strWhere}{Strings.Left(fld.Value.SQLValue(), 11)}'";

                        }
                        else
                        {

                            strWhere = $"{strWhere}{fld.Value.Name}";
                            strWhere = $"{strWhere} {fld.Value.Condition} ";
                            strWhere = $"{strWhere}{fld.Value.SQLValue()}";

                        }

                    }
                    else
                    {

                        strWhere = $"{strWhere}{fld.Value.Name}";
                        strWhere = $"{strWhere} {fld.Value.Condition} ";

                        //'-- Se testo ,textarea o email
                        if (fld.Value.getType() == 1 || fld.Value.getType() == 3 || fld.Value.getType() == 14)
                        {

                            string specialCharLeft;
                            string specialCharRight;

                            specialCharLeft = "%";
                            specialCharRight = "%";

                            v = fld.Value.SQLValue().Replace("*", "%");

                            if (fld.Value.Condition.Trim().ToUpper() == "LIKE")
                            {

                                //'-- Se la condizione � di like e nel valore che si � inserito
                                //'-- c'� all'inizio o alla fine della stringa la parantesi quadra,
                                //'-- vuol dire che si sta cercando una parola che inizia o finisce
                                //'-- nel modo richiesto e non si vuole cercare all'interno della stringa
                                //'-- utilizzando cio� il % ( che rimane il default ). Se invece
                                //'-- si scrive [xxx] vuol dire che si sta cercando solo le parole esatte xxx
                                //'-- e non verranno messi i % ne prima ne dopo

                                if (v.Length >= 3)
                                {

                                    if (Strings.Mid(v, 2, 1) == "[")
                                    {
                                        specialCharLeft = "";

                                        //'-- tolgo il [ all'inizio
                                        v = $"'{Strings.Right(v, v.Length - 2)}";
                                    }

                                    if (Strings.Left(Strings.Right(v, 2), 1) == "]")
                                    {
                                        specialCharRight = "";

                                        //'-- tolgo il ] alla fine
                                        v = $"{Strings.Left(v, v.Length - 2)}'";
                                    }

                                }

                            }

                            v = $"'{specialCharLeft}{Strings.Mid(v, 2, v.Length - 2)}{specialCharRight}'";

                            strWhere = $"{strWhere}{v}";


                        }
                        else
                        {

                            strWhere = $"{strWhere}{fld.Value.SQLValue()}";
                        }

                    }

                } //'If Fields(i).Value <> "" Then

            }

            return strWhere;

        }


        //'-- la funzione controlla che tutti i campi obbligatori siano stati avvalorati
        //'-- nel caso ci siano campi non avvalorati imposta lo stato di errore sul campo
        public bool CheckObblig()
        {
	        bool retVal = false;
			DebugTrace dt = new DebugTrace();
			foreach (KeyValuePair<string, Field> el in Fields)
            {
                try
                {
	                var fl = el.Value;

	                if (fl.Obbligatory && fl.GetEditable() && CStr(fl.Value).Trim() == "")
                    {
						dt.Write("Campo obbligatorio:" + CStr(fl.Name) + ", è necessario inserirlo per proseguire");
						fl.Error = 1;
                        fl.ErrDescription = "Campo obbligatorio, è necessario inserirlo per proseguire";
                        retVal = true;
                    }
				}
                catch (Exception ex)
	            {
	            }
			}

            return retVal;
        }


        //'-- ritorna il codice html per rappresentare il modello verticale in Excel
        private void DrawVerticalExcel(CommonModule.IEprocResponse objResp)
        {

            //Field fld;
            String strApp;
            int numR;
            int? numC;
            bool bOpenRow = false;
            bool bFieldInserted;
            Grid_ColumnsProperty prop;
            bool bShow;

            objResp.Write($@"<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" > ");

            numC = 1;
            numR = 0;

            //'-- per ogni attributo del modello
            foreach (KeyValuePair<string, Field> fld in Fields)
            {

                bFieldInserted = false;

                //'-- controlla se visualizzare il campo
                bShow = true;
                try
                {
                    prop = PropFields[fld.Value.Name];
                    if (prop.Hide == true)
                    {
                        bShow = false;
                    }
                }
                catch
                {

                }


                if (bShow)
                {


                    //'-- ciclo sul campo per posizionarlo correttamente in funzione della posizione scelta
                    //'-- si presuppone che il modello sia ordinato correttamente

                    do
                    {

                        //'-- apro la riga se necessario
                        if (numC == 1)
                        {
                            objResp.Write($@"<tr>");
                            bOpenRow = true;
                        }

                        //'-- controllo se il campo � nella posizione corretta
                        if (fld.Value.Position == numR * NumberColumn + numC)
                        {

                            if (fld.Value.getType() == 15)
                            { //'-- static

                                //'-- nome attributo
                                objResp.Write($@"<td ");

                                objResp.Write($@"width=""10%"">");
                                fld.Value.CaptionExcel(objResp);
                                objResp.Write($@"</td>");

                                objResp.Write($@"<td></td>"); //'<td></td>";

                            }
                            else if (fld.Value.getType() == 16)
                            { //'-- HR

                                numC = 0;
                                numR = numR + 1;

                                //'-- chiudo riga
                                objResp.Write($@"<td colspan=""120""><hr/></td></tr> ");
                                bOpenRow = false;

                            }
                            else
                            {

                                //'-- nome attributo
                                objResp.Write($@"<td ");

                                objResp.Write($@"width=""10%"">");
                                fld.Value.CaptionExcel(objResp);
                                objResp.Write($@"</td>");


                                //'-- valore
                                objResp.Write($@"<td ");

                                if (fld.Value.colspan > 1)
                                {

                                    numC = numC + (fld.Value.colspan - 1);
                                    objResp.Write($@" colspan=""{(1 + (fld.Value.colspan - 1) * 2)}"" ");

                                }

                                objResp.Write($@">");

                                //'-- scrivo il valore
                                if (Editable == false)
                                {
                                    fld.Value.umValueHtml(objResp, false);
                                    fld.Value.ValueExcel(objResp, false);
                                }
                                else
                                {
                                    fld.Value.umValueHtml(objResp, false);
                                    fld.Value.ValueExcel(objResp, false);
                                }

                                objResp.Write($@"</td>");

                            }

                            bFieldInserted = true;

                        }
                        else
                        {

                            //'-- creo le celle vuote nel caso per quella posizione non ci sia l'attributo
                            objResp.Write($@"<td>&nbsp;</td><td></td>"); //'<td></td>";

                        }


                        numC = numC + 1;
                        if (numC > NumberColumn)
                        {
                            numC = 1;
                            numR = numR + 1;

                            //'-- chiudo riga
                            objResp.Write($@"<td width=""100%"" ></td></tr> ");
                            bOpenRow = false;

                        }

                    } while (bFieldInserted != true);
                }
            }

            if (bOpenRow == true)
            {
                objResp.Write($@"</tr> ");
            }

            objResp.Write($@"</table> ");

        }


        //'-- ritorna il codice html per rappresentare il modello verticale
        private void DrawHorizontal(CommonModule.IEprocResponse objResp)
        {
            string strApp;
            int numR;
            int? numC;
            bool bOpenRow = false;
            bool bFieldInserted;
            string PathImage;
            string Path;
            Grid_ColumnsProperty prop;
            bool bShow;

            PathImage = GetParam(param, "PathImage");
            Path = GetParam(param, "Path");

            //'-- inserisco tutti i campi non editabili
            string strValue;
            foreach (KeyValuePair<string, Field> fld in Fields)
            {

                if (PropFields.ContainsKey(fld.Value.Name))
                {
                    prop = PropFields[fld.Value.Name];
                    if (prop.Hide)
                    {
                        strValue = "";
						if (!IsNull(fld.Value.Value))
						{
                            strValue = CStr(fld.Value.TechnicalValue());
                        }
                        if (string.IsNullOrEmpty(strValue))
                        {
                            strValue = fld.Value.DefaultValue;
                        }
                        HTML_HiddenField(objResp, fld.Value.Name, strValue);
                    }
                }

            }

            objResp.Write($@"<table width=""100%"" class=""{Style}_Tab"" id=""{id}"" border=""0""> ");


            numC = 1;
            numR = 0;

            //'-- per ogni attributo del modello
            foreach (KeyValuePair<string, Field> fld in Fields)
            {

                if (disattivaValidazioneFormale)
                {
                    fld.Value.validazioneFormale = false;
                }

                if (!string.IsNullOrEmpty(PathImage))
                {
                    fld.Value.PathImage = PathImage;
                }

                if (!string.IsNullOrEmpty(Path))
                {
                    fld.Value.Path = Path;
                }

                if (UseNameOnField == 1)
                {
                    fld.Value.SetRow2(id);
                }

                bFieldInserted = false;


                //'-- controlla se visualizzare il campo
                bShow = true;
                try
                {
                    if (PropFields.ContainsKey(fld.Value.Name))
                    {
                        prop = PropFields[fld.Value.Name];
                        if (prop.Hide)
                        {
                            bShow = false;
                        }
                    }
                }
                catch { }

                if (bShow)
                {

                    //'-- ciclo sul campo per posizionarlo correttamente in funzione della posizione scelta
                    //'-- si presuppone che il modello sia ordinato correttamente
                    do
                    {

                        //'-- apro la riga se necessario
                        if (numC == 1)
                        {
                            if (IsMasterPageNew())
                            {
                                objResp.Write($@"<tr class=""row gx-0"">");
                            }
                            else 
                            {
								objResp.Write($@"<tr>");
							}
							bOpenRow = true;
                        }


                        //'-- controllo se il campo � nella posizione corretta
                        if (fld.Value.Position == numR * NumberColumn + numC)
                        {

                            if (fld.Value.getType() == 15)
                            { //'-- static

                                //'-- nome attributo
                                objResp.Write($@"<td class=""{Style}");
                                objResp.Write($@"_StaticCaption""  ");
                                objResp.Write($@" colspan=""{((fld.Value.colspan > 0 ? fld.Value.colspan : 1))} "" ");
                                if (IsMasterPageNew())
                                {
                                    objResp.Write($@">");

                                }
                                else
                                {

                                    objResp.Write($@" width=""10%"" >");
                                }
                                fld.Value.CaptionHtml(objResp);
                                objResp.Write($@"</td>");

                            }
                            else if (fld.Value.getType() == 16)
                            { //'-- HR

                                numC = 0;
                                numR = numR + 1;

                                //'-- chiudo riga
                                if (IsMasterPageNew())
                                {
								    objResp.Write($@"<td class=""col align-self-center""><hr></td></tr> " + Environment.NewLine);
                                }
                                else
                                {
									objResp.Write($@"<td colspan=""120""><hr></td></tr> " + Environment.NewLine);
                                }
                                bOpenRow = false;

                            }
                            else
                            {

                                //'-- includo il campo in una tabella
                                objResp.Write(Environment.NewLine);
                                if (IsMasterPageNew())
                                {
                                    var fldColspan = ((fld.Value.colspan > 1 ? fld.Value.colspan : 1));
                                    //se è una TextArea, se è l'ultimo elemento della riga
                                    if (fld.Value.getType() == 3 && (numC + fldColspan + 1) >= NumberColumn)
                                    {
                                        objResp.Write($@"<td class=""col full-width-textarea"" valign=""top"" ");
                                    }
                                    else
                                    {
                                        objResp.Write($@"<td class=""{defaultBootstrapCols}"" valign=""top"" ");
                                    }
                                }
                                else {
									objResp.Write($@"<td valign=""top"" ");
								}
                                objResp.Write($@" colspan=""{((fld.Value.colspan > 0 ? fld.Value.colspan : 1))}"" ");
                                objResp.Write($@"><table border=""0"" width=""100%"" cellpadding=""0"" cellspacing=""0"">");
                                

                                if (IsMasterPageNew())
                                {
                                    if(fld.Value.Error is not null && fld.Value.Error == 1)
                                    {
                                        objResp.Write($@"<tr class=""obbligError"">");
                                    }
                                    else
                                    {
                                        objResp.Write("<tr>");
                                    }
                                }
                                else
                                {
                                    objResp.Write("<tr>");
                                }

                                //'-- nome attributo
                                objResp.Write($@"<td class=""{Style}");
                                if (fld.Value.Obbligatory)
                                {
                                    objResp.Write($@"_ObbligCaption"" ");
                                }
                                else
                                {
                                    objResp.Write($@"_Caption"" ");
                                }

                                objResp.Write($@"width=""100%"">");

                                fld.Value.CaptionHtml(objResp);
                                objResp.Write($@"</td>");
                                if (IsMasterPageNew())
                                {
									objResp.Write($@"</tr><tr class=""row gx-0"">");
                                }
                                else
                                {
								    objResp.Write($@"</tr><tr>");
                                }

                                //'-- valore
                                if (GetParam(param, "Style") == "")
                                {
                                    objResp.Write($@"<td class=""{Style}_Value"" ");
                                }
                                else
                                {
                                    objResp.Write($@"<td class=""{Style}_{fld.Value.Style}"" ");
                                }

                                if (fld.Value.colspan > 1)
                                {

                                    numC = numC + ((fld.Value.colspan > 0 ? fld.Value.colspan - 1 : 0));

                                }

                                objResp.Write($@">");

                                if (!string.IsNullOrEmpty(fld.Value.Help))
                                {
                                    objResp.Write($@"<table border=""0"" cellspacing=""0"" cellpadding=""0""><tr><td width=""100%"" height=""100%"">");
                                }

                                //'-- per i campi non editabili si mette una tabella come bordo
                                if ((!Editable || !fld.Value.GetEditable()) && fld.Value.getType() != 11)
                                {


                                    objResp.Write($@"<table border=""0"" cellspacing=""0"" cellpadding=""0"" class=""{Style}_ReadOnlyField {getWidthAccessibile(GetFieldWidth(fld.Value), "width")}"" ><tr><td  name=""Cell_{fld.Value.Name}"" id=""Cell_{fld.Value.Name}"" width=""100%"" height=""100%"" {(fld.Value.getType() == 2 || fld.Value.getType() == 7 ? @" align=""right"" " : "")} ");

                                    objResp.Write($@">");

                                }


                                //'-- scrivo il valore
                                if (PrintMode)
                                {

                                    fld.Value.toPrint(objResp, false);

                                }
                                else
                                {

                                    if (!Editable)
                                    {
                                        fld.Value.umValueHtml(objResp, false);
                                        fld.Value.ValueHtml(objResp, false);
                                    }
                                    else
                                    {
                                        fld.Value.umValueHtml(objResp);
                                        fld.Value.ValueHtml(objResp);
                                    }

                                }

                                //'-- chiudo la tabella dei soli editabili
                                if ((!Editable || !fld.Value.GetEditable()) && fld.Value.getType() != 11)
                                {
                                    objResp.Write($@"</td></tr></table>");
                                }

                                //'-- help sul campo
                                if (!string.IsNullOrEmpty(fld.Value.Help))
                                {

                                    objResp.Write($@"</td><td ");

                                    objResp.Write($@">");


                                    objResp.Write($@"<span class=""{Style}_Help"">");
                                    objResp.Write($@"{fld.Value.Help}");
                                    objResp.Write($@"</span>");

                                    objResp.Write($@"</td></tr></table>");

                                }


                                objResp.Write($@"</td></tr></table>");


                                objResp.Write($@"</td> ");


                            }

                            bFieldInserted = true;

                        }
                        else
                        {
                            //'-- creo le celle vuote nel caso per quella posizione non ci sia l'attributo
                            if (IsMasterPageNew())
                            {
								
                            }
                            else
                            {
                                objResp.Write($@"<td>&nbsp;</td>");
							}

							//'-- controllo che il campo non sia superato per evitare un ciclo infinito
							if (fld.Value.Position < numR * NumberColumn + numC)
                            {
                                break;
                            }
                        }

                        numC++;
                        if (numC > NumberColumn)
                        {
                            numC = 1;
                            numR = numR + 1;

                            //'-- chiudo riga
                            objResp.Write($@"</tr> ");
                            objResp.Write($@"<!-- riga[{numR}] --> ");

                            bOpenRow = false;

                        }

                    } while (!bFieldInserted);

                }

            }

            if (bOpenRow)
            {
                objResp.Write($@"</tr> ");
            }

            objResp.Write($@"</table> ");
        }

        /// <summary>
        ///  setta i valori dei campi popolandoli da FORM/POST
        /// </summary>
        /// <param name="col"></param>
        public void UpdFieldsValue(IFormCollection? col)
        {
            if (col is null || col!.Count == 0)
            {
                return;
            }

            string addName = "";

            if (UseNameOnField == 1)
            {
                addName = $"R{id}_";
            }

            foreach (KeyValuePair<string, Field> el in Fields)
            {
                try
                {
                    string fullName = $"{addName}{el.Value.Name}";

                    if (col.ContainsKey(fullName))
                    {
                        SetFieldValue(el.Value.Name, GetValueFromForm(col, fullName));
                    }
                    else
                    {
                        //'-- solo per il checkbox si fa eccezione ( perchè non arriva in POST se il check non è stato spuntato ) 
                        if (el.Value.getType() == 9)
                        {
                            SetFieldValue(el.Value.Name, string.Empty);
                        }
                    }
                }
                catch (Exception ex)
                {
                    string g = ex.ToString();
                    DebugTrace dt = new();
                    dt.Write($"Model.UpdFieldsValue() - Errore : {g}");
                }
            }
        }

        private string GetFieldWidth(Field obj)
        {
            string stringToReturn = "";

            Grid_ColumnsProperty prop;
            try
            {
                prop = PropFields[obj.Name];
                //'-- numero di pixel
                if (!string.IsNullOrEmpty(prop.width))
                {
                    stringToReturn = prop.width;
                }
                else if (obj.width > 0)
                {
                    stringToReturn = (obj.width * 7).ToString();
                }
            }
            catch
            {
                if (obj.width > 0)
                {
                    stringToReturn = (obj.width * 7).ToString();
                }
            }


            if (stringToReturn == "")
            {
                stringToReturn = "20";
            }

            return stringToReturn;
        }

        //'-- pulisce tutte le condizioni di errore presenti sui campi
        public bool CleanError()
        {
            foreach (KeyValuePair<string, Field> el in Fields)
            {
                el.Value.Error = 0;
                el.Value.ErrDescription = "";
            }
            return true;
        }

        //'-- ricarica i domini filtrati sui campi non editabili per evitare che non vengano ritornati dei valori presenti
        public void ReloadUnfilteredDomain()
        {

            eProcurementNext.HTML.BasicFunction.ReloadUnfilteredDomain(Fields, Editable);

        }


        //'-- metodo per invocare l'update del field a video
        public void UpdateFieldVisual(CommonModule.IEprocResponse objResp, long nIndRow = -1, string strDocument = "")
        {
            foreach (KeyValuePair<string, Field> el in Fields)
            {
                try
                {
                    if (nIndRow > -1)
                    {
                        el.Value.SetRow(nIndRow);
                    }

                    el.Value.UpdateFieldVisual(objResp, strDocument);
                }
                catch
                {

                }
            }

        }



        //'-- ritorna tre stringhe contenenti separatamente la lista degli attributi, la lista delle condizioni e la lista dei valori
        public string GetSqlWhereList()
        {
            string v;
            string ListAtt;
            string ListCond;
            string ListVal;

            ListAtt = "";
            ListCond = "";
            ListVal = "";

            foreach (KeyValuePair<string, Field> fld in Fields)
            {

                if (!string.IsNullOrEmpty(CStr(fld.Value.Value)))
                {

                    ListAtt = $"{ListAtt}#@#{fld.Value.Name}";
                    ListCond = $"{ListCond}#@#{fld.Value.Condition}";

                    //'-- Se testo ,textarea o email
                    if (fld.Value.getType() == 1 || fld.Value.getType() == 3 || fld.Value.getType() == 14)
                    {
                        v = fld.Value.SQLValue().Replace("*", "%");
                        v = $"'%{Strings.Mid(v, 2, v.Length - 2)}%'";

                        ListVal = $"{ListVal}#@#{v}";
                    }
                    else
                    {
                        ListVal = $"{ListVal}#@#{fld.Value.SQLValue()}";
                    }

                }

            }

            if (!string.IsNullOrEmpty(ListAtt))
            {
                ListAtt = Strings.Mid(ListAtt, 4);
            }
            if (!string.IsNullOrEmpty(ListCond))
            {
                ListCond = Strings.Mid(ListCond, 4);
            }
            if (!string.IsNullOrEmpty(ListVal))
            {
                ListVal = Strings.Mid(ListVal, 4);
            }
            //'Aggiungo if se ListAtt <> "" per continuare a preservare filteredonly=yes anche in presenza di stored su un viewer
            if (!string.IsNullOrEmpty(ListAtt))
            {
                return $"{ListAtt}#~#{ListVal}#~#{ListCond}";
            }
            else
            {
                return $"{ListAtt}";
            }


        }



        private void DrawTemplate(CommonModule.IEprocResponse objResp)
        {

            //Field fld;
            string strApp;
            bool bOpenRow;
            bool bFieldInserted;
            string PathImage;
            string Path;
            Grid_ColumnsProperty prop;
            bool bShow;
            int numPart;
            string strCause;

            strCause = "";
            PathImage = GetParam(param, "PathImage");
            Path = GetParam(param, "Path");

            //'-- inserisco tutti i campi non editabili

            string strValue;
            foreach (KeyValuePair<string, Field> fld in Fields)
            {

                if (UseNameOnField == 1)
                {
                    fld.Value.SetRow2(id);
                }

                if (!String.IsNullOrEmpty(PathImage))
                {
                    fld.Value.PathImage = PathImage;
                }

                if (!String.IsNullOrEmpty(Path))
                {
                    fld.Value.Path = Path;
                }
                try
                {
                    prop = new Grid_ColumnsProperty();
                    prop = PropFields[fld.Value.Name];
                    if (prop.Hide)
                    {
                        strValue = "";
						if (!IsNull(fld.Value.Value))
						{
                            strValue = CStr(fld.Value.TechnicalValue());
                        }
						if (string.IsNullOrEmpty(strValue))
						{
                            strValue = fld.Value.DefaultValue;
                        }
                        HTML_HiddenField(objResp, fld.Value.Name, strValue);
                    }
                }
                catch
                {

                }
            }


            //'-- dividiamo il template per la parte terminale del referenziaore di campo
            string[] vetPartTemplate;
            string[] v;
            vetPartTemplate = CStr(Template).Split(")))");

            numPart = vetPartTemplate.Length;
            int i;
            Field fld2;
            //'-- per ogni parte verifichiamo la presenza del campo
            for (i = 0; i < numPart; i++)
            {

                //'-- se c'� il campo si stampa la parte iniziale e poi il campo
                if (vetPartTemplate[i].Contains("(((", StringComparison.Ordinal))
                {
                    v = vetPartTemplate[i].Split("(((");
                    objResp.Write($@"{v[0]}");
                    try
                    {
                        fld2 = Fields[v[1]];

                        //'-- per i campi non editabili si mette una tabella come bordo
                        if ((Editable == false || fld2.GetEditable() == false) && fld2.getType() != 11)
                        {

                            strCause = "Entro nel blocco per campi non editabili";

                            objResp.Write($@"<table border=""0"" cellspacing=""0"" cellpadding=""0"" class=""{Style}_ReadOnlyField {getWidthAccessibile(GetFieldWidth(fld2), "width")}"" ><tr><td  name=""Cell_{fld2.Name} "" id=""Cell_{fld2.Name} ""  width=""100%"" height=""100%"" {((fld2.getType() == 2 || fld2.getType() == 7) ? @" align=""right"" " : "")} ");

                            objResp.Write($@">");


                        }

                        objResp.Write($@"<div class=""div_fld_template"">");

                        //'-- se il campo � in errore (ad ese. per obbligatoriet� o validazione formale) mostro l'icona di err
                        if (fld2.Error != 0)
                        {

                            string strGifErr = "";
                            string strAlt = "";

                            if (fld2.Error == 1)
                            {

                                strGifErr = "State_Err.png";

                                strAlt = "Errore";

                            }

                            if (fld2.Error == 2)
                            {

                                strGifErr = "State_Warning.png";

                                strAlt = "Attenzione";
                            }

                            if (fld2.Error == 3)
                            {

                                strGifErr = "info.png";

                                strAlt = "Informazione";
                            }

                            objResp.Write($@"<img alt=""{strAlt}"" src=""{HttpUtility.HtmlEncode($"{PathImage}{strGifErr}")}"" title=""{HttpUtility.HtmlEncode(fld2.ErrDescription)}""/>");

                        }

                        if (UseNameOnField == 1)
                        {
                            fld2.SetRow2(id);
                        }

                        //'-- scrivo il valore
                        if (Editable == false)
                        {
                            strCause = "umValueHtml per non editabile";
                            fld2.umValueHtml(objResp, false);
                            strCause = "ValueHtml per non editabile";
                            fld2.ValueHtml(objResp, false);
                        }
                        else
                        {
                            strCause = "umValueHtml.editabile";
                            fld2.umValueHtml(objResp);
                            strCause = "ValueHtml.editabile";
                            fld2.ValueHtml(objResp);
                        }

                        strCause = "Chiudo la tabella per i campi non editabili";

                        objResp.Write($@"</div>");

                        //'-- chiudo la tabella dei soli editabili
                        if ((Editable == false || fld2.GetEditable() == false) && fld2.getType() != 11)
                        {
                            objResp.Write($@"</td></tr></table>");
                        }



                    }
                    catch
                    {
                        objResp.Write($@"[[[[[ --- errore su attributo ({v[1]}) --- ]]]]]");
                    }

                }
                else
                {
                    //'-- altrimenti tutto il pezzo
                    objResp.Write($@"{vetPartTemplate[i]}");
                }



            }

        }
        private void DrawTemplateExcel(CommonModule.IEprocResponse objResp)
        {
            DrawTemplate(objResp);
        }

        public void xml(dynamic ScopeLayer)
        {

            foreach (dynamic el in Fields)
            {
                el.Value.xml(ScopeLayer, "");
            }

        }

        //'-- la funzione controlla che tutti i campi con validazione formale obbligatoria sono validi
        //'-- nel caso ci siano campi non validi imposta lo stato di errore sul campo
        public bool checkValidation()
        {

            //Field el;
            int numEl;
            string strErr;
            bool fldHide;
            DebugTrace dt = new();

            if (disattivaValidazioneFormale == false)
            {
            

                foreach (KeyValuePair<string, Field> el in Fields)
                {
                    try
                    {
                        strErr = el.Value.validateField();
                        fldHide = false;
                        fldHide = PropFields[el.Value.Name].Hide;

                        //'-- se il campo è editabile, visibile e c'è stato un errore
                        if (el.Value.GetEditable() && fldHide == false && !string.IsNullOrEmpty(strErr))
                        {

                            //TODO: PER I FIELD MAIL SI PERDE IL SETTAGGIO DI ERRORE E DESCRZIONE
                            dt.Write("Campo " + el.Key + " non valido per il motivo:" + strErr);
                            el.Value.Error = 1;                            
                            el.Value.ErrDescription = strErr;
                            return true;
                        }
                    }
                    catch (Exception ex)
                    {
                        string g = ex.ToString();
                        dt.Write($"Model.checkValidation() - Errore : {g}");
                    }


                }

            }
            return false;


        }

        /// <summary>
        /// setta i valori dei campi atrtaverso la collezione di un form
        /// </summary>
        /// <param name="col"></param>
        /// <param name="fieldsReloaded"></param>
        public void SetFilteredFieldsValue(IFormCollection col, string fieldsReloaded = "")
        {

            string addName = "";

            if (UseNameOnField == 1)
            {
                addName = $"R{id}_";
            }

            foreach (KeyValuePair<string, Field> el in Fields)
            {
                try
                {
                    if (string.IsNullOrEmpty(fieldsReloaded) || $",{fieldsReloaded.Trim().ToLower()},".Contains("," + el.Value.Name.ToLower() + ",", StringComparison.Ordinal))
                    {
                        var valFieldForm = GetValueFromForm(col, $"{addName}{el.Value.Name}");
                        SetFieldValue(el.Value.Name, valFieldForm);
                    }
                }
                catch (Exception e)
                {
                    /*DebugTrace dt = new();
                    dt.Write($"Errore Model.SetFilteredFieldsValue() - {e}");*/
                }


            }
        }

        /// <summary>
        /// setta i valori dei campi atrtaverso la collezione di un form
        /// </summary>
        /// <param name="col"></param>
        /// <param name="fieldsReloaded"></param>
        public void SetFilteredFieldsValue(DataRow col, string fieldsReloaded = "")
        {

            string addName = "";

            if (UseNameOnField == 1)
            {
                addName = $"R{id}_";
            }

            foreach (KeyValuePair<string, Field> el in Fields)
            {
                try
                {
                    if (string.IsNullOrEmpty(fieldsReloaded) || $",{fieldsReloaded.Trim().ToLower()},".Contains("," + el.Value.Name.ToLower() + ",", StringComparison.Ordinal))
                    {
                        SetFieldValue(el.Value.Name, col[$"{addName}{el.Value.Name}"]);

                    }
                }
                catch (Exception e)
                {
                    /*DebugTrace dt = new();
                    dt.Write($"Errore Model.SetFilteredFieldsValue() - {e}");*/
                }


            }
        }

        /// <summary>
        /// setta i valori dei campi atrtaverso la collezione di un form
        /// </summary>
        /// <param name="col"></param>
        /// <param name="fieldsReloaded"></param>
        public void SetFilteredFieldsValue(Dictionary<dynamic, dynamic> col, string fieldsReloaded = "")
        {

            string addName = "";

            if (UseNameOnField == 1)
            {
                addName = $"R{id}_";
            }

            foreach (KeyValuePair<string, Field> el in Fields)
            {
                try
                {
                    if (string.IsNullOrEmpty(fieldsReloaded) || $",{fieldsReloaded.Trim()},".Contains("," + el.Value.Name + ",", StringComparison.Ordinal))
                    {
                        SetFieldValue(el.Value.Name, col[$"{addName}{el.Value.Name}"]);
                    }
                }
                catch (Exception e)
                {
                    /*DebugTrace dt = new DebugTrace();
                    dt.Write($"Errore Model.SetFilteredFieldsValue() - {e}");*/
                }
            }


        }

        /// <summary>
        /// setta i valori dei campi atrtaverso la collezione di un form
        /// </summary>
        /// <param name="col"></param>
        /// <param name="fieldsReloaded"></param>
        public void SetFilteredFieldsValue(Dictionary<string, dynamic> col, string fieldsReloaded = "")
        {

            string addName = "";

            if (UseNameOnField == 1)
            {
                addName = $"R{id}_";
            }

            foreach (KeyValuePair<string, Field> el in Fields)
            {
                try
                {
                    if (string.IsNullOrEmpty(fieldsReloaded) || $",{fieldsReloaded.Trim()},".Contains("," + el.Value.Name + ",", StringComparison.Ordinal))
                    {
                        SetFieldValue(el.Value.Name, col[$"{addName}{el.Value.Name}"]);
                    }
                }
                catch (Exception e)
                {
                    /*DebugTrace dt = new DebugTrace();
                    dt.Write($"Errore Model.SetFilteredFieldsValue() - {e}");*/
                }
            }


        }

    }
}

