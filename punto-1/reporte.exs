defmodule Sismos.Reporte do
  @moduledoc """
  Construccion del texto del reporte. Recibe los datos ya leidos y no toca archivos.
  """

  alias Sismos.Estadisticas

  @linea String.duplicate("=", 62)
  @separador String.duplicate("-", 62)

  @doc "Reporte de todas las ciudades validas, con los rechazados por archivo."
  def general(%{ciudades: ciudades, movimientos: movimientos}) do
    ids = MapSet.new(ciudades.registros, & &1.id)

    {con_ciudad, sin_ciudad} =
      Enum.split_with(movimientos.registros, &MapSet.member?(ids, &1.id_ciudad))

    por_ciudad = Enum.group_by(con_ciudad, & &1.id_ciudad)
    rechazados_movimientos = movimientos.rechazados + length(sin_ciudad)

    bloques =
      Enum.map(ciudades.registros, fn ciudad ->
        bloque_ciudad(ciudad, Map.get(por_ciudad, ciudad.id, []))
      end)

    [
      "REPORTE DE SISMOS POR CIUDAD",
      @linea,
      Enum.join(bloques, "\n#{@separador}\n"),
      @linea,
      "Registros rechazados",
      "  ciudades.txt: #{ciudades.rechazados}",
      "  movimientos.txt: #{rechazados_movimientos}"
    ]
    |> Enum.join("\n")
  end

  @doc "Reporte de una sola ciudad a partir de su identificador."
  def de_ciudad(%{ciudades: ciudades, movimientos: movimientos}, id) do
    case Enum.find(ciudades.registros, &(&1.id == id)) do
      nil -> "La ciudad no está registrada"
      ciudad -> bloque_ciudad(ciudad, Enum.filter(movimientos.registros, &(&1.id_ciudad == id)))
    end
  end

  def bloque_ciudad(ciudad, movimientos) do
    resumen = Estadisticas.resumir(movimientos)

    detalle =
      case movimientos do
        [] -> ["Sin movimientos registrados"]
        _ -> ["Movimientos:" | Enum.map(movimientos, &linea_movimiento/1)]
      end

    (["Ciudad: #{ciudad.nombre}", "Habitantes: #{ciudad.habitantes}"] ++
       detalle ++
       [
         "Total de movimientos: #{resumen.cantidad}",
         "Movimiento de mayor magnitud: #{texto_mayor(resumen.mayor)}",
         "Profundidad promedio: #{texto_promedio(resumen.promedio)}"
       ])
    |> Enum.join("\n")
  end

  defp linea_movimiento(m) do
    "  - #{m.codigo} | Inicio: #{Time.to_string(m.hora_inicio)} | Final: #{Time.to_string(m.hora_final)}" <>
      " | Magnitud: #{m.magnitud} | Profundidad: #{m.profundidad} km"
  end

  defp texto_mayor(nil), do: "No aplica"
  defp texto_mayor(m), do: "#{m.codigo} - #{m.magnitud}"

  defp texto_promedio(nil), do: "No aplica"
  defp texto_promedio(p), do: "#{:erlang.float_to_binary(p, decimals: 2)} km"
end
