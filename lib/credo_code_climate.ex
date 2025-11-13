defmodule CredoCodeClimate do
  @moduledoc false

  import Credo.Plugin

  alias Credo.Execution

  defmodule Generate do
    @moduledoc false

    use Credo.Execution.Task

    @json_lib if Code.ensure_loaded?(Jason), do: Jason, else: JSON

    def call(exec, _opts) do
      case Execution.get_command_name(exec) do
        "suggest" -> do_run(exec)
        _ -> exec
      end
    end

    defp do_run(exec) do
      path = Execution.get_plugin_param(exec, CredoCodeClimate, :path) || "codeclimate.json"

      content =
        exec
        |> Execution.get_issues()
        |> Enum.map(&format/1)
        |> @json_lib.encode_to_iodata!()

      File.write!(path, content)

      exec
    end

    defp format(
           %{
             priority: priority,
             filename: path,
             line_no: line,
             message: description
           } = entry
         ) do
      fingerprint =
        entry
        |> :erlang.term_to_binary()
        |> hash()

      %{
        severity: severity(priority),
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

    defp severity(p) when p >= 20, do: "blocker"
    defp severity(p) when p in 10..19, do: "critical"
    defp severity(p) when p in 0..9, do: "major"
    defp severity(p) when p in -10..-1, do: "minor"
    defp severity(p) when p < -10, do: "info"

    defp hash(bin), do: :crypto.hash(:sha256, bin) |> Base.encode16(case: :lower)
  end

  def init(exec) do
    exec
    |> register_cli_switch(:path, :string)
    |> append_task(:run_command, Generate)
  end
end
