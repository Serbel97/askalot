module Observable
  extend ActiveSupport::Concern

  included do
    after_save :update_touched_at!
  end

  def update_touched_at!
    require 'pry'; binding.pry
    question = self.to_question
    question.touched_at = self.updated_at
    question.save!
  end
end
