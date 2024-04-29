using eProcurementNext.Application;
using eProcurementNext.Authentication;
using eProcurementNext.BizDB;
using eProcurementNext.Cache;
using eProcurementNext.CommonModule;
using eProcurementNext.DashBoard;
using eProcurementNext.Razor;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Mvc;

// **********************************************************
//
//        A T T E N Z I O N E 
// 
// Questo file non andrebbe modificato se non in caso di 
// particolari interventi sul Core 
//
// In caso di interventi la sequenza della varie impostazioni
// non va modificata per non pregiudicare il corretto 
// funzionamento dell'applicazione
//
// Le parti non commentate sono quelle inserite di default
//
// **********************************************************



var builder = WebApplication.CreateBuilder(args);


#region Eventi
// Le righe seguenti sono necessarie a discriminare se è possibile salvare i dettagli di particolari
// eventi nell'event viewer di Windows che invece non esiste in sistemi operativi diversi (Unix like)

var IsWindows = System.Runtime.InteropServices.RuntimeInformation.IsOSPlatform(System.Runtime.InteropServices.OSPlatform.Windows);
if (IsWindows)
{

    builder.Logging.AddEventLog(eventLogSettings =>
    {
        eventLogSettings.Filter = new Func<string, LogLevel, bool>((str, lev) =>
        {
            if (str == "Microsoft.AspNetCore.Diagnostics.ExceptionHandlerMiddleware")
            {
                return false;
            }
            return true;
        });
    });
}

#endregion


#region XSRF CSRF

// disabilitazione/bypass del controllo nativo del framework
// che normalmente utilizza un proprio cookie e un campo hidden 
// per validare le richieste HTTP

builder.Services.AddRazorPages(options =>
{
    options.Conventions.ConfigureFilter(new IgnoreAntiforgeryTokenAttribute());
});

#endregion

#region Dependency Injection
// le righe seguenti sono necessarie alla Dependency Injection 

builder.Services.AddAutoMapper(typeof(Program));
builder.Services.AddApplication();
builder.Services.AddBizDB();
builder.Services.AddDashboard();
builder.Services.AddEProcResponse();
builder.Services.AddAuthenticationJWT();
builder.Services.AddCustomSession();
builder.Services.AddAuthHandlerCustom();
builder.Services.AddHttpContextAccessor();
builder.Services.AddSingleton<IGlobalAsa, MainGlobalAsa>();
#endregion


#region Regole Form

// trasposizione di impostazione presente nella precedente versione dell'applicazione
// limite massimo dei campi accettabili in un form 

builder.Services.Configure<FormOptions>(options =>
{
    string? formValueCountLimit = builder.Configuration.GetSection("FormValueCountLimit").Value;
    try
    {
        if (formValueCountLimit != null)
        {
            options.ValueCountLimit = Convert.ToInt32(formValueCountLimit);
        }
        else
        {
            options.ValueCountLimit = int.MaxValue;
        }
    }
    catch
    {
        options.ValueCountLimit = int.MaxValue;
    }
});

#endregion

var app = builder.Build();
IConfiguration Configuration = app.Configuration;


#region login

// impostazione dei percorsi di default 
// il valore di LoginPage è recuperato nell'appsettings.json presente nella sezione DefaultPaths

string? loginPath = app.Configuration.GetSection("DefaultPaths:LoginPage").Value;
if (string.IsNullOrEmpty(loginPath))
{
    loginPath = "/demo/index";
}

SessionMiddleware.LoginPath = loginPath;

#endregion


#region Session

// impostazioni delle varie proprietà della implementazione 
// in refactoring della Session nel rispetto di alcuni vincoli della soluzione originale

SessionMiddleware.Cookie_Auth_Name = Configuration.GetRequiredSection("Cookie_Auth_Name").Value!;
SessionMiddleware.Cookie_Anon_Name = Configuration.GetRequiredSection("Cookie_Anon_Name").Value!;
SessionMiddleware.DefaultHomePage = Configuration.GetSection("DefaultPaths:HomePage").Value!;
SessionMiddleware.Unauthorized = Configuration.GetSection("DefaultPaths:Unauthorized").Value!;
#endregion

