defmodule Billing.Ws.Authorization do
  @moduledoc false

  alias Billing.Ws
  alias Billing.AuthorizationParser

  def send(clave_acceso, environment) when is_binary(clave_acceso) and is_integer(environment) do
    params = Ws.AuthorizationSoap.create_request(clave_acceso, :autorizacionComprobante)

    case client().post(get_authorization_url(environment), params) do
      {:ok, response} ->
        AuthorizationParser.parse_response(response)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp client do
    Application.get_env(:billing_core, :client)
  end

  # Test
  def get_authorization_url(1) do
    Application.fetch_env!(:billing_core, :authorization_url)
  end

  # Production 
  def get_authorization_url(2) do
    Application.fetch_env!(:billing_core, :prod_authorization_url)
  end
end
