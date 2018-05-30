namespace :dataset do

  desc 'Import the pageviews test dataset'
  task import: [:environment] do
    dataset = PageviewDataset.new(total_rows: 1_000_000)
    puts 'Importing...'
    dataset.import
  end

  desc 'Regenerate the pageviews test dataset'
  task regenerate: [:environment] do
    dataset = PageviewDataset.new(total_rows: 1_000_000)
    puts 'Cleaning...'
    dataset.clean
    puts 'Generating (this will take a bit)...'
    dataset.generate
  end

end
