class Relationship < ApplicationRecord
  belongs_to :user
  # follow が Follow という存在しないクラスを参照することを防ぎ、User クラスを参照するものだと明示
  belongs_to :follow, class_name: 'User'
end
