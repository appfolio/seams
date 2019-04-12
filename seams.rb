require 'set'
require 'mysql2'

class Seams
  LIST_TABLES_STATEMENT = <<-SQL
    SELECT table_name
    FROM information_schema.tables
    WHERE table_type = 'BASE TABLE'
    AND table_schema = ?;
  SQL

  REFERENCED_TABLES_STATEMENT = <<-SQL
    SELECT referenced_table_name
    FROM information_schema.key_column_usage
    WHERE table_schema = ?
      AND table_name = ?
      AND referenced_table_name IS NOT NULL
  SQL

  REFERENCING_TABLES_STATEMENT = <<-SQL
    SELECT table_name
    FROM information_schema.key_column_usage
    WHERE table_schema = ?
      AND table_name IS NOT NULL
      AND referenced_table_name = ?
  SQL

  def initialize(options)
    @debug = options.delete(:debug)
    @client = Mysql2::Client.new(options) # overrides any my.cnf
    @database = @client.query_options[:database]
  end

  def list_tables
    statement = @client.prepare(LIST_TABLES_STATEMENT)
    result = statement.execute(@database)
    result.map {|e| e.values}.flatten.to_set
  end

  def find_foreign_key_constraint_references(table_name, sql_statement)
    statement = @client.prepare(sql_statement)
    result = statement.execute(@database, table_name)
    result.map {|e| e.values}.flatten.to_set
  end

  # finds the minimum set that includes the initial set
  def find(initial_set)
    initial_set = initial_set.to_set # convert Array if need be
    min_set = SortedSet.new
    queue = Queue.new
    queue_set = SortedSet.new
    initial_set.each do |table_name|
      puts "Add to initial_set: #{table_name}" if @debug
      queue << table_name
      queue_set << table_name
    end
    while (queue.length > 0)
      table_name = queue.deq
      queue_set.delete(table_name)
      puts "Add to min_set: #{table_name}" if @debug
      min_set << table_name

      referenced_tables = find_foreign_key_constraint_references(table_name, REFERENCED_TABLES_STATEMENT)
      puts "Referenced tables: #{referenced_tables.inspect}" if @debug
      referencing_tables = find_foreign_key_constraint_references(table_name, REFERENCING_TABLES_STATEMENT)
      puts "Referencing tables: #{referencing_tables.inspect}" if @debug

      unseen_tables = (referenced_tables + referencing_tables - min_set - queue_set)
      puts "Unseen tables: #{unseen_tables.inspect}" if @debug
      unseen_tables.each do |unseen_table|
        queue << unseen_table
        queue_set << unseen_table
      end
    end
    min_set
  end

  # hacky way to pick a random element from a set
  def pick_set_element(set)
    set.each {|element| return element}
  end

  # finds all the seams in the schema
  def solve
    solution = Set.new # set of sets
    all_tables = list_tables

    while !all_tables.empty?
      table = pick_set_element(all_tables)
      min_set = find([table].to_set)
      puts "Found min_set: #{min_set.inspect}" if @debug
      solution << min_set
      all_tables -= min_set
    end
    solution
  end
end
