defmodule GenReport do
  alias GenReport.Parser

  @names [
    "diego",
    "vinicius",
    "cleiton",
    "daniele",
    "mayk",
    "danilo",
    "giuliano",
    "jakeliny",
    "joseph",
    "rafael"
  ]

  @months [
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro"
  ]

  @years [
    2016,
    2017,
    2018,
    2019,
    2020
  ]

  def build(), do: {:error, "Insira o nome de um arquivo"}

  def build(filename) do
    result =
      filename
      |> Parser.parse_file()
      |> Enum.reduce(report_acc(), fn line, report -> sum_values(line, report) end)

    {:ok, result}
  end

  def build_from_many(filenames) when not is_list(filenames),
    do: {:error, "the argument must be a list of strings"}

  def build_from_many(filenames) do
    result =
      filenames
      |> Task.async_stream(&build/1)
      |> Enum.reduce(report_acc(), fn {:ok, {:ok, result}}, report ->
        sum_reports(report, result)
      end)

    {:ok, result}
  end

  defp sum_values([name, hours, _day, month, year], %{
         "all_hours" => all_hours,
         "hours_per_month" => hours_per_month,
         "hours_per_year" => hours_per_year
       }) do
    all_hours = Map.put(all_hours, name, all_hours[name] + hours)
    hours_per_month = put_in(hours_per_month, [name, month], hours_per_month[name][month] + hours)
    hours_per_year = put_in(hours_per_year, [name, year], hours_per_year[name][year] + hours)
    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp report_acc() do
    all_hours = Enum.into(@names, %{}, &{&1, 0})
    hours_per_month = Enum.into(@names, %{}, &build_nasted_map(&1, @months))
    hours_per_year = Enum.into(@names, %{}, &build_nasted_map(&1, @years))
    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp build_nasted_map(key, values) do
    {key, Enum.into(values, %{}, &{&1, 0})}
  end

  defp sum_reports(
         %{
           "all_hours" => all_hours1,
           "hours_per_month" => hours_per_month1,
           "hours_per_year" => hours_per_year1
         },
         %{
           "all_hours" => all_hours2,
           "hours_per_month" => hours_per_month2,
           "hours_per_year" => hours_per_year2
         }
       ) do
    all_hours = merge_maps(all_hours1, all_hours2)
    hours_per_month = merge_nasted_maps(hours_per_month1, hours_per_month2)
    hours_per_year = merge_nasted_maps(hours_per_year1, hours_per_year2)
    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
  end

  defp merge_nasted_maps(map1, map2) do
    Map.merge(map1, map2, fn _key1, map1, map2 ->
      Map.merge(map1, map2, fn _key2, value1, value2 -> value1 + value2 end)
    end)
  end

  defp build_report(all_hours, hours_per_month, hours_per_year) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end
end
