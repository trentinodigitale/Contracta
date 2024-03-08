using Core.Logger.Types;
using Microsoft.AspNetCore.Http;
using System;
using System.Diagnostics;
using System.Threading.Tasks;

namespace Core.Logger.Middleware
{
    public class ResponseTimeMiddleware
    {
        private readonly RequestDelegate _next;

        // Name of the Response Header, Custom Headers starts with "X-"
        private const string RESPONSE_HEADER_RESPONSE_TIME = "X-Response-Time-ms";

        public ResponseTimeMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public Task Invoke(HttpContext context)
        {
            // 1. Register starting time for request
            Stopwatch timer = new Stopwatch();
            try
            {
                context.Items.Add(Constants.HTTP_CONTEXT_REQUEST_STARTED_ON, DateTime.UtcNow);

                // 2. Create and start new high resolution timer for that request
                timer.Start();
                context.Items.Add(Constants.HTTP_CONTEXT_TIMER, timer);
            }
            catch { }

            // 3. Add Response OnStarting callback
            context.Response.OnStarting(() => {
                // Stop the timer
                timer?.Stop();

                // Add the Response time information in the Response headers.
                try
                {
                    context.Response.Headers.Add(Constants.RESPONSE_HEADER_RESPONSE_TIME, $"{timer?.ElapsedMilliseconds}");
                }
                catch { }

                return Task.CompletedTask;
            });

            // Call the next delegate/middleware in the pipeline
            return _next(context);
        }
    }
}
