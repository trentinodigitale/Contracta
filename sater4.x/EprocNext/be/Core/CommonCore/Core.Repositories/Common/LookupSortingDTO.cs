using Core.Repositories.Abstractions.Interfaces;
using Core.Repositories.Types;

namespace Core.Repositories
{
    public class LookupSortingDTO: ILookupSortingDTO
    {
        public string ColumnName { get; set; }
        public LookupSortingDirection Direction { get; set; }
    }
}
