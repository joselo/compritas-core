defmodule Billing.Dataset.Factura.ImpuestoTest do
  use ExUnit.Case

  alias Billing.Dataset.Factura.Impuesto

  alias Billing.Dataset.Factura.Test.FactorySupport
  alias Billing.Dataset.Test.XmlSupport

  setup do
    impuesto = FactorySupport.impuesto_factory()

    {:ok, impuesto: impuesto}
  end

  test "to_doc", %{impuesto: impuesto} do
    doc_expected = {
      :impuesto,
      nil,
      [
        {:codigo, nil, impuesto.codigo},
        {:codigoPorcentaje, nil, impuesto.codigo_porcentaje},
        {:tarifa, nil, :erlang.float_to_binary(impuesto.tarifa, decimals: 2)},
        {:baseImponible, nil, :erlang.float_to_binary(impuesto.base_imponible, decimals: 2)},
        {:valor, nil, :erlang.float_to_binary(impuesto.valor, decimals: 2)}
      ]
    }

    assert Impuesto.to_doc(impuesto) == doc_expected
  end

  test "to_xml", %{impuesto: impuesto} do
    xml_expected =
      File.read!("test/fixtures/impuesto.xml")
      |> XmlSupport.format()

    xml =
      Impuesto.to_xml(impuesto)
      |> XmlSupport.format()

    assert xml == xml_expected
  end
end
