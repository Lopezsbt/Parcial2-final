Code.require_file("Color.ex", __DIR__)
Code.require_file("Region.ex", __DIR__)
Code.require_file("Detector_regiones.ex", __DIR__)
Code.require_file("Validacion_map.ex", __DIR__)

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
      {:ok, _filas, _paleta, cantidad_filas, cantidad_columnas} ->
        IO.puts("Mapa válido: #{cantidad_filas} filas y #{cantidad_columnas} columnas.")

      {:error, errores} ->
        IO.puts("Se encontraron errores:")
        Enum.each(errores, &IO.puts/1)
    end
  end
end

Main.main()
