# Práctica final: Configurador de orbamentos

## Dominio

El dominio está definido en el fichero `domain.pddl`

## Problemas

Los problemas se han definido en ficheros `.json` en el directorio `problems/`. Estos ficheros se pueden compilar a PDDL con:

```bash
python3 make.py problems/<name>.json > problem.pddl`
```

Es necesario utilizar Python 3.12 o superior. El fichero `problems/README.md` explica la estructura que deben tener estos ficheros JSON. Además, todos los problemas compilados a PDDL, junto con los resultados obtenidos por cada planificador, se encuentran en el directorio `build/`

## Estructura de ficheros

- `problems/`: definición de los diferentes problemas.
  - `README.md`: descripción de la estructura de los ficheros de los problemas.
  - `<name>.json`: problemas desarrollados.
- `simplified-domain/`: resultados de la ejecución del problema más grande con un dominio simplificado sin restricciones de elemento en los orbamentos.
- `doman.pddl`: definición del dominio.
- `make.py`: compilación de la definición de los problemas de JSON a PDDL.
- `proces-fd.awk`: script para transformar la salida de Fast Downward a un CSV.
- `run.sh`: script para ejecutar todos los problemas desarrollados con cada uno de los planificadores probados.
- `trails.py`: definición de los orbamentos, elementos, cuarzos, y artes disponibles
