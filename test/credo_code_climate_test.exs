defmodule CredoCodeClimateTest do
  use ExUnit.Case, async: true

  @report [
    %{
      "description" => "Found a TODO tag in a comment: # TODO: fix this issue",
      "fingerprint" => "3A56884",
      "location" => %{
        "lines" => %{"begin" => 3},
        "path" => "test/fixtures/issues.ex"
      },
      "severity" => "major"
    },
    %{
      "description" => "Use a function call when a pipeline is only one function long.",
      "fingerprint" => "7F38538",
      "location" => %{
        "lines" => %{"begin" => 5},
        "path" => "test/fixtures/issues.ex"
      },
      "severity" => "critical"
    },
    %{
      "description" => "There should be no calls to `IO.inspect/1`.",
      "fingerprint" => "3A177D0",
      "location" => %{
        "lines" => %{"begin" => 5},
        "path" => "test/fixtures/issues.ex"
      },
      "severity" => "critical"
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

  @tag :tmp_dir
  test "diff creates a report file", %{tmp_dir: tmp_dir} do
    Credo.run(~w[diff
      --from-dir test/fixtures
      --config-file test/fixtures/.credo.exs
      --path #{tmp_dir}/codeclimate.json
    ])

    assert read_json("#{tmp_dir}/codeclimate.json") == @report
  end

  @json_lib if Code.ensure_loaded?(Jason), do: Jason, else: JSON
  defp read_json(path), do: @json_lib.decode!(File.read!(path))
end
