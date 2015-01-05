#brands
INSERT INTO `brands` (id, name) VALUES ('2', '奔驰');
INSERT INTO `brands` (id, name) VALUES ('3', '宝马');
INSERT INTO `brands` (id, name) VALUES ('4', '大众');
INSERT INTO `brands` (id, name) VALUES ('5', '别克');
INSERT INTO `brands` (id, name) VALUES ('6', '奥迪');
INSERT INTO `brands` (id, name) VALUES ('7', '奔驰连锁');
INSERT INTO `brands` (id, name) VALUES ('8', '宝马连锁');
INSERT INTO `brands` (id, name) VALUES ('9', '大众连锁');
INSERT INTO `brands` (id, name) VALUES ('10', '别克连锁');
INSERT INTO `brands` (id, name) VALUES ('11', '奥迪连锁');

#discount_types
INSERT INTO `discount_types` (id, name, value, parent) VALUES ('1', '平台推广', '0', '0');
INSERT INTO `discount_types` (id, name, value, parent) VALUES ('2', '洗车', '1', '0');
INSERT INTO `discount_types` (id, name, value, parent) VALUES ('3', '7座及SUV', '2', '2');
INSERT INTO `discount_types` (id, name, value, parent) VALUES ('4', '5座以内', '3', '2');
INSERT INTO `discount_types` (id, name, value, parent) VALUES ('5', '美容', '4', '0');
INSERT INTO `discount_types` (id, name, value, parent) VALUES ('6', '保养', '5', '0');
INSERT INTO `discount_types` (id, name, value, parent) VALUES ('7', '维修', '6', '0');
INSERT INTO `discount_types` (id, name, value, parent) VALUES ('8', '道路救援', '7', '0');


#employee_roles
INSERT INTO `employee_roles` (id, role_id, employee_id) VALUES ('1', '1', '1');
INSERT INTO `employee_roles` (id, role_id, employee_id) VALUES ('2', '2', '1');
INSERT INTO `employee_roles` (id, role_id, employee_id) VALUES ('3', '3', '1');


#employees
INSERT INTO `employees` (id, email, name, phone, password_digest, shop_id,auth_token)
VALUES ('1', 'admin@yuyaa.com', '管理员', '11111111', '$2a$10$Oqr4QS9fRWixFZ6tl40fkOncDe4aZBO3HDMJDgY32t31WGG4KiBO6', '1','HM6tFwB2pU4qlfLfEcb_uA');

INSERT INTO `shops` (id, name, telephone_number, telephone_area_code) VALUES ('1', '平台', '85233147', '028');

#roles
INSERT INTO `roles` (id, authority, name, duty) VALUES ('1', '0', '系统管理员', '系统管理员');
INSERT INTO `roles` (id, authority, name, duty) VALUES ('2', '1', '洗车店', '洗车信息管理');
INSERT INTO `roles` (id, authority, name, duty) VALUES ('3', '2', '品牌/连锁店', '发布品牌/连锁店服务信息');

