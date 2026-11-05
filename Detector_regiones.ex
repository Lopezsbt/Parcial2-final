defmodule Detector_regiones do
  def encontrar(filas, cantidad_filas, cantidad_columnas) do
    matriz = crear_matriz(filas, 0, %{})

    recorrer_casillas(
      0,
      0,
      matriz,
      cantidad_filas,
      cantidad_columnas,
      %{},
      [],
      1
    )
  end

  # Convierte las filas en un mapa de coordenadas a símbolos.
  defp crear_matriz([], _numero_fila, matriz) do
    matriz
  end

  defp crear_matriz([fila | resto], numero_fila, matriz) do
    matriz = agregar_fila(fila, numero_fila, 0, matriz)
    crear_matriz(resto, numero_fila + 1, matriz)
  end

  defp agregar_fila([], _fila, _columna, matriz) do
    matriz
  end

  defp agregar_fila([simbolo | resto], fila, columna, matriz) do
    matriz = Map.put(matriz, {fila, columna}, simbolo)
    agregar_fila(resto, fila, columna + 1, matriz)
  end

  # Recorre el mapa en orden, buscando celdas que aún no pertenezcan a una región.
  defp recorrer_casillas(fila, _columna, _matriz, cantidad_filas, _cantidad_columnas,
         _visitadas, regiones, _id)
       when fila >= cantidad_filas do
    reversar(regiones)
  end

  defp recorrer_casillas(fila, columna, matriz, cantidad_filas, cantidad_columnas,
         visitadas, regiones, id)
       when columna >= cantidad_columnas do
    recorrer_casillas(
      fila + 1,
      0,
      matriz,
      cantidad_filas,
      cantidad_columnas,
      visitadas,
      regiones,
      id
    )
  end

  defp recorrer_casillas(fila, columna, matriz, cantidad_filas, cantidad_columnas,
         visitadas, regiones, id) do
    coordenada = {fila, columna}
    simbolo = Map.get(matriz, coordenada)

    if simbolo == "." or Map.get(visitadas, coordenada) == true do
      recorrer_casillas(
        fila,
        columna + 1,
        matriz,
        cantidad_filas,
        cantidad_columnas,
        visitadas,
        regiones,
        id
      )
    else
      visitadas = Map.put(visitadas, coordenada, true)

      {celdas, visitadas} =
        explorar_region(
          [coordenada],
          simbolo,
          matriz,
          cantidad_filas,
          cantidad_columnas,
          visitadas,
          [coordenada]
        )

      perimetro =
        calcular_perimetro(
          celdas,
          simbolo,
          matriz,
          cantidad_filas,
          cantidad_columnas,
          0
        )

      {:ok, region} = Region.crear(id, simbolo, celdas, perimetro)

      recorrer_casillas(
        fila,
        columna + 1,
        matriz,
        cantidad_filas,
        cantidad_columnas,
        visitadas,
        [region | regiones],
        id + 1
      )
    end
  end

  # Explora una región usando una lista de celdas pendientes.
  defp explorar_region([], _simbolo, _matriz, _filas, _columnas, visitadas, celdas) do
    {reversar(celdas), visitadas}
  end

  defp explorar_region([coordenada | pendientes], simbolo, matriz, filas, columnas,
         visitadas, celdas) do
    {fila, columna} = coordenada

    vecinos = [
      {fila - 1, columna},
      {fila + 1, columna},
      {fila, columna - 1},
      {fila, columna + 1}
    ]

    {pendientes, visitadas, celdas} =
      revisar_vecinos(vecinos, simbolo, matriz, filas, columnas,
        pendientes, visitadas, celdas)

    explorar_region(pendientes, simbolo, matriz, filas, columnas, visitadas, celdas)
  end

  defp revisar_vecinos([], _simbolo, _matriz, _filas, _columnas,
         pendientes, visitadas, celdas) do
    {pendientes, visitadas, celdas}
  end

  defp revisar_vecinos([{fila, columna} = coordenada | resto], simbolo, matriz,
         filas, columnas, pendientes, visitadas, celdas) do
    dentro_del_mapa =
      fila >= 0 and fila < filas and columna >= 0 and columna < columnas

    es_mismo_simbolo = Map.get(matriz, coordenada) == simbolo
    ya_visitada = Map.get(visitadas, coordenada) == true

    if dentro_del_mapa and es_mismo_simbolo and not ya_visitada do
      revisar_vecinos(
        resto,
        simbolo,
        matriz,
        filas,
        columnas,
        [coordenada | pendientes],
        Map.put(visitadas, coordenada, true),
        [coordenada | celdas]
      )
    else
      revisar_vecinos(
        resto,
        simbolo,
        matriz,
        filas,
        columnas,
        pendientes,
        visitadas,
        celdas
      )
    end
  end

  # Suma un lado de perímetro cuando da al borde o a otro símbolo.
  defp calcular_perimetro([], _simbolo, _matriz, _filas, _columnas, total) do
    total
  end

  defp calcular_perimetro([{fila, columna} | resto], simbolo, matriz,
         filas, columnas, total) do
    vecinos = [
      {fila - 1, columna},
      {fila + 1, columna},
      {fila, columna - 1},
      {fila, columna + 1}
    ]

    lados = contar_lados(vecinos, simbolo, matriz, filas, columnas, 0)

    calcular_perimetro(resto, simbolo, matriz, filas, columnas, total + lados)
  end

  defp contar_lados([], _simbolo, _matriz, _filas, _columnas, total) do
    total
  end

  defp contar_lados([{fila, columna} = coordenada | resto], simbolo, matriz,
         filas, columnas, total) do
    fuera =
      fila < 0 or fila >= filas or columna < 0 or columna >= columnas

    if fuera or Map.get(matriz, coordenada) != simbolo do
      contar_lados(resto, simbolo, matriz, filas, columnas, total + 1)
    else
      contar_lados(resto, simbolo, matriz, filas, columnas, total)
    end
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
