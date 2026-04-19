# De bovenste regels zijn comments van de originele makers met tips hoe je dit lokaal kunt runnen.
# RUN ALL CONTAINERS FROM ROOT (folder with .sln file):
# docker-compose build
# docker-compose up
#
# RUN JUST THIS CONTAINER FROM ROOT (folder with .sln file):
# docker build --pull -t web -f src/Web/Dockerfile .
#
# RUN COMMAND
#  docker run --name eshopweb --rm -it -p 5106:5106 web

# --- FASE 1: DE BUILD FASE ---
# Gebruik een zware image van Microsoft waar de hele .NET SDK in zit om de code te kunnen compileren. We noemen deze fase 'build'.
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

# Stel de werkmap binnen de container in op '/app'
WORKDIR /app

# Kopieer alle solution bestanden (*.sln) van onze computer/repository naar de '/app' map in de container
COPY *.sln .

# Kopieer daarna alle andere bestanden en mappen naar de container
COPY . .

# Verander de werkmap specifiek naar de map waar het webproject staat
WORKDIR /app/src/Web

# Download alle benodigde externe bibliotheken (NuGet packages) die het project nodig heeft
RUN dotnet restore

# Compileer (bouw) de applicatie in de 'Release' (geoptimaliseerde) modus en zet de kant-en-klare bestanden in een map genaamd 'out'
RUN dotnet publish -c Release -o out


# --- FASE 2: DE RUNTIME FASE ---
# Start met een schone, veel lichtere image die alleen nodig is om de app te draaien (geen compilers, alleen de runtime). We noemen dit 'runtime'.
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime

# Stel de werkmap in de nieuwe lichte container weer in op '/app'
WORKDIR /app

# Haal de gecompileerde bestanden uit de zware 'build' container (Fase 1) en plak ze in deze lichte container.
# Hierdoor wordt onze uiteindelijke Docker image veel kleiner en sneller!
COPY --from=build /app/src/Web/out ./

# Optionele comment uit de originele repo: je zou hier de environment kunnen hardcoden, maar wij doen dit al via docker-compose.yml
# ENV ASPNETCORE_ENVIRONMENT Development

# Het standaard commando dat wordt uitgevoerd zodra deze container wordt opgestart.
# Het start onze gecompileerde .NET applicatie genaamd 'Web.dll'.
ENTRYPOINT ["dotnet", "Web.dll"]