class UsersController < ApplicationController
  before_action :authenticate_user!

  def me
    @grants = Grant.where(user_id: current_user.id).find_each
    @my_dreams = current_user.created_camps
    # TODO: There's a possible regression here where this list may now display
    # Organization memberships as well.
    # I've written a relation which may be able to replace it cleanly in user.rb#18,
    # so you could start off with seeing if something like the following works:

    # @memberships = current_user.collaborators.distinct.pluck(:email) - Array(current_user.email)
    @memberships = current_user.created_camps.joins(:memberships).joins(:users)
                       .where('users.id != ?', current_user.id).select('users.email')

    respond_to do |format|
      format.html
      format.js
    end
  end
end
