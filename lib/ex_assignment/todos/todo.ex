defmodule ExAssignment.Todos.Todo do
  @moduledoc """
  This module contains todo schema and changeset.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field(:done, :boolean, default: false)
    field(:priority, :integer)
    field(:title, :string)

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :priority, :done])
    |> validate_required([:title, :priority, :done])
  end
end
