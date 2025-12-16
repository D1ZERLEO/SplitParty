-- Тусовки
CREATE TABLE gatherings (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    admin_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Участники тусовки
CREATE TABLE gathering_participants (
    gathering_id INTEGER NOT NULL REFERENCES gatherings(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (gathering_id, user_id)
);

-- Чеки
CREATE TABLE receipts (
    id SERIAL PRIMARY KEY,
    gathering_id INTEGER NOT NULL REFERENCES gatherings(id) ON DELETE CASCADE,
    name VARCHAR(100),
    total_amount DECIMAL(12, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'RUB',
    created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Позиции в чеке
CREATE TABLE receipt_items (
    id SERIAL PRIMARY KEY,
    receipt_id INTEGER NOT NULL REFERENCES receipts(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    price DECIMAL(12, 2) NOT NULL
);

-- Кто за что заплатил (многие-ко-многим)
CREATE TABLE user_receipt_items (
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receipt_item_id INTEGER NOT NULL REFERENCES receipt_items(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, receipt_item_id)
);