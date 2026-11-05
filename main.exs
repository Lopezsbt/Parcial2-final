Code.require_file("Color.ex", __DIR__)
Code.require_file("Region.ex", __DIR__)
Code.require_file("Detector_regiones.ex", __DIR__)
Code.require_file("Validacion_map.ex", __DIR__)
Code.require_file("Reporte_regiones.ex", __DIR__)

defmodule Main do
  def main do
    ruta_mapa = Path.join(__DIR__, "map.txt")
    ruta_paleta = Path.join(__DIR__, "paleta.csv")

    filas =
      File.stream!(ruta_mapa)
      |> Stream.map(&String.trim_trailing/1)
      |> Enum.to_list()

    colores =
      File.stream!(ruta_paleta)
      |> Stream.map(&String.trim_trailing/1)
      |> Enum.to_list()

    case Validacion_map.validar(filas, colores) do

      {:ok, filas, _paleta, cantidad_filas, cantidad_columnas} ->
      regiones =
        Detector_regiones.encontrar(
          filas,
          cantidad_filas,
          cantidad_columnas
        )
      IO.inspect("Regiones encontradas")
      IO.inspect(regiones)

      ruta_csv = Path.join(__DIR__, "regiones.csv")
         Reporte_regiones.guardar_csv(ruta_csv, regiones)
         IO.puts("Se guardó regiones.csv")

      ruta_resumen = Path.join(__DIR__, "resumen_regiones.txt")
         Reporte_regiones.guardar_resumen(ruta_resumen, regiones)
         IO.puts("Se guardó resumen_regiones.txt")

      {:error, errores} ->
        IO.puts("Se encontraron errores:")
        Enum.each(errores, &IO.puts/1)
    end
  end
end

Main.main()
