using System;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Core.Logger.Types
{
    public class NullableDateTime : JsonConverter<DateTime?>
    {
        public override DateTime? Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            DateTime? result = null;
            try { result = reader.GetDateTime(); }
            catch { }
            return result;
        }

        // This method will be ignored on serialization, and the default typeof(DateTime) converter is used instead.
        // This is a bug: https://github.com/dotnet/corefx/issues/41070#issuecomment-560949493
        public override void Write(Utf8JsonWriter writer, DateTime? value, JsonSerializerOptions options)
        {
            if (!value.HasValue)
                writer.WriteStringValue("");
            else
                writer.WriteStringValue(value.Value);
        }
    }
}
