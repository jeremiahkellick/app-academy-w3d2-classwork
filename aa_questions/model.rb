require_relative 'questions_db'

class Model
  attr_accessor :id
  
  def initialize(options)
    @id = options['id']
    attributes.each do |attribute|
      self.instance_variable_set("@#{attribute}", options[attribute])
      self.class.send(:attr_accessor, attribute)
    end
  end
  
  def attributes
    return []
  end
  
  def self.database_name
    raise NotImplementedError
  end
  
  def create
    raise "#{self} already in database" if @id
    QuestionsDB.instance.execute(<<-SQL, *attributes.map { |attribute| self.send(attribute) })
      INSERT INTO
        #{self.class.database_name} (#{attributes.join(", ")})
      VALUES
        (#{(["?"] * attributes.length).join(", ")})
    SQL
    @id = QuestionsDB.instance.last_insert_row_id
  end
  
  def update
    raise "#{self} not in database" unless @id
    QuestionsDB.instance.execute(<<-SQL, *attributes.map { |attribute| self.send(attribute) }, @id)
      UPDATE
        #{self.class.database_name}
      SET
        #{attributes.join(" = ?, ")} = ?
      WHERE
        id = ?
    SQL
  end
  
  def save
    @id ? update : create
  end
  
  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM #{self.database_name}")
    data.map { |datum| self.new(datum) }
  end
  
  def self.find_by_id(id)
    model_hash = QuestionsDB.instance.execute(<<-SQL, id).first
      SELECT
        *
      FROM
        #{database_name}
      WHERE
        id = ?  
    SQL
    
    self.new(model_hash)
  end
  
  def self.where(options)
    if options.is_a?(String)
      model_hashes = QuestionsDB.instance.execute(<<-SQL)
        SELECT
          *
        FROM
          #{database_name}
        WHERE
          #{options}
      SQL
    else
      model_hashes = QuestionsDB.instance.execute(<<-SQL, *options.values)
        SELECT
          *
        FROM
          #{database_name}
        WHERE
          #{options.keys.map { |attribute| "#{attribute} = ?" }.join(" AND ")}
      SQL
    end
    model_hashes.map { |model_hash| self.new(model_hash) }
  end
  
  def self.find_by(options)
    model_hash = QuestionsDB.instance.execute(<<-SQL, *options.values).first
      SELECT
        *
      FROM
        #{database_name}
      WHERE
        #{options.keys.map { |attribute| "#{attribute} = ?" }.join(" AND ")}
    SQL
    
    self.new(model_hash)
  end
end
