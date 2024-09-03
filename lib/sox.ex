defmodule Sox do
  @a4_frequency 440
  @a4_note_no 69
  @bpm 180

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
    note1 = [
      {78, 8},
      {77, 16},
      {0, 16},
      {73, 16},
      {0, 16},
      {0, 8},
      {78, 16},
      {0, 16},
      {77, 16},
      {73, 8},
      {0, 16},
      {0, 8}
    ]

    note2 = [{75, 16}, {75, 16}, {0, 16}, {75, 16}, {0, 16}, {75, 8}, {0, 16}]
    note3 = note_shift(note2, -4)
    note4 = note_shift(note2, 3)

    note1
    |> Enum.concat(note1)
    |> Enum.concat(note2)
    |> Enum.concat(note3)
    |> Enum.concat(note2)
    |> Enum.concat(note4)
    |> List.duplicate(2)
    |> List.flatten()
    |> Enum.each(&play(&1))

    :ok
  end

  def note_shift({0, time}, _), do: {0, time}
  def note_shift({note, time}, shift), do: {note + shift, time}

  def note_shift(notes, shift) when is_list(notes) do
    notes
    |> Enum.map(&note_shift(&1, shift))
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
