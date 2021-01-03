class Micropost < ApplicationRecord
  # User と Micropost の一対多を表現
  belongs_to :user
  
  validates :content, presence: true, length: { maximum: 255 }
  
  has_many :favorites
  has_many :liked, through: :favorites, source: :user
end
