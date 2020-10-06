defmodule UniWeb.MonographLive.NewTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  @valid_params %{
    "name" => "Monograph 1",
    "publisher" => "Helikon",
    "year" => 1994,
  }
  @invalid_params %{
    "name" => nil,
    "publisher" => nil,
    "year" => nil
  }

  test "saves the new monograph", %{conn: conn} do
    user = insert(:user)
    author_1 = insert(:user, name: "Bob John", email: "bob@john.com")
    author_2 = insert(:user, name: "Mike Babo", email: "mike@babo.com")
    conn = init_test_session(conn, %{user_id: user.id})

    {:ok, monograph_live, html} = live(conn, Routes.monograph_new_path(conn, :monographs))

    assert html =~ "New Monograph"

    refute has_element?(monograph_live, "li#author-1", "Rob Stark")

    monograph_live
    |> element("div#author-multiselect")
    |> render_hook("add_author", %{"id" => 1, "text" => "Rob Stark"})

    monograph_live
    |> element("div#author-multiselect")
    |> render_hook("add_author", %{"id" => author_1.id, "text" => author_1.name})

    monograph_live
    |> element("div#author-multiselect")
    |> render_hook("add_author", %{"id" => author_2.id, "text" => author_2.name})

    assert has_element?(monograph_live, "li#author-1", "Rob Stark")
    assert has_element?(monograph_live, "li#author-#{author_1.id}", author_1.name)
    assert has_element?(monograph_live, "li#author-#{author_2.id}", author_2.name)

    monograph_live
    |> element("a#remove-author-1")
    |> render_click()

    refute has_element?(monograph_live, "li#author-1", "Rob Stark")
    assert has_element?(monograph_live, "li#author-#{author_1.id}", author_1.name)
    assert has_element?(monograph_live, "li#author-#{author_2.id}", author_2.name)

    assert monograph_live
           |> form("#monographs-form", monograph: @invalid_params)
           |> render_change() =~ "can&apos;t be blank"

    {:ok, _, html} =
      monograph_live
      |> form("#monographs-form", monograph: @valid_params)
      |> render_submit()
      |> follow_redirect(conn, Routes.monograph_index_path(conn, :monographs))

    assert html =~ "Monograph created successfuly"
    assert html =~ "Monograph 1"
    assert html =~ "1994"

    assert Uni.Monographs.Author |> Uni.Repo.all() |> length == 2
  end
end
