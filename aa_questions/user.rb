require_relative 'model'

class User < Model
  def self.database_name
    'users'
  end
  
  def self.find_by_name(fname, lname)
    user_hash = QuestionsDB.instance.execute(<<-SQL, fname, lname).first
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    User.new(user_hash)
  end
  
  def authored_questions
    Question.find_by_author_id(@id)
  end
  
  def authored_replies
    Reply.find_by_author_id(@id)
  end
  
  def attributes
    ['fname', 'lname']
  end
  
  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end
end
