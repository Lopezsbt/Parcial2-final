defmodule ReporteRegiones do

  def guardar_csv(ruta, regiones) do
    encabezado = "id;simbolo;area;perimetro;desde;hasta"

    filas =
      Stream.map(regiones, fn region ->
        Region.a_csv(region)
      end)
  end
end
