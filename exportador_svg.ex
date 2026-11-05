defmodule Exportador_svg do
  def exportar(ruta, filas, paleta, regiones, cantidad_filas, cantidad_columnas) do
    {:ok, archivo} = File.open(ruta, [:write, :utf8])

    ancho = cantidad_columnas * 40
    alto = cantidad_filas * 40
    fondo = Map.get(paleta, ".").hex

    IO.write(archivo, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
    IO.write(archivo, "<svg xmlns=\"http://www.w3.org/2000/svg\" ")
    IO.write(archivo, "width=\"#{ancho}\" height=\"#{alto}\" ")
    IO.write(archivo, "viewBox=\"0 0 #{ancho} #{alto}\">\n")
    IO.write(archivo, "<rect width=\"100%\" height=\"100%\" fill=\"#{fondo}\"/>\n")

    escribir_filas(
      archivo,
      filas,
      paleta,
      regiones,
      0,
      cantidad_filas,
      cantidad_columnas
    )

    IO.write(archivo, "</svg>\n")
    File.close(archivo)
  end

  defp escribir_filas(_archivo, _filas, _paleta, _regiones, fila, cantidad_filas, _columnas)
       when fila >= cantidad_filas do
    :ok
  end

  defp escribir_filas(archivo, filas, paleta, regiones, fila, cantidad_filas, columnas) do
    escribir_columnas(archivo, filas, paleta, regiones, fila, 0, columnas)

    escribir_filas(
      archivo,
      filas,
      paleta,
      regiones,
      fila + 1,
      cantidad_filas,
      columnas
    )
  end

  defp escribir_columnas(_archivo, _filas, _paleta, _regiones, _fila, columna, columnas)
       when columna >= columnas do
    :ok
  end

  defp escribir_columnas(archivo, filas, paleta, regiones, fila, columna, columnas) do
    simbolos_fila = Enum.at(filas, fila)
    simbolo = Enum.at(simbolos_fila, columna)
    color = Map.get(paleta, simbolo).hex

    x = columna * 40
    y = fila * 40

    IO.write(
      archivo,
      "<rect x=\"#{x}\" y=\"#{y}\" width=\"40\" height=\"40\" " <>
        "fill=\"#{color}\" stroke=\"black\"/>\n"
    )

    escribir_id_region(archivo, regiones, {fila, columna}, x, y)

    escribir_columnas(
      archivo,
      filas,
      paleta,
      regiones,
      fila,
      columna + 1,
      columnas
    )
  end

  defp escribir_id_region(_archivo, [], _coordenada, _x, _y) do
    :ok
  end

  defp escribir_id_region(archivo, [region | resto], coordenada, x, y) do
    case region.celdas do
      [primera_celda | _otras] when primera_celda == coordenada ->
        centro_x = x + 20
        centro_y = y + 25

        IO.write(
          archivo,
          "<text x=\"#{centro_x}\" y=\"#{centro_y}\" " <>
            "text-anchor=\"middle\" font-size=\"14\">#{region.id}</text>\n"
        )

      _ ->
        escribir_id_region(archivo, resto, coordenada, x, y)
    end
  end
end
