require 'test_helper'

class DirectmessagesTest < ActionDispatch::IntegrationTest

  def setup
    @michael = users(:michael)
    @archer = users(:archer)
    @lana = users(:lana)
    @malory = users(:malory)
    @susan=users(:susan)

    Directmessage.create(sender_id: @michael.id,
                         receiver_id: @archer.id, content: "M->A1...")
    Directmessage.create(sender_id: @michael.id,
                         receiver_id: @archer.id, content: "M->A2...")
    Directmessage.create(sender_id: @michael.id,
                         receiver_id: @archer.id, content: "M->A3...")

    Directmessage.create(sender_id: @archer.id,
                         receiver_id: @michael.id, content: "A->M1...")
    Directmessage.create(sender_id: @archer.id,
                         receiver_id: @michael.id, content: "A->M2...")
    Directmessage.create(sender_id: @archer.id,
                         receiver_id: @michael.id, content: "A->M3...")

    @msg_archer_to_susuan = Directmessage.create(sender_id: @archer.id,
                            receiver_id: @susan.id, content: "A->S1...")



  end

  test "a user sees the DM link on another user's show page" do
    log_in_as(@michael)
    get user_path(@archer)
    assert_select 'a', {count: 1, text: "DM Me!"}
  end

  test "a user does not see the DM link on their own page" do
    log_in_as(@michael)
    get user_path(@michael)
    assert_select 'a', {count: 0, text: "DM Me!"}
  end

  test "following the DM route opens the DM creation form" do
    log_in_as(@michael)
    get message_new_path(sender_id: @michael.id, receiver_id: @archer.id)
    assert_select 'form input' do
      assert_select "[name=?]", "directmessage[content]"
    end
  end

  test "a user can send a DM to another user" do
    log_in_as(@michael)
    get message_new_path(sender_id: @michael.id, receiver_id: @archer.id)
    assert_difference "Directmessage.count", 1 do
      post message_create_path(directmessage: {sender_id: @michael.id, receiver_id: @archer.id, content: "Super Test Message"})
    end
    log_out_test
    log_in_as(@archer)
    get messages_received_path(user_id: @archer.id)
    assert_select 'a', {count: 1, text: "Super..."}
  end

  test "a user can view messages they have received but not messages received by others" do
    log_in_as(@michael)
    get messages_received_url(user_id: @michael.id)
      assert_select 'a', {count: 1, text: "A->M1..."}
      assert_select 'a', {count: 1, text: "A->M2..."}
      assert_select 'a', {count: 1, text: "A->M3..."}
      assert_select 'a', {count: 0, text: "M->A1..."}
      assert_select 'a', {count: 0, text: "M->A2..."}
      assert_select 'a', {count: 0, text: "M->A3..."}
  end

  test "a user can view messages they have sent but not messages sent by others" do
    log_in_as(@michael)
    get messages_sent_url(user_id: @michael.id)
    assert_select 'a', {count: 1, text: "M->A1..."}
    assert_select 'a', {count: 1, text: "M->A2..."}
    assert_select 'a', {count: 1, text: "M->A3..."}
    assert_select 'a', {count: 0, text: "A->M1..."}
    assert_select 'a', {count: 0, text: "A->M2..."}
    assert_select 'a', {count: 0, text: "A->M3..."}
  end

  test "a user cannot view messages they did not send or receive" do
    log_in_as(@michael)
    get message_show_url(user_id: @michael.id, message_id: @msg_archer_to_susuan.id)
    assert_select 'a', {count: 0, text: "A->S1..."}
  end

  # test "a user can select an individual message to view the full message" do
  #   log_in_as(@michael)
  #   get message_show_url(user_id: @michael.id, )
  # end





end
