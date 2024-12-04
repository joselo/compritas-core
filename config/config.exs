import Config

# BillingCore
config :billing_core,
  decimals: 2,
  reception_url:
    "https://celcer.sri.gob.ec/comprobantes-electronicos-ws/RecepcionComprobantesOffline?wsdl",
  authorization_url:
    "https://celcer.sri.gob.ec/comprobantes-electronicos-ws/AutorizacionComprobantesOffline?wsdl",
  prod_reception_url:
    "https://cel.sri.gob.ec/comprobantes-electronicos-ws/RecepcionComprobantesOffline?wsdl",
  prod_authorization_url:
    "https://cel.sri.gob.ec/comprobantes-electronicos-ws/AutorizacionComprobantesOffline?wsdl",
  soap_server_timeout: 900_000,
  soap_server_recv_timeout: 900_000,
  timeout: 900_000,
  client: BillingCore.Ws.ClientMock,
  open_ssl_legacy: true,
  timezone: "America/Guayaquil",
  test_p12_password: System.get_env("TEST_P12_FILE_PASSWORD")
