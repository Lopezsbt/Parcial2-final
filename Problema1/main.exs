# Problema 1: Rutas de entrega en una red dirigida.
#
# Se ejecuta desde cualquier carpeta con:   elixir main.exs
# (el script busca los demás archivos en su propia carpeta)

# --- Cargar los módulos (sin Mix). No importa si los archivos empiezan en
#     mayúscula o minúscula (Tramo.ex / tramo.ex).
for nombre <- ~w(tramo itinerario lectura depuracion busqueda alcance) do
  archivo =
    Enum.find(Path.wildcard(Path.join(__DIR__, "*.ex")), fn ruta ->
      String.downcase(Path.basename(ruta, ".ex")) == nombre
    end)

  if archivo do
    Code.require_file(archivo)
  else
    IO.puts("Falta el archivo del módulo: #{nombre}.ex")
    System.halt(1)
  end
end

defmodule Main do
  # Sin argumentos usa tramos.csv y consultas.txt de esta carpeta.
  # Con argumentos:  elixir Problema1/main.exs <tramos> <consultas>
  # (las rutas se interpretan desde donde ejecutas el comando)
  @args System.argv()
  @tramos (case @args do
             [t, _c] -> t
             _ -> Path.join(__DIR__, "tramos.csv")
           end)
  @consultas (case @args do
                [_t, c] -> c
                _ -> Path.join(__DIR__, "consultas.txt")
              end)
  @errores Path.join(__DIR__, "errores_tramos.txt")
  @depuracion Path.join(__DIR__, "depuracion_tramos.txt")
  @itinerarios Path.join(__DIR__, "itinerarios.txt")
  @alcance Path.join(__DIR__, "alcance_centros.txt")

  def run do
    faltantes = Enum.reject([@tramos, @consultas], &File.exists?/1)

    if faltantes == [] do
      procesar()
    else
      Enum.each(faltantes, fn ruta ->
        IO.puts("Falta el archivo requerido: #{Path.basename(ruta)}")
      end)
    end
  end

  defp procesar do
    # 1. Lectura perezosa + errores de formato
    {:ok, tramos, n_errores} = Lectura.cargar_tramos(@tramos, @errores)

    # 2. Depuración recursiva de la red
    {limpios, n_descartados} = Depuracion.depurar_a_archivo(tramos, @depuracion)

    IO.puts("Tramos bien formados: #{length(tramos)}")
    IO.puts("Líneas con errores de formato: #{n_errores} (ver errores_tramos.txt)")
    IO.puts("Tramos descartados en la depuración: #{n_descartados} (ver depuracion_tramos.txt)")
    IO.puts("Tramos finales: #{length(limpios)}")
    IO.puts("")

    # 3. Grafo (se arma después de consumir la etapa perezosa)
    grafo = Busqueda.construir_grafo(limpios)
    centros = Busqueda.centros(limpios)

    # 4. Consultas: se leen en flujo y cada resultado se escribe al producirse
    {:ok, out_it} = File.open(@itinerarios, [:write, :utf8])
    {:ok, out_al} = File.open(@alcance, [:write, :utf8])

    try do
      @consultas
      |> Lectura.lineas_utiles()
      |> Enum.each(fn {n, texto} -> consulta(n, texto, grafo, centros, out_it, out_al) end)
    after
      File.close(out_it)
      File.close(out_al)
    end
  end

  defp consulta(n, texto, grafo, centros, out_it, out_al) do
    case String.split(texto, ",") |> Enum.map(&String.trim/1) do
      [origen, destino] when origen != "" and destino != "" ->
        resolver(origen, destino, grafo, centros, out_it, out_al)

      _ ->
        IO.puts("Consulta inválida en la línea #{n}: #{texto}")
    end
  end

  defp resolver(origen, destino, grafo, centros, out_it, out_al) do
    faltan = Enum.reject([origen, destino], &MapSet.member?(centros, &1))

    if faltan != [] do
      mensaje = "Centro inexistente: #{Enum.join(Enum.uniq(faltan), ", ")} (no se inicia la búsqueda)"
      Busqueda.escribir_mensaje(out_it, origen, destino, mensaje)
      Busqueda.escribir_mensaje(out_al, origen, destino, mensaje)
      IO.puts("#{origen} → #{destino}: #{mensaje}")
    else
      # Stream infinito: se consume hasta el primer estado repetido
      {estados, paso} = Alcance.hasta_estabilizar(grafo, origen)
      Alcance.escribir(out_al, origen, destino, estados, paso)

      if Alcance.alcanzable?(estados, destino) do
        itinerarios = Busqueda.itinerarios(grafo, origen, destino)
        Busqueda.escribir_bloque(out_it, origen, destino, itinerarios)
        IO.puts("#{origen} → #{destino}: #{length(itinerarios)} itinerarios")
      else
        Busqueda.escribir_mensaje(out_it, origen, destino, "sin itinerarios")
        IO.puts("#{origen} → #{destino}: sin itinerarios")
      end
    end
  end
end

Main.run()
