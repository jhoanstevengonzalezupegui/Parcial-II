# Responsabilidad: leer un archivo, validar cada línea y devolver structs.
defmodule Lector do

  # Lee ciudades.txt usando el parser de ciudades.
  def leer_ciudades(ruta), do: leer(ruta, &parsear_ciudad/1)

  # Lee movimientos.txt usando el parser de movimientos.
  def leer_movimientos(ruta), do: leer(ruta, &parsear_movimiento/1)

  # Función común: devuelve {:ok, registros_validos, cantidad_rechazados} o {:error, razon}.
  defp leer(ruta, parser) do
    case File.read(ruta) do
      {:ok, contenido} ->
        lineas =
          contenido
          # separa por saltos de línea (\n o \r\n)
          |> String.split(~r/\R/)
          # las líneas vacías se ignoran (no cuentan como rechazadas)
          |> Enum.reject(fn linea -> String.trim(linea) == "" end)

        # aplica el parser a cada línea: {:ok, struct} o :error
        resultados = Enum.map(lineas, parser)
        # se queda solo con los structs válidos, conservando el orden del archivo
        validos = for {:ok, registro} <- resultados, do: registro
        # cada línea inválida se cuenta una sola vez
        rechazados = Enum.count(resultados, fn r -> r == :error end)
        {:ok, validos, rechazados}

      {:error, razon} ->
        # el archivo no se pudo leer (no existe, sin permisos, etc.)
        {:error, razon}
    end
  end

  # Formato esperado: idCiudad@nombre@numeroHabitantes
  defp parsear_ciudad(linea) do
    campos = linea |> String.split("@") |> Enum.map(&String.trim/1)

    case campos do
      # exactamente 3 campos y los dos textos no vacíos
      [id, nombre, habitantes] when id != "" and nombre != "" ->
        case Integer.parse(habitantes) do
          # el entero debe ser completo (resto "") y mayor que cero
          {n, ""} when n > 0 -> {:ok, %Ciudad{id: id, nombre: nombre, habitantes: n}}
          _ -> :error
        end

      # cantidad de campos distinta o campo obligatorio vacío
      _ ->
        :error
    end
  end

  # Formato esperado: codigo@idCiudad@horaInicio@horaFinal@magnitud@profundidad
  defp parsear_movimiento(linea) do
    campos = linea |> String.split("@") |> Enum.map(&String.trim/1)

    # 'with' encadena validaciones: si una falla, salta al 'else'
    with [codigo, id_ciudad, h_ini, h_fin, mag, prof]
         when codigo != "" and id_ciudad != "" <- campos,
         {:ok, inicio} <- parsear_hora(h_ini),
         {:ok, final} <- parsear_hora(h_fin),
         {magnitud, ""} <- Float.parse(mag),
         {profundidad, ""} <- Float.parse(prof),
         true <- profundidad >= 0 do
      {:ok,
       %Movimiento{
         codigo: codigo,
         id_ciudad: id_ciudad,
         hora_inicio: inicio,
         hora_final: final,
         magnitud: magnitud,
         profundidad: profundidad
       }}
    else
      _ -> :error
    end
  end

  # Valida que sea una hora del día con formato HH:MM:SS.
  defp parsear_hora(texto) do
    if Regex.match?(~r/^\d{2}:\d{2}:\d{2}$/, texto) do
      # Time.from_iso8601 rechaza horas como 25:00:00 o 10:61:00
      Time.from_iso8601(texto)
    else
      :error
    end
  end


end
