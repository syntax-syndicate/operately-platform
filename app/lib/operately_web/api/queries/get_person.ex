defmodule OperatelyWeb.Api.Queries.GetPerson do
  use TurboConnect.Query
  use OperatelyWeb.Api.Helpers

  alias Operately.People.Person

  inputs do
    field? :id, :id, null: true
    field? :include_manager, :boolean, null: true
    field? :include_reports, :boolean, null: true
    field? :include_peers, :boolean, null: true
    field? :include_permissions, :boolean, null: true
  end

  outputs do
    field? :person, :person, null: true
  end

  def call(conn, inputs) do
    with {:ok, me} <- find_me(conn),
         {:ok, person} <- load(me, inputs[:id], inputs) do
      {:ok, %{person: Serializer.serialize(person, level: :full)}}
    end
  end

  defp load(me, id, inputs) do
    Person.get(me, id: id, company_id: me.company_id, opts: [
      preload: preload(inputs),
      after_load: after_load(inputs),
    ])
  end

   def preload(inputs) do
    Inputs.parse_includes(inputs, [
      include_manager: [:manager],
      include_reports: [:reports],
    ])
  end

  def after_load(inputs) do
    Inputs.parse_includes(inputs, [
      include_peers: &Person.preload_peers/1,
      include_permissions: &Person.load_permissions/1,
    ])
  end
end
