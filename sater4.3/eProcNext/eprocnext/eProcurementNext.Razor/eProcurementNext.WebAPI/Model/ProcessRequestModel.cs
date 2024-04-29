using System.ComponentModel.DataAnnotations;

namespace eProcurementNext.WebAPI.Model
{
    public class ProcessRequestModel
    {

        [Required(AllowEmptyStrings = false,
            ErrorMessage = "Il campo ProcessName è obbligatorio"
            )]
        public string ProcessName { get; set; } = null!;

        [Required(AllowEmptyStrings = false,
            ErrorMessage = "Il campo DocType è obbligatorio"
            )]
        public string DocType { get; set; } = null!;

        [Required(ErrorMessage = "Il campo DocKey è obbligatorio")]
        public int DocKey { get; set; }

        public ProcessRequestModel(string processName, string docType, int docKey)
        {
            ProcessName = processName;
            DocType = docType;
            DocKey = docKey;
        }
    }
}
