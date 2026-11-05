defmodule Color do
  defstruct [:simbolo, :nombre, :hex]

  def parse(linea) do
    campos = String.split(String.trim(linea), ",")

    case campos do
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
            color = %__MODULE__{
              simbolo: simbolo,
              nombre: nombre,
              hex: hex
            }

            {:ok, color}
        end

      _ ->
        {:error, "se esperaban tres campos: simbolo,nombre,#RRGGBB"}
    end
  end

  defp hex_valido?("#" <> digitos) do
    revisar_digitos(String.to_charlist(digitos), 0)
  end

  defp hex_valido?(_texto) do
    false
  end

  defp revisar_digitos([], 6) do
    true
  end

  defp revisar_digitos([digito | resto], cantidad)
       when cantidad < 6 and
              ((digito >= ?0 and digito <= ?9) or
                 (digito >= ?a and digito <= ?f) or
                 (digito >= ?A and digito <= ?F)) do
    revisar_digitos(resto, cantidad + 1)
  end

  defp revisar_digitos(_resto, _cantidad) do
    false
  end
end
