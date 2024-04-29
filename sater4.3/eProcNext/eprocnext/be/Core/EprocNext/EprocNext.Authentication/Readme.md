# Core.Authentication

This project implements Authentication logic used in eProcurement Next platform.
The project have the following dependency: 
1. `Core.Repositories`: used to retrieve information from user table;
2. `Core.DistributedCache`: used to caching information about the logged user;

## Source tree structure
1. `Auth`: contains all implementations for the authentication workflow;
2. `DTO`: contains all DTO used inside the authentication process;
3. `Interfaces`: contains all interfaces used inside project;
10. `Types`: contains types used inside project for generic operations;

## Authentication configuration

Actually the Auth module load its configuration with the following logic:

* `appsetting.json` must contains the following sections:
  ``` js
  "ConnectionStrings": {
    // ...
    "Repository": "YOUR_SQL_SERVICE_CONNECTION_STRING",
    "Redis": "YOUR_REDIS_CONNECTION_STRING"
  },
  "JwtGenerationSettings": {
    "JwtBearer": {
      "ValidAudience": "YourAudienceString",
      "ValidIssuer": "YourIssuerString"
    },
    "JwtTokenDuration": 20,
    "RefreshTokenDuration": 40,
    "BypassRefreshTokenExpiration": false
  },
  ```
* `JwtTokenDuration` and `RefreshTokenDuration` are in minutes;
* RefreshTokenDuration must be greater than JwtTokenDuration (if not, the auth module take set RefreshTokenDuration to JwtTokenDuration + 5);

## Register at Starup.cs

For registring Authentication service on your web API application, just use the extension method on startup.cs:
``` csharp
// ...
using Core.Authentication;
using Core.Authentication.Auth;

public IConfiguration Configuration { get; }

public void ConfigureServices(IServiceCollection services)
{
    // ...

    // Add all services to perform Login
    services.AddAuthServices<BaseUserClaimsIdentityProvider>(configuration);

    // Add Jwt Bearer configuration for Authorization middleware
    services.AddJwtBearer(configuration);

    // ...
}

public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
    // ...
    
    // Remember to enable dotnet core middleware for authentication
    app.UseAuthentication();
}
```

Remember that actually the project use Microsoft StackExchange package to connect to Azure Redis cache
service. Docker container for Redis cache is not actually supported. 