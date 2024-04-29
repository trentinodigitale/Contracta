using Core.Repositories.Abstractions.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Cloud.Core.Controllers.JsonConverters
{
    public class CustomJsonConverterFactory : JsonConverterFactory
    {
        private Dictionary<Type, Type> RegisteredInterface { get; } = new Dictionary<Type, Type>
        {
            { typeof(ILookupFilterDTO), typeof(LookupFilterJsonConverter) },
            { typeof(ILookupSortingDTO), typeof(LookupSortingJsonConverter) }
        };

        public override bool CanConvert(Type typeToConvert)
        {
            if (!typeToConvert.IsInterface)
                return false;

            return RegisteredInterface.Keys.Any(t => t == typeToConvert);
        }

        public override JsonConverter CreateConverter(Type typeToConvert, JsonSerializerOptions options)
        {
            var converterType = RegisteredInterface[typeToConvert];
            return (JsonConverter)Activator.CreateInstance(converterType);
        }
    }
}
