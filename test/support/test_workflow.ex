defmodule Ada.TestWorkflow do
  @behaviour Ada.Workflow

  @impl true
  def human_name, do: "Test workflow"

  @impl true
  def requirements, do: %{name: :string}

  @impl true
  def fetch(params, _ctx) do
    {:ok, %{name: String.upcase(params.name)}}
  end

  @impl true
  def format(raw_data, :email, _ctx) do
    {:ok, %Ada.Email{subject: raw_data.name}}
  end
end
