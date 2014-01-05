require 'test_helper'

class ReviewsControllerTest < ActionController::TestCase
  test "can get reviews by anime id" do
    get :index, format: :json, anime_id: 'sword-art-online'
    assert_response 200
    assert JSON.parse(@response.body)["reviews"].any? {|x| x["id"] == reviews(:one).id }
  end

  test "can get reviews by user id" do
    get :index, format: :json, user_id: 'vikhyat'
    assert_response 200
    assert JSON.parse(@response.body)["reviews"].any? {|x| x["id"] == reviews(:one).id }
  end
end
