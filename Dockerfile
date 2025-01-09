FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 5001
EXPOSE 5002


FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
ENV ASPNETCORE_URLS=http://+:5001

WORKDIR /src
COPY ["FintechAPI/FintechAPI.csproj", "FintechAPI/"]
RUN dotnet restore "FintechAPI/FintechAPI.csproj"
COPY . .
WORKDIR "/src/FintechAPI"
RUN dotnet build "FintechAPI.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "FintechAPI.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "FintechAPI.dll"]
