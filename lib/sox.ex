defmodule Sox do
  @a4_frequency 440

  @c4_note_no 60
  @d4_note_no 62
  @e4_note_no 64
  @f4_note_no 65
  @g4_note_no 67
  @a4_note_no 69
  @b4_note_no 71
  @r_note_no 0
  @dotted_note 1.5

  @bpm 150
  @tmp_dir "/dev/shm/sox_ymn"
  @play_file_name "ymn.wav"

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
    File.rm_rf(@tmp_dir)
    File.mkdir(@tmp_dir)

    File.read!("music.txt")
    |> text_to_play()

    :ok
  end

  def text_to_play(text) do
    [parts | main] =
      text
      |> String.split("main ")

    part_map =
      get_list_part(parts)
      |> Enum.map(&create_part_keyword(&1))

    main
    |> List.first()
    |> String.split(" ")
    |> Enum.map(&Keyword.get(part_map, String.to_atom(&1)))
    |> List.flatten()
    |> Enum.map(&create_play_syntax(&1))
    |> Enum.with_index(1)
    |> Enum.each(&sox(&1))

    sox_merge_cmd()
    aplay_cmd()
  end

  def get_list_part(parts) do
    parts
    |> String.split("part")
    |> Enum.reject(&(&1 == ""))
  end

  def create_part_keyword(part) do
    [part_name | part_data] =
      part
      |> String.split("\n")
      |> Enum.reject(&(&1 == ""))

    {String.to_atom(part_name), part_data}
  end

  def create_play_syntax(line) do
    [note, time] = line |> String.split(" ")
    {note, time}
  end

  def note_no_to_frequency(@a4_note_no), do: @a4_frequency

  def note_no_to_frequency(note) when note < @a4_note_no,
    do: @a4_frequency / :math.pow(2, 1 / 12 * (@a4_note_no - note))

  def note_no_to_frequency(note) when note > @a4_note_no,
    do: @a4_frequency * :math.pow(2, 1 / 12 * (note - @a4_note_no))

  def sox({{note, time}, index}) do
    file_name =
      index
      |> Integer.to_string()
      |> String.pad_leading(10, "0")
      |> then(&"#{@tmp_dir}/#{&1}.wav")

    [alphabet | number] = note |> String.split("") |> Enum.reject(&(&1 == ""))
    note_no = get_note_no(alphabet) + get_octaval_and_semitone(number)
    sox(note_no, time, file_name)
  end

  def sox(0, time, file_name) do
    sec = get_sec(time)
    sox_cmd(0, sec, file_name)
  end

  def sox(note, time, file_name) do
    sec = get_sec(time)

    note_no_to_frequency(note)
    |> sox_cmd(sec, file_name)
  end

  def sox_cmd(frequency, time, file_name),
    do: System.cmd("sox", ~w"-n #{file_name} synth #{time} sin #{frequency}")

  def sox_merge_cmd(), do: System.cmd("sox", ~w"#{@tmp_dir}/*.wav #{@tmp_dir}/#{@play_file_name}")
  def aplay_cmd(), do: System.cmd("aplay", ~w"#{@tmp_dir}/#{@play_file_name}")

  def get_sec("1"), do: get_sec("4") * 4
  def get_sec("1."), do: get_sec("1") * @dotted_note
  def get_sec("2"), do: get_sec("4") * 2
  def get_sec("2."), do: get_sec("2") * @dotted_note
  def get_sec("4"), do: 60 / @bpm
  def get_sec("4."), do: get_sec("4") * @dotted_note
  def get_sec("8"), do: get_sec("4") / 2
  def get_sec("8."), do: get_sec("8") * @dotted_note
  def get_sec("16"), do: get_sec("4") / 4
  def get_sec("16."), do: get_sec("16") * @dotted_note

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
