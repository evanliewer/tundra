require "controllers/api/v1/test"

class Api::V1::DemographicsControllerTest < Api::Test
  setup do
    # See `test/controllers/api/test.rb` for common set up for API tests.

    @demographic = build(:demographic, team: @team)
    @other_demographics = create_list(:demographic, 3)

    @another_demographic = create(:demographic, team: @team)

    # 🚅 super scaffolding will insert file-related logic above this line.
    @demographic.save
    @another_demographic.save

    @original_hide_things = ENV["HIDE_THINGS"]
    ENV["HIDE_THINGS"] = "false"
    Rails.application.reload_routes!
  end

  teardown do
    ENV["HIDE_THINGS"] = @original_hide_things
    Rails.application.reload_routes!
  end

  # This assertion is written in such a way that new attributes won't cause the tests to start failing, but removing
  # data we were previously providing to users _will_ break the test suite.
  def assert_proper_object_serialization(demographic_data)
    # Fetch the demographic in question and prepare to compare it's attributes.
    demographic = Demographic.find(demographic_data["id"])

    assert_equal_or_nil demographic_data['name'], demographic.name
    # 🚅 super scaffolding will insert new fields above this line.

    assert_equal demographic_data["team_id"], demographic.team_id
  end

  test "index" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/teams/#{@team.id}/demographics", params: {access_token: access_token}
    assert_response :success

    # Make sure it's returning our resources.
    demographic_ids_returned = response.parsed_body.map { |demographic| demographic["id"] }
    assert_includes(demographic_ids_returned, @demographic.id)

    # But not returning other people's resources.
    assert_not_includes(demographic_ids_returned, @other_demographics[0].id)

    # And that the object structure is correct.
    assert_proper_object_serialization response.parsed_body.first
  end

  test "show" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/demographics/#{@demographic.id}", params: {access_token: access_token}
    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    get "/api/v1/demographics/#{@demographic.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "create" do
    # Use the serializer to generate a payload, but strip some attributes out.
    params = {access_token: access_token}
    demographic_data = JSON.parse(build(:demographic, team: nil).api_attributes.to_json)
    demographic_data.except!("id", "team_id", "created_at", "updated_at")
    params[:demographic] = demographic_data

    post "/api/v1/teams/#{@team.id}/demographics", params: params
    assert_response :success

    # # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    post "/api/v1/teams/#{@team.id}/demographics",
      params: params.merge({access_token: another_access_token})
    assert_response :not_found
  end

  test "update" do
    # Post an attribute update ensure nothing is seriously broken.
    put "/api/v1/demographics/#{@demographic.id}", params: {
      access_token: access_token,
      demographic: {
        name: 'Alternative String Value',
        # 🚅 super scaffolding will also insert new fields above this line.
      }
    }

    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # But we have to manually assert the value was properly updated.
    @demographic.reload
    assert_equal @demographic.name, 'Alternative String Value'
    # 🚅 super scaffolding will additionally insert new fields above this line.

    # Also ensure we can't do that same action as another user.
    put "/api/v1/demographics/#{@demographic.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "destroy" do
    # Delete and ensure it actually went away.
    assert_difference("Demographic.count", -1) do
      delete "/api/v1/demographics/#{@demographic.id}", params: {access_token: access_token}
      assert_response :success
    end

    # Also ensure we can't do that same action as another user.
    delete "/api/v1/demographics/#{@another_demographic.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end
end
