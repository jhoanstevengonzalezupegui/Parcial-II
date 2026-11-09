defmodule Ciudad do
  defstruct [:id, :nombre, :habitantes]
end

defmodule Movimiento do
  defstruct [:codigo, :id_ciudad, :hora_inicio, :hora_final, :magnitud, :profundidad]
end
