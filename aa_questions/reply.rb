require_relative 'model'

class Reply < Model
  def self.database_name
    'replies'
  end
  
  def self.find_by_author_id(author_id)
    reply_hashes = QuestionsDB.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        replies
      WHERE
        author_id = ?
    SQL
    reply_hashes.map do |reply_hash|
      Reply.new(reply_hash)
    end
  end
  
  def self.find_by_question_id(question_id)
    reply_hashes = QuestionsDB.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    reply_hashes.map do |reply_hash|
      Reply.new(reply_hash)
    end
  end
  
  def author
    User.find_by_id(@author_id)
  end
  
  def question
    Question.find_by_id(@question_id)
  end
  
  def parent_reply
    Reply.find_by_id(@parent_reply_id)
  end
  
  def child_replies
    reply_hashes = QuestionsDB.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply_id = ?
    SQL
    reply_hashes.map do |reply_hash|
      Reply.new(reply_hash)
    end
  end
  
  def attributes
    ['question_id', 'parent_reply_id', 'author_id', 'body']
  end
end
