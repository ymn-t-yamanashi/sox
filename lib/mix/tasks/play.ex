defmodule Mix.Tasks.Play do
  @moduledoc """
  曲を再生するタスクです
  """
  use Mix.Task

  @shortdoc "曲を再生する"
  def run(arg) do
    play(arg)
  end

  defp play([]), do: Sox.play("music1.txt")

  defp play(arg) do
    arg
    |> List.first()
    |> Sox.play()
  end
end
