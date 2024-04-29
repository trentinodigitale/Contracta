using Core.Repositories.Abstractions.Interfaces;
using Core.Repositories.Types;

namespace Core.Repositories
{
    public class LookupFilterDTO: ILookupFilterDTO
    {
        public string ColumnName { get; set; }
        public object Value { get; set; }
        public LookupFilterOperation Operation { get; set; } 
    }
}
