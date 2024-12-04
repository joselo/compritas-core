defmodule BillingCore.AuthorizationSoapTest do
  use ExUnit.Case

  alias BillingCore.Dataset.Test.XmlSupport
  alias BillingCore.Ws

  setup do
    clave_acceso = "123456789"

    {:ok, clave_acceso: clave_acceso}
  end

  test "create_request/2", %{clave_acceso: clave_acceso} do
    xml_expected =
      File.read!("test/fixtures/verificar_comprobante.xml")
      |> XmlSupport.format()

    xml =
      Ws.AuthorizationSoap.create_request(clave_acceso, :autorizacionComprobante)
      |> XmlSupport.format()

    assert xml == xml_expected
  end
end
