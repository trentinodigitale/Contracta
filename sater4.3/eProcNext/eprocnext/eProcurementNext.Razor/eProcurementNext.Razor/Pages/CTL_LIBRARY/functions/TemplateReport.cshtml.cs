using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.VisualBasic;

using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.Razor.Pages.CTL_LIBRARY.DOCUMENT.CommonModel;


namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class TemplateReportModel : PageModel
    {
        //' ***** Funzioni di utilità *****
        public void OnGet()
        {
        }
        public static string elabTemplate(string templ, TSRecordSet objDocument)
        {

            long l;// ' Long
            long i;// ' Long
            long j;// ' Long
            string[] ss;// ' String
            string c; //' String
            bool b;// ' Boolean
            Dictionary<string, string> Coll;// ' New Collection
            TSRecordSet? rs = null; //'As ADODB.Recordset
            dynamic template;
            template = templ;


            Coll = new Dictionary<string, string>();
            string strTipo;// ' String
            string strField;// ' String
            string strItem;// ' String
            string VALORE;// ' Variant
            l = template.Lenght;
            b = false;
            j = 0;
            for (i = 1; i < l; i++)
            {
                //' legge il carattere i-esimo
                c = Strings.Mid(template, CInt(i), 1);
                if (string.Equals(c, "#"))
                {
                    if (!b)
                    {
                        b = true;
                        j = i;
                        b = false;
                        strItem = Strings.Mid(template, CInt(j + 1), CInt(i - j - 1));

                        try
                        {
                            Coll.Add(strItem, strItem);
                        }
                        catch
                        {
                            //err.Clear
                        }


                        //on error goto 0

                    }
                }

            }
            //'stop


            string x = "";
            //' -- STEP 2: scorre la collezione dei campi da calcolare e poi li rimpiazza nell'espressione con il valore
            foreach (KeyValuePair<string, string> item in Coll)
            {
                x = item.Value;
                ss = x.Split(".");
                strTipo = ss[0].ToUpper();
                strField = ss[1];
                switch (strTipo)
                {
                    case "DOCUMENT":
                        VALORE = "";
                        //'stop 

                        CommonDbFunctions cd = new CommonDbFunctions();
                        if (cd.FieldExistsInRS(objDocument, strField))
                        {
                            switch (strField.ToUpper())
                            {
                                //' lasciamo il case per inserire eventuali future gestioni speciali
                                case "1234567890_34232_Zxcsd":
                                    VALORE = "";
                                    break;
                                default:

                                    VALORE = GetValueFromRS(objDocument.Fields[strField]);
                                    break;

                            }
                        }
                        else
                        {
                            VALORE = "Colonna " + strField + " non trovata";

                        }

                        if (IsNull(VALORE))
                        {
                            VALORE = "";
                        }

                        template = template.Replace(CStr("#" + x + "#"), CStr(VALORE));


                        break;
                    case "DOCUMENT_MEM":
                        VALORE = "";
                        //'stop

                        VALORE = DOC_Field(ss[2], strField);
                        if (IsNull(VALORE))
                        {
                            VALORE = "";
                        }
                        template = template.Replace(CStr("#" + x + "#"), CStr(VALORE));
                        break;
                    case "ML":

                        string strSql = "select dbo.CNV_ESTESA( ML_Description ,'I') as ML_Description from LIB_Multilinguismo where ML_KEY = '" + strField + "' and ML_LNG = 'I'";
                        try
                        {
                            CommonDbFunctions cdb = new CommonDbFunctions();
                            rs = cdb.GetRSReadFromQuery_(strSql, ApplicationCommon.Application["ConnectionString"]);
                        }
                        catch
                        {

                        }

                        string Value;
                        Value = "";
                        if (!(rs.EOF && rs.BOF))
                        {
                            rs.MoveFirst();
                            Value = GetValueFromRS(rs.Fields["ML_Description"]);

                        }
                        if (string.IsNullOrEmpty(Value))
                        {
                            Value = "???" + strField + "???";

                        }
                        template = template.Replace(CStr("#" + CStr(x) + "#"), CStr(Value));
                        break;
                    default:
                        VALORE = "";
                        if (!IsNull(GetValueFromRS(objDocument.Fields[strField])))
                        {
                            VALORE = GetValueFromRS(objDocument.Fields[strField]);

                        }
                        break;

                }


            }
            return template;
        }
        private string formatDate(DateTime data)
        {
            string _formatDate = "";
            if (IsNull(data) == false)
            {
                string strDate;


                strDate = CStr(data).Replace("T", " ");

                strDate = Strings.Mid(strDate, 9, 2) + "/" + Strings.Mid(strDate, 6, 2) + "/" + Strings.Mid(strDate, 1, 4) + " " + Strings.Mid(strDate, 12, 5);
                _formatDate = strDate;
            }
            else
            {
                _formatDate = "";

            }
            return _formatDate;

        }



    }
}
