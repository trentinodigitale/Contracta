using System;
using System.Collections.Generic;
using System.Text;

namespace Core.Logger.Types
{
    public static class Constants
    {
        public static string RESPONSE_HEADER_RESPONSE_TIME => "X-Response-Time-ms";
        public static string HTTP_CONTEXT_TIMER => "ExecutionTimer";
        public static string HTTP_CONTEXT_REQUEST_STARTED_ON => "RequestStartedOn";
    }
}
