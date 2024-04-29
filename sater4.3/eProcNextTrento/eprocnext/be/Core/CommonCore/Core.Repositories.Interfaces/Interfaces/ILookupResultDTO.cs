using System.Collections.Generic;

namespace Core.Repositories.Abstractions.Interfaces
{
    public interface ILookupResultDTO<T>
    {
        IEnumerable<T> Data { get; set; }
        long TotalRecords { get; set; }
        long TotalPages { get; set; }
    } 
}
