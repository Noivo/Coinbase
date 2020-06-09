defmodule Demo.Coinbase do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://api.pro.coinbase.com")
  plug(Tesla.Middleware.Headers, [{"user-agent", "Tesla"}])
  plug(Tesla.Middleware.JSON)

  def products do
    get("/products/")
    |> parse_response()
  end

  def product(id) do
    get("products/" <> id <> "/ticker")
    |> parse_response()
  end

  def products_ticker do
    with {:ok, response} <- products() do
      result_list = products_ticker_list(response)

      {:ok, result_list}
    else
      error -> error
    end
  end

  defp products_ticker_list(products) do
    Enum.reduce(products, [], &product_ticker/2)
  end

  defp product_ticker(%{"id" => id}, list) do
    with {:ok, product} <- product_with_id(id) do
      [product | list]
    else
      _ -> list
    end
  end

  def product_with_id(id) do
    product(id)
    |> add_id(id)
  end

  defp add_id({:ok, ticker}, id) do
    {:ok, Map.merge(ticker, %{"id" => id})}
  end

  defp add_id(error, _), do: error

  defp parse_response({:ok, %Tesla.Env{status: 200, body: body}}),
    do: {:ok, body}

  defp parse_response({:ok, %Tesla.Env{status: status, body: body}}),
    do: {:error, status, body}

  defp parse_response(error), do: error
end
