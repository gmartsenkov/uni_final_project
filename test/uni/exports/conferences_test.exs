defmodule Uni.Exports.ConferencesTest do
  use ExSpec

  alias Uni.Conferences.Conference
  alias Uni.Users.User
  alias Uni.Exports.Conferences, as: Export

  describe "when no conferences" do
    test "it returns the correct csv string" do
      assert Export.call([]) == "Създател,Тема,Страници,Тип,Докладван,Публикуван\r\n"
    end
  end

  describe "with conferences" do
    test "it returns the correct csv string" do
      authors = [
        %Conference{
          name: "Web Conf",
          page_start: 10,
          page_end: 20,
          type: "national",
          reported: true,
          published: false,
          owner: %User{name: "Bob"}
        },
        %Conference{
          name: "Mobile Conf",
          page_start: 15,
          page_end: 25,
          type: "international",
          reported: true,
          published: false,
          owner: %User{name: "Jon"}
        }
      ]

      assert Export.call(authors) == ~s"""
             Създател,Тема,Страници,Тип,Докладван,Публикуван\r
             Bob,Web Conf,10 - 20,Национален,Да,Не\r
             Jon,Mobile Conf,15 - 25,Международен,Да,Не\r
             """
    end
  end
end
