defmodule Sismos.Coordinador do
  @moduledoc """
  Coordina la lectura concurrente de los dos archivos con Task.
  """

  alias Sismos.Lector

  @doc """
  Lanza un Task por archivo y espera ambos resultados. Cada Task responde con
  el nombre del archivo, asi el orden de llegada no importa.

  Devuelve {:ok, %{ciudades: ..., movimientos: ...}} o {:error, [{archivo, motivo}]}.
  """
  def obtener_datos(directorio) do
    ruta_ciudades = Path.join(directorio, "ciudades.txt")
    ruta_movimientos = Path.join(directorio, "movimientos.txt")

    # Se inician los dos antes de esperar cualquier respuesta.
    tareas = [
      Task.async(fn -> {:ciudades, Lector.leer_ciudades(ruta_ciudades)} end),
      Task.async(fn -> {:movimientos, Lector.leer_movimientos(ruta_movimientos)} end)
    ]

    tareas
    |> Enum.map(&Task.await(&1, 30_000))
    |> combinar()
  end

  defp combinar(resultados) do
    errores =
      for {archivo, {:error, razon}} <- resultados do
        {nombre_archivo(archivo), razon |> :file.format_error() |> to_string()}
      end

    case errores do
      [] -> {:ok, Map.new(resultados, fn {archivo, {:ok, datos}} -> {archivo, datos} end)}
      _ -> {:error, errores}
    end
  end

  defp nombre_archivo(:ciudades), do: "ciudades.txt"
  defp nombre_archivo(:movimientos), do: "movimientos.txt"
end
