%{
  configs: [
    %{
      name: "default",
      strict: true,
      checks: [
        {CredoBinaryPatterns.Check.Consistency.Pattern},
        {Credo.Check.Readability.ParenthesesOnZeroArityDefs, parens: true},
        {Credo.Check.Readability.LargeNumbers, only_greater_than: 86400}
      ]
    }
  ]
}
