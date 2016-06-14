require 'test_helper'

class ListsTest < ActionDispatch::IntegrationTest

  def setup
    @michael = users(:michael)
    @archer = users(:archer)
    @lana = users(:lana)
    @malory = users(:malory)
    @susan=users(:susan)

    @michael_list_1 = @michael.lists.create(name: "Michael's List 1")
    @michael_list_2 = @michael.lists.create(name: "Michael's List 2")

    @archer_list_1 = @archer.lists.create(name: "Archer's List 1")

    Listuser.create(list_id: @michael_list_1.id, selected_user_id: @archer.id )
    Listuser.create(list_id: @michael_list_1.id, selected_user_id: @lana.id )
    Listuser.create(list_id: @michael_list_1.id, selected_user_id: @malory.id )

    Listuser.create(list_id: @archer_list_1.id, selected_user_id: @michael.id )
    Listuser.create(list_id: @archer_list_1.id, selected_user_id: @lana.id )
    Listuser.create(list_id: @archer_list_1.id, selected_user_id: @malory.id )

    log_in_as(@michael)
  end

  test "user's lists can be seen at /users/:user_id/lists" do
    get user_lists_path(@michael.id)
    assert_select 'a', text: "Michael's List 1"
    assert_select 'a', text: "Michael's List 2"
  end

  test "only the selected user's lists are shown" do
    get user_lists_path(@michael.id)
    assert_select 'a', text: "Archer's List 1", count: 0
    assert_select 'a', text: "Archer's List 2", count: 0
  end

  test "users on a list can be seen at /users/:user_id/lists/:id" do
    get list_show_path(user_id: @michael.id, id: @michael_list_1.id)
    assert_select 'a', text: "Sterling Archer", count: 1
    assert_select 'a', text: "Lana Kane", count: 1
    assert_select 'a', text: "Malory Archer", count: 1
  end

  test "users from another list are not shown" do
    get list_show_path(user_id: @michael.id, id: @michael_list_1.id)
    assert_select 'a', text: "Michael Example", count: 0
  end

  test "a user sees a create list button on their list index page only" do
    get user_lists_path(@michael.id)
    assert_select 'a', text: "Create a List!", count: 1
    get user_lists_path(@archer.id)
    assert_select 'a', text: "Create a List!", count: 0
  end

  test "a user can create lists" do
    get user_lists_path(@michael.id)
    assert_select 'a', text: "Test List", count: 0
    get list_new_path(@michael.id)
    assert_select 'form input' do
      assert_select "[name=?]", "list[name]"
    end
    assert_difference "List.count", 1 do
      post list_create_path(user_id: @michael.id, list:{name: "Test List"})
    end

    assert_redirected_to user_lists_path(@michael.id)
    assert_not flash.empty?
    get user_lists_path(@michael.id)
    assert_select 'a', {count: 1, text: "Test List"}
  end

  test "a user cannot create lists for a different user" do
    get list_new_path(@michael.id)
    assert_no_difference "List.count" do
      post list_create_path(user_id: @archer.id, list:{name: "Test List"})
    end
  end

  test "a user sees delete links for their lists only" do
    get user_lists_path(@michael.id)
    assert_select 'a', {count: @michael.lists.count, text: "Delete this list"}
    # all lists can be seen by any user
    get user_lists_path(@archer.id)
    assert @archer.lists.count > 0
    assert_select 'a', {count: 0, text: "Delete this list"}
  end

  test "a user can delete lists" do
    get user_lists_path(@michael.id)
    assert_select 'a', {count: 1, text: @michael_list_1.name}
    assert_difference "List.count", -1 do
      delete list_destroy_path(user_id: @michael.id, list_id: @michael_list_1.id)
    end
    assert_select 'a', {count: 0, text: @michael_list_1.name}
  end

  test "a user cannot delete other users' lists" do
    get user_lists_path(@michael.id)
    assert_no_difference "List.count" do
      delete list_destroy_path(user_id: @archer.id, list_id: @archer_list_1.id)
    end
  end

  test "a user can add another user to their lists" do
    get user_path(@susan)
    assert_difference "Listuser.count", 1 do
      post listuser_new_path(list_id: @michael_list_1.id, user_id: @susan.id)
    end
    get list_show_path(user_id: @michael.id, id: @michael_list_1.id)
    assert_select 'a', {count: 1, text: "Susan Archer"}
  end

  test "a user can add the same person to more than one list" do
    # add to first list
    get user_path(@susan)
    assert_difference "Listuser.count", 1 do
      post listuser_new_path(list_id: @michael_list_1.id, user_id: @susan.id)
    end
    get list_show_path(user_id: @michael.id, id: @michael_list_1.id)
    assert_select 'a', {count: 1, text: "Susan Archer"}
    # add to second list
    get user_path(@susan)
    assert_difference "Listuser.count", 1 do
      post listuser_new_path(list_id: @michael_list_2.id, user_id: @susan.id)
    end
    get list_show_path(user_id: @michael.id, id: @michael_list_2.id)
    assert_select 'a', {count: 1, text: "Susan Archer"}
  end

  test "a user cannot add the same person twice to the same list" do
    get user_path(@susan)
    assert_difference "Listuser.count", 1 do
      post listuser_new_path(list_id: @michael_list_1.id, user_id: @susan.id)
    end
    get user_path(@susan)
    assert_difference "Listuser.count", 0 do
      post listuser_new_path(list_id: @michael_list_1.id, user_id: @susan.id)
    end
    get list_show_path(user_id: @michael.id, id: @michael_list_1.id)
    assert_select 'a', {count: 1, text: "Susan Archer"}
  end

  test "a user cannot add to another user's lists" do
    get user_lists_path(@michael)
    assert_difference "Listuser.count", 0 do
      post listuser_new_path(list_id: @archer_list_1.id, user_id: @susan.id)
    end
  end

  test "only the list owner sees the option to remove a person from a list" do
    get list_show_path(user_id: @michael.id, id: @michael_list_1.id)
    assert_select 'a', {count: 3, text: "Remove from this List"}
    get list_show_path(user_id: @archer.id, id: @archer_list_1.id)
    assert_select 'a', {count: 0, text: "Remove from this List"}
  end

  test "a user cannot delete from another user's lists" do
    get user_lists_path(@archer)
    listuser_id = @archer.lists[0].listusers[0].id
    assert_no_difference "Listuser.count" do
      delete listuser_delete_path(listuser_id: listuser_id)
    end
  end
end
