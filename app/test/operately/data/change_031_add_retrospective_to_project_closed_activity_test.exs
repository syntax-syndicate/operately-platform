defmodule Operately.Data.Change031AddRetrospectiveToProjectClosedActivityTest do
  use Operately.DataCase

  alias Operately.Repo

  import Ecto.Query, only: [from: 2]
  import Operately.ProjectsFixtures

  setup ctx do
    ctx
    |> Factory.setup()
    |> Factory.add_space(:space)
  end

  test "migration doesn't delete current data in activity content", ctx do
    projects = Enum.map(1..3, fn _ ->
      project_fixture(%{company_id: ctx.company.id, creator_id: ctx.creator.id, group_id: ctx.space.id})
    end)

    projects = Enum.map(projects, fn p ->
      attrs = %{
        content: %{},
        success_status: "achieved",
        send_to_everyone: false,
        subscription_parent_type: :project_retrospective,
        subscriber_ids: [],
      }
      {:ok, _} = Operately.Operations.ProjectClosed.run(ctx.creator, p, attrs)

      Repo.preload(p, :retrospective)
    end)

    Operately.Data.Change031AddRetrospectiveToProjectClosedActivity.run()

    fetch_activities()
    |> Enum.each(fn activity ->
      project = Enum.find(projects, &(&1.id == activity.content["project_id"]))

      assert activity.content["company_id"] == ctx.company.id
      assert activity.content["space_id"] == ctx.space.id
      assert activity.content["retrospective_id"] == project.retrospective.id
    end)
  end

  #
  # Helpers
  #

  defp fetch_activities() do
    from(a in Operately.Activities.Activity,
      where: a.action == "project_closed"
    )
    |> Repo.all()
  end
end
