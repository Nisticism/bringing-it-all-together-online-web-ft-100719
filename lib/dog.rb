class Dog 

  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(id: nil, name:, breed:)
    
    @name = name
    @breed = breed 
    @id = id
    
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
    dog = Dog.new(name: name, breed: breed)
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
      new_dog = Dog.find_by_name(self.name)
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
    new_dog = self.new(id: result[0], name: result[1], breed: result[2])
    new_dog
  end
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    new_dog = self.new(id: result[0], name: result[1], breed: result[2])
    new_dog
  end
  
  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    result = DB[:conn].execute(sql, name, breed)[0]
    if !result.empty?
      new_dog = self.new(id: result[0], name: result[1], breed: result[2])
      return new_dog
    else 
      new_dog = self.create(name: name, breed: breed)
      return new_dog
    end
    
  end
    

end