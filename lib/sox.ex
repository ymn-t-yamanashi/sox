defmodule Sox do
  @moduledoc """
  Documentation for `Sox`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Sox.hello()
      :ok

  """
  def hello do
    1..10
    |> Enum.each(fn _ -> piko() end)
    :ok
  end

  def piko do
    play(0.1, 440)
    play(0.1, 880)
  end

  def  play(t, f) do
    System.cmd("play", ~w"-n synth #{t} sin #{f}")
  end
end
