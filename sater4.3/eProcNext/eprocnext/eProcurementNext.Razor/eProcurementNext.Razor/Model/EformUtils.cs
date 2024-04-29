using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using System.Data.SqlClient;
using System.Web;

namespace eProcurementNext.Razor.Model
{
    public class EformUtils
    {
        public string GetXmlTemplate(string template, string pathWorkspace)
        {
            var workspace = ConfigurationServices.GetKey("e_forms:cn16.pathTemplate", pathWorkspace);
            var pathTemplate = Path.Combine(workspace!, "wwwroot", "eForms", template + ".xml");

            return CommonStorage.ReadAllText(pathTemplate);
        }

        public string ElabXmlDb(TSRecordSet rs, string xmlbase, List<string>? colToExlude = null)
        {
            var newXmlbase = xmlbase;

            // Itera attraverso le colonne
            for (var i = 0; i < rs.Columns!.Count; i++)
            {
                var columnName = rs.Columns[i].ColumnName;      // Nome della colonna
                var columnValue = "";

                //Se il valore restituito dal db è NULL forziamo a stringa vuota
                if (rs[i] != null)
                    columnValue = (string?)rs[i];   // Valore della colonna, sempre stringa

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

    }
}
