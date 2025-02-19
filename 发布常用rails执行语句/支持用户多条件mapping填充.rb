# 支持用户多条件mapping填充
# user.listings.managed.selected.not_published.joins(:problems).where(problems:{i18n_key: "21919303"}).count
# specific 缺失的报错的i18n_key好像都是 21919303
name = "hertune_japan".strip
user = Account.find_by_name(name).user
# total = user.listings.managed.selected.with_errors.not_published.count
total = user.listings.managed.selected.not_published.joins(:problems).where(problems:{i18n_key: "21919303"}).count
changed_size = 0
error_size = 0
total_size = 0
# 修改mapping完成拷贝定制
specific_mappings = {
  "Focus Type" => ["Focal type", "Focus"],
  "Mount" => ["Lens mount", "Mounting"],
  "Type" => ["Type of focus"],
}
# 修改hardcode完成手动填充值
hardcode_mappings = {
  "Support" => "N/A",
  # "Certification" => "Uncertified",
  # "Attestation" => "Uncertified",
  # "Classe" => "Ungraded",
  # "Grade" => "Ungraded"
}
user.listings.managed.selected.not_published.joins(:problems).where(problems:{i18n_key: "21919303"}).find_each do |listing|
  total_size += 1
  next if listing.problems.blank?
  product = listing.source
  locale = product.language
  target_specifics = []
  specifics = []
  if specific_mappings.any?
    specific_mappings.each do |source_name, target_names|
      asp = product.aspects.to_h[:items].find {|aaa| aaa[:name][:translations].any? {|bbb| bbb[:locale] == locale && bbb[:text] == source_name }}
      next unless asp
      value = asp[:value][:translations].find {|ccc| ccc[:locale] == locale}
      text = value[:text]
      target_names.each do |target_name|
        specifics << { name: target_name, value: text }
      end
    end
  end
  if hardcode_mappings.any?
    hardcode_mappings.each do |hardcode_name, hardcode_value|
      specifics << { name: hardcode_name, value: hardcode_value }
    end
  end
  product.aspects.to_h[:items].each do |attr|
    name_obj = attr[:name][:translations].find {|eee| eee[:locale] == locale}
    value_obj = attr[:value].nil? ? "" : attr[:value][:translations].find {|eee| eee[:locale] == locale}
    target_specifics << {name: name_obj[:text], value: value_obj.blank? ? "" : value_obj[:text]}
  end
  if specifics.any?
    specifics.each do |specific|
      need_change_item = target_specifics.find { |item| item[:name] == specific[:name] }
      next if need_change_item.nil?
      need_change_item.merge!(specific)
    end
  end
  Store.save_product! record: product, specifics: target_specifics
  changed_size += 1
  puts "changed: #{changed_size}/#{total} - errors: #{error_size} - total_processed: #{total_size}"
rescue DistributedLock::TimeoutError, NoMethodError
  error_size += 1
  changed_size += 1
end
