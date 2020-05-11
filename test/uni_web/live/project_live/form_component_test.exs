defmodule UniWeb.ProjectLive.FormComponentTest do
  use UniWeb.ConnCase

  alias UniWeb.ArticleLive.FormComponent
  alias Uni.Articles.Article
  import Phoenix.LiveViewTest

  test "it contains the correct fields" do
    component =
      render_component(
        FormComponent,
        %{article: %Article{authors: []}, myself: nil, action: :new}
      )

    assert component =~ "Name"
    assert component =~ "Year"
    assert component =~ "Type"
    assert component =~ "Publisher"
    assert component =~ "Scopus"
    assert component =~ "Wofsciense"
  end
end
