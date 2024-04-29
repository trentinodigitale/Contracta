using System;
using System.Collections.Generic;
using System.Net;
using System.Text;

namespace Core.Logger.HelkLogEntry.Types
{
    /// <summary>
    /// Host info class for Client and Server information
    /// </summary>
    public class HostInfo
    {
        public string Ip { get; set; }
        public string Hostname { get; set; }
    }
}
