defmodule Demo.Coinbase do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://api.pro.coinbase.com")
  plug(Tesla.Middleware.Headers, [{"user-agent", "Tesla"}])
  plug(Tesla.Middleware.JSON)

  def products do
    with {:ok, response} <- get("/products/") |> parse_response() do
      result_list = tickers_list(response)

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

  defp tickers_list(products) do
    Enum.reduce(products, [], fn product, list ->
      fetch_products_tickers(product)
      |> parse_products_tickers(list)
    end)
  end

  defp aggregate_id({:ok, ticker}, id) do
    {:ok, Map.merge(ticker, %{"id" => id})}
  end

  defp aggregate_id(error, _), do: error

  defp parse_products_tickers({:ok, ticker}, list),
    do: list ++ [ticker]

  defp parse_products_tickers(_, list), do: list

  defp fetch_products_tickers(%{"id" => id}), do: product(id)

  defp fetch_products_tickers(error), do: error

  defp parse_response({:ok, %Tesla.Env{status: 200, body: body}}),
    do: {:ok, body}

  defp parse_response({:ok, %Tesla.Env{status: status, body: body}}),
    do: {:error, status, body}

  defp parse_response(error), do: error
end
