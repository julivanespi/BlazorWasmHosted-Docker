# https://hub.docker.com/_/microsoft-dotnet
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /source

# copy csproj and restore as distinct layers
COPY ["BlazorWasmHosted/Server/BlazorWasmHosted.Server.csproj", "BlazorWasmHosted/Server/"]
COPY ["BlazorWasmHosted/Client/BlazorWasmHosted.Client.csproj", "BlazorWasmHosted/Client/"]
COPY ["BlazorWasmHosted/Shared/BlazorWasmHosted.Shared.csproj", "BlazorWasmHosted/Shared/"]
RUN dotnet restore "BlazorWasmHosted/Server/BlazorWasmHosted.Server.csproj"
# copy everything else and build app
COPY . .
WORKDIR "/source/BlazorWasmHosted/Server/"
RUN dotnet build "BlazorWasmHosted.Server.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "BlazorWasmHosted.Server.csproj" -c Release -o /app/publish

# final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORKDIR /app
EXPOSE 80
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "BlazorWasmHosted.Server.dll"]