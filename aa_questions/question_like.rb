require_relative 'model'

class QuestionLike < Model
  def self.database_name
    'question_likes'
  end
  
  def self.likers_for_question_id(question_id)
    user_hashes = QuestionsDB.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      JOIN 
        question_likes ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL
    user_hashes.map do |user_hash|
      User.new(user_hash)
    end
  end
  
  def self.num_likes_for_question_id(question_id)
    arr = QuestionsDB.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*) AS count
      FROM
        users
      JOIN 
        question_likes ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL
    
    arr.first['count']
  end
  
  def self.liked_questions_for_user_id(user_id)
    question_hashes = QuestionsDB.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN 
        question_likes ON questions.id = question_likes.question_id
      WHERE
        question_likes.user_id = ?
    SQL
    question_hashes.map do |question_hash|
      Question.new(question_hash)
    end
  end
  
  def attributes
    ['user_id', 'question_id']
  end
end