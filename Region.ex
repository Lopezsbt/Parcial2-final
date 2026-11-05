defmodule Parcial2.Problema2.Region do
  defstruct [:id, :simbolo, :celdas, :area, :perimetro, :desde, :hasta]

  def crear(id, simbolo, celdas, perimetro) do
    case celdas do
      [] ->
        {:error, "una región debe contener al menos una celda"}

      [{fila, columna} | resto] ->
        {fila_min, columna_min, fila_max, columna_max} =
          recorrer_celdas(resto, fila, columna, fila, columna)

        {:ok,
         %__MODULE__{
           id: id,
           simbolo: simbolo,
           celdas: celdas,
           area: contar(celdas, 0),
           perimetro: perimetro,
           desde: {fila_min, columna_min},
           hasta: {fila_max, columna_max}
         }}
    end
  end

  def a_csv(region) do
    {fila_min, columna_min} = region.desde
    {fila_max, columna_max} = region.hasta

    "#{region.id};#{region.simbolo};#{region.area};#{region.perimetro};" <>
      "{#{fila_min},#{columna_min}};{#{fila_max},#{columna_max}}"
  end

  defp contar([], total), do: total
  defp contar([_celda | resto], total), do: contar(resto, total + 1)

  defp recorrer_celdas([], fila_min, col_min, fila_max, col_max) do
    {fila_min, col_min, fila_max, col_max}
  end

  defp recorrer_celdas([{fila, columna} | resto], fila_min, col_min, fila_max, col_max) do
    recorrer_celdas(
      resto,
      min(fila_min, fila),
      min(col_min, columna),
      max(fila_max, fila),
      max(col_max, columna)
    )
  end
end
