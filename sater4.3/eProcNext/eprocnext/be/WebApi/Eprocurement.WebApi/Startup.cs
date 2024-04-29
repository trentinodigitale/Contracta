using EprocNext.WebApi.Common;
using Core.Authentication;
using Core.Authentication.Auth;
using Cloud.Core.Controllers.SchemaFilter;
using Core.DistribuitedCache;
using Core.Logger;
using Core.Logger.Interfaces;
using Core.Logger.Types;
using Core.Repositories.NoSql;
using Cloud.Core.WebApi.Binder;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.PlatformAbstractions;
using Microsoft.OpenApi.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.Unicode;
using EprocNext.Controllers.Base;
using EprocNext.Repositories;

namespace EprocNext.WebApi
{
    /// <summary>
    /// Startup class
    /// </summary>
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddHelkLogger(Configuration);
            
            services.AddRedisCache(Configuration);
            var mapper = services.GetEpcorNextRepositoriesMappingList();
            services.AddNoSqlRepository<DbSessionProvider>(Configuration);
            //services.AddEprocNextDto(mapper);
            services.AddEprocNextRepositories<DbSessionProvider>(registerMaps: false);
            //services.AddEprocNextRepositories<DbSessionProvider>(mapper);
            services.AddCoreServices(Configuration);
            services.AddLogging();
            services.AddNoSqlRepository<DbSessionProvider>(Configuration);
            services.AddAuthServices<BaseUserClaimsIdentityProvider>(Configuration);
            

            services.AddControllers()
                .AddJsonOptions(options =>
                {
                    options.JsonSerializerOptions.PropertyNameCaseInsensitive = false;
                    options.JsonSerializerOptions.Encoder = JavaScriptEncoder.Create(UnicodeRanges.All);
                    options.JsonSerializerOptions.Converters.Add(new NullableDateTime());
                }).AddXmlSerializerFormatters();

            //services.AddCors()
            //    .AddMvc(option =>
            //    {
            //        option.ModelBinderProviders.Insert(0, new ComplexModelBinderProvider<HeaderComplexModelBinder>());
            //        option.EnableEndpointRouting = false;
            //    })
            //    .AddXmlSerializerFormatters()
            //    .SetCompatibilityVersion(CompatibilityVersion.Version_3_0);

            services.AddSwaggerGen(options =>
            {
                // Aggiornamento Fwk 3.1
                options.SwaggerDoc("v1",
                new OpenApiInfo
                {
                    Version = "Last version v1.0",
                    Title = "eProcurement Next",
                    Description = "Cloud eProcurement Next API Swagger surface",
                    Contact = new OpenApiContact { Name = "TeamSystem S.p.A.", Email = "info@teamsystem.com", Url = new Uri("http://www.teamsystem.com") },
                    License = new OpenApiLicense { Name = "Copyright(c) 2022 - TeamSystem S.p.A.", Url = new Uri("http://www.teamsystem.com") }
                });

                var filePath = Path.Combine(PlatformServices.Default.Application.ApplicationBasePath, "api.xml");
                options.IncludeXmlComments(filePath);
                options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
                {
                    Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
                    Name = "Authorization",
                    In = ParameterLocation.Header,
                    Type = SecuritySchemeType.ApiKey,
                    Scheme = "Bearer"
                });

                options.AddSecurityRequirement(new OpenApiSecurityRequirement
                {
                    {
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference
                            {
                                Id = "Bearer", // The name of the previously defined security scheme.
                                Type = ReferenceType.SecurityScheme
                            }
                        },
                        new List<string>()
                    }
                });

                options.SchemaFilter<RequireValueTypePropertiesSchemaFilter>(/*camelCasePropertyNames:*/ true);
            });


        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, IServiceProvider svp)
        {
            #region 1 - Middleware building
            app.UseCors(x => x
                .AllowAnyOrigin()
                .AllowAnyMethod()
                .AllowAnyHeader()
            );

            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                var Logger = svp.GetRequiredService<IHelkLogger>();
                app.UseExceptionHandler(errorApp =>
                {
                    errorApp.Run(async context =>
                    {
                        context.Response.StatusCode = StatusCodes.Status500InternalServerError;
                        context.Response.ContentType = "application/json";
                        var exceptionHandlerPathFeature = context.Features.Get<IExceptionHandlerPathFeature>();
                        var ErrorMessage = exceptionHandlerPathFeature?.Error?.Message ?? "Errore generico";
                        //await Logger.LogAsync(new LogEntryData
                        //{
                        //    Level = LogLevel.error,
                        //    Message = JsonSerializer.Serialize(new
                        //    {
                        //        error = ErrorMessage,
                        //        path = exceptionHandlerPathFeature?.Path,
                        //        stacktrace = exceptionHandlerPathFeature?.Error?.StackTrace
                        //    }),
                        //    ResponseStatusCode = StatusCodes.Status500InternalServerError
                        //});
                        if (env.IsDevelopment())
                        {
                            ErrorMessage = exceptionHandlerPathFeature?.Error?.StackTrace ?? ErrorMessage;
                        }
                        await context.Response.WriteAsync(ErrorMessage);
                    });
                });
                app.UseHsts();
                app.UseHttpsRedirection();
            }

            app.UseAuthentication();
            app.UseFileServer();
            if (env.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI(s =>
                {
                    s.SwaggerEndpoint("/swagger/v1/swagger.json", "EprocNext.WebApi");
                });
            }

            app.UseMvc();
            app.UseRouting();
            app.UseAuthorization();
            app.UseEndpoints(endpoints => { endpoints.MapControllers(); });
            #endregion

        }
    }
}

