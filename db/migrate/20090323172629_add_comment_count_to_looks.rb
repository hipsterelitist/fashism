class AddCommentCountToLooks < ActiveRecord::Migration
  def self.up
    add_column :looks, :comment_count, :int, :default => 0
    add_index :looks, :comment_count
    @looks = Look.find(:all)
    for look in @looks
      look.comment_count = look.comments.count
      look.save
    end
  end

  def self.down
    remove_index :looks, :comment_count
    remove_column :looks, :comment_count
  end
end
