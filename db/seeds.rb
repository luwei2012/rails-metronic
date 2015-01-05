# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#brands
5.times do |i|
  Brand.create(name: '奔驰'+i.to_s)
end

5.times do |i|
  Brand.create(name: '连锁'+i.to_s)
end


#discount_types
discount_type_names=['平台推广', '洗车', '美容', '保养', '维修', '道路救援', '5座以内', '7座及SUV']
discount_type_parent=['0', '0', '0', '0', '0', '0', '2', '2']
8.times do |i|
  DiscountType.create(name: discount_type_names[i], parent: discount_type_parent[i])
end

#shops
shop = Shop.create(name: '平台', telephone_number: '85233147', telephone_area_code: '028', address: "成都", longitude: '109', latitude: '30')

#employees
employee = Employee.create(email: 'admin@yuyaa.com', name: '管理员', phone: '11111111', password_digest: '$2a$10$Oqr4QS9fRWixFZ6tl40fkOncDe4aZBO3HDMJDgY32t31WGG4KiBO6', shop_id: shop.id)

#roles
role_names=['系统管理员', '洗车店', '品牌/连锁店']
role_duties=['系统管理员', '洗车信息管理', '发布品牌/连锁店服务信息']
3.times do |i|
  Role.create(authority: i, name: role_names[i], duty: role_duties[i])
end

#employee_roles
3.times do |i|
  EmployeeRole.create(role_id: (i+1), employee_id: employee.id)
end



