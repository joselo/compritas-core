defmodule BillingCore.Dataset.NotaCredito do
  @moduledoc false

  alias BillingCore.Dataset.NotaCredito.{
    CampoAdicional,
    Detalle,
    InfoNotaCredito,
    InfoTributaria
  }

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    embeds_one(:info_tributaria, InfoTributaria)
    embeds_one(:info_nota_credito, InfoNotaCredito)

    embeds_many(:detalles, Detalle)
    embeds_many(:info_adicional, CampoAdicional)
  end

  def changeset(nota_credito, params \\ %{}) do
    nota_credito
    |> cast(params, [])
    |> cast_embed(:info_tributaria, required: true, with: &InfoTributaria.changeset/2)
    |> cast_embed(:info_nota_credito, required: true, with: &InfoNotaCredito.changeset/2)
    |> cast_embed(:detalles, required: true, with: &Detalle.changeset/2)
    |> cast_embed(:info_adicional, required: true, with: &CampoAdicional.changeset/2)
  end

  def to_doc(%BillingCore.Dataset.NotaCredito{} = nota_credito) do
    {
      :nota_credito,
      %{id: "comprobante", version: "1.0.0"},
      [
        InfoTributaria.to_doc(nota_credito.info_tributaria),
        InfoNotaCredito.to_doc(nota_credito.info_nota_credito),
        {:detalles, nil, detalles_to_doc(nota_credito.detalles)},
        {:infoAdicional, nil, info_adicional_to_doc(nota_credito.info_adicional)}
      ]
    }
  end

  def to_xml(%BillingCore.Dataset.NotaCredito{} = nota_credito) do
    XmlBuilder.document(to_doc(nota_credito))
    |> XmlBuilder.generate()
  end

  defp detalles_to_doc(detalles) do
    detalles
    |> Enum.map(fn detalle -> Detalle.to_doc(detalle) end)
  end

  defp info_adicional_to_doc(info_adicional) do
    info_adicional
    |> Enum.map(fn info -> CampoAdicional.to_doc(info) end)
  end
end
