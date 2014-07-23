module ActivityLogger

  def add_activities(options = {})
    user = options[:user]
    include_user = options[:include_users]
    activity = options[:activity] ||
                Activity.create!(:item => options[:item], :user => user)
    user_ids = other_users(user, activity, include_user)
    do_feed_insert(user_ids, activity.id) unless user_ids.empty?
  end
  
  def other_users(user, activity, include_user)
    all = user.followers.map(&:id)
    all.push(user.id) if include_user
    all - have_activity(all, activity)
  end
  
  
  # Return the ids of users who already have the given activity.
  # The results of the query are Feed objects with only a user_id
  # attribute (due to the "DISTINCT person_id" clause), which is extracted
  # using map(&:person_id).
  #Modelled after inoshi
  
  def have_activity(users, activity)
    Feed.find(:all, :select => "DISTINCT user_id",
                    :conditions => ["user_id IN (?) AND activity_id = ?",
                                    users, activity]).map(&:user_id)    
  end
  
  def do_feed_insert(user_ids, activity_id)
    sql = %(INSERT INTO feeds (user_id, activity_id) 
            VALUES #{values(user_ids, activity_id)})
    ActiveRecord::Base.connection.execute(sql)
  end
  
  # Return the SQL values string needed for the SQL VALUES clause.
  # Arguments: an array of ids and a common value to be inserted for each.
  # E.g., values([1, 3, 4], 17) returns "(1, 17), (3, 17), (4, 17)"
  def values(ids, common_value)
    common_values = [common_value] * ids.length
    convert_to_sql(ids.zip(common_values))
  end

  # Convert an array of values into an SQL string.
  # For example, [[1, 2], [3, 4]] becomes "(1,2), (3, 4)".
  # This does no escaping since it currently only needs to work with ints.
  def convert_to_sql(array_of_values)
    array_of_values.inspect[1...-1].gsub('[', '(').gsub(']', ')')
  end
  
end