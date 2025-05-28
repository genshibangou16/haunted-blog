# frozen_string_literal: true

class Blog < ApplicationRecord
  belongs_to :user
  has_many :likings, dependent: :destroy
  has_many :liking_users, class_name: 'User', source: :user, through: :likings

  validates :title, :content, presence: true
  validate :eyecatch_requires_premium

  scope :published, -> { where('secret = FALSE') }

  scope :visible_to, lambda { |user|
    if user
      where(secret: false).or(where(user_id: user.id))
    else
      where(secret: false)
    end
  }

  scope :search, lambda { |term|
    term &&= ActiveRecord::Base.sanitize_sql_like(term)
    where('title LIKE :keyword OR content LIKE :keyword', keyword: "%#{term}%")
  }

  scope :default_order, -> { order(id: :desc) }

  def owned_by?(target_user)
    user == target_user
  end

  private

  def eyecatch_requires_premium
    return unless random_eyecatch && !user.premium

    errors.add(:random_eyecatch, 'Premium users can only use random eyecatch')
  end
end
