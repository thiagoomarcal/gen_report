defmodule GenReportTest do
  use ExUnit.Case

  alias GenReport
  alias GenReport.Support.ReportFixture

  @file_name "gen_report.csv"

  describe "build/1" do
    test "When passing file name return a report" do
      response = GenReport.build(@file_name)

      assert response == ReportFixture.build()
    end

    test "When no filename was given, returns an error" do
      response = GenReport.build()

      assert response == {:error, "Insira o nome de um arquivo"}
    end
  end

  describe "build_from_many/1" do
    test "when a file list is provided, builds the report" do
      filenames = ["part_1.csv", "part_2.csv", "part_3.csv"]

      result =
        filenames
        |> GenReport.build_from_many()

      expected_result = ReportFixture.build()
      assert result == expected_result
    end

    test "when a file list is not provided, returns an error" do
      filenames = "banana"

      result =
        filenames
        |> GenReport.build_from_many()

      expected_result = {:error, "the argument must be a list of strings"}
      assert result == expected_result
    end
  end
end
