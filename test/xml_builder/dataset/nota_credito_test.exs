defmodule BillingCore.Dataset.NotaCreditoTest do
  use ExUnit.Case

  alias BillingCore.Dataset.NotaCredito.Test.FactorySupport

  alias BillingCore.Dataset.NotaCredito

  alias BillingCore.Dataset.NotaCredito.{
    CampoAdicional,
    Detalle,
    InfoNotaCredito,
    InfoTributaria
  }

  alias BillingCore.Dataset.Test.XmlSupport

  setup do
    nota_credito = FactorySupport.nota_credito_factory()

    {:ok, nota_credito: nota_credito}
  end

  test "to_doc", %{nota_credito: nota_credito} do
    detalles =
      nota_credito.detalles
      |> Enum.map(fn detalle -> Detalle.to_doc(detalle) end)

    info_adicional =
      nota_credito.info_adicional
      |> Enum.map(fn info -> CampoAdicional.to_doc(info) end)

    doc_expected = {
      :nota_credito,
      %{id: "comprobante", version: "1.0.0"},
      [
        InfoTributaria.to_doc(nota_credito.info_tributaria),
        InfoNotaCredito.to_doc(nota_credito.info_nota_credito),
        {:detalles, nil, detalles},
        {:infoAdicional, nil, info_adicional}
      ]
    }

    assert NotaCredito.to_doc(nota_credito) == doc_expected
  end

  test "to_xml", %{nota_credito: nota_credito} do
    xml_expected =
      File.read!("test/fixtures/nota_credito/nota_credito.xml")
      |> XmlSupport.format()

    xml =
      NotaCredito.to_xml(nota_credito)
      |> XmlSupport.format()

    assert xml == xml_expected
  end
end
