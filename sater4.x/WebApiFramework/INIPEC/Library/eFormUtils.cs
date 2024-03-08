using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;

namespace INIPEC.Library
{
    public class EformUtils
    {
        public string GetXmlTemplate(string template, string pathWorkspace)
        {
            var workspace = ConfigurationManager.AppSettings["e_forms.cn16.pathTemplate"];

            //Se non è presente il path dei template nel file di conf, lo recupero dinamicamente
            if (string.IsNullOrEmpty(workspace))
                workspace = pathWorkspace;

            var pathTemplate = Path.Combine(workspace, "eForms", template + ".xml");
            return File.ReadAllText(pathTemplate);
        }

        public string ElabXmlDb(SqlDataReader rs, string xmlbase, List<string> colToExlude = null)
        {
            var newXmlbase = xmlbase;

            // Scorro tutte le colonne del recordset
            for (var i = 0; i < rs.FieldCount; i++)
            {
                var columnName = rs.GetName(i);      // Nome della colonna
                var columnValue = "";

                //Se il valore restituito dal db è NULL forziamo a stringa vuota
                if (!rs.IsDBNull(i))
                    columnValue = rs.GetString(i);   // Valore della colonna, sempre stringa

                //Se non ci sono colonne da escludere oppure se la colonna in esame non è tra quelle escluse
                if (colToExlude == null || !colToExlude.Contains(columnName))
                {
                    //Se la fonte dati richiede che il codice NON faccia un htmlencode lascio il valore originale, altrimenti applico un htmlencode
                    if (!columnName.Contains("_NO_ENCODE_"))
                        columnValue = HttpUtility.HtmlEncode(columnValue);

                    newXmlbase = newXmlbase.Replace("@@@" + columnName + "@@@", columnValue);
                }

            }

            return newXmlbase;
        }

        public string GetNewGuid()
        {
            var nuovoGuid = Guid.NewGuid();

            return nuovoGuid.ToString("D"); // "D" rappresenta il formato standard dei GUID
        }
    }
}