defmodule Lectura do
  @moduledoc """
  Lectura perezosa de archivos de entrada (requisitos generales 1, 2, 3 y 6).

  Nada se carga completo en memoria: `File.stream!/1` entrega una línea a la
  vez y las transformaciones (`Stream.*`) solo se ejecutan cuando alguien
  consume el flujo.
  """

  @doc """
  Devuelve un Stream de `{numero_de_linea_fisica, texto}` sin líneas en blanco
  ni comentarios (primer carácter no blanco igual a `#`).

  La numeración se hace ANTES de filtrar, así los números coinciden con la
  línea real del archivo.
  """
  def lineas_utiles(ruta) do
    ruta
    |> File.stream!()
    |> Stream.with_index(1)
    |> Stream.map(fn {texto, n} -> {n, String.trim(texto)} end)
    |> Stream.reject(fn {_n, texto} -> texto == "" or String.starts_with?(texto, "#") end)
  end

  @doc """
  Stream perezoso de resultados por línea:

    * `{:ok, %Tramo{}}` con `linea` y `contenido` ya asignados
    * `{:error, linea, contenido, motivo}`
  """
  def tramos(ruta) do
    ruta
    |> lineas_utiles()
    |> Stream.map(&a_tramo/1)
  end

  defp a_tramo({n, texto}) do
    case Tramo.parse(texto) do
     {:ok, %Tramo{} = tramo} -> {:ok, %{tramo | linea: n, contenido: texto}}
      {:error, motivo} -> {:error, n, texto, motivo}
    end
  end

  @doc """
  Consume el stream de tramos UNA vez: escribe cada error en `ruta_errores`
  en cuanto aparece y acumula los tramos válidos (la lista se construye solo
  al terminar la etapa perezosa, como permite el enunciado).

  Retorna:

    * `{:ok, tramos_validos, cantidad_de_errores}`
    * `{:error, {:archivo_faltante, ruta}}` si no existe el archivo
  """
  def cargar_tramos(ruta, ruta_errores) do
    if File.exists?(ruta) do
      File.mkdir_p!(Path.dirname(ruta_errores))
      dispositivo = File.open!(ruta_errores, [:write, :utf8])

      try do
        {validos, errores} =
          ruta
          |> tramos()
          |> Enum.reduce({[], 0}, fn
            {:ok, tramo}, {acc, e} ->
              {[tramo | acc], e}

            {:error, n, texto, motivo}, {acc, e} ->
              IO.puts(dispositivo, "Línea #{n}: #{texto} -> #{motivo}")
              {acc, e + 1}
          end)

        {:ok, Enum.reverse(validos), errores}
      after
        File.close(dispositivo)
      end
    else
      {:error, {:archivo_faltante, ruta}}
    end
  end
end
