defmodule BillingCore.Dataset.Factura.Pago do
  @moduledoc false

  @decimals Application.compile_env(:billing, :decimals, 2)

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:forma_pago, :integer)
    field(:total, :float)
    field(:plazo, :integer)
    field(:unidad_tiempo, :string)
  end

  def changeset(impuesto, params) do
    impuesto
    |> cast(params, [:forma_pago, :total, :plazo, :unidad_tiempo])
    |> validate_required([:forma_pago, :total, :plazo, :unidad_tiempo])
  end

  def to_doc(key, %BillingCore.Dataset.Factura.Pago{} = pago, decimals \\ @decimals)
      when is_atom(key) do
    {
      key,
      nil,
      [
        {:formaPago, nil, pago.forma_pago},
        {:total, nil, :erlang.float_to_binary(pago.total, decimals: decimals)},
        {:plazo, nil, pago.plazo},
        {:unidadTiempo, nil, pago.unidad_tiempo}
      ]
    }
  end

  def to_xml(key, %BillingCore.Dataset.Factura.Pago{} = pago) when is_atom(key) do
    to_doc(key, pago)
    |> XmlBuilder.generate()
  end
end
