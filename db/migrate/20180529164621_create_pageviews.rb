Sequel.migration do
  change do

    create_table :pageviews do
      primary_key :id
      Text :url,              null: false
      Text :referrer,         null: true
      DateTime :created_at,   null: false
      String :hash,           null: false, fixed: true, size: 32

      index [:created_at, :url, :referrer]
    end

  end
end
