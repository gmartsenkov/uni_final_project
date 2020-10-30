defmodule UniWeb.MonographLive.EditTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  @update_params %{
    "name" => "Monograph update",
    "publisher" => "new publisher",
    "year" => 2005
  }
  @invalid_params %{
    "name" => nil,
    "publisher" => nil,
    "year" => nil
  }

  test "redirects correctly when monograph is not found", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})
    monograph = %Uni.Monographs.Monograph{id: 0}

    {:ok, _monograph_live, html} =
      live(conn, Routes.monograph_edit_path(conn, :monographs, monograph))
      |> follow_redirect(conn, Routes.monograph_index_path(conn, :monographs))

    assert html =~ "Monograph not found"
  end

  test "updates the monograph", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})
    author_1 = insert(:user, name: "Rob Stark", email: "rob@stark.com")
    author_2 = insert(:user, name: "Arya Stark", email: "arya.stark.com")
    monograph = insert(:monograph, owner: user, authors: [author_1])

    {:ok, monograph_live, html} =
      live(conn, Routes.monograph_edit_path(conn, :monographs, monograph))

    assert html =~ "Edit Monograph"

    assert has_element?(monograph_live, "li#author-#{author_1.id}", author_1.name)
    refute has_element?(monograph_live, "li#author-1", "Rob Stark")

    monograph_live
    |> element("div#author-multiselect")
    |> render_hook("add_author", %{"id" => 1, "text" => "Rob Stark"})

    assert has_element?(monograph_live, "li#author-1", "Rob Stark")

    monograph_live
    |> element("div#author-multiselect")
    |> render_hook("add_author", %{"id" => "#{author_2.id}", "text" => author_2.name})

    assert monograph_live
           |> element("div#author-multiselect")
           |> render_hook("add_author", %{"id" => "#{author_2.id}", "text" => author_2.name}) =~
             "Author is already in the list"

    assert has_element?(monograph_live, "li#author-#{author_2.id}", author_2.name)

    monograph_live
    |> element("a#remove-author-1")
    |> render_click()

    refute has_element?(monograph_live, "li#author-1", "Rob Stark")

    assert monograph_live
           |> form("#monographs-form", monograph: @invalid_params)
           |> render_change() =~ "can&apos;t be blank"

    assert Uni.Monographs.Author |> Uni.Repo.all() |> length == 1

    {:ok, _, html} =
      monograph_live
      |> form("#monographs-form", monograph: @update_params)
      |> render_submit()
      |> follow_redirect(conn, Routes.monograph_edit_path(conn, :monographs, monograph))

    assert Uni.Monographs.Author |> Uni.Repo.all() |> length == 2

    assert html =~ "Monograph updated successfuly"
    assert html =~ "Monograph updated"
    assert html =~ "2005"
  end
end
