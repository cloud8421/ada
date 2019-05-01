defmodule Ada.Schema.WorkflowTest do
  use ExUnit.Case, async: true

  alias Ada.{TestWorkflow, Workflow}

  defmodule TestEmailAdapter do
    @behaviour Ada.Email.Adapter

    def send_email(%Ada.Email{} = email), do: {:ok, {:email_delivered, email}}
  end

  describe "run/4" do
    test "validates params" do
      assert {:error, :invalid_params, [name: {"is invalid", [type: :string, validation: :cast]}]} ==
               Workflow.run(TestWorkflow, %{name: 1}, :email, email_adapter: TestEmailAdapter)
    end

    test "it uses the transport" do
      assert {:ok, {:email_delivered, %Ada.Email{subject: "ADA"}}} ==
               Workflow.run(TestWorkflow, %{name: "Ada"}, :email, email_adapter: TestEmailAdapter)
    end
  end

  describe "raw_data/3" do
    test "validates params" do
      assert {:error, :invalid_params, [name: {"is invalid", [type: :string, validation: :cast]}]} ==
               Workflow.raw_data(TestWorkflow, %{name: 1}, [])
    end

    test "it returns raw data" do
      assert {:ok, %{name: "ADA"}} ==
               Workflow.raw_data(TestWorkflow, %{name: "Ada"}, [])
    end
  end

  describe "valid_name?/1" do
    test "it passes for valid workflows" do
      assert Workflow.valid_name?(TestWorkflow)
      refute Workflow.valid_name?(Map)
      refute Workflow.valid_name?(NonExistentWorkflow)
    end
  end

  describe "validate/2" do
    test "it casts and validate params" do
      assert {:ok, %{name: "Ada"}} == Workflow.validate(TestWorkflow, %{name: "Ada"})
      assert {:ok, %{name: "Ada"}} = Workflow.validate(TestWorkflow, %{"name" => "Ada"})

      assert {:error, :invalid_params, [name: {"is invalid", [type: :string, validation: :cast]}]} ==
               Workflow.validate(TestWorkflow, %{"name" => 1})
    end
  end

  describe "normalize_name/1" do
    test "it handles atoms and strings" do
      assert "Ada.TestWorkflow" == Workflow.normalize_name(TestWorkflow)
      assert "Ada.TestWorkflow" == Workflow.normalize_name("Ada.TestWorkflow")
      assert "Ada.TestWorkflow" == Workflow.normalize_name("Elixir.Ada.TestWorkflow")
    end
  end
end
