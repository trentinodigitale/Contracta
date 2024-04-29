using Core.Logger.HelkLogEntry.Types;
using Core.Logger.Interfaces;
using Core.Logger.Sql;
using Core.Logger.Types;
using Microsoft.AspNetCore.Http;
using System;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Security.Claims;

namespace Core.Logger.HelkLogEntry.Builders
{
    internal class StandardHelkLogEntryBuilder
    {
        private HttpContext HttpContext { get; }
        private ISqlUserInfo LoggerRepository { get; }
        private ApplicationData Data { get; }

        public StandardHelkLogEntryBuilder(IHttpContextAccessor httpContext, ISqlUserInfo loggerRepository, ApplicationData data)
        {
            HttpContext = httpContext.HttpContext;
            LoggerRepository = loggerRepository;
            Data = data;
        }

        private HttpRequestMethod RequestMethod()
        {
            var method = (string.IsNullOrEmpty(HttpContext?.Request?.Method) ? "GET" : HttpContext?.Request?.Method).ToLower();
            var selectedRequestMethod = Enum.GetNames(typeof(HttpRequestMethod)).FirstOrDefault(m => m == method);
            return (HttpRequestMethod)Enum.Parse(typeof(HttpRequestMethod), selectedRequestMethod);
        }

        private (long? tenant, long? user, string user_login) GetInfoClaims()
        {
            var claims = HttpContext?.User?.Claims;
            var tenantId = claims?.FirstOrDefault(x => x.Type == "tenant_id")?.Value;
            var Tenant = long.TryParse(tenantId, out var tId) ? tId : default(long?);
            var accountId = claims?.FirstOrDefault(x => x.Type == ClaimTypes.NameIdentifier)?.Value;
            var AccountId = long.TryParse(accountId, out var accId) ? accId : default(long?);
            var CurrentUser = claims?.FirstOrDefault(x => x.Type == ClaimTypes.Name)?.Value;
            return (Tenant, AccountId, CurrentUser);
        }

        public StandardHelkLogEntry<T> Build<T>(ILogEntryData<T> Input) where T: class
        {
            var executionTimer = HttpContext?.Items!=null ? (Stopwatch) HttpContext?.Items[Constants.HTTP_CONTEXT_TIMER]:null;
            var Result = new StandardHelkLogEntry<T>
            {
                Timestamp = DateTime.Now,

                Event = new EventInfo<T>
                {
                    Duration = executionTimer?.ElapsedMilliseconds ?? Input.ExecutionTimer?.ElapsedMilliseconds ?? -1,
                    Message = Input.Message
                },

                Error = new ErrorInfo
                {
                    Message = Input.LogException?.Message,
                    Stack_trace = Input.LogException?.StackTrace,
                    Type = Input.LogException?.GetType().Name
                },

                App = Data?.Application,

                Business_unit = BusinessUnit.enterprise,

                Client = new HostInfo
                {
                    Hostname = HttpContext?.Request?.Host.Value ?? "",
                    Ip = HttpContext?.Connection?.RemoteIpAddress?.ToString() ?? ""
                },

                Server = Data.Server,

                Cloud = Data.Cloud,

                Correlation = new CorrelationInfo
                {
                    Id = Guid.NewGuid().ToString(),
                },

                Http = new HttpInfo
                {
                    Request = new HttpRequestInfo
                    {
                        Bytes = HttpContext?.Request?.ContentLength ?? null,
                        Method = RequestMethod()
                    },
                    Response = new HttpResponseInfo
                    {
                        Status_code = (HttpStatusCode) (Input.ResponseStatusCode ?? HttpContext?.Response?.StatusCode ?? (int?) HttpStatusCode.InternalServerError)
                    }
                },

                Log = new LogInfo
                {
                    Level = Input.Level,
                    Retention = Input.Retention
                },

                Environment = Data.Env
            };

            var (tenant, user, user_login) = GetInfoClaims();
            Result.User = user_login;
            Result.Customer = LoggerRepository.GetInfo(new UserInfoFilter { Tenant = tenant ?? default, User = user ?? default });
            return Result;
        }
    }
}
