# Use the ASP.NET 6.0 runtime as the base image for running the application
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Use the .NET 6.0 SDK as the base image for building the application
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

# Copy only the project file and restore dependencies to leverage Docker cache
COPY ["WebApplication222/WebApplication222.csproj", "WebApplication222/"]
RUN dotnet restore "WebApplication222/WebApplication222.csproj"

# Copy the entire application and build
COPY . .
WORKDIR "/src/WebApplication222"
RUN dotnet build "WebApplication222.csproj" -c Release -o /app/build

# Use the build image to publish the application
FROM build AS publish
RUN dotnet publish "WebApplication222.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Use the ASP.NET 6.0 runtime as the final base image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Specify the entry point for the container
ENTRYPOINT ["dotnet", "WebApplication222.dll"]
