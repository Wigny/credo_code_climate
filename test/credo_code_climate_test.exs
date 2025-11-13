defmodule CredoCodeClimateTest do
  use ExUnit.Case, async: true

  @report [
    %{
      "description" => "Found a TODO tag in a comment: # TODO: fix this issue",
      "fingerprint" => "3e1d47210e77e7711c9cd30c41aba2e24ca2a3c5c8fdb7140c7f6fe86187a0af",
      "location" => %{
        "lines" => %{"begin" => 3},
        "path" => "test/fixtures/issues.ex"
      },
      "severity" => "minor"
    },
    %{
      "description" => "Use a function call when a pipeline is only one function long.",
      "fingerprint" => "8fa20cd1458e6feb62eb5aba5828f69ec2410ab65fe4fa7bacacea7bae83cb7d",
      "location" => %{
        "lines" => %{"begin" => 5},
        "path" => "test/fixtures/issues.ex"
      },
      "severity" => "major"
    },
    %{
      "description" => "There should be no calls to `IO.inspect/1`.",
      "fingerprint" => "86931891bb5fd236c157d407d052e7cf5183b9b54f78a212b5e19bbbd9918f0d",
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

  @json_lib if Code.ensure_loaded?(Jason), do: Jason, else: JSON
  defp read_json(path), do: @json_lib.decode!(File.read!(path))
end
