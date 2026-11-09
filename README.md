# Parcial 2 - Programación 3 (Elixir)

Observatorio Sismológico de la Universidad del Quindío. El proyecto tiene dos partes: un reporte local de sismos por ciudad (punto 1) y una consulta de esos reportes entre dos nodos de Elixir (punto 2).

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
    │   └── nodo-Cliente.exs
    └── nodo-servidor/
        ├── nodo-Servidor.exs
        └── resources/
            ├── ciudades.txt
            └── movimientos.txt
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

Se necesitan dos terminales. Primero se inicia el servidor y después el cliente. Los dos nodos usan la misma cookie, `my_cookie`, que se configura con la opción `--cookie`. Los comandos se ejecutan desde la raíz del repositorio.

Nombres de los nodos: `nodoservidor@localhost` y `nodocliente@localhost`.

Terminal 1 - nodo servidor:

```
cd punto-2\nodo-servidor
elixir --sname nodoservidor@localhost --cookie my_cookie nodo-Servidor.exs
```

Debe aparecer el mensaje `NODO SERVIDOR`. La terminal queda abierta, esperando solicitudes.

Terminal 2 - nodo cliente (después de iniciar el servidor):

```
cd punto-2\nodo-cliente
elixir --sname nodocliente@localhost --cookie my_cookie nodo-Cliente.exs
```

El cliente se conecta al servidor, envía sus consultas y muestra las respuestas en consola hasta recibir `:fin`.

## Verificación del punto 2

Identificadores usados para probar (con los datos de ejemplo):

| Consulta | Identificador | Resultado esperado |
|---|---|---|
| Ciudad con movimientos | `C01` (Armenia) | Detalle de sus movimientos, total 2, mayor S001 con 3.4, promedio 14.00 km |
| Ciudad sin movimientos | `C03` (Circasia) | Sin movimientos registrados, total 0, No aplica |
| Ciudad inexistente | `C99` | La ciudad no está registrada |
| Reporte general | - | Todas las ciudades y registros rechazados por archivo |

Para comprobar que el servidor sigue atendiendo solicitudes, se deja abierta la Terminal 1 y se ejecuta el cliente por segunda vez en la Terminal 2, con el mismo comando:

```
cd punto-2\nodo-cliente
elixir --sname nodocliente@localhost --cookie my_cookie nodo-Cliente.exs
```

Debe mostrar de nuevo las respuestas en el mismo orden y terminar al recibir `:fin`.
