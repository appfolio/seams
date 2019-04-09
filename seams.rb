require 'set'
require 'mysql2'

class Seams
  SHOW_TABLES_STATEMENT = <<~SQL
    SHOW TABLES
  SQL

  FOREIGN_KEYS_STATEMENT = <<~SQL
    SELECT referenced_table_name
    FROM information_schema.key_column_usage
    WHERE TABLE_NAME = ?
      AND referenced_table_name IS NOT NULL
  SQL

  def initialize(options)
    @client = Mysql2::Client.new(options) # overrides any my.cnf
    @debug = options.has_key?(:debug)
  end

  def show_tables
    result = @client.query(SHOW_TABLES_STATEMENT)
    result.map {|e| e.values}.flatten.to_set
  end

  def find_foreign_key_constraint_references(table_name)
    statement = @client.prepare(FOREIGN_KEYS_STATEMENT)
    result = statement.execute(table_name)
    result.map {|e| e.values}.flatten.to_set
  end

  def gather(initial_set)
    initial_set = initial_set.to_set # convert Array if need be
    min_set = Set.new
    queue = Queue.new
    initial_set.each do |table_name|
      puts "Enqueue: #{table_name}" if @debug
      queue << table_name
    end
    while (queue.length > 0)
      table_name = queue.deq
      puts "Dequeue: #{table_name}" if @debug
      references = find_foreign_key_constraint_references(table_name)
      min_set << table_name
      unseen_tables = (references - min_set)
      unseen_tables.each do |unseen_table|
        puts "Enqueue: #{unseen_table}" if @debug
        queue << unseen_table
      end
    end
    min_set
  end
end
