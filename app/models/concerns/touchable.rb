module Touchable
  extend ActiveSupport::Concern

  included do
    after_save :update_touched_at! if self != Question
  end

  def update_touched_at!
    return if self.is_a? Question

    attributes_blacklist = [:favorites_count, :votes_count, :views_count, :votes_difference, :votes_lb_wsci_bp]

    question            = self.to_question
    question.touched_at = self.updated_at unless (self.changed.map(&:to_sym) & attributes_blacklist).any?

    question.save!
  end

  private

  def attribute_changed?(column)
    attributes_blacklist = [:favorites_count, :votes_count, :views_count, :votes_difference, :votes_lb_wsci_bp]

    return true if column.to_sym == :touched_at && (self.changed.map(&:to_sym) & attributes_blacklist).any?

    super
  end
end
