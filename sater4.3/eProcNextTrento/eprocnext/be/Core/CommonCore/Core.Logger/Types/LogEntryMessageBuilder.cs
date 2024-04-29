using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Core.Logger.Types
{
    public class LogEntryMessageBuilder<TInput> where TInput : class
    {
        public string Method { get; set; }
        public TInput Input { get; set; }
        public string Info { get; set; }

        public LogEntryMessageBuilder(string method, string info, TInput input = null)
        {
            Method = method;
            Input = input;
            Info = info;
        }

        public override string ToString()
        {
            var a = new JsonSerializerOptions() { };
            a.Converters.Add(new NullableDateTime());
            return JsonSerializer.Serialize(this, a);
        }
    }

    public class LogEntryMessageBuilderMultipleEntries
    {
        public string CreateMultipleEntries<T>(string method, string info, T input) where T : class
        {
            return new LogEntryMessageBuilder<T>(method, info, input).ToString();
        }
    }
}
