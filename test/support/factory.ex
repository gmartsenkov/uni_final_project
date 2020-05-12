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

  def project_factory do
    %Uni.Projects.Project{
      name: "Project name",
      project_id: "project01",
      project_type: "national",
      financing_type: "internal",
      participation_role: "boss"
    }
  end

  def conference_factory do
    %Uni.Conferences.Conference{
      name: "Conference name",
      type: "national",
      published: true,
      reported: true,
      page_start: 5,
      page_end: 15
    }
  end
end
