defmodule Alcance do
  @moduledoc """
  Stream infinito de conjuntos de centros alcanzables.

  Paso 0: solo el origen. Cada paso siguiente añade los destinos de los
  tramos que salen de los centros ya alcanzados.
  """

  @doc """
  Stream INFINITO de conjuntos (`MapSet`) de centros alcanzables desde `origen`.
  Es perezoso: no calcula nada hasta que alguien lo consume.
  """
  def estados(grafo, origen) do
    Stream.iterate(MapSet.new([origen]), fn alcanzados -> expandir(grafo, alcanzados) end)
  end

  # Un paso: se conservan los centros ya alcanzados y se añaden todos los
  # destinos de los tramos que salen de ellos.
  defp expandir(grafo, alcanzados) do
    Enum.reduce(alcanzados, alcanzados, fn centro, acc ->
      grafo
      |> Map.get(centro, [])
      |> Enum.reduce(acc, fn tramo, acc_interno -> MapSet.put(acc_interno, tramo.destino) end)
    end)
  end

  @doc """
  Consume solo los pasos necesarios: se detiene en el primer estado repetido
  consecutivo.

  Retorna `{estados_distintos, paso_estabilizacion}`, donde `estados_distintos`
  es una lista de `{paso, conjunto}` desde el paso 0 hasta el paso en que el
  conjunto deja de cambiar.
  """
  def hasta_estabilizar(grafo, origen) do
    grafo
    |> estados(origen)
    |> Stream.with_index()
    |> Stream.chunk_every(2, 1, :discard)
    |> Enum.reduce_while([], fn [{actual, paso}, {siguiente, _}], acc ->
      acumulado = [{paso, actual} | acc]

      if MapSet.equal?(actual, siguiente) do
        {:halt, {:lists.reverse(acumulado), paso}}
      else
        {:cont, acumulado}
      end
    end)
  end

  @doc "¿El destino está en el conjunto final de centros alcanzables?"
  def alcanzable?(estados, destino) do
    {_paso, final} = List.last(estados)
    MapSet.member?(final, destino)
  end

  @doc "Escribe en `dispositivo` los estados distintos y el paso de estabilización."
  def escribir(dispositivo, origen, destino, estados, paso_final) do
    IO.puts(dispositivo, "=== #{origen} → #{destino} ===")

    Enum.each(estados, fn {paso, conjunto} ->
      IO.puts(dispositivo, "Paso #{paso}: #{formatear(conjunto)}")
    end)

    IO.puts(dispositivo, "Se estabiliza en el paso #{paso_final}")

    if alcanzable?(estados, destino) do
      IO.puts(dispositivo, "#{destino} es alcanzable desde #{origen}")
    else
      IO.puts(dispositivo, "#{destino} no es alcanzable desde #{origen}: sin itinerarios")
    end
  end

  defp formatear(conjunto) do
    "{" <> (conjunto |> Enum.sort() |> Enum.join(", ")) <> "}"
  end
end

