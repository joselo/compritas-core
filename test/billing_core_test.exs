defmodule BillingCoreTest do
  use ExUnit.Case

  describe "decimals/0" do
    2
  end

  describe "reception_url/0" do
    test "returns the test reception url" do
      assert BillingCore.reception_url() ==
               "https://celcer.sri.gob.ec/comprobantes-electronicos-ws/RecepcionComprobantesOffline?wsdl"
    end
  end

  describe "authorization_url/0" do
    test "returns the test authorization url" do
      assert BillingCore.authorization_url() ==
               "https://celcer.sri.gob.ec/comprobantes-electronicos-ws/AutorizacionComprobantesOffline?wsdl"
    end
  end

  describe "prod_reception_url/0" do
    test "returns the production reception url" do
      assert BillingCore.prod_reception_url() ==
               "https://cel.sri.gob.ec/comprobantes-electronicos-ws/RecepcionComprobantesOffline?wsdl"
    end
  end

  describe "prod_authorization_url/0" do
    test "returns the production authorization url" do
      assert BillingCore.prod_authorization_url() ==
               "https://cel.sri.gob.ec/comprobantes-electronicos-ws/AutorizacionComprobantesOffline?wsdl"
    end
  end

  describe "soap_server_timeout/0" do
    test "returns the timeout for the soap server" do
      assert BillingCore.soap_server_timeout() == 900_000
    end
  end

  describe "soap_server_recv_timeout/0" do
    test "returns the recv timeout for the soap server" do
      assert BillingCore.soap_server_recv_timeout() == 900_000
    end
  end

  describe "timeout/0" do
    test "returns the timeout for the sri http client" do
      assert BillingCore.timeout() == 900_000
    end
  end

  describe "open_ssl_legacy/0" do
    test "returns the flag for open ssl legacy" do
      assert BillingCore.open_ssl_legacy() == true
    end
  end

  describe "timezone/0" do
    test "returns the default timezone" do
      assert BillingCore.timezone() == "America/Guayaquil"
    end
  end
end
