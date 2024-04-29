using eProcurementNext.Services;

IHost host = Host.CreateDefaultBuilder(args)
    .UseWindowsService(options =>
    {
        options.ServiceName = "CtlServices";
    })
    .ConfigureServices(services =>
    {
        services.AddHostedService<ServicesWorker>();
    })
    .Build();

await host.RunAsync();
