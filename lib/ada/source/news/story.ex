defmodule Ada.Source.News.Story do
  @moduledoc false
  defstruct title: nil,
            body_html: nil,
            body_text: nil,
            thumbnail: nil,
            url: nil,
            pub_date: nil

  @type t :: %__MODULE__{
          title: String.t(),
          body_html: String.t(),
          body_text: String.t(),
          thumbnail: String.t(),
          url: String.t(),
          pub_date: DateTime.t()
        }
end
