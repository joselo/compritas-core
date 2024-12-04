defmodule Billing.Service.P12Service do
  @moduledoc false

  def read(path, password) do
    case read_cert(path, password) do
      {:ok, cert} ->
        case read_rsa(path, password) do
          {:ok, rsa} -> {:ok, cert, rsa}
          {:error, error} -> {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  def read_cert(path, password) do
    options = [
      "pkcs12",
      "-in",
      path,
      "-clcerts",
      "-nokeys",
      "-passin",
      "pass:#{password}"
    ]

    options =
      if Application.get_env(:billing_core, :open_ssl_legacy) do
        options ++ ["-legacy"]
      else
        options
      end

    case System.cmd("openssl", options, stderr_to_stdout: true) do
      {cert, 0} -> {:ok, cert}
      {error, 1} -> {:error, error}
    end
  end

  def read_rsa(path, password) do
    options = [
      "pkcs12",
      "-in",
      path,
      "-nocerts",
      "-nodes",
      "-passin",
      "pass:#{password}"
    ]

    options =
      if Application.get_env(:billing_core, :open_ssl_legacy) do
        options ++ ["-legacy"]
      else
        options
      end

    case System.cmd("openssl", options, stderr_to_stdout: true) do
      {rsa, 0} -> {:ok, rsa}
      {error, 1} -> {:error, error}
    end
  end
end
