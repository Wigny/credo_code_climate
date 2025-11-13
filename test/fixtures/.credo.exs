%{
  configs: [
    %{
      name: "default",
      plugins: [
        {CredoCodeClimate, []}
      ],
      checks: %{
        enabled: [
          {Credo.Check.Design.TagTODO, [exit_status: 2]},
          {Credo.Check.Readability.SinglePipe, []},
          {Credo.Check.Warning.IoInspect, []}
        ]
      }
    }
  ]
}
