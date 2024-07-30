defmodule ExAssignment.Todos do
  @moduledoc """
  Provides operations for working with todos.
  """

  import Ecto.Query, warn: false
  alias ExAssignment.Repo

  alias ExAssignment.Todos.Todo
  alias ExAssignment.RecommendedTodo

  @doc """
  Returns the list of todos, optionally filtered by the given type.

  ## Examples

      iex> list_todos(:open)
      [%Todo{}, ...]

      iex> list_todos(:done)
      [%Todo{}, ...]

      iex> list_todos()
      [%Todo{}, ...]

  """
  def list_todos(type \\ nil) do
    cond do
      type == :open ->
        from(t in Todo, where: not t.done, order_by: t.priority)
        |> Repo.all()

      type == :done ->
        from(t in Todo, where: t.done, order_by: t.priority)
        |> Repo.all()

      true ->
        from(t in Todo, order_by: t.priority)
        |> Repo.all()
    end
  end

  @doc """
  Returns the next todo that is recommended to be done by the system.

  ASSIGNMENT: ...
  """
  # def get_recommended() do
  #   list_todos(:open)
  #   |> case do
  #     [] -> nil
  #     todos -> Enum.take_random(todos, 1) |> List.first()
  #   end
  #   |> IO.inspect(label: "get_recommended")
  # end


@doc """
  Returns the next todo that is recommended to be done by the system.
  """
  def get_recommended do
    case RecommendedTodo.get() do
      nil ->
        new_recommendation = generate_recommendation()
        RecommendedTodo.set(new_recommendation)
        new_recommendation

      todo ->
        # Check if the todo is still open
        if todo.done do
          new_recommendation = generate_recommendation()
          RecommendedTodo.set(new_recommendation)
          new_recommendation
        else
          todo
        end
    end
  end

  defp generate_recommendation do
    open_todos = list_todos(:open)

    case open_todos do
      [] ->
        nil
      todos ->
        total_weight = Enum.sum(Enum.map(todos, fn todo -> 1 / todo.priority end))
        random_value = :rand.uniform() * total_weight

        Enum.reduce_while(todos, {0, nil}, fn todo, {acc_weight, _} ->
          weight = 1 / todo.priority
          new_acc_weight = acc_weight + weight
          if new_acc_weight >= random_value do
            {:halt, {new_acc_weight, todo}}
          else
            {:cont, {new_acc_weight, todo}}
          end
        end)
        |> elem(1)
    end
  end

  @doc """
  Marks the todo referenced by the given id as checked (done).
  """
  def check(id) do
    {_, _} =
      from(t in Todo, where: t.id == ^id, update: [set: [done: true]])
      |> Repo.update_all([])

    # Clear the recommended todo if it was marked as done
    RecommendedTodo.clear()
    :ok
  end


  @doc """
  Gets a single todo.

  Raises `Ecto.NoResultsError` if the Todo does not exist.

  ## Examples

      iex> get_todo!(123)
      %Todo{}

      iex> get_todo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_todo!(id), do: Repo.get!(Todo, id)

  @doc """
  Creates a todo.

  ## Examples

      iex> create_todo(%{field: value})
      {:ok, %Todo{}}

      iex> create_todo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_todo(attrs \\ %{}) do
    %Todo{}
    |> Todo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a todo.

  ## Examples

      iex> update_todo(todo, %{field: new_value})
      {:ok, %Todo{}}

      iex> update_todo(todo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a todo.

  ## Examples

      iex> delete_todo(todo)
      {:ok, %Todo{}}

      iex> delete_todo(todo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_todo(%Todo{} = todo) do
    data = Repo.delete(todo)
     # Clear the recommended todo if it was marked as done
     RecommendedTodo.clear()
     data
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking todo changes.

  ## Examples

      iex> change_todo(todo)
      %Ecto.Changeset{data: %Todo{}}

  """
  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end

  @doc """
  Marks the todo referenced by the given id as checked (done).

  ## Examples

      iex> check(1)
      :ok

  """
  def check(id) do
    {_, _} =
      from(t in Todo, where: t.id == ^id, update: [set: [done: true]])
      |> Repo.update_all([])

    :ok
  end

  @doc """
  Marks the todo referenced by the given id as unchecked (not done).

  ## Examples

      iex> uncheck(1)
      :ok

  """
  def uncheck(id) do
    {_, _} =
      from(t in Todo, where: t.id == ^id, update: [set: [done: false]])
      |> Repo.update_all([])

    :ok
  end
end
