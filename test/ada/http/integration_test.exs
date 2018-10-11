defmodule Ada.HTTP.IntegrationTest do
  use ExUnit.Case, async: true

  alias Ada.HTTPClient, as: H

  setup [:db_cleanup]

  ################################################################################
  ################################## LOCATIONS ###################################
  ################################################################################

  describe "GET /locations" do
    test "with no locations" do
      response = H.json_get("http://localhost:#{http_port()}/locations")
      assert %H.Response{} = response
      assert 200 == response.status_code
      assert [] == response.body
    end

    test "with locations" do
      location = Ada.Repo.insert!(%Ada.Schema.Location{name: "Home", lat: 1.0, lng: 1.0})
      response = H.json_get("http://localhost:#{http_port()}/locations")
      assert %H.Response{} = response
      assert 200 == response.status_code
      assert [response_location] = response.body
      assert Map.get(response_location, "id") == location.id
      assert Map.get(response_location, "name") == location.name
    end
  end

  describe "POST /locations" do
    test "with valid data" do
      data = %{name: "Home", lat: 0.12, lng: 0.13}
      response = H.json_post("http://localhost:#{http_port()}/locations", data)
      assert %H.Response{} = response
      assert 204 == response.status_code
    end

    test "with invalid data" do
      data = %{name: "Home"}
      response = H.json_post("http://localhost:#{http_port()}/locations", data)
      assert %H.Response{} = response
      assert 400 == response.status_code
    end
  end

  describe "PUT /locations/:id" do
    test "with valid data" do
      location = Ada.Repo.insert!(%Ada.Schema.Location{name: "Home", lat: 1.0, lng: 1.0})
      data = %{name: "Office"}
      response = H.json_put("http://localhost:#{http_port()}/locations/#{location.id}", data)
      updated_location = Ada.Repo.get!(Ada.Schema.Location, location.id)
      assert %H.Response{} = response
      assert 204 == response.status_code
      assert updated_location.name == "Office"
    end

    test "with invalid data" do
      location = Ada.Repo.insert!(%Ada.Schema.Location{name: "Home", lat: 1.0, lng: 1.0})
      data = %{name: 799}
      response = H.json_put("http://localhost:#{http_port()}/locations/#{location.id}", data)
      assert %H.Response{} = response
      assert 400 == response.status_code
      assert location == Ada.Repo.get!(Ada.Schema.Location, location.id)
    end
  end

  describe "DELETE /locations/:id" do
    test "with existing location" do
      location = Ada.Repo.insert!(%Ada.Schema.Location{name: "Home", lat: 1.0, lng: 1.0})
      response = H.delete("http://localhost:#{http_port()}/locations/#{location.id}")
      assert %H.Response{} = response
      assert 204 == response.status_code
      refute Ada.Repo.get(Ada.Schema.Location, location.id)
    end

    test "without location" do
      response = H.delete("http://localhost:#{http_port()}/locations/999")
      assert %H.Response{} = response
      assert 404 == response.status_code
    end
  end

  ################################################################################
  #################################### USERS #####################################
  ################################################################################

  describe "GET /users" do
    test "with no users" do
      response = H.json_get("http://localhost:#{http_port()}/users")
      assert %H.Response{} = response
      assert 200 == response.status_code
      assert [] == response.body
    end

    test "with users" do
      user = Ada.Repo.insert!(%Ada.Schema.User{name: "Ada", email: "ada@example.com"})
      response = H.json_get("http://localhost:#{http_port()}/users")
      assert %H.Response{} = response
      assert 200 == response.status_code
      assert [response_user] = response.body
      assert Map.get(response_user, "id") == user.id
      assert Map.get(response_user, "name") == user.name
    end
  end

  describe "POST /users" do
    test "with valid data" do
      data = %{name: "Ada", email: "ada@example.com"}
      response = H.json_post("http://localhost:#{http_port()}/users", data)
      assert %H.Response{} = response
      assert 204 == response.status_code
    end

    test "with invalid data" do
      data = %{name: "Ada"}
      response = H.json_post("http://localhost:#{http_port()}/users", data)
      assert %H.Response{} = response
      assert 400 == response.status_code
    end
  end

  describe "PUT /users/:id" do
    test "with valid data" do
      user = Ada.Repo.insert!(%Ada.Schema.User{name: "Ada", email: "ada@example.com"})
      data = %{name: "Grace"}
      response = H.json_put("http://localhost:#{http_port()}/users/#{user.id}", data)
      updated_user = Ada.Repo.get!(Ada.Schema.User, user.id)
      assert %H.Response{} = response
      assert 204 == response.status_code
      assert updated_user.name == "Grace"
    end

    test "with invalid data" do
      user = Ada.Repo.insert!(%Ada.Schema.User{name: "Ada", email: "ada@example.com"})
      data = %{name: 799}
      response = H.json_put("http://localhost:#{http_port()}/users/#{user.id}", data)
      assert %H.Response{} = response
      assert 400 == response.status_code
      assert user == Ada.Repo.get!(Ada.Schema.User, user.id)
    end
  end

  describe "DELETE /users/:id" do
    test "with existing user" do
      user = Ada.Repo.insert!(%Ada.Schema.User{name: "Ada", email: "ada@example.com"})
      response = H.delete("http://localhost:#{http_port()}/users/#{user.id}")
      assert %H.Response{} = response
      assert 204 == response.status_code
      refute Ada.Repo.get(Ada.Schema.User, user.id)
    end

    test "without user" do
      response = H.delete("http://localhost:#{http_port()}/users/999")
      assert %H.Response{} = response
      assert 404 == response.status_code
    end
  end

  ################################################################################
  ############################### SCHEDULED TASKS ################################
  ################################################################################

  describe "GET /scheduled_tasks" do
    test "with no scheduled_tasks" do
      response = H.json_get("http://localhost:#{http_port()}/scheduled_tasks")
      assert %H.Response{} = response
      assert 200 == response.status_code
      assert [] == response.body
    end

    test "with scheduled_tasks" do
      scheduled_task =
        Ada.Repo.insert!(%Ada.Schema.ScheduledTask{
          workflow_name: Ada.Workflow.WeatherForecast,
          params: %{"user_id" => 1, "location_id" => 1},
          frequency: %{}
        })

      response = H.json_get("http://localhost:#{http_port()}/scheduled_tasks")
      assert %H.Response{} = response
      assert 200 == response.status_code
      assert [response_scheduled_task] = response.body
      assert Map.get(response_scheduled_task, "id") == scheduled_task.id

      assert Map.get(response_scheduled_task, "workflow_name") ==
               "Elixir.Ada.Workflow.WeatherForecast"
    end
  end

  describe "POST /scheduled_tasks" do
    test "with valid data" do
      data = %{
        workflow_name: Ada.Workflow.WeatherForecast,
        params: %{"user_id" => 1, "location_id" => 1},
        frequency: %{}
      }

      response = H.json_post("http://localhost:#{http_port()}/scheduled_tasks", data)
      assert %H.Response{} = response
      assert 204 == response.status_code
    end

    test "with invalid data" do
      data = %{workflow_name: Ada.Foo}
      response = H.json_post("http://localhost:#{http_port()}/scheduled_tasks", data)
      assert %H.Response{} = response
      assert 400 == response.status_code
    end
  end

  describe "PUT /scheduled_tasks/:id" do
    test "with valid data" do
      scheduled_task =
        Ada.Repo.insert!(%Ada.Schema.ScheduledTask{
          workflow_name: Ada.Workflow.WeatherForecast,
          params: %{"user_id" => 1, "location_id" => 1},
          frequency: %{}
        })

      data = %{params: %{user_id: 2, location_id: 1}}

      response =
        H.json_put("http://localhost:#{http_port()}/scheduled_tasks/#{scheduled_task.id}", data)

      updated_scheduled_task = Ada.Repo.get!(Ada.Schema.ScheduledTask, scheduled_task.id)
      assert %H.Response{} = response
      assert 204 == response.status_code
      assert updated_scheduled_task.params == %{"user_id" => 2, "location_id" => 1}
    end

    test "with invalid data" do
      scheduled_task =
        Ada.Repo.insert!(%Ada.Schema.ScheduledTask{
          workflow_name: Ada.Workflow.Foo,
          params: %{"user_id" => 1, "location_id" => 1},
          frequency: %{}
        })

      data = %{workflow_name: 799}

      response =
        H.json_put("http://localhost:#{http_port()}/scheduled_tasks/#{scheduled_task.id}", data)

      assert %H.Response{} = response
      assert 400 == response.status_code
      assert scheduled_task == Ada.Repo.get!(Ada.Schema.ScheduledTask, scheduled_task.id)
    end
  end

  describe "DELETE /scheduled_tasks/:id" do
    test "with existing scheduled_task" do
      scheduled_task =
        Ada.Repo.insert!(%Ada.Schema.ScheduledTask{
          workflow_name: Ada.Workflow.WeatherForecast,
          params: %{"user_id" => 1, "location_id" => 1},
          frequency: %{}
        })

      response = H.delete("http://localhost:#{http_port()}/scheduled_tasks/#{scheduled_task.id}")
      assert %H.Response{} = response
      assert 204 == response.status_code
      refute Ada.Repo.get(Ada.Schema.ScheduledTask, scheduled_task.id)
    end

    test "without scheduled_task" do
      response = H.delete("http://localhost:#{http_port()}/scheduled_tasks/999")
      assert %H.Response{} = response
      assert 404 == response.status_code
    end
  end

  defp http_port() do
    System.get_env("HTTP_PORT") || 4001
  end

  defp db_cleanup(_config) do
    on_exit(fn ->
      Ada.Repo.delete_all(Ada.Schema.User)
      Ada.Repo.delete_all(Ada.Schema.Location)
      Ada.Repo.delete_all(Ada.Schema.ScheduledTask)
    end)
  end
end
