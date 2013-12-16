module Watchable
  extend ActiveSupport::Concern

  included do
    has_many :watchings, as: :watchable
    has_many :watchers, through: :watchings, source: :watcher

    scope :watched, lambda { joins(:watchings).uniq }
  end
end