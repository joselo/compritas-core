defmodule Billing.Xbes.CertificateTest do
  use ExUnit.Case

  alias Billing.Xbes.P12.Certificate

  setup do
    pem_file = File.read!("test/fixtures/cert.pem")
    {pem, _} = Certificate.pem_decode(pem_file)

    {:ok, pem_file: pem_file, pem: pem}
  end

  test "issuer_name_from_pem with bank data pem file", %{pem: pem} do
    expected_result =
      "L=QUITO, CN=AC BANCO CENTRAL DEL ECUADOR, OU=ENTIDAD DE CERTIFICACION DE INFORMACION-ECIBCE, O=BANCO CENTRAL DEL ECUADOR, C=EC"

    result =
      pem
      |> Certificate.issuer_name_from_pem()
      |> String.split(", ")
      |> Enum.all?(fn value ->
        String.contains?(expected_result, value)
      end)

    assert result
  end

  ## Se comento ya que el certificado es informacion sensible y no se incluye en el codigo
  # test "issuer_name_from_pem with security data pem file" do
  #   pem_file = File.read!("test/fixtures/security-data.crt.pem")
  #   {pem, _} = Certificate.pem_decode(pem_file)

  #   expected_result = "C=EC, CN=AUTORIDAD DE CERTIFICACION SUBCA-2 SECURITY DATA, O=SECURITY DATA S.A. 2, OU=ENTIDAD DE CERTIFICACION DE INFORMACION"

  #   assert Certificate.issuer_name_from_pem(pem) == expected_result
  # end

  test "pem_decode", %{pem_file: pem_file} do
    [_, _, _, expected_cert] = pem_file |> :public_key.pem_decode()

    {cert, index} = Certificate.pem_decode(pem_file)

    assert cert == expected_cert
    assert index == 3
  end

  test "validity_from_pem", %{pem: pem} do
    assert {:ok, not_before: _, not_after: _} = Certificate.validity_from_pem(pem)
  end
end
