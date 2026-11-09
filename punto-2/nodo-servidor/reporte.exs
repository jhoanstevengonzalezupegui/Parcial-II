# Responsabilidad: calcular estadísticas y dar formato al texto del reporte.
defmodule Reporte do
  # Reporte de UNA ciudad.
  def ciudad(%Ciudad{} = c, movimientos) do
    # movimientos de esta ciudad, en el mismo orden del archivo
    propios = Enum.filter(movimientos, fn m -> m.id_ciudad == c.id end)
    # un solo recorrido recursivo calcula cantidad, mayor y suma
    {total, mayor, suma} = recorrer(propios, 0, nil, 0.0)

    "=== #{c.nombre} ===\n" <>
      "Habitantes: #{c.habitantes}\n" <>
      detalle(propios, total, mayor, suma)
  end

  # Reporte GENERAL: todas las ciudades válidas + rechazados por archivo.
  def general(ciudades, movimientos, rechazados_c, rechazados_m) do
    cuerpo = Enum.map_join(ciudades, "\n", fn c -> ciudad(c, movimientos) end)

    "REPORTE DE SISMOS POR CIUDAD\n\n" <>
      cuerpo <>
      "\nRegistros rechazados:\n" <>
      "  ciudades.txt: #{rechazados_c}\n" <>
      "  movimientos.txt: #{rechazados_m}\n"
  end

  # Caso base de formato: ciudad sin movimientos.
  defp detalle([], _total, _mayor, _suma) do
    "Sin movimientos registrados\n" <>
      "Total de movimientos: 0\n" <>
      "Mayor magnitud: No aplica\n" <>
      "Profundidad promedio: No aplica\n"
  end

  # Ciudad con movimientos.
  defp detalle(propios, total, mayor, suma) do
    lineas = Enum.map_join(propios, "\n", &linea_movimiento/1)
    # promedio = suma / cantidad, con dos decimales
    promedio = :erlang.float_to_binary(suma / total, decimals: 2)

    "Movimientos:\n#{lineas}\n" <>
      "Total de movimientos: #{total}\n" <>
      "Mayor magnitud: #{mayor.codigo} · #{mayor.magnitud}\n" <>
      "Profundidad promedio: #{promedio} km\n"
  end

  # Una línea de detalle por movimiento.
  defp linea_movimiento(m) do
    "  - #{m.codigo} | inicio #{Time.to_string(m.hora_inicio)} | final #{Time.to_string(m.hora_final)}" <>
      " | magnitud #{m.magnitud} | profundidad #{m.profundidad} km"
  end

  # RECURSIVIDAD EXPLÍCITA. Caso base: lista vacía -> devuelve los acumuladores.
  defp recorrer([], total, mayor, suma), do: {total, mayor, suma}

  # Caso recursivo: procesa la cabeza m y sigue con la cola.
  defp recorrer([m | resto], total, mayor, suma) do
    # '>' estricto: si hay empate se conserva el primero que apareció en el archivo
    nuevo_mayor = if mayor == nil or m.magnitud > mayor.magnitud, do: m, else: mayor
    recorrer(resto, total + 1, nuevo_mayor, suma + m.profundidad)
  end
end
