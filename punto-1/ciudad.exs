defmodule Sismos.Ciudad do
  @moduledoc """
  Ciudad del catalogo. Se construye a partir de una linea de ciudades.txt
  con el formato idCiudad@nombre@numeroHabitantes.
  """

  defstruct [:id, :nombre, :habitantes]

  @doc "Devuelve {:ok, %Ciudad{}} o :error si la linea no es valida."
  def desde_linea(linea) do
    with [id, nombre, habitantes] <- linea |> String.split("@") |> Enum.map(&String.trim/1),
         true <- id != "" and nombre != "",
         true <- digitos?(habitantes),
         n when n > 0 <- String.to_integer(habitantes) do
      {:ok, %__MODULE__{id: id, nombre: nombre, habitantes: n}}
    else
      _ -> :error
    end
  end

  defp digitos?(""), do: false
  defp digitos?(texto), do: texto |> String.to_charlist() |> Enum.all?(&(&1 in ?0..?9))
end
