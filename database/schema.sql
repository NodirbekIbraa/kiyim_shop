-- VESTRA CRM — Complete Database Schema

CREATE TABLE IF NOT EXISTS users (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(150) UNIQUE NOT NULL,
    password    VARCHAR(255) NOT NULL,
    role        VARCHAR(20) NOT NULL DEFAULT 'staff',
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS customers (
    id           SERIAL PRIMARY KEY,
    company_name VARCHAR(200) NOT NULL,
    contact_name VARCHAR(150),
    phone        VARCHAR(50),
    email        VARCHAR(150),
    city         VARCHAR(100),
    type         VARCHAR(30) NOT NULL DEFAULT 'retail',
    status       VARCHAR(20) NOT NULL DEFAULT 'active',
    notes        TEXT,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS products (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    category    VARCHAR(100) NOT NULL,
    description TEXT,
    price       NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock       INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    image_url   TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS orders (
    id              SERIAL PRIMARY KEY,
    customer_id     INTEGER REFERENCES customers(id) ON DELETE SET NULL,
    customer_name   VARCHAR(150),
    customer_phone  VARCHAR(50),
    status          VARCHAR(30) NOT NULL DEFAULT 'pending',
    total_amount    NUMERIC(10,2) NOT NULL DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
    id          SERIAL PRIMARY KEY,
    order_id    INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id  INTEGER REFERENCES products(id) ON DELETE SET NULL,
    quantity    INTEGER NOT NULL CHECK (quantity > 0),
    unit_price  NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);

CREATE TABLE IF NOT EXISTS activity_log (
    id          SERIAL PRIMARY KEY,
    user_name   VARCHAR(150) NOT NULL DEFAULT 'Admin',
    action      TEXT NOT NULL,
    entity_type VARCHAR(50),
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_orders_customer   ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status     ON orders(status);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_activity_created  ON activity_log(created_at DESC);

-- Admin user: nodir@gmail.com / univernodir
INSERT INTO users (name, email, password, role) VALUES
    ('Nodir', 'nodir@gmail.com',
     '$2a$10$WLdlYL0BWXW23uB.ec7/YOUv2kfpiJXV.It7NS6RqiW9Y3TNavlxG', 'admin')
ON CONFLICT (email) DO NOTHING;

-- ── Products (30 items · 10 categories) ─────────────────────
INSERT INTO products (name, category, description, price, stock, image_url) VALUES
  ('Classic White Tee',        'T-Shirts',   '100% organic cotton crew-neck tee',           12.99, 520, 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400'),
  ('Heavyweight Crew Tee',     'T-Shirts',   '240gsm structured cotton t-shirt',            16.50, 340, 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=400'),
  ('Graphic Print Tee',        'T-Shirts',   'Screen-printed soft-touch tee',               18.99, 280, 'https://images.unsplash.com/photo-1503341504253-dff4815485f1?w=400'),
  ('Oxford Button-Down',       'Shirts',     'Classic oxford cotton shirt',                 32.00, 190, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=400'),
  ('Linen Casual Shirt',       'Shirts',     'Breathable pure linen summer shirt',          38.50, 120, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400'),
  ('Flannel Check Shirt',      'Shirts',     'Brushed flannel checked overshirt',           29.99, 210, 'https://images.unsplash.com/photo-1607345366928-199ea26cfe3e?w=400'),
  ('Slim Fit Chinos',          'Trousers',   'Modern slim-fit stretch chinos',              34.99, 175, 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400'),
  ('Pleated Wool Trousers',    'Trousers',   'Tailored pleated wool-blend trousers',        49.99,  90, 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=400'),
  ('Straight Leg Denim',       'Jeans',      'Mid-wash straight leg jeans',                 42.00, 230, 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400'),
  ('Skinny Stretch Jeans',     'Jeans',      'Comfort-stretch skinny denim',                39.99, 260, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=400'),
  ('Vintage Wash Jeans',       'Jeans',      'Faded vintage-wash relaxed jeans',            45.50, 140, 'https://images.unsplash.com/photo-1582552938357-32b906df40cb?w=400'),
  ('Denim Jacket',             'Jackets',    'Vintage-wash unisex denim jacket',            59.99, 110, 'https://images.unsplash.com/photo-1551537482-f2075a1d41f2?w=400'),
  ('Linen Blazer',             'Jackets',    'Relaxed unstructured linen blazer',           89.99,  60, 'https://images.unsplash.com/photo-1594938298603-c8148c4b984b?w=400'),
  ('Bomber Jacket',            'Jackets',    'Lightweight zip-up bomber jacket',            64.99,  95, 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400'),
  ('Wool Overcoat',            'Coats',      'Tailored long wool-blend overcoat',          129.99,  45, 'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=400'),
  ('Padded Puffer Coat',       'Coats',      'Insulated water-repellent puffer',            99.99,  70, 'https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=400'),
  ('Belted Trench Coat',       'Coats',      'Classic double-breasted trench',             119.00,  38, 'https://images.unsplash.com/photo-1591047139756-eec3bca508e?w=400'),
  ('Floral Summer Dress',      'Dresses',    'Lightweight floral print midi dress',         44.99,  85, 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=400'),
  ('Knit Midi Dress',          'Dresses',    'Ribbed knit bodycon midi dress',              54.99,  65, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400'),
  ('Wrap Maxi Dress',          'Dresses',    'Flowing wrap-front maxi dress',               59.99,  50, 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=400'),
  ('Merino Wool Sweater',      'Knitwear',   'Fine merino wool crew-neck sweater',          69.99, 130, 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=400'),
  ('Cable Knit Cardigan',      'Knitwear',   'Chunky cable-knit button cardigan',           74.99,  88, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=400'),
  ('Lightweight Crew Knit',    'Knitwear',   'Soft cotton-blend lightweight knit',          49.99, 160, 'https://images.unsplash.com/photo-1576871337622-98d48d1cf531?w=400'),
  ('Pullover Hoodie',          'Hoodies',    'Brushed-back fleece pullover hoodie',         39.99, 300, 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=400'),
  ('Zip-Up Fleece Hoodie',     'Hoodies',    'Full-zip cotton fleece hoodie',               44.99, 220, 'https://images.unsplash.com/photo-1620799139507-2a76f79a2f4d?w=400'),
  ('Oversized Hoodie',         'Hoodies',    'Drop-shoulder oversized hoodie',              42.50, 180, 'https://images.unsplash.com/photo-1565693413579-8a73ffa8de15?w=400'),
  ('Athletic Shorts',          'Sportswear', 'Quick-dry athletic shorts with liner',        19.99, 310, 'https://images.unsplash.com/photo-1539185441755-769473a23570?w=400'),
  ('Performance Leggings',     'Sportswear', 'High-waist compression leggings',             29.99, 240, 'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=400'),
  ('Track Jacket',             'Sportswear', 'Retro zip-up panelled track jacket',          49.99, 130, 'https://images.unsplash.com/photo-1556906781-9a412961c28c?w=400'),
  ('Jogger Sweatpants',        'Sportswear', 'Tapered cuffed jogger sweatpants',            34.99, 200, 'https://images.unsplash.com/photo-1552902865-b72c031ac5ea?w=400')
ON CONFLICT DO NOTHING;

-- ── Customers (12 wholesale buyers) ─────────────────────────
INSERT INTO customers (company_name, contact_name, phone, email, city, type, status) VALUES
  ('Bella Moda MChJ',       'Aziz Karimov',      '+998 90 111 22 33', 'info@bellamoda.uz',   'Toshkent',  'corporate', 'active'),
  ('Samarqand Tekstil YaTT','Dilshod Rustamov',  '+998 91 222 33 44', 'sales@samtekstil.uz', 'Samarqand', 'corporate', 'active'),
  ('Orzu Fashion MChJ',     'Malika Yusupova',   '+998 93 333 44 55', 'orzu@fashion.uz',     'Buxoro',    'vip',       'active'),
  ('Nihol Kiyim YaTT',      'Nodira Ahmedova',   '+998 94 444 55 66', 'nihol@kiyim.uz',      'Namangan',  'retail',    'active'),
  ('Zamin Trade MChJ',      'Bobur Mirzayev',    '+998 97 555 66 77', 'zamin@trade.uz',      'Andijon',   'corporate', 'active'),
  ('Lola Boutique YaTT',    'Sevara Tosheva',    '+998 99 666 77 88', 'lola@boutique.uz',    'Toshkent',  'vip',       'active'),
  ('Fargona Moda MChJ',     'Jasur Ergashev',    '+998 90 777 88 99', 'fargona@moda.uz',     'Fargona',   'retail',    'active'),
  ('Diyor Textile MChJ',    'Sherzod Nazarov',   '+998 91 888 99 00', 'diyor@textile.uz',    'Qarshi',    'corporate', 'inactive'),
  ('Yangi Asr YaTT',        'Gulnora Karimova',  '+998 93 999 00 11', 'yangiasr@shop.uz',    'Nukus',     'retail',    'active'),
  ('Premium Style MChJ',    'Otabek Saidov',     '+998 94 100 20 30', 'premium@style.uz',    'Toshkent',  'vip',       'active'),
  ('Shahriyor Savdo YaTT',  'Akmal Tursunov',    '+998 97 200 30 40', 'shahriyor@savdo.uz',  'Jizzax',    'retail',    'active'),
  ('Marvarid Fashion MChJ', 'Kamola Yoldosheva', '+998 99 300 40 50', 'marvarid@fashion.uz', 'Termiz',    'corporate', 'active')
ON CONFLICT DO NOTHING;

-- ── Orders (24 orders across 6 months) ──────────────────────
-- unit_price is taken from each product's own price; totals recomputed at the end.
DO $$
DECLARE o INT;
BEGIN
  IF (SELECT COUNT(*) FROM orders) = 0 THEN

  -- helper macro pattern repeated per order
  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Bella Moda MChJ'),'Bella Moda MChJ','delivered',NOW()-INTERVAL'165 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Classic White Tee',20),('Pullover Hoodie',8),('Slim Fit Chinos',6)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Samarqand Tekstil YaTT'),'Samarqand Tekstil YaTT','delivered',NOW()-INTERVAL'158 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Merino Wool Sweater',10),('Wool Overcoat',3),('Cable Knit Cardigan',5)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Orzu Fashion MChJ'),'Orzu Fashion MChJ','delivered',NOW()-INTERVAL'150 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Floral Summer Dress',12),('Wrap Maxi Dress',6),('Knit Midi Dress',4)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Zamin Trade MChJ'),'Zamin Trade MChJ','delivered',NOW()-INTERVAL'140 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Straight Leg Denim',10),('Skinny Stretch Jeans',8),('Denim Jacket',4)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Lola Boutique YaTT'),'Lola Boutique YaTT','delivered',NOW()-INTERVAL'132 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Linen Blazer',4),('Oxford Button-Down',8),('Linen Casual Shirt',6)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Premium Style MChJ'),'Premium Style MChJ','delivered',NOW()-INTERVAL'124 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Belted Trench Coat',3),('Padded Puffer Coat',5),('Track Jacket',6)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Nihol Kiyim YaTT'),'Nihol Kiyim YaTT','cancelled',NOW()-INTERVAL'118 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Graphic Print Tee',15),('Athletic Shorts',10)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Fargona Moda MChJ'),'Fargona Moda MChJ','delivered',NOW()-INTERVAL'110 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Jogger Sweatpants',12),('Zip-Up Fleece Hoodie',8),('Performance Leggings',10)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Yangi Asr YaTT'),'Yangi Asr YaTT','delivered',NOW()-INTERVAL'98 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Heavyweight Crew Tee',16),('Flannel Check Shirt',6),('Vintage Wash Jeans',5)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Marvarid Fashion MChJ'),'Marvarid Fashion MChJ','delivered',NOW()-INTERVAL'88 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Cable Knit Cardigan',6),('Lightweight Crew Knit',10),('Merino Wool Sweater',5)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Bella Moda MChJ'),'Bella Moda MChJ','shipped',NOW()-INTERVAL'76 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Pullover Hoodie',14),('Oversized Hoodie',8),('Classic White Tee',20)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Orzu Fashion MChJ'),'Orzu Fashion MChJ','shipped',NOW()-INTERVAL'68 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Wrap Maxi Dress',8),('Knit Midi Dress',6),('Floral Summer Dress',10)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Samarqand Tekstil YaTT'),'Samarqand Tekstil YaTT','delivered',NOW()-INTERVAL'60 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Wool Overcoat',4),('Padded Puffer Coat',6),('Belted Trench Coat',3)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Zamin Trade MChJ'),'Zamin Trade MChJ','shipped',NOW()-INTERVAL'52 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Skinny Stretch Jeans',12),('Straight Leg Denim',8),('Bomber Jacket',5)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Lola Boutique YaTT'),'Lola Boutique YaTT','processing',NOW()-INTERVAL'44 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Linen Casual Shirt',8),('Oxford Button-Down',10),('Linen Blazer',3)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Premium Style MChJ'),'Premium Style MChJ','processing',NOW()-INTERVAL'36 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Track Jacket',8),('Performance Leggings',12),('Jogger Sweatpants',10)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Fargona Moda MChJ'),'Fargona Moda MChJ','delivered',NOW()-INTERVAL'30 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Athletic Shorts',16),('Graphic Print Tee',12),('Heavyweight Crew Tee',10)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Yangi Asr YaTT'),'Yangi Asr YaTT','processing',NOW()-INTERVAL'24 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Vintage Wash Jeans',8),('Flannel Check Shirt',6),('Zip-Up Fleece Hoodie',7)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Marvarid Fashion MChJ'),'Marvarid Fashion MChJ','pending',NOW()-INTERVAL'16 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Lightweight Crew Knit',12),('Cable Knit Cardigan',5),('Merino Wool Sweater',6)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Bella Moda MChJ'),'Bella Moda MChJ','pending',NOW()-INTERVAL'11 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Oversized Hoodie',10),('Pullover Hoodie',12),('Jogger Sweatpants',8)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Orzu Fashion MChJ'),'Orzu Fashion MChJ','pending',NOW()-INTERVAL'7 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Knit Midi Dress',8),('Wrap Maxi Dress',6),('Floral Summer Dress',9)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Shahriyor Savdo YaTT'),'Shahriyor Savdo YaTT','pending',NOW()-INTERVAL'4 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Classic White Tee',18),('Athletic Shorts',12),('Slim Fit Chinos',8)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Premium Style MChJ'),'Premium Style MChJ','processing',NOW()-INTERVAL'2 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Wool Overcoat',2),('Linen Blazer',4),('Bomber Jacket',6)) v(n,q) JOIN products p ON p.name=v.n;

  INSERT INTO orders(customer_id,customer_name,status,created_at) VALUES((SELECT id FROM customers WHERE company_name='Zamin Trade MChJ'),'Zamin Trade MChJ','pending',NOW()-INTERVAL'1 days') RETURNING id INTO o;
  INSERT INTO order_items(order_id,product_id,quantity,unit_price) SELECT o,p.id,v.q,p.price FROM (VALUES('Straight Leg Denim',10),('Pleated Wool Trousers',5),('Track Jacket',6)) v(n,q) JOIN products p ON p.name=v.n;

  -- recompute every order total from its items
  UPDATE orders SET total_amount = COALESCE((SELECT SUM(oi.quantity*oi.unit_price) FROM order_items oi WHERE oi.order_id=orders.id),0);

  -- activity log
  INSERT INTO activity_log(user_name,action,entity_type,created_at) VALUES
    ('Nodir','Tizimga kirdi','auth',NOW()-INTERVAL'30 minutes'),
    ('Nodir','Yangi buyurtma qabul qilindi','order',NOW()-INTERVAL'2 days'),
    ('Nodir','Buyurtma holati o''zgartirildi: shipped','order',NOW()-INTERVAL'3 days'),
    ('Nodir','Yangi mahsulot qo''shildi: Belted Trench Coat','product',NOW()-INTERVAL'5 days'),
    ('Nodir','Yangi mijoz qo''shildi: Shahriyor Savdo YaTT','customer',NOW()-INTERVAL'4 days'),
    ('Nodir','Ombor yangilandi: Pullover Hoodie','product',NOW()-INTERVAL'6 days'),
    ('Nodir','Buyurtma bekor qilindi','order',NOW()-INTERVAL'8 days'),
    ('Nodir','Oylik hisobot yaratildi','report',NOW()-INTERVAL'10 days');
  END IF;
END $$;
