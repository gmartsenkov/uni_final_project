defmodule Uni.Exports.ProjectsTest do
  use ExSpec

  alias Uni.Projects.Project
  alias Uni.Users.User
  alias Uni.Exports.Projects, as: Export

  describe "when no projects" do
    test "it returns the correct csv string" do
      assert Export.call([]) == "Създател,Име,Проект №,Роля,Вид,Финансиране\r\n"
    end
  end

  describe "with projects" do
    test "it returns the correct csv string" do
      projects = [
        %Project{
          name: "Web Proj",
          project_id: "1",
          project_type: "national",
          financing_type: "internal",
          participation_role: "Manager",
          owner: %User{name: "Bob"}
        },
        %Project{
          name: "Mobile Proj",
          project_id: "2",
          project_type: "international",
          financing_type: "external",
          participation_role: "Assistant",
          owner: %User{name: "Rob"}
        }
      ]

      assert Export.call(projects) == ~s"""
      Създател,Име,Проект №,Роля,Вид,Финансиране\r
      Bob,Web Proj,1,Manager,Национален,Вътрешно\r
      Rob,Mobile Proj,2,Assistant,Международен,Външно\r
      """
    end
  end
end
