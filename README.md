# Uni

To start your Phoenix server:

  * Setup the project with `mix setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## How to create user via repl
Run `iex -S mix` and then `Uni.Users.create_user(%{name: "Admin", email: "admin@admin.com", password: Bcrypt.hash_pwd_salt("1234")})`

## How to get lecterurers by faculty
`GET http://tt.swu.bg/Schedule/GetLecturersByFacultyId?facultyId=1`

Faculties:

Природо-математически факултет = 1
Правно-исторически факултет = 2
Факултет по педагогика = 3
Филологически факултет = 4
Философски факултет = 5
Факултет &quot;Обществено здраве, здравни грижи и спорт&quot; = 6
Стопански факултет = 7
Технически факултет = 8
 Факултет по изкуствата = 9
---ОБУЧЕНИЯ--- = 10

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
