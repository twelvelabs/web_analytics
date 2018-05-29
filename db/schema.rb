Sequel.migration do
  change do
    create_table(:pageviews) do
      primary_key :id
      column :url, "text", :null=>false
      column :referrer, "text"
      column :created_at, "timestamp without time zone", :null=>false
      column :hash, "character(32)", :null=>false
      
      index [:created_at, :url, :referrer]
    end
    
    create_table(:schema_migrations) do
      column :filename, "text", :null=>false
      
      primary_key [:filename]
    end
  end
end
Sequel.migration do
  change do
    self << "SET search_path TO \"$user\", public"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20180529164621_create_pageviews.rb')"
  end
end
