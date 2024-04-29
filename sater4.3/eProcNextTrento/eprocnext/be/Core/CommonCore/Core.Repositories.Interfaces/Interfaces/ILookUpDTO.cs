using System;
using System.Collections.Generic;
using System.Text;

namespace Core.Repositories.Abstractions.Interfaces
{
    public interface ILookupDTO
    {
        int PageNumber { get; set; }
        int PageSize { get; set; }
        IEnumerable<ILookupFilterDTO> Filters { get; set; }
        IEnumerable<ILookupSortingDTO> Sorting { get; set; }
        string ComplexExpresionFilters { get; set; }
    }
}
