defmodule BillingCore.Dataset.NotaCredito.InfoNotaCredito do
  @moduledoc false

  @decimals BillingCore.decimals()

  alias BillingCore.Dataset.NotaCredito.TotalImpuesto

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:fecha_emision, :date)
    field(:dir_establecimiento, :string)
    field(:tipo_identificacion_comprador, :integer)
    field(:razon_social_comprador, :string)
    field(:identificacion_comprador, :string)
    field(:contribuyente_especial, :string)
    field(:obligado_contabilidad, :string)
    field(:rise, :string)
    field(:cod_documento_modificado, :string)
    field(:num_documento_modificado, :string)
    field(:fecha_emision_doc_sustento, :date)
    field(:total_sin_impuestos, :float)
    field(:valor_modificacion, :float)
    field(:moneda, :string)
    field(:motivo, :string)

    embeds_many(:total_con_impuestos, TotalImpuesto)
  end

  def changeset(info_nota_credito, params) do
    info_nota_credito
    |> cast(params, [
      :fecha_emision,
      :dir_establecimiento,
      :tipo_identificacion_comprador,
      :razon_social_comprador,
      :identificacion_comprador,
      :contribuyente_especial,
      :obligado_contabilidad,
      :rise,
      :cod_documento_modificado,
      :num_documento_modificado,
      :fecha_emision_doc_sustento,
      :total_sin_impuestos,
      :valor_modificacion,
      :moneda,
      :motivo
    ])
    |> validate_required([
      :fecha_emision,
      :dir_establecimiento,
      :tipo_identificacion_comprador,
      :razon_social_comprador,
      :identificacion_comprador,
      :cod_documento_modificado,
      :num_documento_modificado,
      :fecha_emision_doc_sustento,
      :total_sin_impuestos,
      :valor_modificacion,
      :moneda,
      :motivo
    ])
    |> cast_embed(:total_con_impuestos, required: true, with: &TotalImpuesto.changeset/2)
  end

  def to_doc(
        %BillingCore.Dataset.NotaCredito.InfoNotaCredito{} = info_nota_credito,
        decimals \\ @decimals
      ) do
    doc =
      [
        {:fechaEmision, nil, format_fecha_emision(info_nota_credito.fecha_emision)},
        {:dirEstablecimiento, nil, info_nota_credito.dir_establecimiento},
        {:tipoIdentificacionComprador, nil,
         info_nota_credito.tipo_identificacion_comprador
         |> Integer.to_string()
         |> String.pad_leading(2, "0")},
        {:razonSocialComprador, nil, info_nota_credito.razon_social_comprador},
        {:identificacionComprador, nil, info_nota_credito.identificacion_comprador},
        {:obligadoContabilidad, nil, info_nota_credito.obligado_contabilidad},
        {:rise, nil, info_nota_credito.rise},
        {:codDocumentoModificado, nil, info_nota_credito.cod_documento_modificado},
        {:numDocumentoModificado, nil, info_nota_credito.cod_documento_modificado},
        {:fechaEmisionDocSustento, nil,
         format_fecha_emision(info_nota_credito.fecha_emision_doc_sustento)},
        {:totalSinImpuestos, nil,
         :erlang.float_to_binary(info_nota_credito.total_sin_impuestos, decimals: decimals)},
        {:valorModificacion, nil,
         :erlang.float_to_binary(info_nota_credito.valor_modificacion, decimals: decimals)},
        {:moneda, nil, info_nota_credito.moneda},
        {:motivo, nil, info_nota_credito.motivo},
        {:totalConImpuestos, nil,
         total_con_impuestos_to_doc(info_nota_credito.total_con_impuestos)}
      ]
      |> add_contribuyente_especial(info_nota_credito)

    {
      :infoNotaCredito,
      nil,
      doc
    }
  end

  def to_xml(%BillingCore.Dataset.NotaCredito.InfoNotaCredito{} = info_nota_credito) do
    to_doc(info_nota_credito)
    |> XmlBuilder.generate()
  end

  defp total_con_impuestos_to_doc(total_con_impuestos) do
    total_con_impuestos
    |> Enum.map(fn impuesto -> TotalImpuesto.to_doc(impuesto) end)
  end

  defp format_fecha_emision(fecha_emision) do
    day = fecha_emision.day |> Integer.to_string() |> String.pad_leading(2, "0")
    month = fecha_emision.month |> Integer.to_string() |> String.pad_leading(2, "0")

    [day, month, fecha_emision.year] |> Enum.join("/")
  end

  defp add_contribuyente_especial(doc, %{
         obligado_contabilidad: "SI",
         contribuyente_especial: contribuyente_especial
       }) do
    List.insert_at(doc, 2, {:contribuyenteEspecial, nil, contribuyente_especial})
  end

  defp add_contribuyente_especial(doc, %{obligado_contabilidad: _}), do: doc
end
