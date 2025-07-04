defmodule Operately.Features.ProjectCreationTest do
  use Operately.FeatureCase
  alias Operately.Support.Features.ProjectCreationSteps, as: Steps

  setup ctx, do: Steps.setup(ctx)

  @tag login_as: :champion
  feature "add project", ctx do
    params = %{name: "Website Redesign", space: ctx.group, creator: ctx.champion, champion: ctx.champion, reviewer: ctx.reviewer}

    ctx
    |> Steps.start_adding_project()
    |> Steps.submit_project_form(params)
    |> Steps.assert_project_created(params)
    |> Steps.assert_project_created_email_sent(params)
    |> Steps.assert_project_created_notification_sent(params)
    |> Steps.assert_project_created_feed()
  end

  @tag login_as: :reviewer
  feature "add project and assign someone else as champion, myself as reviewer", ctx do
    params = %{name: "Website Redesign", space: ctx.group, creator: ctx.reviewer, champion: ctx.champion, reviewer: ctx.reviewer}

    ctx
    |> Steps.start_adding_project()
    |> Steps.submit_project_form(params)
    |> Steps.assert_project_created(params)
    |> Steps.assert_project_created_email_sent(params)
    |> Steps.assert_project_created_notification_sent(params)
    |> Steps.assert_project_created_feed(ctx.reviewer)
  end

  @tag login_as: :non_contributor
  feature "add project for someone else, I'm not a contributor", ctx do
    params = %{name: "Website Redesign", space: ctx.group, creator: ctx.non_contributor, champion: ctx.champion, reviewer: ctx.reviewer}

    ctx
    |> Steps.start_adding_project()
    |> Steps.submit_project_form(params)
    |> Steps.assert_project_created(params)
    |> Steps.assert_project_created_email_sent(params)
    |> Steps.assert_project_created_notification_sent(params)
    |> Steps.assert_project_created_feed(ctx.non_contributor)
  end


  @tag login_as: :project_manager
  feature "add project for someone else, I'm a contributor", ctx do
    params = %{name: "Website Redesign", space: ctx.group, creator: ctx.project_manager, champion: ctx.champion, reviewer: ctx.reviewer, add_creator_as_contributor: true}

    ctx
    |> Steps.start_adding_project()
    |> Steps.submit_project_form(params)
    |> Steps.assert_project_created(params)
    |> Steps.assert_project_created_email_sent(params)
    |> Steps.assert_project_created_notification_sent(params)
    |> Steps.assert_project_created_feed(ctx.project_manager)
  end

  @tag login_as: :champion
  feature "select a parent goal while adding a project", ctx do
    params = %{
      name: "Website Redesign",
      space: ctx.group,
      creator: ctx.champion,
      champion: ctx.champion,
      reviewer: ctx.reviewer,
      goal: ctx.goal
    }

    ctx
    |> Steps.start_adding_project()
    |> Steps.submit_project_form(params)
    |> Steps.assert_project_created(params)
    |> Steps.assert_project_created_email_sent(params)
    |> Steps.assert_project_created_notification_sent(params)
    |> Steps.assert_project_created_feed()
  end

  #
  # TODO: the current implementation of the test is no longer working.
  #       A new implementation is needed.
  #
  # @tag login_as: :champion
  # feature "operately prefills the reviewer with the champion's manager", ctx do
  #   params = %{name: "Website Redesign", space: ctx.group, creator: ctx.champion, champion: ctx.champion}

  #   ctx
  #   |> Steps.given_that_champion_has_a_manager()
  #   |> Steps.start_adding_project()
  #   |> Steps.submit_project_form(params)
  #   |> Steps.assert_project_created(params)
  #   |> Steps.assert_project_created_feed()
  #   |> Steps.assert_reviewer_is_champions_manager(params)
  # end

  @tag login_as: :champion
  feature "champion == reviewer is not allowed", ctx do
    params = %{name: "Website Redesign", space: ctx.group, creator: ctx.champion, champion: ctx.champion, reviewer: ctx.champion}

    ctx
    |> Steps.start_adding_project()
    |> Steps.submit_project_form(params)
    |> Steps.assert_validation_error("Can't be the same as the champion")
  end

  @tag login_as: :champion
  feature "creating a project without space is not allowed", ctx do
    params = %{name: "Website Redesign", creator: ctx.champion, champion: ctx.champion}

    ctx
    |> Steps.start_adding_project_from_lobby()
    |> Steps.submit_project_form(params)
    |> Steps.assert_validation_error("Space is required")
  end

  @tag login_as: :champion
  feature "creating a project with no reviewer", ctx do
    params = %{name: "Website Redesign", space: ctx.group, creator: ctx.champion, champion: ctx.champion}

    ctx
    |> Steps.start_adding_project()
    |> Steps.submit_project_form(params)
    |> Steps.assert_project_created(params)
    |> Steps.assert_no_reviewer_calluout_showing()
    |> Steps.assert_review_placeholder_showing()
    |> Steps.follow_add_reviewer_link_and_add_reviewer()
    |> Steps.assert_project_has_reviewer(params)
    |> Steps.assert_project_created_feed()
  end

  @tag login_as: :champion
  feature "creating a project in a confidential space", ctx do
    params = %{name: "Website Redesign", creator: ctx.champion, reviewer: ctx.reviewer, champion: ctx.champion}

    ctx
    |> Steps.given_that_space_is_hidden_from_company_members()
    |> Steps.start_adding_project()
    |> Steps.select_space(ctx.group.name)
    |> Steps.assert_form_offers_space_wide_access_level()
    |> Steps.submit_project_form(params)
    |> Steps.assert_project_created(params)
    |> Steps.assert_company_members_cant_see_project(params)
    |> Steps.assert_space_members_can_see_project(params)
    |> Steps.assert_project_created_feed()
  end

  @tag login_as: :champion
  feature "creating an invite-only project in a confidential space", ctx do
    params = %{name: "Website Redesign", creator: ctx.champion, reviewer: ctx.reviewer, champion: ctx.champion}

    ctx
    |> Steps.given_that_space_is_hidden_from_company_members()
    |> Steps.start_adding_project()
    |> Steps.select_space(ctx.group.name)
    |> Steps.assert_form_offers_space_wide_access_level()
    |> Steps.change_project_access_level_to_invite_only()
    |> Steps.submit_project_form(params)
    |> Steps.assert_project_created(params)
    |> Steps.assert_company_members_cant_see_project(params)
    |> Steps.assert_space_members_cant_see_project(params)
    |> Steps.assert_project_created_feed()
  end
end
