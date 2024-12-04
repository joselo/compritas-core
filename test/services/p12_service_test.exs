defmodule Billing.Service.P12ServiceTest do
  use ExUnit.Case

  alias Billing.Service

  setup do
    path =
      "test/fixtures/file.p12"
      |> Path.absname()

    bad_path = Path.absname("test/fixtures/badpath.p12")
    password = Application.get_env(:billing_core, :test_p12_password)

    {:ok, path: path, password: password, bad_path: bad_path}
  end

  test "read", %{path: path, password: password, bad_path: bad_path} do
    assert {:ok, _cert, _rsa} = Service.P12Service.read(path, password)
    assert {:error, _error} = Service.P12Service.read_cert(path, "badpass")
    assert {:error, _error} = Service.P12Service.read(bad_path, password)
  end

  test "read_cert", %{path: path, password: password, bad_path: bad_path} do
    assert {:ok, _cert} = Service.P12Service.read_cert(path, password)
    assert {:error, _error} = Service.P12Service.read_cert(path, "badpass")
    assert {:error, _error} = Service.P12Service.read_cert(bad_path, password)
  end

  test "read_rsa", %{path: path, password: password, bad_path: bad_path} do
    assert {:ok, _rsa} = Service.P12Service.read_rsa(path, password)
    assert {:error, _error} = Service.P12Service.read_rsa(path, "badpass")
    assert {:error, _error} = Service.P12Service.read_rsa(path, bad_path)
  end
end
