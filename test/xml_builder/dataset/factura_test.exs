defmodule Billing.Dataset.FacturaTest do
  use ExUnit.Case

  alias Billing.Dataset.Factura.Test.FactorySupport

  alias Billing.Dataset.Factura

  alias Billing.Dataset.Factura.{
    CampoAdicional,
    Detalle,
    InfoFactura,
    InfoTributaria
  }

  alias Billing.Dataset.Test.XmlSupport

  setup do
    factura = FactorySupport.factura_factory()

    {:ok, factura: factura}
  end

  test "to_doc", %{factura: factura} do
    detalles =
      factura.detalles
      |> Enum.map(fn detalle -> Detalle.to_doc(detalle) end)

    info_adicional =
      factura.info_adicional
      |> Enum.map(fn info -> CampoAdicional.to_doc(info) end)

    doc_expected = {
      :factura,
      %{id: "comprobante", version: "1.0.0"},
      [
        InfoTributaria.to_doc(factura.info_tributaria),
        InfoFactura.to_doc(factura.info_factura),
        {:detalles, nil, detalles},
        {:infoAdicional, nil, info_adicional}
      ]
    }

    assert Factura.to_doc(factura) == doc_expected
  end

  test "to_xml", %{factura: factura} do
    xml_expected =
      File.read!("test/fixtures/factura.xml")
      |> XmlSupport.format()

    xml =
      Factura.to_xml(factura)
      |> XmlSupport.format()

    assert xml == xml_expected
  end
end
