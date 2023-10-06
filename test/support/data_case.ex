defmodule GymLive.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use GymLive.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias GymLive.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import GymLive.DataCase
    end
  end

  setup tags do
    GymLive.DataCase.setup_sandbox(tags)
    :ok
  end

  @doc """
  Sets up the sandbox based on the test tags.
  """
  def setup_sandbox(tags) do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(GymLive.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  @doc """
  A helper that removes unloaded ecto associations form a struct. It will remove unloaded keys from the left struct and remove the same keys from the right
  """
  def remove_unloaded([left_elem | _] = left, right) when is_list(left) and is_list(right) do
    keys_to_remove =
      Map.from_struct(left_elem)
      |> Enum.filter(fn {_k, v} -> match?(%Ecto.Association.NotLoaded{}, v) end)
      |> Keyword.keys()

    left = Enum.map(left, fn l -> Map.from_struct(l) |> Map.drop(keys_to_remove) end)
    right = Enum.map(right, fn r -> Map.from_struct(r) |> Map.drop(keys_to_remove) end)

    {left, right}
  end

  def remove_unloaded(left, right) do
    keys_to_remove =
      Map.from_struct(left)
      |> Enum.filter(fn {_k, v} -> match?(%Ecto.Association.NotLoaded{}, v) end)
      |> Keyword.keys()

    left = Map.from_struct(left) |> Map.drop(keys_to_remove)
    right = Map.from_struct(right) |> Map.drop(keys_to_remove)
    {left, right}
  end
end
