defmodule Billing.Dataset.Factura.TotalImpuestoTest do
  use ExUnit.Case

  alias Billing.Dataset.Factura.TotalImpuesto

  alias Billing.Dataset.Factura.Test.FactorySupport
  alias Billing.Dataset.Test.XmlSupport

  setup do
    total_impuesto = FactorySupport.total_impuesto_factory()

    {:ok, total_impuesto: total_impuesto}
  end

  test "to_doc", %{total_impuesto: total_impuesto} do
    doc_expected = {
      :totalImpuesto,
      nil,
      [
        {:codigo, nil, total_impuesto.codigo},
        {:codigoPorcentaje, nil, total_impuesto.codigo_porcentaje},
        {:baseImponible, nil,
         :erlang.float_to_binary(total_impuesto.base_imponible, decimals: 2)},
        {:valor, nil, :erlang.float_to_binary(total_impuesto.valor, decimals: 2)}
      ]
    }

    assert TotalImpuesto.to_doc(total_impuesto) == doc_expected
  end

  test "to_xml", %{total_impuesto: total_impuesto} do
    xml_expected =
      File.read!("test/fixtures/total_impuesto.xml")
      |> XmlSupport.format()

    xml =
      TotalImpuesto.to_xml(total_impuesto)
      |> XmlSupport.format()

    assert xml == xml_expected
  end
end
