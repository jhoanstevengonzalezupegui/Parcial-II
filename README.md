# Parcial 2 - Programación 3 (Elixir)

Observatorio Sismológico de la Universidad del Quindío. El proyecto tiene dos partes: un reporte local de sismos por ciudad (punto 1) y una consulta de esos reportes entre dos nodos de Elixir (punto 2, a cargo del compañero).

## Requisitos

- Elixir 1.12 o superior (incluye Erlang/OTP).
- Una terminal. En Windows, si las tildes salen mal en consola, ejecutar antes `chcp 65001`.

## Estructura

```
parcial-2-elixir/
├── README.md
├── punto-1/
│   ├── main.exs
│   ├── ciudad.exs, movimiento.exs, lector.exs
│   ├── estadisticas.exs, reporte.exs, coordinador.exs
│   └── resources/
│       ├── ciudades.txt
│       └── movimientos.txt
└── punto-2/
    ├── nodo-cliente/
    └── nodo-servidor/
        └── resources/
```

## Cómo funciona

- `ciudad.exs` y `movimiento.exs` definen los structs y validan cada línea.
- `lector.exs` lee un archivo, ignora líneas vacías y cuenta las líneas rechazadas.
- `estadisticas.exs` calcula, en un solo recorrido recursivo, la cantidad de movimientos, el de mayor magnitud y la suma de profundidades.
- `reporte.exs` arma el texto del reporte.
- `coordinador.exs` inicia dos tareas (`Task.async`), una por archivo, y espera ambos resultados con `Task.await`.
- Los archivos de entrada no tienen encabezado y los campos van separados por `@`. Las ciudades usan tres campos: `idCiudad@nombre@numeroHabitantes`.

## Punto 1 - Reporte local

Desde la carpeta `punto-1`:

```
elixir main.exs
```

- Archivos de entrada: `punto-1/resources/ciudades.txt` y `punto-1/resources/movimientos.txt`.
- El reporte se muestra en consola y se guarda en `punto-1/resources/reporte_sismos.txt`. Cada ejecución exitosa reemplaza el contenido anterior.
- Si un archivo de entrada no se puede leer, se indica cuál falló y se conserva el reporte anterior.

## Punto 2 - Consulta entre nodos

Pendiente. Las carpetas `punto-2/nodo-cliente` y `punto-2/nodo-servidor` están listas para agregar el código, los datos y las instrucciones de ejecución.
