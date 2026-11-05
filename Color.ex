defmodule Color do
  @enforce_keys [:simbolo, :nombre, :hex]
  defstruct [:simbolo, :nombre, :hex]

  def parse(linea) when is_binary(linea) do
    case String.split(String.trim(linea), ",") do
      [simbolo, nombre, hex] ->
        simbolo = String.trim(simbolo)
        nombre = String.trim(nombre)
        hex = String.trim(hex)

        cond do
          simbolo == "" ->
            {:error, "el símbolo está vacío"}

          nombre == "" ->
            {:error, "el nombre está vacío"}

          not hex_valido?(hex) ->
            {:error, "el color debe tener formato #RRGGBB"}

          true ->
            {:ok, %__MODULE__{simbolo: simbolo, nombre: nombre, hex: hex}}
        end

      _ ->
        {:error, "se esperaban: simbolo,nombre,#RRGGBB"}
    end
  end

  def hex_valido?(hex) do
    String.match?(hex, ~r/^#[0-9A-Fa-f]{6}$/)
  end
end