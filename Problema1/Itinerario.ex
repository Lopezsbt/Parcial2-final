defmodule Itinerario do
  @moduledoc """
  Itinerario simple entre dos centros: secuencia de centros y totales.
  El número de tramos se deduce: `length(centros) - 1`.
  """
  defstruct centros: [], minutos: 0, costo: 0

  def num_tramos(%Itinerario{centros: centros}), do: length(centros) - 1
end
