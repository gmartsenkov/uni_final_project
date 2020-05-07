defmodule UniWeb.PaginationComponentTest do
  use UniWeb.ConnCase

  alias UniWeb.PaginationComponent
  import Phoenix.LiveViewTest

  test "it contains the correct fields" do
    component = render_component(PaginationComponent, %{page: 5, total_pages: 10, myself: nil})

    assert component =~ "4"
    assert component =~ "5"
    assert component =~ "6"
  end
end
