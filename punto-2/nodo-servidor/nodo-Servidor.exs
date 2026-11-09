# Los módulos Ciudad, Movimiento, Lector, Reporte y Coordinador (y Util) están compilados
# como archivos .beam en esta misma carpeta. Se generan una vez con:
#   elixirc modelos.exs lector.exs reporte.exs coordinador.exs

defmodule NodoServidor do
  # Nombre con el que este proceso se registra (el cliente le escribe a este nombre).
  @nombre_servicio_local :servicio_sismos
  # Rutas de los archivos de entrada; se vuelven a leer en CADA consulta.
  @ruta_ciudades Path.join(__DIR__, "resources/ciudades.txt")
  @ruta_movimientos Path.join(__DIR__, "resources/movimientos.txt")

  def main() do
    Util.mostrar_mensaje("NODO SERVIDOR")
    # registra el proceso con el nombre :servicio_sismos
    registrar_servicio(@nombre_servicio_local)
    # queda esperando solicitudes
    procesar_mensajes()
  end

  defp registrar_servicio(nombre_servicio_local),
    do: Process.register(self(), nombre_servicio_local)

  # Bucle principal. Cada mensaje llega como {destino_respuesta, solicitud}.
  defp procesar_mensajes() do
    receive do
      {destino, solicitud} ->
        # calcula la respuesta y se la envía al cliente
        send(destino, procesar_solicitud(solicitud))
    end

    # DIFERENCIA con el ejemplo de clase: aquí SIEMPRE se vuelve a llamar,
    # incluso después de :fin, para poder atender un segundo cliente.
    procesar_mensajes()
  end

  # Una cláusula por tipo de solicitud (pattern matching, como en clase).
  defp procesar_solicitud(:fin), do: :fin

  defp procesar_solicitud({:reporte_ciudad, id_ciudad}) do
    Coordinador.cargar(@ruta_ciudades, @ruta_movimientos)
    |> reporte_ciudad(id_ciudad)
  end

  defp procesar_solicitud(:reporte_general) do
    Coordinador.cargar(@ruta_ciudades, @ruta_movimientos)
    |> reporte_general()
  end

  # Cualquier otra cosa es desconocida.
  defp procesar_solicitud(solicitud),
    do: "La solicitud #{inspect(solicitud)} es desconocida."

  # --- Reporte de una ciudad ---
  # Si la carga salió bien, busca la ciudad por id.
  defp reporte_ciudad({:ok, datos}, id_ciudad) do
    datos.ciudades
    |> Enum.find(fn ciudad -> ciudad.id == id_ciudad end)
    |> armar_reporte_ciudad(datos.movimientos)
  end

  # Si algún archivo falló, se informa cuál (y el servidor sigue vivo).
  defp reporte_ciudad({:error, errores}, _id_ciudad), do: mensaje_error(errores)

  # Enum.find devuelve nil si no existe la ciudad.
  defp armar_reporte_ciudad(nil, _movimientos), do: "La ciudad no está registrada"
  defp armar_reporte_ciudad(ciudad, movimientos), do: Reporte.ciudad(ciudad, movimientos)

  # --- Reporte general ---
  defp reporte_general({:ok, datos}) do
    Reporte.general(
      datos.ciudades,
      datos.movimientos,
      datos.rechazados_ciudades,
      datos.rechazados_movimientos
    )
  end

  defp reporte_general({:error, errores}), do: mensaje_error(errores)

  # Texto que identifica el archivo con error.
  defp mensaje_error(errores) do
    Enum.map_join(errores, "\n", fn {archivo, razon} ->
      "Error al leer #{archivo}.txt: #{:file.format_error(razon)}"
    end)
  end
end

NodoServidor.main()
