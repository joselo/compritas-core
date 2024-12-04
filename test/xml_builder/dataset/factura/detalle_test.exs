defmodule BillingCore.Dataset.Factura.DetalleTest do
  use ExUnit.Case

  alias BillingCore.Dataset.Factura.Test.FactorySupport

  alias BillingCore.Dataset.Factura.{
    DetAdicional,
    Detalle,
    Impuesto
  }

  alias BillingCore.Dataset.Test.XmlSupport

  setup do
    detalle = FactorySupport.detalle_factory()

    {:ok, detalle: detalle}
  end

  test "to_doc", %{detalle: detalle} do
    detalles_adicionales =
      detalle.detalles_adicionales
      |> Enum.map(fn det_adicional -> DetAdicional.to_doc(det_adicional) end)

    impuestos =
      detalle.impuestos
      |> Enum.map(fn impuesto -> Impuesto.to_doc(impuesto) end)

    doc_expected = {
      :detalle,
      nil,
      [
        {:codigoPrincipal, nil, detalle.codigo_principal},
        {:codigoAuxiliar, nil, detalle.codigo_auxiliar},
        {:descripcion, nil, detalle.descripcion},
        {:cantidad, nil, detalle.cantidad},
        {:precioUnitario, nil, :erlang.float_to_binary(detalle.precio_unitario, decimals: 2)},
        {:descuento, nil, :erlang.float_to_binary(detalle.descuento, decimals: 2)},
        {:precioTotalSinImpuesto, nil,
         :erlang.float_to_binary(detalle.precio_total_sin_impuesto, decimals: 2)},
        {:detallesAdicionales, nil, detalles_adicionales},
        {:impuestos, nil, impuestos}
      ]
    }

    assert Detalle.to_doc(detalle) == doc_expected
  end

  test "to_xml", %{detalle: detalle} do
    xml_expected =
      File.read!("test/fixtures/detalle.xml")
      |> XmlSupport.format()

    xml =
      Detalle.to_xml(detalle)
      |> XmlSupport.format()

    assert xml == xml_expected
  end
end
