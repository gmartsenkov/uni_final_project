defmodule Uni.Exports.ArticlesTest do
  use ExSpec

  alias Uni.Articles.Article
  alias Uni.Users.User
  alias Uni.Exports.Articles, as: Export

  describe "when no articles" do
    test "it returns the correct csv string" do
      assert Export.call([]) == "Създател,Автори,Заглавие,Издателство,Година,Тип,Scopus,Web of Science\r\n"
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
          owner: %User{name: "Arya"},
          authors: [%User{name: "Jon"}, %User{name: "Rob"}]
        },
        %Article{
          name: "Mobile",
          publisher: "Pub2",
          scopus: false,
          wofscience: true,
          year: 1002,
          type: "international",
          owner: %User{name: "Sansa"},
          authors: [%User{name: "Sam"}, %User{name: "Andy"}]
        }
      ]

      assert Export.call(authors) == ~s"""
             Създател,Автори,Заглавие,Издателство,Година,Тип,Scopus,Web of Science\r\n\
             Arya,"Jon, Rob\",Web,Pub,1001,Национален,Да,Не\r
             Sansa,"Sam, Andy\",Mobile,Pub2,1002,Международен,Не,Да\r
             """
    end
  end
end
