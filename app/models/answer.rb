class Answer < ActiveRecord::Base
  belongs_to :author, class_name: :User
  belongs_to :question

  has_many :labelings
  has_many :labels, through: :labelings

  has_many :watchings, as: :watchable

  validates :text, presence: true
end