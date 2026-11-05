defmodule Validacion_map do

  def validar(lineas_mapa, lineas_paleta) do
    {paleta, errores_paleta} =
      revisar_paleta(lineas_paleta, 1, %{}, [])

    {filas, columnas, errores_filas} =
      revisar_filas(lineas_mapa, 1, nil, [], [])

    errores_fondo =
      if Map.get(paleta, ".") == nil do
        ["Falta definir el símbolo de fondo '.' en la paleta"]
      else
        []
      end

    errores_simbolos =
      revisar_simbolos(filas, 0, paleta, [])

    errores =
      errores_paleta ++ errores_fondo ++ errores_filas ++ errores_simbolos

    if errores == [] do
      {:ok, filas, paleta, contar(filas, 0), columnas}
    else
      {:error, errores}
    end
  end

  defp revisar_paleta([], _numero_linea, paleta, errores) do
    {paleta, errores}
  end

  defp revisar_paleta([linea | resto], numero_linea, paleta, errores) do
    texto = String.trim(linea)

    cond do
      texto == "" or String.starts_with?(texto, "#") ->
        revisar_paleta(resto, numero_linea + 1, paleta, errores)

      true ->
        case Color.parse(texto) do
          {:ok, color} ->
            if Map.get(paleta, color.simbolo) != nil do
              error = "Línea #{numero_linea}: símbolo repetido '#{color.simbolo}'"

              revisar_paleta(
                resto,
                numero_linea + 1,
                paleta,
                errores ++ [error]
              )
            else
              revisar_paleta(
                resto,
                numero_linea + 1,
                Map.put(paleta, color.simbolo, color),
                errores
              )
            end

          {:error, motivo} ->
            error = "Línea #{numero_linea} de paleta: #{motivo}"

            revisar_paleta(
              resto,
              numero_linea + 1,
              paleta,
              errores ++ [error]
            )
        end
    end
  end

  defp revisar_filas([], _numero_linea, columnas, filas, errores) do
    filas = reversar(filas)
    columnas = columnas || 0

    errores =
      if filas == [] do
        errores ++ ["El mapa no tiene filas"]
      else
        errores
      end

    {filas, columnas, errores}
  end

  defp revisar_filas([linea | resto], numero_linea, columnas, filas, errores) do
    texto = String.trim(linea)

    cond do
      String.starts_with?(texto, "#") ->
        revisar_filas(resto, numero_linea + 1, columnas, filas, errores)

      texto == "" ->
        error = "Línea #{numero_linea} del mapa: la fila está vacía"

        revisar_filas(
          resto,
          numero_linea + 1,
          columnas,
          filas,
          errores ++ [error]
        )

      true ->
        simbolos = String.split(texto)
        cantidad = contar(simbolos, 0)

        if columnas == nil do
          revisar_filas(
            resto,
            numero_linea + 1,
            cantidad,
            [simbolos | filas],
            errores
          )
        else
          if cantidad == columnas do
            revisar_filas(
              resto,
              numero_linea + 1,
              columnas,
              [simbolos | filas],
              errores
            )
          else
            error =
              "Línea #{numero_linea}: se esperaban #{columnas} columnas y hay #{cantidad}"

            revisar_filas(
              resto,
              numero_linea + 1,
              columnas,
              [simbolos | filas],
              errores ++ [error]
            )
          end
        end
    end
  end

  defp revisar_simbolos([], _numero_fila, _paleta, errores) do
    errores
  end

  defp revisar_simbolos([fila | resto], numero_fila, paleta, errores) do
    errores_fila =
      revisar_celdas(fila, numero_fila, 0, paleta, [])

    revisar_simbolos(
      resto,
      numero_fila + 1,
      paleta,
      errores ++ errores_fila
    )
  end

  defp revisar_celdas([], _fila, _columna, _paleta, errores) do
    errores
  end

  defp revisar_celdas([simbolo | resto], fila, columna, paleta, errores) do
    if Map.get(paleta, simbolo) != nil do
      revisar_celdas(resto, fila, columna + 1, paleta, errores)
    else
      error = "Fila #{fila}, columna #{columna}: '#{simbolo}' no está en la paleta"

      revisar_celdas(
        resto,
        fila,
        columna + 1,
        paleta,
        errores ++ [error]
      )
    end
  end

  defp contar([], total) do
    total
  end

  defp contar([_cabeza | cola], total) do
    contar(cola, total + 1)
  end

  defp reversar(lista) do
    reversar(lista, [])
  end

  defp reversar([], acumulado) do
    acumulado
  end

  defp reversar([cabeza | cola], acumulado) do
    reversar(cola, [cabeza | acumulado])
  end
end
