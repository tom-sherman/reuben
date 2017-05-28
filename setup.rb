require 'sqlite3'

db = SQLite3::Database.new 'reuben.db'

db.execute <<-SQL
  create table reps (
    giver char(18),
    receiver char(18),
    message char(18),
    channel char(18),
    server char(18)
  );
SQL
