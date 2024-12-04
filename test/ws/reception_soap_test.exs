defmodule Billing.SoapTest do
  use ExUnit.Case

  alias Billing.Dataset.Test.XmlSupport
  alias Billing.Ws

  setup do
    xml = "<xml />"

    {:ok, xml: xml}
  end

  test "create_request/2", %{xml: xml} do
    xml_expected =
      File.read!("test/fixtures/validar_comprobante.xml")
      |> XmlSupport.format()

    xml =
      Ws.ReceptionSoap.create_request(xml, :validarComprobante)
      |> XmlSupport.format()

    assert xml == xml_expected
  end
end
