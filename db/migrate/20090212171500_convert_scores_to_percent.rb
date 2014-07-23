class ConvertScoresToPercent < ActiveRecord::Migration
  def self.up
    @looks = Look.find(:all, :conditions => "score > 0")
    @looks.each do |look|
      look.score = ((look.score/5)*100)
      look.save!
    end
  end

  def self.down
    @looks = Look.find(:all, :conditions => "score > 0")
    @looks.each do |look|
      look.score = ((look.score/100)*5)
      look.save!
    end
  end
end
