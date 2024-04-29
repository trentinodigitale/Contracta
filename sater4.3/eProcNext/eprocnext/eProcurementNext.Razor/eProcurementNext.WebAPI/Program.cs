
//Creiamo l'oggetto builder per effettuare le configurazioni dell'applicazione
using eProcurementNext.Application;
using eProcurementNext.Authentication;
using eProcurementNext.BizDB;
using eProcurementNext.Cache;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Handler;
using eProcurementNext.DashBoard;
using eProcurementNext.Razor;
using eProcurementNext.Session;
using eProcurementNext.WebAPI.Filter;
using eProcurementNext.WebAPI.Utils;
using Microsoft.OpenApi.Models;
using MongoDB.Bson.Serialization;
using MongoDB.Bson.Serialization.Serializers;

var builder = WebApplication.CreateBuilder(args);

/* Inizio configurazione dei servizi */
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(
    policy =>
    {
        string[] AllowedHosts = builder.Configuration.GetSection("AllowedHosts").Get<string[]>();
        policy.WithOrigins(AllowedHosts);
        if (!AllowedHosts.Contains("*"))
        {
            policy.AllowCredentials();
        }
        policy.AllowAnyHeader();
        policy.AllowAnyMethod();
    });
});
builder.Services.AddControllers()
	.AddXmlSerializerFormatters();

/*
builder.Services.AddControllers(options =>
{
	options.Filters.Add<HttpResponseExceptionFilter>();
});*/

builder.Services.AddEndpointsApiExplorer(); //marcher� le API come consultabili 
builder.Services.AddSwaggerGen(opt =>
{
    opt.AddSecurityDefinition("bearer", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http,
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Scheme = "bearer"
    });
    opt.OperationFilter<AuthenticationRequirementsOperationFilter>();
});           //genera il file swagger
builder.Services.AddAutoMapper(typeof(Program));
builder.Services.AddAuthenticationJWT();
builder.Services.AddCustomSession();
builder.Services.AddAuthHandlerCustom();
builder.Services.AddLogHandler();
builder.Services.AddHttpContextAccessor();
builder.Services.AddApplication();
builder.Services.AddBizDB();
builder.Services.AddDashboard();

ApplicationCommon.Configuration = builder.Configuration;
SessionCommon.Configuration = builder.Configuration;
CacheCommon.Configuration = builder.Configuration;
ConfigurationServices._configuration = builder.Configuration;
ApplicationCommon.Application["ConnectionString"] = builder.Configuration.GetSection("ConnectionStrings:DefaultConnection").Value!;
MainGlobalAsa.InitializeMultiLanguage();
/* Fine configurazione dei servizi */

var app = builder.Build();

ConfigurationServices._contentRootPath = app.Environment.ContentRootPath;
WidgetUtils widgetUtils = new();
widgetUtils.LoadWidgetFromJson(checkLastUpdate: true);
/* Inizio gestione delle HTTP request pipeline / middleware */

app.UseCors();

if (app.Environment.IsDevelopment())
{
    //Se invocato swagger gestiamo in automatico le richieste e le risposte tramite swagger
    app.UseSwagger();
    app.UseSwaggerUI();
}

if (builder.Configuration.GetSection("UseHttpsRedirection").Exists() && builder.Configuration.GetRequiredSection("UseHttpsRedirection").Value == "yes")
    app.UseHttpsRedirection();//Effettua il redirect da http ad https in modo automatico
  

/* API-Handler degli errori */
if (app.Environment.IsDevelopment())
{

    app.UseExceptionHandler(new ExceptionHandlerOptions()
    {
        AllowStatusCode404Response = true,
        ExceptionHandlingPath = "/apierror-development"
    });
}
else
{
    app.UseExceptionHandler("/apierror");
}

BsonSerializer.RegisterSerializer(new ObjectSerializer(ObjectSerializer.AllAllowedTypes));

app.UseAuthorization();     //Aggiungiamo il supporto per le autorizzazioni di default

/* middleware Map___ */

app.MapControllers();   //mappa le richieste sui controller, va a leggere tutti gli attributi ROUTE

app.Run(); //middleware di tipo RUN, gira 1 sola volta e blocca l'esecuzione della pipeline. manda in esecuzione l'applicazione

/* Fine gestione delle pipeline */

