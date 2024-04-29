namespace Core.Controllers.Types
{
    public class ErrorClientResponse
    {
        public string UserMessage { get; set; }
        public string InternalMessage { get; set; }
        public int? ErrorCode { get; set; }
        public string Tips { get; set; }
    }
}
