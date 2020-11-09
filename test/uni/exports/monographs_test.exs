defmodule Uni.Exports.MonographsTest do
  use ExSpec

  alias Uni.Monographs.Monograph
  alias Uni.Users.User
  alias Uni.Exports.Monographs, as: Export

  describe "when no monographs" do
    test "it returns the correct csv string" do
      assert Export.call([]) == "Автори,Име,Издателство,Година\r\n"
    end
  end

  describe "with monographs" do
    test "it returns the correct csv string" do
      authors = [
        %Monograph{
          name: "Web",
          publisher: "Pub",
          year: 1001,
          authors: [%User{name: "Jon"}, %User{name: "Rob"}]
        },
        %Monograph{
          name: "Mobile",
          publisher: "Pub2",
          year: 1002,
          authors: [%User{name: "Sam"}, %User{name: "Andy"}]
        }
      ]

      assert Export.call(authors) == ~s"""
      Автори,Име,Издателство,Година\r\n\
      "Jon, Rob\",Web,Pub,1001\r
      "Sam, Andy\",Mobile,Pub2,1002\r
      """
    end
  end
end
