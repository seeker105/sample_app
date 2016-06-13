require 'test_helper'

class ListTest < ActiveSupport::TestCase

  def setup
    @michael = users(:michael)
    @archer = users(:archer)
    @lana = users(:lana)
    @malory = users(:malory)
    @list = @michael.lists.create(name: "Michael's List 1")


      Listuser.create(list_id: @list.id, selected_user_id: @archer.id )
      Listuser.create(list_id: @list.id, selected_user_id: @lana.id )
      Listuser.create(list_id: @list.id, selected_user_id: @malory.id )


    # byebug
  end

  test "a list has a name" do
    assert_equal "Michael's List 1", @list.name
  end

  test "a list has an owner" do
    # byebug
    assert_equal @michael, @list.owner
  end

  test "a list has many other users" do
    assert_equal 3, @list.listusers.count

    assert_equal @archer, @list.listusers[0].selected_user
    assert_equal @lana, @list.listusers[1].selected_user
    assert_equal @malory, @list.listusers[2].selected_user
  end





end
