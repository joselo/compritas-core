defmodule BillingCore.CallbackTest do
  use ExUnit.Case

  import Mox

  setup :verify_on_exit!

  alias BillingCore.Ws

  setup do
    success_response = "Shop Succes"
    error_response = "Shop Error"
    callback_url = "http://callback_url"

    params = %{
      "clave_acceso" => "123",
      "callback_url" => callback_url,
      "status" => "STATUS",
      "response" => "response",
      "key" => "doc.xml",
      "signed_url" => "/uploads/doc.xml"
    }

    {:ok,
     params: params,
     success_response: success_response,
     error_response: error_response,
     callback_url: callback_url}
  end

  describe "send/2" do
    test "returns success response", %{
      params: params,
      success_response: success_response,
      callback_url: callback_url
    } do
      expect(Ws.ClientMock, :put, fn _callback_url, _request -> {:ok, success_response} end)

      assert {:ok, _success_response} = Ws.Callback.send(callback_url, params)
    end

    test "returns error 500", %{params: params, callback_url: callback_url} do
      expect(Ws.ClientMock, :put, fn _wsdl_url, _request -> {:error, "some error"} end)

      assert {:error, _error} = Ws.Callback.send(callback_url, params)
    end

    test "returns unknown error", %{params: params, callback_url: callback_url} do
      expect(Ws.ClientMock, :put, fn _wsdl_url, _request -> {:error, "bad request"} end)

      assert {:error, _error} = Ws.Callback.send(callback_url, params)
    end

    test "returns timeout", %{params: params, callback_url: callback_url} do
      expect(Ws.ClientMock, :put, fn _wsdl_url, _request -> {:error, "timeout"} end)

      assert {:error, "timeout"} = Ws.Callback.send(callback_url, params)
    end

    test "returns connection closed", %{params: params, callback_url: callback_url} do
      expect(Ws.ClientMock, :put, fn _wsdl_url, _request -> {:error, "closed"} end)

      assert {:error, "closed"} = Ws.Callback.send(callback_url, params)
    end
  end
end
