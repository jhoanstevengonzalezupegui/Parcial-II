defmodule Sismos.Estadisticas do
  @moduledoc """
  Calculos por ciudad. Un solo recorrido recursivo obtiene la cantidad de
  movimientos, el de mayor magnitud y la suma de profundidades.
  """

  def resumir(movimientos), do: recorrer(movimientos, 0, nil, 0.0)

  defp recorrer([], cantidad, mayor, suma) do
    promedio = if cantidad == 0, do: nil, else: suma / cantidad
    %{cantidad: cantidad, mayor: mayor, promedio: promedio}
  end

  defp recorrer([movimiento | resto], cantidad, nil, suma) do
    recorrer(resto, cantidad + 1, movimiento, suma + movimiento.profundidad)
  end

  defp recorrer([movimiento | resto], cantidad, mayor, suma) do
    # Con > estricto se conserva el primero del archivo si hay empate.
    nuevo_mayor = if movimiento.magnitud > mayor.magnitud, do: movimiento, else: mayor
    recorrer(resto, cantidad + 1, nuevo_mayor, suma + movimiento.profundidad)
  end
end
