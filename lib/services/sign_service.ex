defmodule Billing.Service.SignService do
  @moduledoc false

  alias Billing.Service.P12Service
  alias Billing.Xbes

  def sign(xml, p12_path, p12_password) do
    signing_time =
      Application.get_env(:billing_core, :timezone)
      |> Timex.now()
      |> Timex.format!("%FT%T%:z", :strftime)

    case P12Service.read(p12_path, p12_password) do
      {:ok, cert, rsa} ->
        Xbes.sign(xml, cert, rsa, signing_time)

      {:error, error} ->
        {:error, error}
    end
  end
end
