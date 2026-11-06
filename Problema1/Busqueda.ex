defmodule Busqueda do
  @moduledoc """
  Grafo dirigido, búsqueda recursiva de itinerarios simples y criterios óptimos.
  """

  @doc """
  Arma el grafo DESPUÉS de consumir la etapa perezosa: un mapa
  `origen => [tramos que salen de ese origen]`, en el orden del archivo.
  """
  def construir_grafo(tramos) do
    Enum.group_by(tramos, fn t -> t.origen end)
  end

  @doc "Conjunto de todos los centros que aparecen (como origen o destino)."
  def centros(tramos) do
    Enum.reduce(tramos, MapSet.new(), fn t, acc ->
      acc |> MapSet.put(t.origen) |> MapSet.put(t.destino)
    end)
  end

  @doc """
  Todos los itinerarios simples de `origen` a `destino`, como lista de
  `%Itinerario{}` en el orden en que la recursión los encuentra.
  """
  def itinerarios(grafo, origen, destino) do
    grafo
    |> explorar(origen, destino, MapSet.new([origen]), [origen], 0, 0, [])
    |> Enum.reverse()
  end

  # Caso base: se llegó al destino -> se registra el itinerario.
  defp explorar(_grafo, destino, destino, _visitados, camino, minutos, costo, acc) do
    it = %Itinerario{centros: Enum.reverse(camino), minutos: minutos, costo: costo}
    [it | acc]
  end

  # Caso recursivo: probar cada tramo que sale del centro actual, sin repetir centros.
  defp explorar(grafo, actual, destino, visitados, camino, minutos, costo, acc) do
    grafo
    |> Map.get(actual, [])
    |> Enum.reduce(acc, fn tramo, acc_interno ->
      if MapSet.member?(visitados, tramo.destino) do
        acc_interno
      else
        explorar(
          grafo,
          tramo.destino,
          destino,
          MapSet.put(visitados, tramo.destino),
          [tramo.destino | camino],
          minutos + tramo.minutos,
          costo + tramo.costo,
          acc_interno
        )
      end
    end)
  end

  @doc """
  Para una lista NO vacía de itinerarios devuelve los números (desde 1) de los
  que minimizan cada criterio, conservando todos los empates:
  `%{tramos: [..], tiempo: [..], costo: [..]}`.
  """
  def optimos(itinerarios) do
    numerados = Enum.with_index(itinerarios, 1)

    %{
      tramos: minimos(numerados, &Itinerario.num_tramos/1),
      tiempo: minimos(numerados, fn it -> it.minutos end),
      costo: minimos(numerados, fn it -> it.costo end)
    }
  end

  defp minimos(numerados, criterio) do
    menor = numerados |> Enum.map(fn {it, _n} -> criterio.(it) end) |> Enum.min()

    for {it, n} <- numerados, criterio.(it) == menor, do: n
  end

  @doc "Una línea de itinerario, con el formato del enunciado."
  def formatear(%Itinerario{} = it, numero) do
    ruta = Enum.join(it.centros, " → ")

    "Itinerario #{numero}: #{ruta} | tramos: #{Itinerario.num_tramos(it)} | " <>
      "#{it.minutos} min | costo: #{it.costo}"
  end

  @doc """
  Escribe en `dispositivo` el bloque de una consulta, línea por línea
  (sin armar un único string con todo el resultado).
  """
  def escribir_bloque(dispositivo, origen, destino, itinerarios) do
    IO.puts(dispositivo, "=== #{origen} → #{destino} ===")

    itinerarios
    |> Enum.with_index(1)
    |> Enum.each(fn {it, n} -> IO.puts(dispositivo, formatear(it, n)) end)

    opt = optimos(itinerarios)
    IO.puts(dispositivo, "Total: #{length(itinerarios)} itinerarios")
    IO.puts(dispositivo, "Menos tramos: #{Enum.join(opt.tramos, ", ")}")
    IO.puts(dispositivo, "Menor tiempo: #{Enum.join(opt.tiempo, ", ")}")
    IO.puts(dispositivo, "Menor costo: #{Enum.join(opt.costo, ", ")}")
  end

  @doc "Bloque de una consulta que no se puede resolver (centro inexistente o sin ruta)."
  def escribir_mensaje(dispositivo, origen, destino, mensaje) do
    IO.puts(dispositivo, "=== #{origen} → #{destino} ===")
    IO.puts(dispositivo, mensaje)
  end
end
