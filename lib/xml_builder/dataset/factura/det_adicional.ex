defmodule Billing.Dataset.Factura.DetAdicional do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:nombre, :string)
    field(:valor, :string)
  end

  def changeset(det_adicional, params) do
    det_adicional
    |> cast(params, [:nombre, :valor])
    |> validate_required([:nombre, :valor])
  end

  def to_doc(%Billing.Dataset.Factura.DetAdicional{} = detAdicional) do
    {
      :detAdicional,
      %{nombre: detAdicional.nombre, valor: detAdicional.valor},
      nil
    }
  end

  def to_xml(%Billing.Dataset.Factura.DetAdicional{} = detAdicional) do
    to_doc(detAdicional)
    |> XmlBuilder.generate()
  end
end
