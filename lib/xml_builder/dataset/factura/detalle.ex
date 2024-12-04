defmodule BillingCore.Dataset.Factura.Detalle do
  @moduledoc false

  @decimals BillingCore.decimals()

  alias BillingCore.Dataset.Factura.{DetAdicional, Impuesto}

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:codigo_principal, :string)
    field(:codigo_auxiliar, :string)
    field(:descripcion, :string)
    field(:cantidad, :float)
    field(:precio_unitario, :float)
    field(:descuento, :float)
    field(:precio_total_sin_impuesto, :float)

    embeds_many(:detalles_adicionales, DetAdicional)
    embeds_many(:impuestos, Impuesto)
  end

  def changeset(campo_adicional, params) do
    campo_adicional
    |> cast(params, [
      :codigo_principal,
      :codigo_auxiliar,
      :descripcion,
      :cantidad,
      :precio_unitario,
      :descuento,
      :precio_total_sin_impuesto
    ])
    |> validate_required([
      :codigo_principal,
      :codigo_auxiliar,
      :descripcion,
      :cantidad,
      :precio_unitario,
      :descuento,
      :precio_total_sin_impuesto
    ])
    |> cast_embed(:detalles_adicionales, required: true, with: &DetAdicional.changeset/2)
    |> cast_embed(:impuestos, required: true, with: &Impuesto.changeset/2)
  end

  def to_doc(%BillingCore.Dataset.Factura.Detalle{} = detalle, decimals \\ @decimals) do
    {
      :detalle,
      nil,
      [
        {:codigoPrincipal, nil, detalle.codigo_principal},
        {:codigoAuxiliar, nil, detalle.codigo_auxiliar},
        {:descripcion, nil, detalle.descripcion},
        {:cantidad, nil, detalle.cantidad},
        {:precioUnitario, nil,
         :erlang.float_to_binary(detalle.precio_unitario, decimals: decimals)},
        {:descuento, nil, :erlang.float_to_binary(detalle.descuento, decimals: decimals)},
        {:precioTotalSinImpuesto, nil,
         :erlang.float_to_binary(detalle.precio_total_sin_impuesto, decimals: decimals)},
        {:detallesAdicionales, nil, detalles_adicionales_to_doc(detalle.detalles_adicionales)},
        {:impuestos, nil, impuestos_to_doc(detalle.impuestos)}
      ]
    }
  end

  def to_xml(%BillingCore.Dataset.Factura.Detalle{} = detalle) do
    to_doc(detalle)
    |> XmlBuilder.generate()
  end

  def detalles_adicionales_to_doc(detalles_adicionales) do
    detalles_adicionales
    |> Enum.map(fn det_adicional -> DetAdicional.to_doc(det_adicional) end)
  end

  defp impuestos_to_doc(impuestos) do
    impuestos
    |> Enum.map(fn impuesto -> Impuesto.to_doc(impuesto) end)
  end
end
