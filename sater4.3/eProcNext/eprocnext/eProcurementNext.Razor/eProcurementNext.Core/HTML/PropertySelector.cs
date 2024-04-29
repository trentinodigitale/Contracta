using Microsoft.VisualBasic;

using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.Basic;

namespace eProcurementNext.HTML
{
    public class PropertySelector
    {
        public string? URL { get; set; }           //'-- indirizzo da chiamare per il salto pagina
        public string? Target { get; set; }        //'-- pagina di destinazione
        public string? Caption { get; set; }       //'-- contiene le intestazioni della griglia


        // -- collezione di attributi per i quali si devono gestire propiètà   
        public Dictionary<string, Field>? Column { get; set; } = new Dictionary<string, Field>();

        public bool bSort { get; set; }
        public bool bVisible { get; set; }


        public string? Style { get; set; }
        public string? strPath { get; set; }
        private string? strPathJS { get; set; }


        private string? id = default;
        public string? Id
        {
            get { return id; }
            set { id = value; }
        }


        // Public Value As Variant          '-- valore tecnico del campo


        private eProcurementNext.CommonModule.IEprocResponse objResp;


        public PropertySelector(eProcurementNext.CommonModule.IEprocResponse objResp)
        {
            this.objResp = objResp;
            Style = "PropertySelector";
            id = "PropertySelector";
            Target = "";
            URL = "";
            strPath = "../CTL_Library/images/PropertySelector/";
            Caption = "Attributo,Visualizza,Ordina,Tipo ordine";
        }

        // -- avvalora la collezione con i javascript necessari al corretto
        // -- funzionamento del controllo
        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library/")
        {
            strPathJS = Path;

            // -- questi java script vengono messi staticamente nella pagina per consentire il corretto funzionamento
            if (!JS.ContainsKey("getObj"))
            {
                JS.Add("getObj", "<script src=\"" + Path + "jscript/getObj.js\" ></script>");
            }
            if (!JS.ContainsKey("PropertySelector"))
            {
                JS.Add("PropertySelector", "<script src=\"" + Path + "jscript/PropertySelector/PropertySelector.js\" ></script>");
            }

        }

        // -- ritorna il codice html per rappresentare la riga di un gruppo
        public string Html(CommonModule.IEprocResponse objResp)
        {
            string StrUrl;
            Field f;
            var Value = "";
            string strProperty;
            int i;
            string strAttProp;
            int n;
            string[] strVetAttrib;
            dynamic strVetProp;
            var colProp = new Dictionary<string, string>();
            StrUrl = !String.IsNullOrEmpty(URL) ? URL.Replace(@"\", @"\\").Replace("'", @"\'") : "";



            // -- creazione della div che conterrà la barra di paginazione
            objResp.Write("<div id=\"" + id + "_Control\" >");
            objResp.Write("</div>" + Constants.vbCrLf);
            objResp.Write("<input type=\"hidden\" name=\"" + id + "\"  id=\"" + id + "\" ");
            objResp.Write(" value=\"" + HtmlEncodeValue(Value) + "\" ");
            objResp.Write("/>" + Constants.vbCrLf);
            objResp.Write("<script type=\"text/javascript\">" + Constants.vbCrLf);
            // objResp.Write "   debugger;" & vbCrLf

            // -- array degli attributi
            objResp.Write("   var " + id + "_id = '" + id + "';");
            objResp.Write("   var " + id + "_Num = " + Column.Count + ";");
            objResp.Write("   var " + id + "_Attrib = new Array(" + Column.Count + " );");


            // -- nel caso sull'url è presente il parametro property lo si usa per dare i valori di default
            // -- caricando una collezione con le proprietà
            strProperty = GetParam(StrUrl, "Property");
            if (!string.IsNullOrEmpty(strProperty))
            {
                strProperty = strProperty.Replace("%23", "#");
                strVetAttrib = strProperty.Split("#");
                for (i = 0; i < strVetAttrib.Length; i++)
                {
                    if (strVetAttrib[i] != "")
                    {
                        strVetProp = strVetAttrib[i].Split(",");

                        // -- inserisco nella collezione le caratteristiche dell'attributo
                        colProp.Add(strVetProp[0], Strings.Mid(strVetAttrib[i], Strings.Len(strVetProp[0]) + 2));
                    }
                }
            }


            for (i = 0; i < Column.Count; i++)
            {
                f = Column.ElementAt(i).Value;
                objResp.Write("   " + id + "_Attrib[" + i + "] = new Array( 4 );");
                objResp.Write("   " + id + "_Attrib[" + i + "][0] = '" + f.Name + "';");
                objResp.Write("   " + id + "_Attrib[" + i + "][1] = '" + f.Caption + "';");

                // -- recupero l'impostazione iniziale dell'attributo dalla collezione
                strAttProp = "";
                if (!String.IsNullOrEmpty(f.Name) && colProp.ContainsKey(f.Name))
                {
                    strAttProp = CStr(colProp[f.Name]);
                }

                if (!string.IsNullOrEmpty(strAttProp))
                {
                    objResp.Write("   " + id + "_Attrib[" + i + "][2] = '" + Strings.Left(strAttProp, 1) + "';");   // -- il check di visualizzazione
                    objResp.Write("   " + id + "_Attrib[" + i + "][4] = '" + Strings.Mid(strAttProp, 3) + "';");
                }
                else
                {
                    objResp.Write("   " + id + "_Attrib[" + i + "][2] = '1';");     // -- il check di visualizzazione
                    objResp.Write("   " + id + "_Attrib[" + i + "][4] = 'asc';");
                }
                objResp.Write("   " + id + "_Attrib[" + i + "][3] = '1';");
                Value = Value + f.Name + "," + f.Caption + ",1,asc#";
            }
            //f = null;


            objResp.Write("  var " + id + "_URL = '" + HtmlEncode(StrUrl) + "';" + Constants.vbCrLf);
            objResp.Write("  var " + id + "_Target = '" + Target + "';" + Constants.vbCrLf);
            objResp.Write("  var " + id + "_Style = '" + Style + "';" + Constants.vbCrLf);
            objResp.Write("  var " + id + "_strPath = '" + strPath + "';" + Constants.vbCrLf);
            objResp.Write("  var " + id + "_Caption = '" + Caption + "';" + Constants.vbCrLf);
            objResp.Write("   " + Constants.vbCrLf);
            objResp.Write("   " + Constants.vbCrLf);
            objResp.Write("   " + Constants.vbCrLf);

            objResp.Write(" try { ");
            objResp.Write("   DrawPropertySelector( '" + id + "' );");
            objResp.Write(" }catch(e){} ");
            objResp.Write("</script>" + Constants.vbCrLf);
            return objResp.Out();
        }
    }
}