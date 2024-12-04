Mox.defmock(BillingCore.Ws.ClientMock, for: BillingCore.Ws.ClientBehaviour)

# Mimic Mocks
# Mimic.copy(BillingCore.Service.SignService)
Mimic.copy(BillingCore.Ws.Reception)
Mimic.copy(BillingCore.Crypto)
Mimic.copy(BillingCore.Ws.Client)

# Mimic.copy(BillingCore.Service.FacturaService)
Mimic.copy(BillingCore.Ws.Authorization)
# Mimic.copy(BillingCore.Service.UploadService)
