
using Core.Logger.Types;

namespace Core.Logger.HelkLogEntry.Types
{
    public class ApplicationInfo
    {
        /// <summary>
        /// Service name, is constant keyword which depends
        /// on your application registered to the TS PAAS
        /// </summary>
        public string Name { get; set; }
        /// <summary>
        /// Application version, keyword value.
        /// Example: 1.0, 1.2, 2.0, ...
        /// </summary>
        public string Version { get; set; }
        /// <summary>
        /// Tech stack used in your application
        /// Example: node, python, etc...
        /// </summary>
        public ApplicationStack Stack { get; set; }
    }
}
