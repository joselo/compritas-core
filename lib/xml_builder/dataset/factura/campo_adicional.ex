defmodule BillingCore.Dataset.Factura.CampoAdicional do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:nombre, :string)
    field(:valor, :string)
  end

  def changeset(campo_adicional, params) do
    campo_adicional
    |> cast(params, [:nombre, :valor])
    |> validate_required([:nombre, :valor])
  end

  def to_doc(%BillingCore.Dataset.Factura.CampoAdicional{} = campo_adicional) do
    {
      :campoAdicional,
      %{nombre: campo_adicional.nombre},
      campo_adicional.valor
    }
  end

  def to_xml(%BillingCore.Dataset.Factura.CampoAdicional{} = campo_adicional) do
    to_doc(campo_adicional)
    |> XmlBuilder.generate()
  end
end
