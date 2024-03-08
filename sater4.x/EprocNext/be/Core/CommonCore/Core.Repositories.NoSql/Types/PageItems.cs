using System.Collections.Generic;

namespace Core.Repositories.NoSql.Model
{
    public class PageItems<T>
    {
        public IEnumerable<T> Data { get; set; }
        public long TotalRecords { get; set; }
        public long TotalPages { get; set; }
    }

    public class PageItems : PageItems<object> { }
}
