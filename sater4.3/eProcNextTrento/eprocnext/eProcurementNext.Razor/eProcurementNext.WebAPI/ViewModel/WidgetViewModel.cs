using eProcurementNext.WebAPI.Model;
using System.ComponentModel.DataAnnotations;

namespace eProcurementNext.WebAPI.Model
{
    public class WidgetViewModel : WidgetModel
    {
        public enum WidgetType
        {
            Base,//0
            List,//1
            Group,//2
            Chart//3
        }

        public int Id { get; set; }
        public WidgetType Type { get; set; }
        public Guid Code { get; set; }
        public string Title { get; set; }
        public Dictionary<string, object> Params { get; set; }
        public int Pos_permission { get; set; }
        public string Stored { get; set; }
        public string Deleted { get; set; }
    }
}
