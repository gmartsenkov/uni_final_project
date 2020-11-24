defmodule UniWeb.ConferenceLive.FormComponentTest do
  use UniWeb.ConnCase

  alias UniWeb.ConferenceLive.FormComponent
  alias Uni.Conferences.Conference
  import Phoenix.LiveViewTest

  test "it contains the correct fields" do
    component =
      render_component(
        FormComponent,
        %{conference: %Conference{}, myself: nil, action: :new}
      )

    assert component =~ "Name"
    assert component =~ "Type"
    assert component =~ "Published"
    assert component =~ "Reported"
  end
end
