defmodule CredoCodeClimateTest do
  use ExUnit.Case, async: true

  @report [
    %{
      "description" => "Found a TODO tag in a comment: # TODO: fix this issue",
      "fingerprint" => "5d77d87efe1fd90d4d6a8453f48e7a46efe10186c9de765c51946afe141c3e42",
      "location" => %{
        "lines" => %{"begin" => 3},
        "path" => "test/fixtures/issues.ex"
      },
      "severity" => "minor"
    },
    %{
      "description" => "Use a function call when a pipeline is only one function long.",
      "fingerprint" => "5ffcee51392eadb79d72672a783af4373690ee661e871fad923ac1c17985778a",
      "location" => %{
        "lines" => %{"begin" => 5},
        "path" => "test/fixtures/issues.ex"
      },
      "severity" => "major"
    },
    %{
      "description" => "There should be no calls to `IO.inspect/1`.",
      "fingerprint" => "c60cfd45ef43074bf38da38f8b40b544f734ccbea9e83b67a4fe1216f995870f",
      "location" => %{
        "lines" => %{"begin" => 5},
        "path" => "test/fixtures/issues.ex"
      },
      "severity" => "major"
    }
  ]

  @tag :tmp_dir
  test "suggest creates a report file", %{tmp_dir: tmp_dir} do
    Credo.run(~w[suggest test/fixtures/issues.ex
      --config-file test/fixtures/.credo.exs
      --path #{tmp_dir}/codeclimate.json
    ])

    assert read_json("#{tmp_dir}/codeclimate.json") == @report
  end

  @json_lib if Code.ensure_loaded?(JSON), do: JSON, else: Code.ensure_loaded!(Jason)
  defp read_json(path), do: @json_lib.decode!(File.read!(path))
end
