defmodule GymLive.Utils.Time do
  # formats seconds in 00:00:00 format
  def format_time(seconds) do
    {h, m, s} = hhmmss(seconds)
    "#{pad_int(h)}:#{pad_int(m)}:#{pad_int(s)}"
  end

  defp pad_int(int, padding \\ 2) do
    Integer.to_string(int)
    |> String.pad_leading(padding, "0")
  end

  @one_hour 3600
  @one_minute 60

  defp hhmmss(seconds), do: hhmmss(seconds, 0, 0, 0)

  defp hhmmss(seconds, h, m, s) when seconds >= @one_hour,
    do: hhmmss(seconds - @one_hour, h + 1, m, s)

  defp hhmmss(seconds, h, m, s) when seconds >= @one_minute,
    do: hhmmss(seconds - @one_minute, h, m + 1, s)

  defp hhmmss(seconds, h, m, s) when seconds >= 1,
    do: hhmmss(seconds - 1, h, m, s + 1)

  defp hhmmss(_seconds, h, m, s), do: {h, m, s}
end
