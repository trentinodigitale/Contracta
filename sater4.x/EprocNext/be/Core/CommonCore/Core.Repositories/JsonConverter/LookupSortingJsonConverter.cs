using Core.Repositories;
using Core.Repositories.Abstractions.Interfaces;
using System;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Core.Controllers.JsonConverters
{
    public class LookupSortingJsonConverter : JsonConverter<ILookupSortingDTO>
    {
        public override ILookupSortingDTO Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            return JsonSerializer.Deserialize<LookupSortingDTO>(ref reader, options);
        }

        public override void Write(Utf8JsonWriter writer, ILookupSortingDTO value, JsonSerializerOptions options)
        {
            writer.WriteStringValue(value.ColumnName);
            writer.WriteNumberValue((int) value.Direction);
        }
    }
}
