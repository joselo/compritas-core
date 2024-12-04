defmodule Billing.Dataset.Factura.CampoAdicionalTest do
  use ExUnit.Case

  alias Billing.Dataset.Factura.CampoAdicional

  alias Billing.Dataset.Factura.Test.FactorySupport
  alias Billing.Dataset.Test.XmlSupport

  setup do
    campo_adicional = FactorySupport.campo_adicional_factory()

    {:ok, campo_adicional: campo_adicional}
  end

  test "new", %{campo_adicional: campo_adicional} do
    assert campo_adicional.nombre == "Direccion"
    assert campo_adicional.valor == "East 109 St - 6J Manhattan NY"
  end

  test "to_doc", %{campo_adicional: campo_adicional} do
    doc_expected = {
      :campoAdicional,
      %{nombre: campo_adicional.nombre},
      campo_adicional.valor
    }

    assert CampoAdicional.to_doc(campo_adicional) == doc_expected
  end

  test "to_xml", %{campo_adicional: campo_adicional} do
    xml_expected =
      File.read!("test/fixtures/campo_adicional.xml")
      |> XmlSupport.format()

    xml =
      CampoAdicional.to_xml(campo_adicional)
      |> XmlSupport.format()

    assert xml == xml_expected
  end
end
