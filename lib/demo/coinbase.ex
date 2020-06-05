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
    |> add_id(id)
  end

  defp tickers_list(products) do
    Enum.reduce(products, [], fn %{"id" => id}, list ->
      product(id)
      |> parse_products_tickers(list)
    end)
  end

  defp add_id({:ok, ticker}, id) do
    {:ok, Map.merge(ticker, %{"id" => id})}
  end

  defp add_id(error, _), do: error

  defp parse_products_tickers({:ok, ticker}, list),
    do: [ticker | list]

  defp parse_products_tickers(_, list), do: list

  defp parse_response({:ok, %Tesla.Env{status: 200, body: body}}),
    do: {:ok, body}

  defp parse_response({:ok, %Tesla.Env{status: status, body: body}}),
    do: {:error, status, body}

  defp parse_response(error), do: error
end
