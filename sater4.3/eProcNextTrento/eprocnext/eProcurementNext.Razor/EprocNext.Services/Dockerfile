#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["EprocNext.Services/EprocNext.Services.csproj", "EprocNext.Services/"]
RUN dotnet restore "EprocNext.Services/EprocNext.Services.csproj"
COPY . .
WORKDIR "/src/EprocNext.Services"
RUN dotnet build "EprocNext.Services.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "EprocNext.Services.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "EprocNext.Services.dll"]