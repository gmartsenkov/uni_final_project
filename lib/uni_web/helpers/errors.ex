defmodule UniWeb.Helpers.Errors do
  def full_messages(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(&full_message/3)
    |> Enum.reduce([], fn {_key, errors}, acc -> acc ++ errors end)
  end

  defp full_message(%Ecto.Changeset{} = changeset, key, error) do
    module_name =
      changeset.data.__struct__
      |> Module.split()
      |> Enum.join(".")

    key_path = "#{module_name}.#{key}"

    key_name =
      case Gettext.dgettext(UniWeb.Gettext, "schema", key_path) do
        ^key_path -> Atom.to_string(key)
        n -> n
      end

    key_name
    |> String.capitalize()
    |> Kernel.<>(" ")
    |> Kernel.<>(String.downcase(UniWeb.ErrorHelpers.translate_error(error)))
  end
end
