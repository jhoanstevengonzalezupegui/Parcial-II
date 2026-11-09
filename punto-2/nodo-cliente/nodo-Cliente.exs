defmodule NodoCliente do
  # Nombre y dirección completa (nombre + nodo) del proceso que recibe las respuestas.
  @nombre_servicio_local :servicio_respuesta
  @nodo_local :nodocliente@localhost
  @servicio_local {@nombre_servicio_local, @nodo_local}
  # Nodo servidor y su proceso registrado.
  @nodo_remoto :nodoservidor@localhost
  @servicio_remoto {:servicio_sismos, @nodo_remoto}
  # Solicitudes, en el orden pedido por el enunciado.
  @mensajes [
    # 1. ciudad con movimientos
    {:reporte_ciudad, "C01"},
    # 2. ciudad sin movimientos
    {:reporte_ciudad, "C03"},
    # 3. ciudad inexistente
    {:reporte_ciudad, "C99"},
    # 4. reporte general
    :reporte_general,
    # 5. fin
    :fin
  ]

  def main() do
    Util.mostrar_mensaje("NODO CLIENTE")

    @nombre_servicio_local
    |> registrar_servicio()

    establecer_conexion(@nodo_remoto)
    |> iniciar_produccion()
  end

  defp registrar_servicio(nombre_servicio_local),
    do: Process.register(self(), nombre_servicio_local)

  # Node.connect devuelve true, false o :ignored.
  defp establecer_conexion(nodo_remoto), do: Node.connect(nodo_remoto)

  defp iniciar_produccion(true) do
    enviar_mensajes()
    recibir_respuestas()
  end

  # Cualquier otro valor (false o :ignored) = no hay conexión: informa y termina.
  defp iniciar_produccion(_),
    do: IO.puts(:stderr, "Error: no se pudo conectar con el nodo servidor")

  defp enviar_mensajes(), do: Enum.each(@mensajes, &enviar_mensaje/1)

  # Forma exigida: {destino_respuesta, solicitud}
  defp enviar_mensaje(mensaje), do: send(@servicio_remoto, {@servicio_local, mensaje})

  # Recursión: recibe e imprime hasta que llegue :fin.
  defp recibir_respuestas() do
    receive do
      :fin ->
        Util.mostrar_mensaje("--- Fin de las respuestas ---")

      respuesta ->
        Util.mostrar_mensaje(respuesta)
        recibir_respuestas()
    end
  end
end

NodoCliente.main()
