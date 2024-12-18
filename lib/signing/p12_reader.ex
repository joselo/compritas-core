defmodule BillingCore.P12Reader do
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

    options = legacy_options(options)

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

    options = legacy_options(options)

    case System.cmd("openssl", options, stderr_to_stdout: true) do
      {rsa, 0} -> {:ok, rsa}
      {error, 1} -> {:error, error}
    end
  end

  defp legacy_options(options) do
    {major, minor, _patch} = openssl_version()

    if major > 3 or (major == 3 and minor >= 0) do
      options ++ ["-legacy"]
    else
      options
    end
  end

  defp openssl_version do
    {output, 0} = System.cmd("openssl", ["version"])

    case Regex.run(~r/OpenSSL (\d+)\.(\d+)\.(\d+)/, output) do
      [_, major, minor, patch] ->
        {String.to_integer(major), String.to_integer(minor), String.to_integer(patch)}

      _ ->
        {0, 0, 0}
    end
  end
end
