# Docker image copy pasted van de github repo zelf : https://github.com/looking4ward/CloudShirt/blob/main/src/Web/Dockerfile

# --- FASE 1: BUILD FASE ---
# Gebruik de officiële Microsoft Docker image met de volledige .NET 6 SDK.
# Deze image bevat alle tools die nodig zijn om .NET code te compileren (dotnet build/publish).
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

# Stel de huidige map in de container in op '/app'.
# Alle volgende commando's worden standaard vanuit deze map uitgevoerd.
WORKDIR /app

# Kopieer alle .sln-bestanden (solutions) van mijn project naar /app in de container.
# De solution beschrijft welke projecten bij elkaar horen, zodat dotnet alle dependencies kan vinden.
COPY *.sln .

# Kopieer nu de rest van de broncode en projectmappen (zoals src/, tests/, etc.) naar /app.
# Hierdoor heeft de container dezelfde projectstructuur als jouw lokale repository.
COPY . .

# Ga naar de map van het webproject, waar het Web.csproj bestand staat.
# Vanaf hier voer je restore en publish uit voor de webapplicatie.
WORKDIR /app/src/Web

# Haal alle benodigde NuGet packages (externe .NET libraries) op voor dit webproject.
# Zonder deze stap kan de applicatie niet gecompileerd worden.
RUN dotnet restore

# Bouw en publiceer de applicatie in Release modus (geoptimaliseerd voor productie).
# De gecompileerde output wordt in de submap 'out' geplaatst.
RUN dotnet publish -c Release -o out


# --- FASE 2: RUNTIME FASE ---
# Start een nieuwe, lichte Docker image met alleen de ASP.NET Core 6 runtime.
# Deze image mist de SDK en build-tools en is daarom kleiner en geschikter om in productie te draaien.
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime

# Stel opnieuw de werkmap in op '/app' in deze tweede (runtime) container.
WORKDIR /app

# Kopieer de gepubliceerde (gecompileerde) bestanden vanuit de build-fase naar deze runtime-container.
# We nemen alleen de kant-en-klare app mee, niet de volledige broncode of de build-tools.
COPY --from=build /app/src/Web/out ./

# Definieer het standaard commando dat wordt uitgevoerd als de container start.
# Dit start de ASP.NET Core webapplicatie door Web.dll uit te voeren met de .NET runtime.
ENTRYPOINT ["dotnet", "Web.dll"]