#region Cache Redis

// Cache distribuita su Redis
// attualmente non in uso

EProcNextCache.RedisConnectionString = Configuration.GetSection("Redis:RedisConnectionString").Value!;
EProcNextCache.RedisDBNameCache = Configuration.GetSection("Redis:RedisDBNameCache").Value!;
EProcNextCache.RedisDBNameML = Configuration.GetSection("Redis:RedisDBNameML").Value!;
EProcNextCache.RedisDBEnabled = Configuration.GetSection("Redis:RedisDBEnabled").Value!.ToLower() == "true";
#endregion

#region Condivisione variabili globali

// work around ad alcuni limiti al ricorso alla DI

ConfigurationServices._configuration = app.Configuration;
MongoLog.ConnectionString = Configuration.GetSection("ConnectionStrings:MongoDbConnection").Value!;
#endregion


#region Proxy

//gestione ip proxy "HTTP_X_FORWARDED_FOR"

app.UseForwardedHeaders(new ForwardedHeadersOptions 
{
    ForwardedHeaders =
        ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
});
#endregion


#region HTTP Pipeline

// Inizio della configurazione per le HTTP request pipeline.


// pagina da usare in caso di Eccezione
// in realtà le eccezioni vengono rilevate e gestite nel codice
app.UseExceptionHandler("/Error");
#endregion

#region HTTPS
// impostazione relativa alla gestione HTTPS ottimizzata da parte del framework
if (!app.Environment.IsDevelopment())
{
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    if (Configuration.GetRequiredSection("UseHsts").Value == "yes")
        app.UseHsts();
}


if (Configuration.GetRequiredSection("UseHttpsRedirection").Value == "yes")
    app.UseHttpsRedirection();

#endregion


#region impostazioni per i files

// azzeramento impostazione di default relativa alla gestione dei files
// per rispettare le esigenze di refactoring e retrocompatibilitò con pagine .asp

var options = new DefaultFilesOptions();
options.DefaultFileNames.Clear();
app.UseDefaultFiles(options);

app.UsePathBase(Configuration.GetRequiredSection("ApplicationContext:strVirtualDirectory").Value); //Es: /startPath
app.UseStaticFiles();
#endregion

#region 404

// definizione di come gestire l'errore 404 verso una specifica pagina
app.UseStatusCodePages(async statusCodeContext =>
{
    if (statusCodeContext.HttpContext.Response.StatusCode == 404)
    {
        statusCodeContext.HttpContext.Response.Redirect(Configuration.GetRequiredSection("DefaultPaths:NotFound").Value + @"?page=" + statusCodeContext.HttpContext.Request.Path.ToString());
    }
});
#endregion

app.UseRouting();


app.UseRoutingMiddleware();
app.UseSessionMiddleware();
app.Use(async (context, next) =>
{
    //Necessario per pagine come DisplayAttach che scrivono in modo sincrono sulla Body della Response
    var syncIoFeature = context.Features.Get<IHttpBodyControlFeature>();
    if (syncIoFeature != null)
    {
        syncIoFeature.AllowSynchronousIO = true;
    }

    await next();
});
app.MapDefaultControllerRoute();
app.UseEndpoints(endpoints =>
{
    endpoints.MapRazorPages();
    foreach (var endpointsItem in endpoints.DataSources)
    {
        ConfigurationServices.ListOfEndpoints.Add(endpointsItem.Endpoints);
    }

});

ConfigurationServices._contentRootPath = app.Environment.ContentRootPath;


#region Comaptibilità con Global.asa pre-refactoring

// gestione eventi durante la fase di avvio dell'applicazione
IGlobalAsa globalAsa = app.Services.GetRequiredService<IGlobalAsa>();
globalAsa.MY_Application_OnStart();

// gestione eventi al termine dell'applicazione (inutilizzo per i minuti di latenza impostati)
app.Lifetime.ApplicationStopped.Register(() =>
{
    IGlobalAsa globalAsa = app.Services.GetRequiredService<IGlobalAsa>();
    globalAsa.Application_OnEnd();
});
#endregion

app.Run();
