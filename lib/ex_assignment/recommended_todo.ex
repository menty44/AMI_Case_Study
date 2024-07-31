defmodule ExAssignment.RecommendedTodo do
  @moduledoc """
  This module contains todo agent for persisting recommendation data.
  """
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, & &1)
  end

  def set(todo) do
    Agent.update(__MODULE__, fn _ -> todo end)
  end

  def clear do
    Agent.update(__MODULE__, fn _ -> nil end)
  end
end
