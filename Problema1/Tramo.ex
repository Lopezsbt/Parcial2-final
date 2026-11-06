defmodule Tramo do
  @moduledoc """
  Tramo de transporte dirigido entre dos centros.

  `linea` y `contenido` guardan la línea física original del archivo para
  poder reportar errores y descartes (los asigna la etapa de lectura).
  """
  defstruct [:origen, :destino, :minutos, :costo, :linea, :contenido]

  @doc """
  Convierte una línea `origen,destino,minutos,costo` en un `%Tramo{}`.
  Devuelve `{:ok, tramo}` o `{:error, motivo}`.
  """
  def parse(texto) when is_binary(texto) do
    case texto |> String.split(",") |> Enum.map(&String.trim/1) do
      [origen, destino, minutos, costo] ->
        with :ok <- validar_centro(origen, "origen"),
             :ok <- validar_centro(destino, "destino"),
             {:ok, m} <- entero_positivo(minutos, "minutos"),
             {:ok, c} <- entero_positivo(costo, "costo") do
          {:ok, %Tramo{origen: origen, destino: destino, minutos: m, costo: c}}
        end

      campos ->
        {:error, "se esperaban 4 campos y hay #{length(campos)}"}
    end
  end

  defp validar_centro("", campo), do: {:error, "#{campo} vacío"}
  defp validar_centro(_, _), do: :ok

  defp entero_positivo(texto, campo) do
    case Integer.parse(texto) do
      {n, ""} when n > 0 -> {:ok, n}
      {_, ""} -> {:error, "#{campo} debe ser un entero positivo"}
      _ -> {:error, "#{campo} no es un entero: #{inspect(texto)}"}
    end
  end
end
