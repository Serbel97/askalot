class Comment < ActiveRecord::Base
  include Deletable
  include Editable
  include Touchable

  belongs_to :author, class_name: :User, counter_cache: true
  belongs_to :commentable, -> { deleted_or_not }, polymorphic: true, counter_cache: true

  has_many :revisions, class_name: :CommentRevision, dependent: :destroy

  validates :text, presence: true

  scope :by,  lambda { |user| where(author: user) }
  scope :for, lambda { |model| where(commentable_type: model.to_s.classify) }

  def to_question
    self.commentable.to_question
  end
end
