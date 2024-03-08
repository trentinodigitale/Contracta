using Core.Repositories.Types;

namespace Core.Repositories.Abstractions.Interfaces
{
    public interface ILookupSortingDTO
    {
        string ColumnName { get; set; }
        LookupSortingDirection Direction { get; set; }
    }
}
