defmodule UniWeb.ProjectLive.FormComponentTest do
  use UniWeb.ConnCase

  alias UniWeb.ProjectLive.FormComponent
  alias Uni.Projects.Project
  import Phoenix.LiveViewTest

  test "it contains the correct fields" do
    component =
      render_component(
        FormComponent,
        %{project: %Project{}, myself: nil, action: :new}
      )

    assert component =~ "Name"
    assert component =~ "Financing"
    assert component =~ "Project ID"
    assert component =~ "Participation Role"
  end
end
