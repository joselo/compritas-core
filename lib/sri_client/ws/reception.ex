defmodule BillingCore.Ws.Reception do
  @moduledoc false

  alias BillingCore.Ws
  alias BillingCore.ReceptionParser

  def send(xml, environment) do
    params = Ws.ReceptionSoap.create_request(xml, :validarComprobante)

    case client().post(get_reception_url(environment), params) do
      {:ok, response} ->
        ReceptionParser.parse_response(response)

      {:error, response} ->
        {:error, response}
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
end
