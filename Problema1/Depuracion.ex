defmodule Depuracion do
  @moduledoc """
  Validación previa con recursión: depurar la red (requisito general 7).

  Reglas:
    * se descartan los tramos con origen == destino
    * se descarta la repetición de la misma pareja origen->destino en la
      misma dirección (se conserva la PRIMERA aparición)
    * A->B y B->A son distintos y pueden coexistir

  Dentro de las funciones recursivas NO se usa Enum ni Stream (por eso se
  invierte la lista con :lists.reverse/1 y no con Enum.reverse/1).
  """

  @doc """
  Depura `tramos` y escribe cada descarte en `ruta_salida`
  (línea física, contenido y motivo), creando/reemplazando el archivo.

  Retorna `{tramos_limpios, cantidad_descartados}`.
  """
  def depurar_a_archivo(tramos, ruta_salida) do
    File.mkdir_p!(Path.dirname(ruta_salida))
    dispositivo = File.open!(ruta_salida, [:write, :utf8])

    try do
      depurar(tramos, dispositivo)
    after
      File.close(dispositivo)
    end
  end

  @doc """
  Recorre recursivamente la lista de tramos. Cada descarte se escribe en
  `dispositivo` en el momento en que se detecta.
  """
  def depurar(tramos, dispositivo) do
    depurar(tramos, %{}, [], 0, dispositivo)
  end

  # Caso base: no quedan tramos. Se devuelve la lista en el orden original.
  defp depurar([], _vistos, limpios, descartados, _dispositivo) do
    {:lists.reverse(limpios), descartados}
  end

  # Tramo que sale y llega al mismo centro.
  defp depurar([%Tramo{origen: o, destino: o} = t | resto], vistos, limpios, descartados, dev) do
    registrar(dev, t, "tramo de un centro a sí mismo (#{o} → #{o})")
    depurar(resto, vistos, limpios, descartados + 1, dev)
  end

  # Tramo normal: puede ser repetido o ser la primera aparición.
  defp depurar([%Tramo{origen: o, destino: d} = t | resto], vistos, limpios, descartados, dev) do
    case Map.fetch(vistos, {o, d}) do
      {:ok, linea_primera} ->
        registrar(
          dev,
          t,
          "repetición de #{o} → #{d} (se conserva la primera, línea #{linea_primera})"
        )

        depurar(resto, vistos, limpios, descartados + 1, dev)

      :error ->
        depurar(resto, Map.put(vistos, {o, d}, t.linea), [t | limpios], descartados, dev)
    end
  end

  defp registrar(dispositivo, %Tramo{linea: linea, contenido: contenido}, motivo) do
    IO.puts(dispositivo, "Línea #{linea}: #{contenido} -> #{motivo}")
  end
end
