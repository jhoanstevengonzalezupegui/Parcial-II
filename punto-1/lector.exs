defmodule Sismos.Lector do
  @moduledoc """
  Lectura de los archivos de entrada. Cada funcion devuelve
  {:ok, %{registros: lista, rechazados: n}} o {:error, razon}.
  """

  alias Sismos.{Ciudad, Movimiento}

  def leer_ciudades(ruta), do: leer(ruta, &Ciudad.desde_linea/1)

  def leer_movimientos(ruta), do: leer(ruta, &Movimiento.desde_linea/1)

  defp leer(ruta, parser) do
    case File.read(ruta) do
      {:ok, contenido} -> {:ok, procesar(contenido, parser)}
      {:error, razon} -> {:error, razon}
    end
  end

  defp procesar(contenido, parser) do
    resultados =
      contenido
      |> String.split(["\r\n", "\n"])
      |> Enum.reject(&(String.trim(&1) == ""))
      |> Enum.map(&parsear(parser, &1))

    validos = for {:ok, registro} <- resultados, do: registro

    %{registros: validos, rechazados: length(resultados) - length(validos)}
  end

  # Una linea que haga fallar el parser se cuenta como rechazada.
  defp parsear(parser, linea) do
    parser.(linea)
  rescue
    _ -> :error
  end
end
