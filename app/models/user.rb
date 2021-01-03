class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  # User から Micropost をみたとき、複数存在
  has_many :microposts
  
  # 『多対多の図』の右半分にいる「自分がフォローしているUser」への参照
  has_many :relationships
  # through: :relationships という記述により、has_many: relationships の結果を中間テーブルとして指定
  # その中間テーブルのカラムの中でどれを参照先の id とすべきかを source: :follow で、選択
  has_many :followings, through: :relationships, source: :follow
  # 『多対多の図』の左半分にいるUserからフォローされている」という関係への参照（自分をフォローしているUserへの参照）
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  # through: には逆方向の :reverses_of_relationship を指定
  # relationships 中間テーブルの user_id のほうが取得したい User だと指定
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  has_many :favorites
  has_many :likes, through: :favorites, source: :micropost
  
  def follow(other_user)
    # unless self == other_user によって、フォローしようとしている other_user が自分自身ではないかを検証
    unless self == other_user
      # self には user.follow(other) を実行したとき user が代入される
      # 見つかれば Relationshipモデル（クラス）のインスタンスを返し、見つからなければ self.relationships.create(follow_id: other_user.id) としてフォロー関係を保存(create = build + save)
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
  
  def favorite(micropost)
    self.favorites.find_or_create_by(micropost_id: micropost.id)
  end

  def unfavorite(micropost)
    favorite = self.favorites.find_by(micropost_id: micropost.id)
    favorite.destroy if favorite
  end
  
  def favorite?(micropost)
    self.likes.include?(micropost)
  end
end
