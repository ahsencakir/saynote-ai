-- Eksik Products tablosu
CREATE TABLE public.products (
  product_id uuid NOT NULL DEFAULT extensions.uuid_generate_v4(),
  seller_id uuid NOT NULL,
  urun_adi character varying(100) NOT NULL,
  kategori character varying(50) NULL,
  fiyat numeric(10,2) NOT NULL,
  stok_miktari integer NOT NULL DEFAULT 0,
  aciklama text NULL,
  kayit_tarihi date NULL DEFAULT CURRENT_DATE,
  aktif_mi boolean NULL DEFAULT true,
  
  CONSTRAINT products_pkey PRIMARY KEY (product_id),
  CONSTRAINT products_seller_id_fkey FOREIGN KEY (seller_id) 
    REFERENCES sellers (seller_id) ON DELETE CASCADE,
  CONSTRAINT products_fiyat_check CHECK (fiyat >= 0),
  CONSTRAINT products_stok_check CHECK (stok_miktari >= 0)
) TABLESPACE pg_default;

-- Teslimat durumu için enum tip (eğer yoksa)
CREATE TYPE public.teslimat_durumu_tipi AS ENUM (
  'hazirlanıyor',
  'kargoda', 
  'teslim_edildi',
  'iptal_edildi'
);

-- İndeksler (performans için)
CREATE INDEX idx_products_seller_id ON products(seller_id);
CREATE INDEX idx_products_kategori ON products(kategori);
CREATE INDEX idx_orders_seller_via_product ON orders(product_id);
CREATE INDEX idx_orders_teslimat_durumu ON orders(teslimat_durumu);
CREATE INDEX idx_reviews_product_id ON reviews(product_id);

-- Satıcının kendi verilerini görmesi için RLS (Row Level Security) politikaları
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Örnek RLS politikaları (Supabase auth ile entegrasyon için)
CREATE POLICY "Sellers can view their own products" ON products
  FOR SELECT USING (seller_id IN (
    SELECT seller_id FROM sellers WHERE auth_user_id = auth.uid()
  ));

CREATE POLICY "Sellers can insert their own products" ON products
  FOR INSERT WITH CHECK (seller_id IN (
    SELECT seller_id FROM sellers WHERE auth_user_id = auth.uid()
  ));

CREATE POLICY "Sellers can update their own products" ON products
  FOR UPDATE USING (seller_id IN (
    SELECT seller_id FROM sellers WHERE auth_user_id = auth.uid()
  ));
