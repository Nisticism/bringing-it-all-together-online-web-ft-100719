class Dog 

  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(id=nil, name:, breed:)
    
    @name = name
    @id = id
    @breed = breed 
    
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"

    DB[:conn].execute(sql)
  end
  
  def self.create(name:, breed:)
    dog = Dog.new(name, breed)
    dog.save
    dog
  end
  
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
 
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT MAX(id) FROM dogs")[0]
      new_dog = self.find_by_name(self.name)
      new_dog
    end
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    result = DB[:conn].execute(sql, name)[0]
    new_dog = Dog.new(result[0], result[1], result[2])
    new_dog
  end
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    new_dog = Dog.new(result[0], result[1], result[2])
    new_dog
  end
  
  def self.new_from_db(row)
    dog = self.new(row[0], name=row[1], breed=row[2])
    # dog.id = row[0]
    # dog.name = row[1]
    # dog.breed = row[2]
    dog
  end
    

end