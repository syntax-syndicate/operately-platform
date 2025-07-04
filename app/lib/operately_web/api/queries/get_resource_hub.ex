defmodule OperatelyWeb.Api.Queries.GetResourceHub do
  use TurboConnect.Query
  use OperatelyWeb.Api.Helpers

  alias Operately.ResourceHubs.{ResourceHub, Node}

  inputs do
    field? :id, :id, null: true
    field? :include_space, :boolean, null: true
    field? :include_nodes, :boolean, null: true
    field? :include_potential_subscribers, :boolean, null: true
    field? :include_permissions, :boolean, null: true
  end

  outputs do
    field? :resource_hub, :resource_hub, null: true
  end

  def call(conn, inputs) do
    Action.new()
    |> run(:me, fn -> find_me(conn) end)
    |> run(:hub, fn ctx -> load(ctx, inputs) end)
    |> run(:serialized, fn ctx -> {:ok, %{resource_hub: Serializer.serialize(ctx.hub)}} end)
    |> respond()
  end

  defp respond(result) do
    case result do
      {:ok, ctx} -> {:ok, ctx.serialized}
      {:error, :id, _} -> {:error, :bad_request}
      {:error, :hub, _} -> {:error, :not_found}
      _ -> {:error, :internal_server_error}
    end
  end

  defp load(ctx, inputs) do
    ResourceHub.get(ctx.me, id: inputs.id, opts: [
      preload: preload(inputs),
      after_load: after_load(inputs),
    ])
  end

  defp preload(inputs) do
    q = from(n in Node, where: is_nil(n.parent_folder_id)) |> Node.preload_content()

    Inputs.parse_includes(inputs, [
      include_space: :space,
      include_nodes: [nodes: q],
    ])
  end

  defp after_load(inputs) do
    Inputs.parse_includes(inputs, [
      include_potential_subscribers: &ResourceHub.load_potential_subscribers/1,
      include_permissions: &ResourceHub.set_permissions/1,
    ])
  end
end
