defmodule Sox do
  @a4_frequency 440

  @c4_note_no 60
  @d4_note_no 62
  @e4_note_no 64
  @f4_note_no 65
  @g4_note_no 67
  @a4_note_no 69
  @b4_note_no 81
  @r_note_no 0

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
    """
    a3 8
    r0 8
    a4 8
    a5 8
    """
    |> text_to_play()

    :ok
  end

  def text_to_play(text) do
    text
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&create_play_syntax(&1))
    |> Enum.each(&play(&1))
  end

  def create_play_syntax(line) do
    [note, time] = line |> String.split(" ")
    {note, String.to_integer(time)}
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

  def play({note, time}) do
    [alphabet | number] = note |> String.split("") |> Enum.reject(&(&1 == ""))
    note_no = get_note_no(alphabet) + get_octaval_and_semitone(number)
    play(note_no, time)
  end

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

  def get_note_no("c"), do: @c4_note_no
  def get_note_no("d"), do: @d4_note_no
  def get_note_no("e"), do: @e4_note_no
  def get_note_no("f"), do: @f4_note_no
  def get_note_no("g"), do: @g4_note_no
  def get_note_no("a"), do: @a4_note_no
  def get_note_no("b"), do: @b4_note_no
  def get_note_no("r"), do: @r_note_no

  def get_octaval_and_semitone(number) when length(number) == 2 do
    [octaval | semitone] = number
    semitone = List.first(semitone)
    get_octaval_and_semitone(octaval) + get_semitone(semitone)
  end

  def get_octaval_and_semitone(number) when length(number) == 1 do
    List.first(number)
    |> get_octaval_and_semitone()
  end

  def get_octaval_and_semitone(number) do
    String.to_integer(number)
    |> get_octaval()
  end

  def get_octaval(octaval), do: (octaval - 4) * 12
  def get_semitone("+"), do: 1
  def get_semitone("-"), do: -1
  def get_semitone("#"), do: 1
end
