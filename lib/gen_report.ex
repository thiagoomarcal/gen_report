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
    hours_per_month = Enum.into(@names, %{}, &build_submap(&1, @months))
    hours_per_year = Enum.into(@names, %{}, &build_submap(&1, @years))
    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp build_submap(key, values) do
    {key, Enum.into(values, %{}, &{&1, 0})}
  end

  defp build_report(all_hours, hours_per_month, hours_per_year) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end
end
