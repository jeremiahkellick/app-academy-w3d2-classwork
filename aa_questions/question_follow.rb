require_relative 'model'

class QuestionFollow < Model
  def self.database_name
    'question_follows'
  end
  
  def self.followers_for_question_id(question_id)
    user_hashes = QuestionsDB.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      JOIN 
        question_follows ON users.id = question_follows.user_id
      WHERE
        question_follows.question_id = ?
    SQL
    user_hashes.map do |user_hash|
      User.new(user_hash)
    end
  end
  
  def self.followed_questions_for_user_id(user_id)
    question_hashes = QuestionsDB.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN 
        question_follows ON questions.id = question_follows.question_id
      WHERE
        question_follows.user_id = ?
    SQL
    question_hashes.map do |question_hash|
      Question.new(question_hash)
    end
  end
  
  def self.most_followed_questions(n)
    Question.all.sort_by do |question|
      question.followers.length
    end.reverse[0...n]
  end
  
  def attributes
    ['user_id', 'question_id']
  end
end