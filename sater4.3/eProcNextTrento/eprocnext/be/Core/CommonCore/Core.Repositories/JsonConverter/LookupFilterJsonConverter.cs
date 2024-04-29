using Core.Repositories;
using Core.Repositories.Abstractions.Interfaces;
using System;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Core.Controllers.JsonConverters
{
    public class LookupFilterJsonConverter : JsonConverter<ILookupFilterDTO>
    {
        public override ILookupFilterDTO Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            var obj = JsonSerializer.Deserialize<LookupFilterDTO>(ref reader, options);
            if (obj.Value != null)
            {
                obj.Value = obj.Value.ToString();
            }
            return obj;
        }

        public override void Write(Utf8JsonWriter writer, ILookupFilterDTO value, JsonSerializerOptions options)
        {
            writer.WriteStringValue(value.ColumnName);
            writer.WriteNumberValue((int)value.Operation);
            writer.WriteStringValue(value.Value.ToString());
        }
    }
}
