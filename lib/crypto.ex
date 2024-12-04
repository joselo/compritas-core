defmodule Billing.Crypto do
  @moduledoc """
  Provides functions to encrypt and decrypt base_64 encoded tokens with
  AES in GCM algorithm, accept an optional timer if expiration minutes are given.
  """

  @auth_data "my-crypto-module"

  @doc """
  Generate a 256 bits url 64 encoded key
  """
  def generate_key do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64()
  end

  @doc """
  Encrypts a string and returns a token
  """
  @spec encrypt(String.t()) :: {:ok, String.t()} | {:error, any}
  def encrypt(data) when is_binary(data) do
    case block_encrypt(data) do
      {:ok, payload} ->
        {:ok, encode_payload(payload)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def encrypt(_), do: {:error, :invalid}

  @doc """
  Same as encrypt/1 but adds a given expiration time in minutes
  """
  @spec encrypt(String.t(), integer) :: {:ok, String.t()} | {:error, any}
  def encrypt(data, minutes) when is_binary(data) do
    ttl = Timex.shift(Timex.now(), minutes: minutes)
    data = data <> "|" <> to_string(ttl)

    case block_encrypt(data) do
      {:ok, payload} ->
        {:ok, encode_payload(payload)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def encrypt(_, _), do: {:error, :invalid}

  @doc """
  Decrypts a given token, if expiration exist evaluate it.
  """
  @spec decrypt(String.t()) :: {:ok, String.t()} | {:error, :invalid} | {:error, :expired}
  def decrypt(token) when is_binary(token) do
    with {:ok, payload} <- decode_payload(token),
         {:ok, decrypted} <- block_decrypt(payload) do
      case String.split(decrypted, "|") do
        [data, expiration] ->
          {:ok, date_time} = Timex.parse(expiration, "{ISO:Extended:Z}")

          if Timex.after?(date_time, Timex.now()) do
            {:ok, data}
          else
            {:error, :expired}
          end

        [data] ->
          {:ok, data}
      end
    else
      _ -> {:error, :invalid}
    end
  end

  def decrypt(_), do: {:error, :invalid}

  # =================
  # Private functions
  # =================

  defp block_encrypt(data) do
    iv = :crypto.strong_rand_bytes(16)

    case :crypto.crypto_one_time_aead(:aes_gcm, get_key(), iv, data, @auth_data, true) do
      {cipher_text, cipher_tag} ->
        {:ok, {iv, cipher_text, cipher_tag}}

      x ->
        {:error, x}
    end
  end

  defp block_decrypt({iv, cipher_text, cipher_tag}) do
    case :crypto.crypto_one_time_aead(
           :aes_gcm,
           get_key(),
           iv,
           cipher_text,
           @auth_data,
           cipher_tag,
           false
         ) do
      :error -> {:error, :invalid}
      data -> {:ok, data}
    end
  end

  # Returns a base_64 encoded token
  #  init_vec  <> cipher_tag <> cipher_text
  # [128 bits] <> [128 bits] <> [??? bits]
  # Change text & tag order so we can pattern match binary later.
  defp encode_payload({iv, cipher_text, cipher_tag}) do
    Base.url_encode64(iv <> cipher_tag <> cipher_text)
  end

  # Decodes and splits a token
  defp decode_payload(encoded_token) do
    case Base.url_decode64(encoded_token) do
      {:ok, decoded} ->
        case decoded do
          <<iv::binary-size(16), cipher_tag::binary-size(16), cipher_text::bitstring>> ->
            {:ok, {iv, cipher_text, cipher_tag}}

          _ ->
            {:error, :invalid}
        end

      :error ->
        {:error, :invalid}
    end
  end

  def get_key do
    Application.get_env(:billing_core, :crypto_key) |> Base.url_decode64!()
  end
end
