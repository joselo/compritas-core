defmodule Billing.Service.SignServiceTest do
  use ExUnit.Case

  alias Billing.Service.SignService

  setup do
    xml = File.read!("test/fixtures/xml.xml")
    p12_path = "test/fixtures/file.p12"
    p12_password = Application.get_env(:billing_core, :test_p12_password)

    {:ok,
     xml: xml,
     p12_path: p12_path,
     p12_password: p12_password}
  end

  describe "sign/3" do
    test "sign the xml with plain password successfully", %{
      xml: xml,
      p12_password: p12_password,
      p12_path: p12_path
    } do
      assert {:ok, _xml} = SignService.sign(xml, p12_path, p12_password)
    end

    test "do not sign the with wrong plain password", %{
      xml: xml,
      p12_path: p12_path
    } do
      assert {:error, _xml} = SignService.sign(xml, p12_path, "bad-pass")
    end

    test "sign the xml with encrypted password successfully", %{
      xml: xml,
      p12_password: p12_password,
      p12_path: p12_path
    } do
      assert {:ok, _xml} =
               SignService.sign(xml, p12_path, p12_password)
    end
  end
end
