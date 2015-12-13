module Shared
class ApplicationController < ActionController::Base
  helper Mooc::Engine.helpers

  protected

  # concerns order is significant
  include Shared::Applications::Security
  include Shared::Applications::Flash
  include Shared::Applications::Form
  include Shared::Applications::Tab

  include Shared::Events::Log

  include Shared::Facebook::Modal
  include Shared::Slido::Flash
  include (Rails.module.classify + '::Application').constantize

  def current_ability
    @current_ability ||= Shared::Ability.new(current_user)
  end
end
end
