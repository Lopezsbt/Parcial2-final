defmodule Reporte_regiones do

  def guardar_csv(ruta, regiones) do
    encabezado = "id;simbolo;area;perimetro;desde;hasta"

    filas =
      Stream.map(regiones, fn region ->
        Region.a_csv(region)
      end)

  lineas =
      Stream.concat([encabezado], filas)
      |> Stream.map(fn linea -> linea <> "\n" end)

    lineas
    |> Stream.into(File.stream!(ruta, [:write, :utf8]))
    |> Stream.run()
  end

  def guardar_resumen(ruta, regiones) do
    lineas =
      if regiones == [] do
        [
          "Número de regiones: 0",
          "No hay regiones para comparar."
        ]
      else
        mayor_area =
          regiones
          |> Enum.map(fn region -> region.area end)
          |> Enum.max()

        mayor_perimetro =
          regiones
          |> Enum.map(fn region -> region.perimetro end)
          |> Enum.max()

        ids_mayor_area =
          regiones
          |> Enum.filter(fn region -> region.area == mayor_area end)
          |> Enum.map(fn region -> Integer.to_string(region.id) end)
          |> Enum.join(", ")

        ids_mayor_perimetro =
          regiones
          |> Enum.filter(fn region -> region.perimetro == mayor_perimetro end)
          |> Enum.map(fn region -> Integer.to_string(region.id) end)
          |> Enum.join(", ")

        [
          "Numero de regiones: #{length(regiones)}",
          "Mayor area: #{mayor_area} (regiones: #{ids_mayor_area})",
          "Mayor perimetro: #{mayor_perimetro} (regiones: #{ids_mayor_perimetro})"
        ]
      end

    lineas
    |> Stream.map(fn linea -> linea <> "\n" end)
    |> Stream.into(File.stream!(ruta, [:write, :utf8]))
    |> Stream.run()
  end

end
