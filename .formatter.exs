# Used by "mix format"
[
  inputs: ["mix.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    # plug, plug_rest
    forward: 2,
    plug: 1,
    plug: 2,
    resource: 2,
    resource: 3,
    match: 2,
    # distillery
    set: 1,
    # ecto
    from: 2,
    field: 1,
    field: 2,
    field: 3,
    timestamps: 1,
    embeds_one: 2,
    embeds_one: 3,
    add: 3
  ]
]
