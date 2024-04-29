using System.Collections.Generic;

namespace Cloud.EprocNext.DTO.Controllers
{
    public class SearchResult<TDto> // where TDto : IDTO // Stefano: temporary commented because I need to use another kind of DTO (MongoDB DTO and it may cause circular dependency error )
    {
        public List<TDto> data { get; set; } = new List<TDto>();
        public long recordsOut { get; set; } = 0;
        public long totalRecords { get; set; } = 0;
        public long totalPages { get; set; } = 0;
    }
}
