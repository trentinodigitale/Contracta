using Core.Logger.HelkLogEntry.Types;

namespace Core.Logger.Types
{
    public class ApplicationData
    {
        public string Env { get; set; }
        public CloudInfo Cloud { get; set; }
        public ApplicationInfo Application { get; set; }
        public HostInfo Server { get; set; }
    }
}
