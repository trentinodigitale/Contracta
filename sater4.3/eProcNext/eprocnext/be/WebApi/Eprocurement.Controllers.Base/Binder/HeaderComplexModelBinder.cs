using Cloud.Core.Controllers.JsonConverters;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using System;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace Cloud.Core.WebApi.Binder
{
    [ExcludeFromCodeCoverage]
    public class HeaderComplexModelBinder : IModelBinder
    {
        private JsonSerializerOptions SerializerOptions
        {
            get
            {
                var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
                options.Converters.Add(new CustomJsonConverterFactory());
                return options;
            }
        }

        public Task BindModelAsync(ModelBindingContext bindingContext)
        {
            if (bindingContext == null)
            {
                throw new ArgumentNullException(nameof(bindingContext));
            }

            var headerKey = bindingContext.ModelMetadata.BinderModelName; // Resolve Name from FormHeader(Name = "Key")
            if (string.IsNullOrEmpty(headerKey))
            {
                throw new ArgumentNullException(nameof(bindingContext.ModelMetadata.BinderModelName));
            }

            var headerValue = bindingContext.HttpContext.Request.Headers[headerKey].FirstOrDefault();
            if (!string.IsNullOrEmpty(headerValue))
            {
                try
                {
                    bindingContext.Model = JsonSerializer.Deserialize(headerValue, bindingContext.ModelType, SerializerOptions);
                    bindingContext.Result = ModelBindingResult.Success(bindingContext.Model);
                }
                catch (Exception ex)
                {
                    bindingContext.ModelState.AddModelError(bindingContext.ModelName, ex.Message);
                }
            }
            return Task.CompletedTask;
        }
    }
}
