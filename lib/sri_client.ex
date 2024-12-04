defmodule BillingCore.SriClient do
  alias BillingCore.Ws
  alias BillingCore.ReceptionParser
  alias BillingCore.AuthorizationParser

  def send_document(xml, environment) do
    params = Ws.ReceptionSoap.create_request(xml, :validarComprobante)

    case client().post(get_reception_url(environment), params) do
      {:ok, response} ->
        ReceptionParser.parse_response(response)

      {:error, response} ->
        {:error, response}
    end
  end

  def is_authorized(clave_acceso, environment)
      when is_binary(clave_acceso) and is_integer(environment) do
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
  defp get_reception_url(1) do
    Application.fetch_env!(:billing_core, :reception_url)
  end

  # Production
  defp get_reception_url(2) do
    Application.fetch_env!(:billing_core, :prod_reception_url)
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
