defmodule Uni.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Uni.Repo

  def user_factory do
    %Uni.Users.User{
      name: "Jon Snow",
      email: "jon@snow.com",
      password: Bcrypt.hash_pwd_salt("1234")
    }
  end

  def article_factory do
    %Uni.Articles.Article{
      publisher: "some publisher",
      scopus: true,
      type: "national",
      wofscience: true,
      year: 1994
    }
  end
end
