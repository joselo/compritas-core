defmodule Billing.Dataset.Test.XmlSupport do
  def format(xml) do
    xml
    |> String.replace(~r/\r|\n/, "")
  end
end
