name = 'top-moebel24'
published_listings_count = 0;
errors_count = 0;
global_start_time = Time.now;
user = Account.find_by(name: name).user;
total_not_published_listings = user.listings.not_published.selected.managed.where(site_id:77).size
user.listings.not_published.selected.managed.where(site_id:77).find_each do |el|
  start_time = Time.now
  el&.ebay_profile('return')&.update(changed_at:Time.current)
  Publishing.synchronize(el)
  end_time = Time.now
  published_listings_count += 1
  puts "|----------------------------------"
  puts "| name-- #{name}"
  puts "| Completed in #{(end_time-start_time).to_s} seconds."
  puts "| Published count: #{published_listings_count}/#{total_not_published_listings} listings."
  puts "| AVG SPEED: #{(end_time-global_start_time).to_f / published_listings_count}."
  puts "|----------------------------------"
  puts "| ERRORS COUNT: #{errors_count}"
  puts "|----------------------------------"
rescue StandardError => e
  errors_count += 1
  nil
end