# ROBOREAN
>strong and sturdy; like an oak tree.

A simple word scoring application.


What you need:
- Docker Compose.
- Buildx (plugin).
- A [Merriam Webster](https://dictionaryapi.com/) API key (free!).
- An open port 3000.

How to run the application:
- clone the repository.
- Insert your API key (MW_API_KEY=\[YOUR KEY]) and a db password into a .env in the root directory similar to .env.example.
- run:
```bash
cd roborean
docker compose up --build
```
- Enjoy a coffee while it spins up.

# CURRENT ARCHITECTURE
![Roborean Architecture](roborean-architecture.excalidraw.svg)
>Plans to deprecate local frequency corpus in favor of cached frequency scores from soon-to-be-added Datamuse API.




