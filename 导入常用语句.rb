# 首先在页面上创建一个导入的task,然后执行下面的方法，帮卖家手动推送
ProductImport::Prepare.call(Account.find_by_name(name).user.product_import) if Account.find_by_name(name).user.product_import
Account.find_by_name(name).user.product_import.items.each do |item| ProductImport::Process.call(item)  end

# 可以用下面的脚本来帮卖家批量导入商品
#下面的数组是 item_id
site_id = 0
account = Account.find_by_name(name)
[1,2,3].each do |item_id|
  ::ProductImport::Load.call(
    item_id: item_id,
    site_ids: [site_id],
    account: account,
    data_source: "from_ebay",
    original_site_id: site_id || account.site_id,
    )
end