defmodule Fakex.Action do
  def begin do
    case Agent.start_link(fn -> [] end, name: __MODULE__) do
      {:ok, _} -> :ok
      {:error, {:already_started, _}} -> {:error, :already_started}
      _ -> {:error, :unknown_error}
    end
  end

  def stop do
    case Process.whereis(__MODULE__) do
      nil -> {:error, :not_started}
      _ -> Agent.stop(__MODULE__)
    end
  end

  def create(name, action = %{response_code: _code, response_body: _body}) do
    case is_atom name do
      true -> Agent.update(__MODULE__, fn(action_list) -> Keyword.put(action_list, name, action) end)
      false -> {:error, :invalid_name}
    end
  end
  def create(_name, %{response_body: _body}) do
    {:error, :response_code_not_provided}
  end
  def create(_name, %{response_code: _code}) do
    {:error, :response_body_not_provided}
  end
  def create(_action) do
    {:error, :name_not_provided}
  end

  def get do
    {:ok, Agent.get(__MODULE__, fn(action_list) -> action_list end)}
  end

  def get(name) do
    action = Agent.get(__MODULE__, fn(action_list) -> Keyword.get(action_list, name) end)
    case action do
      nil -> {:error, :not_found}
      _ -> {:ok, action}
    end
  end
end
