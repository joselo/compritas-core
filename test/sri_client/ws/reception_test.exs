defmodule Billing.ReceptionTest do
  use ExUnit.Case

  import Mox

  setup :verify_on_exit!

  alias Billing.Ws

  @environment 1

  setup do
    success_response = File.read!("test/fixtures/success_reception_response.xml")
    error_response = File.read!("test/fixtures/error_reception_response.xml")

    {:ok, success_response: success_response, error_response: error_response}
  end

  describe "send/1" do
    test "returns success response", %{success_response: success_response} do
      expect(Ws.ClientMock, :post, fn _wsdl_url, _request -> {:ok, success_response} end)

      assert {:ok, %{status: "RECIBIDA"}} = Ws.Reception.send("<xml />", @environment)
    end

    test "returns error 500" do
      expect(Ws.ClientMock, :post, fn _wsdl_url, _request -> {:error, "some error"} end)

      assert {:error, _error} = Ws.Reception.send("<xml />", @environment)
    end

    test "returns unknown error" do
      expect(Ws.ClientMock, :post, fn _wsdl_url, _request -> {:error, "bad request"} end)

      assert {:error, _error} = Ws.Reception.send("<xml />", @environment)
    end

    test "returns timeout" do
      expect(Ws.ClientMock, :post, fn _wsdl_url, _request -> {:error, "timeout"} end)

      assert {:error, "timeout"} = Ws.Reception.send("<xml />", @environment)
    end

    test "returns connection closed" do
      Ws.ClientMock
      |> expect(:post, fn _wsdl_url, _request -> {:error, "closed"} end)

      assert {:error, "closed"} = Ws.Reception.send("<xml />", @environment)
    end
  end
end
