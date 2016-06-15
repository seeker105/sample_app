require 'test_helper'

class DirectmessagesTest < ActionDispatch::IntegrationTest

  def setup
    @michael = users(:michael)
    @archer = users(:archer)
    @lana = users(:lana)
    @malory = users(:malory)
    @susan=users(:susan)

    log_in_as(@michael)
  end

  test "a user sees the DM link on another user's show page" do
    get user_path(@archer)
    assert_select 'a', {count: 1, text: "DM Me!"}
  end

  test "a user does not see the DM link on their own page" do
    get user_path(@michael)
    assert_select 'a', {count: 0, text: "DM Me!"}
  end

  test "following the DM route opens the DM creation form" do
    get message_new_path(sender_id: @michael.id, receiver_id: @archer.id)
    assert_select 'form input' do
      assert_select "[name=?]", "directmessage[content]"
    end
  end

  test "a user can send a DM to another user" do
    get message_new_path(sender_id: @michael.id, receiver_id: @archer.id)
    assert_difference "Directmessage.count", 1 do
      post message_create_path(sender_id: @michael.id, receiver_id: @archer.id, content: "Super Test Message")
    end
    log_out_test
    log_in_as(@archer)
    get messages_received_path(@archer)
    assert_select 'a', {count: 1, text: "Super..."}
  end

  # test "a user can view messages they have received" do
  #   get messages_received_path(@michael)
  #   assert_select 'a', {count: 1, text: "A->M1"}
  #   assert_select 'a', {count: 1, text: "A->M2"}
  #   assert_select 'a', {count: 1, text: "A->M3"}
  # end
  #
  # test "a user can view messages they have sent" do
  #   get messages_sent_path(@michael)
  #   assert_select 'a', {count: 1, text: "M->A1"}
  #   assert_select 'a', {count: 1, text: "M->A2"}
  #   assert_select 'a', {count: 1, text: "M->A3"}
  # end
  #
  # test "a user cannot view messages they did not send or receive to another user" do
  # end
  #
  # test "a user can select an individual message to view the full message" do
  #
  # end





end
