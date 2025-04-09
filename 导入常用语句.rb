# 首先在页面上创建一个导入的task,然后执行下面的方法，帮卖家手动推送
ProductImport::Prepare.call(Account.find_by_name(name).user.product_import) if Account.find_by_name(name).user.product_import
Account.find_by_name(name).user.product_import.items.each do |item| ProductImport::Process.call(item)  end
