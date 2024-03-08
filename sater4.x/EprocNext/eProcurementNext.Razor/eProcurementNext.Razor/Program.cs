using Amazon.Auth.AccessControlPolicy;
using Chilkat;
using DocumentFormat.OpenXml.ExtendedProperties;
using DocumentFormat.OpenXml.InkML;
using DocumentFormat.OpenXml.Spreadsheet;
using DocumentFormat.OpenXml.Wordprocessing;
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
using Microsoft.Extensions.Options;
using Microsoft.VisualStudio.TestPlatform.ObjectModel;
using System;
using System.Net.NetworkInformation;

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

#region VL1 - Lack of Security Headers
//X - Frame - Options
//DENY: impedisce completamente che la pagina venga richiamata in un iframe.
//SAMEORIGIN : Impedisce che la pagina venga richiamata in un iframe esterno al suo dominio.
//ALLOW -FROM uri: consente di chiamare da un URL specifico in un iframe.
string X_Frame_OptionsX_Frame_Options = "";
try 
{
    X_Frame_OptionsX_Frame_Options = Configuration.GetRequiredSection("ApplicationContext:X_Frame_Options").Value;
}
catch (Exception)
{
    X_Frame_OptionsX_Frame_Options = "";
}
if (X_Frame_OptionsX_Frame_Options == "1")
{
    app.Use(async (context, next) =>
    {
        context.Response.Headers.Add("X-Frame-Options", Configuration.GetRequiredSection("ApplicationContext:X_Frame_Options_Value").Value);
        await next();
    });
}


//Cache - Control
//Aggiunge intestazioni per controllare la memorizzazione nella cache delle richieste successive
// - Cache-Control: memorizza nella cache le risposte memorizzabili nella cache per un massimo di 10 secondi.
// - Vary: configura il middleware per fornire una risposta memorizzata nella cache solo se l' intestazione Accept-Encoding delle richieste successive corrisponde a quella della richiesta originale.
// per info vai al link https://learn.microsoft.com/en-us/aspnet/core/performance/caching/middleware?view=aspnetcore-8.0
string Cache_Control = "";
try
{
    Cache_Control = Configuration.GetRequiredSection("ApplicationContext:Cache_Control").Value;
}
catch (Exception)
{
    Cache_Control = "";
}
if (Cache_Control == "1")
{
    builder.Services.AddResponseCaching();
    app.UseResponseCaching();
    app.Use(async (context, next) =>
    {
        context.Response.GetTypedHeaders().CacheControl =
            new Microsoft.Net.Http.Headers.CacheControlHeaderValue()
            {
                Public = true,
                MaxAge = TimeSpan.FromSeconds(10)
            };

        string? Cache_Control_Value = "";
        Cache_Control_Value = Configuration.GetRequiredSection("ApplicationContext:Cache_Control_Value").Value;
        if (string.IsNullOrWhiteSpace(Cache_Control_Value))
        {
            Cache_Control_Value = "";
        }

        context.Response.Headers[Microsoft.Net.Http.Headers.HeaderNames.Vary] =
            new string[] { Cache_Control_Value };

        await next();
    });
}


//X - XSS - Protection
// - 0 : Disabilita la protezione XSS (utile quando potresti voler testare XSS da solo)
// - 1 : Abilita la protezione XSS. Se viene rilevato XSS, il browser tenta di filtrare o pulire l'output, ma lo visualizza comunque per la maggior parte.
// - 1; mode = block : Abilita la protezione XSS e se viene rilevato XSS, il browser interrompe completamente il rendering.
string X_XSS_Protection = "";
try
{
    X_XSS_Protection = Configuration.GetRequiredSection("ApplicationContext:X_XSS_Protection").Value;
}
catch (Exception)
{
    X_XSS_Protection = "";
}
if (X_XSS_Protection == "1")
{
    app.Use(async (context, next) =>
    {
        context.Response.Headers.Add("X-Xss-Protection", Configuration.GetRequiredSection("ApplicationContext:X_XSS_Protection_Value").Value);
        await next();
    });
}
//X - Content - Type - Options
//X-Content-Type-Options è un'intestazione che dice a un browser di non provare a "indovinare" quale potrebbe essere il tipo MIME di una risorsa e di prendere semplicemente quale tipo MIME il server ha restituito come dato di fatto.
string X_Content_Type_Options = "";
try
{
    X_Content_Type_Options = Configuration.GetRequiredSection("ApplicationContext:X_Content_Type_Options").Value;
}
catch (Exception)
{
    X_Content_Type_Options = "";
}
if (X_Content_Type_Options == "1")
{
    app.Use(async (context, next) =>
    {
        context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
        await next();
    });
}
//Content - Security - Policy
//CSP è una raccolta di policy o direttive che un browser applica su una pagina Web quando le richiede.
//Durante il processo di caricamento di una pagina, questo livello di sicurezza aiuta a impedire agli aggressori di sfruttare vulnerabilità come scripting cross-site e attacchi injection fornendo una lista consentita di risorse attendibili.
string Content_Security_Policy = "";
try
{
    X_Content_Type_Options = Configuration.GetRequiredSection("ApplicationContext:Content_Security_Policy").Value;
}
catch (Exception)
{
    Content_Security_Policy = "";
}
if (Content_Security_Policy == "1")
{
    app.Use(async (context, next) =>
    {
        context.Response.Headers.Add("Content-Security-Policy-Report-Only", "default-src 'self'; script-src 'self'; style-src 'self'; font-src 'self'; img-src 'self'; frame-src 'self'");

        await next();
    });
}
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
