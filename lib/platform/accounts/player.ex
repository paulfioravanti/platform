defmodule Platform.Accounts.Player do
  use Ecto.Schema
  import Ecto.Changeset
  alias Platform.Accounts.Player
  alias Platform.Products.{Game, Gameplay}

  schema "players" do
    many_to_many(:games, Game, join_through: Gameplay)
    field(:display_name, :string)
    field(:password, :string, virtual: true)
    field(:password_digest, :string)
    field(:score, :integer, default: 0)
    field(:username, :string, unique: true)

    timestamps()
  end

  @doc false
  def changeset(%Player{} = player, attrs) do
    player
    |> cast(attrs, [:display_name, :password, :score, :username])
    |> validate_required([:username])
    |> validate_length(:username, min: 2, max: 100)
    |> unique_constraint(:username)
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_digest()
  end

  @doc false
  def registration_changeset(%Player{} = player, attrs) do
    player
    |> cast(attrs, [:password, :username])
    |> validate_required([:password, :username])
    |> validate_length(:username, min: 2, max: 100)
    |> unique_constraint(:username)
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_digest()
  end

  defp put_pass_digest(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        changeset
        |> put_change(:password_digest, Comeonin.Bcrypt.hashpwsalt(pass))

      _ ->
        changeset
    end
  end
end
