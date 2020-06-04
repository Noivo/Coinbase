defmodule Demo.Coinbase do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://api.pro.coinbase.com")
  plug(Tesla.Middleware.Headers, [{"user-agent", "Tesla"}])
  plug(Tesla.Middleware.JSON)

  def products do
    with {:ok, response} <- get("/products/") |> parse_response() do
      result_list =
        response
        |> Enum.reduce([], fn product, acc ->
          fetch_products_tickers(product)
          |> parse_products_tickers(acc)
        end)

      {:ok, result_list}
    else
      error -> error
    end
  end

  def product(id) do
    get("products/" <> id <> "/ticker")
    |> parse_response()
    |> aggregate_id(id)
  end

  defp aggregate_id({:ok, response}, id) do
    {:ok, Map.merge(response, %{"id" => id})}
  end

  defp aggregate_id(error, _) do
    error
  end

  defp parse_products_tickers({:ok, response}, acc) do
    acc ++ [response]
  end

  defp parse_products_tickers(_, acc) do
    acc
  end

  defp fetch_products_tickers(%{"id" => id}) do
    product(id)
  end

  defp fetch_products_tickers(error) do
    error
  end

  defp parse_response({:ok, %Tesla.Env{status: 200, body: body}}),
    do: {:ok, body}

  defp parse_response({:ok, %Tesla.Env{status: status, body: body}}),
    do: {:error, status, body}

  defp parse_response(error), do: error
end
