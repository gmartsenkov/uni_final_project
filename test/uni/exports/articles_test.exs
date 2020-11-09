defmodule Uni.Exports.ArticlesTest do
  use ExSpec

  alias Uni.Articles.Article
  alias Uni.Users.User
  alias Uni.Exports.Articles, as: Export

  describe "when no articles" do
    test "it returns the correct csv string" do
      assert Export.call([]) == "Автори,Име,Издателство,Година,Тип,Scopus,Wofscience\r\n"
    end
  end

  describe "with articles" do
    test "it returns the correct csv string" do
      authors = [
        %Article{
          name: "Web",
          publisher: "Pub",
          scopus: true,
          wofscience: false,
          year: 1001,
          type: "national",
          authors: [%User{name: "Jon"}, %User{name: "Rob"}]
        },
        %Article{
          name: "Mobile",
          publisher: "Pub2",
          scopus: false,
          wofscience: true,
          year: 1002,
          type: "international",
          authors: [%User{name: "Sam"}, %User{name: "Andy"}]
        }
      ]

      assert Export.call(authors) == ~s"""
      Автори,Име,Издателство,Година,Тип,Scopus,Wofscience\r\n\
      "Jon, Rob\",Web,Pub,1001,Национален,Да,Не\r
      "Sam, Andy\",Mobile,Pub2,1002,Международен,Не,Да\r
      """
    end
  end
end
