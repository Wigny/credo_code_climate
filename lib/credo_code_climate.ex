defmodule CredoCodeClimate do
  @moduledoc false

  import Credo.Plugin

  alias Credo.CLI.Command

  defmodule Generate do
    @moduledoc false

    use Credo.Execution.Task

    @json_lib if Code.ensure_loaded?(Jason), do: Jason, else: JSON

    def call(exec, _opts) do
      path = Execution.get_plugin_param(exec, CredoCodeClimate, :path) || "codeclimate.json"

      content =
        exec
        |> Execution.get_issues()
        |> Enum.filter(&new_issue?/1)
        |> Enum.map(&format/1)
        |> @json_lib.encode_to_iodata!()

      File.write!(path, content)

      exec
    end

    defp new_issue?(%{diff_marker: diff}) when diff in [:new, nil], do: true
    defp new_issue?(_issue), do: false

    defp format(
           %{
             filename: path,
             line_no: line,
             message: description
           } = entry
         ) do
      check_name = Credo.Code.Name.full(entry.check)
      priority = Credo.Priority.to_atom(entry.priority)
      fingerprint = hash({check_name, priority, path, line})

      %{
        severity: severity(priority),
        check_name: check_name,
        description: description,
        fingerprint: fingerprint,
        location: %{
          path: path,
          lines: %{
            begin: line
          }
        }
      }
    end

    defp severity(:higher), do: "blocker"
    defp severity(:high), do: "critical"
    defp severity(:normal), do: "major"
    defp severity(:low), do: "minor"
    defp severity(:ignore), do: "info"

    defp hash(term), do: Integer.to_string(:erlang.phash2(term), 16)
  end

  def init(exec) do
    exec
    |> register_cli_switch(:path, :string)
    |> append_task(Command.Suggest.SuggestCommand, :print_after_analysis, Generate)
    |> append_task(Command.Diff.DiffCommand, :print_after_analysis, Generate)
  end
end
