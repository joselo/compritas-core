defmodule Billing.Xbes.SignedInfo.KeyInfo do
  @moduledoc false

  alias Billing.Xbes.Util

  def digest(cfg) do
    get(cfg)
    |> XmlBuilder.generate(format: :none)
    |> Util.digest()
  end

  def get(cfg, xmlns \\ true) do
    id = "Certificate#{cfg.certificate_number}"
    {attrs, _close_tag} = Util.attrs(id, xmlns)

    {:"ds:KeyInfo", attrs,
     [
       {:"ds:X509Data", nil,
        [
          {:"ds:X509Certificate", nil, cfg.crt_x509}
        ]},
       {:"ds:KeyValue", nil,
        [
          {:"ds:RSAKeyValue", nil,
           [
             {:"ds:Modulus", nil, cfg.crt_modulus},
             {:"ds:Exponent", nil, cfg.crt_exponent}
           ]}
        ]}
     ]}
  end
end
