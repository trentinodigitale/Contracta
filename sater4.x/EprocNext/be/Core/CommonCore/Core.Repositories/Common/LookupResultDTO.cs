using Core.Repositories.Abstractions.Interfaces;
using System.Collections.Generic;

namespace Core.Repositories
{
    public class LookupResultDTO<T> : ILookupResultDTO<T>
    {
        public IEnumerable<T> Data { get; set; }
        public long TotalRecords { get; set; }
        public long TotalPages { get; set; }
    }
}
