defmodule Sismos.Movimiento do
  @moduledoc """
  Movimiento sismico. Se construye a partir de una linea de movimientos.txt con el
  formato codigo@idCiudad@horaInicio@horaFinal@magnitud@profundidad.
  """

  defstruct [:codigo, :id_ciudad, :hora_inicio, :hora_final, :magnitud, :profundidad]

  @doc "Devuelve {:ok, %Movimiento{}} o :error si la linea no es valida."
  def desde_linea(linea) do
    with [codigo, id_ciudad, inicio, final, magnitud, profundidad] <-
           linea |> String.split("@") |> Enum.map(&String.trim/1),
         true <- codigo != "" and id_ciudad != "",
         {:ok, hora_inicio} <- parsear_hora(inicio),
         {:ok, hora_final} <- parsear_hora(final),
         {:ok, magnitud} <- parsear_decimal(magnitud),
         {:ok, profundidad} <- parsear_decimal(profundidad),
         true <- profundidad >= 0 do
      {:ok,
       %__MODULE__{
         codigo: codigo,
         id_ciudad: id_ciudad,
         hora_inicio: hora_inicio,
         hora_final: hora_final,
         magnitud: magnitud,
         profundidad: profundidad
       }}
    else
      _ -> :error
    end
  end

  # Acepta solo HH:MM:SS con dos digitos por parte y valores dentro del dia.
  defp parsear_hora(texto) do
    case String.split(texto, ":") do
      [h, m, s] ->
        if Enum.all?([h, m, s], &dos_digitos?/1), do: Time.from_iso8601(texto), else: :error

      _ ->
        :error
    end
  end

  defp dos_digitos?(parte) do
    byte_size(parte) == 2 and parte |> String.to_charlist() |> Enum.all?(&(&1 in ?0..?9))
  end

  defp parsear_decimal(texto) do
    case Float.parse(texto) do
      {numero, ""} -> {:ok, numero}
      _ -> :error
    end
  end
end
