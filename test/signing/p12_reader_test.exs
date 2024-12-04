defmodule BillingCore.P12ReaderTest do
  use ExUnit.Case

  alias BillingCore.P12Reader

  setup do
    path =
      "test/fixtures/file.p12"
      |> Path.absname()

    bad_path = Path.absname("test/fixtures/badpath.p12")
    password = System.get_env("TEST_P12_FILE_PASSWORD")

    {:ok, path: path, password: password, bad_path: bad_path}
  end

  test "read", %{path: path, password: password, bad_path: bad_path} do
    assert {:ok, _cert, _rsa} = P12Reader.read(path, password)
    assert {:error, _error} = P12Reader.read_cert(path, "badpass")
    assert {:error, _error} = P12Reader.read(bad_path, password)
  end

  test "read_cert", %{path: path, password: password, bad_path: bad_path} do
    assert {:ok, _cert} = P12Reader.read_cert(path, password)
    assert {:error, _error} = P12Reader.read_cert(path, "badpass")
    assert {:error, _error} = P12Reader.read_cert(bad_path, password)
  end

  test "read_rsa", %{path: path, password: password, bad_path: bad_path} do
    assert {:ok, _rsa} = P12Reader.read_rsa(path, password)
    assert {:error, _error} = P12Reader.read_rsa(path, "badpass")
    assert {:error, _error} = P12Reader.read_rsa(path, bad_path)
  end
end
