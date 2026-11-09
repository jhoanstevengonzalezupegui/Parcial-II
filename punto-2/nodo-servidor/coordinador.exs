# Responsabilidad: lanzar los dos trabajadores y recoger sus resultados.
defmodule Coordinador do
  def cargar(ruta_ciudades, ruta_movimientos) do
    # referencia única: evita confundir estos mensajes con las solicitudes de los clientes
    ref = make_ref()
    # pid del proceso coordinador (el que recibirá las respuestas)
    yo = self()

    # trabajador 1: lee ciudades y envía el resultado identificando el archivo
    spawn(fn -> send(yo, {:resultado, ref, :ciudades, Lector.leer_ciudades(ruta_ciudades)}) end)
    # trabajador 2: lee movimientos (ambos ya están corriendo antes de esperar)
    spawn(fn -> send(yo, {:resultado, ref, :movimientos, Lector.leer_movimientos(ruta_movimientos)}) end)

    # espera las dos respuestas, en cualquier orden
    esperar(ref, %{}) |> combinar()
  end

  # Caso base: ya llegaron los dos resultados.
  defp esperar(_ref, resultados) when map_size(resultados) == 2, do: resultados

  # Caso recursivo: recibe un resultado (^ref = solo mensajes de ESTA carga) y vuelve a esperar.
  defp esperar(ref, resultados) do
    receive do
      {:resultado, ^ref, archivo, resultado} ->
        esperar(ref, Map.put(resultados, archivo, resultado))
    end
  end

  # Ambos archivos leídos bien: descarta movimientos con ciudad inexistente.
  defp combinar(%{ciudades: {:ok, ciudades, rech_c}, movimientos: {:ok, movs, rech_m}}) do
    ids = MapSet.new(ciudades, fn c -> c.id end)
    {validos, huerfanos} = Enum.split_with(movs, fn m -> MapSet.member?(ids, m.id_ciudad) end)

    {:ok,
     %{
       ciudades: ciudades,
       movimientos: validos,
       rechazados_ciudades: rech_c,
       # los movimientos con ciudad inexistente cuentan como rechazados de movimientos.txt
       rechazados_movimientos: rech_m + length(huerfanos)
     }}
  end

  # Alguno falló: devuelve cuál(es) archivo(s) y el motivo.
  defp combinar(resultados) do
    {:error, for({archivo, {:error, razon}} <- resultados, do: {archivo, razon})}
  end
end
