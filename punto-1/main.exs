# Punto 1: reporte local de sismos por ciudad.
# Uso (desde esta carpeta): elixir main.exs

for archivo <- ~w(ciudad movimiento lector estadisticas reporte coordinador) do
  Code.require_file("#{archivo}.exs", __DIR__)
end

defmodule Sismos.Consola do
  alias Sismos.{Coordinador, Reporte}

  @directorio Path.join(__DIR__, "resources")
  @salida Path.join(@directorio, "reporte_sismos.txt")

  def ejecutar do
    case Coordinador.obtener_datos(@directorio) do
      {:ok, datos} ->
        texto = Reporte.general(datos)
        IO.puts(texto)
        guardar(texto)

      {:error, errores} ->
        Enum.each(errores, fn {archivo, motivo} ->
          IO.puts("Error al leer #{archivo}: #{motivo}")
        end)

        IO.puts("No se generó el reporte; se conserva el anterior.")
    end
  end

  defp guardar(texto) do
    case File.write(@salida, texto <> "\n") do
      :ok ->
        IO.puts("\nReporte guardado en resources/reporte_sismos.txt")

      {:error, razon} ->
        IO.puts("\nError al guardar el reporte: #{razon |> :file.format_error() |> to_string()}")
    end
  end
end

Sismos.Consola.ejecutar()
