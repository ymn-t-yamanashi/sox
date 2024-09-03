defmodule Sox do
  @a4_frequency 440
  @a4_note_no 69

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
    base_note = [60, 62, 64, 65, 67, 69, 71, 72]

    note_add12 =
      base_note
      |> Enum.slice(1..7)
      |> Enum.map(&(&1 + 12))

    base_note
    |> Enum.concat(note_add12)
    |> Enum.each(&play(&1, 0.2))

    :ok
  end

  def note_no_to_frequency(@a4_note_no), do: @a4_frequency

  def note_no_to_frequency(note) when note < @a4_note_no,
    do: @a4_frequency / :math.pow(2, 1 / 12 * (@a4_note_no - note))

  def note_no_to_frequency(note) when note > @a4_note_no,
    do: @a4_frequency * :math.pow(2, 1 / 12 * (note - @a4_note_no))

  def play(note, time) do
    frequency = note_no_to_frequency(note)
    System.cmd("play", ~w"-n synth #{time} sin #{frequency}")
  end
end
