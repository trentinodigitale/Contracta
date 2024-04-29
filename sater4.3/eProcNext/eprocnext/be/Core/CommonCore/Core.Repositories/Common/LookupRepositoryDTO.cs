using Core.Repositories.Abstractions.Interfaces;
using System.Collections.Generic;

namespace Core.Repositories
{
    public class LookupRepositoryDTO : ILookupDTO
    {
        public int PageNumber { get; set; }
        public int PageSize { get; set; }
        public IEnumerable<ILookupFilterDTO> Filters { get; set; } = new List<LookupFilterDTO>();
        public IEnumerable<ILookupSortingDTO> Sorting { get; set; } = new List<LookupSortingDTO>();
        public string ComplexExpresionFilters { get; set; } = string.Empty;
    }
}
