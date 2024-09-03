defmodule Sox do
  @a4_frequency 440
  @a4_note_no 69
  @bpm 150

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
    base_note = [{60, 8}, {0, 8}, {62, 4}, {64, 4}, {65, 4}, {67, 4}, {69, 4}, {71, 4}, {72, 4}]

    base_note
    |> Enum.each(&play(&1))

    :ok
  end

  def note_no_to_frequency(@a4_note_no), do: @a4_frequency

  def note_no_to_frequency(note) when note < @a4_note_no,
    do: @a4_frequency / :math.pow(2, 1 / 12 * (@a4_note_no - note))

  def note_no_to_frequency(note) when note > @a4_note_no,
    do: @a4_frequency * :math.pow(2, 1 / 12 * (note - @a4_note_no))

  def play({note, time}), do: play(note, time)

  def play(0, time) do
    sec = get_sec(time)
    play_cmd(0, sec)
  end

  def play(note, time) do
    sec = get_sec(time)

    note_no_to_frequency(note)
    |> play_cmd(sec)
  end

  def play_cmd(frequency, time), do: System.cmd("play", ~w"-n synth #{time} sin #{frequency}")

  def get_sec(1), do: get_sec(4) * 4
  def get_sec(2), do: get_sec(4) * 2
  def get_sec(4), do: 60 / @bpm
  def get_sec(8), do: get_sec(4) / 2
  def get_sec(16), do: get_sec(4) / 4
end
