using Core.Repositories.Types;

namespace Core.Repositories.Abstractions.Interfaces
{
    public interface ILookupFilterDTO
    {
        string ColumnName { get; set; }
        object Value { get; set; }
        LookupFilterOperation Operation { get; set; }  
    }  

  
}
