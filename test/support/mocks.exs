Mox.defmock(Billing.Ws.ClientMock, for: Billing.Ws.ClientBehaviour)

# Mimic Mocks
# Mimic.copy(Billing.Service.SignService)
Mimic.copy(Billing.Ws.Reception)
Mimic.copy(Billing.Crypto)
Mimic.copy(Billing.Ws.Client)

# Mimic.copy(Billing.Service.FacturaService)
Mimic.copy(Billing.Ws.Authorization)
# Mimic.copy(Billing.Service.UploadService)
