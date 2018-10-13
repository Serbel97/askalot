module Mooc
class UserMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  default from: ::Shared::Configuration.mailer.alias

  helper Shared::ActivitiesHelper
  helper Shared::AnswersHelper
  helper Shared::ApplicationHelper
  helper Shared::BootstrapHelper
  helper Shared::CategoriesHelper
  helper Shared::CommentsHelper
  helper Shared::DeletablesHelper
  helper Shared::EvaluationsHelper
  helper Shared::FavoritesHelper
  helper Shared::FollowingsHelper
  helper Shared::LabelingsHelper
  helper Shared::NotificationsHelper
  helper Shared::QuestionsHelper
  helper Shared::ResourcesHelper
  helper Shared::TagsHelper
  helper Shared::TextHelper
  helper Shared::UsersHelper
  helper Shared::VotesHelper
  helper Shared::WatchingsHelper

  layout 'mooc/mailer'

  def notifications(user)
    @user                      = user
    @from                      = Shared::Notifications::Utility.notifications_since(user)
    @contexts                  = @user.contexts
    @contexts_by_id            = Hash[@contexts.map { |c| [c.id, c] }]
    @notifications_in_contexts = @contexts.map do |context|
      @user.notifications.unread.in_context(context.id).where('created_at >= ?', Shared::Notifications::Utility.notifications_since(user))
    end
    @notifications_in_contexts = @notifications_in_contexts.select { |n| n.count > 0 } unless @notifications_in_contexts.nil?

    return if @notifications_in_contexts.empty?
    return unless Shared::Notifications::Utility.send_notification_email?(user)

    mail to: @user.email, subject: t('user_mailer.subject'), content_type: 'text/html'

    Shared::Notifications::Utility.update_last_notification_sent_at(user)
  end
end
end
