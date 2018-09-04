require_relative 'model'

class Question < Model
  def self.database_name
    'questions'
  end
  
  def self.find_by_author_id(author_id)
    question_hashes = QuestionsDB.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    question_hashes.map do |question_hash|
      Question.new(question_hash)
    end
  end
  
  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end
  
  def likers
    QuestionLike.likers_for_question_id(@id)
  end
  
  def most_liked(n)
    QuestionLike.most_liked_questions(n)
  end
  
  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end
  
  def author
    User.find_by_id(@author_id)
  end
  
  def replies
    Reply.find_by_question_id(@id)
  end
  
  def attributes
    ['title', 'body', 'author_id']
  end
  
  def followers
    QuestionFollow.followers_for_question_id(@id)
  end
end