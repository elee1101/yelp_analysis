-- USERS TABLE
CREATE TABLE users (
    user_id TEXT PRIMARY KEY,
    name TEXT,
    review_count INT,
    yelping_since DATE,
    useful INT,
    funny INT,
    cool INT,
    fans INT,
    average_stars FLOAT
);

CREATE TABLE businesses (
    business_id TEXT PRIMARY KEY,
    name TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    latitude FLOAT,
    longitude FLOAT,
    stars FLOAT,
    review_count INT,
    is_open INT
);

-- REVIEWS TABLE
CREATE TABLE reviews (
    review_id TEXT PRIMARY KEY,
    user_id TEXT,
    business_id TEXT,
    stars FLOAT,
    date DATE,
    text TEXT,
    useful INT,
    funny INT,
    cool INT,

    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (business_id) REFERENCES businesses(business_id)
);

SELECT * FROM users

SELECT * FROM businesses

SELECT * FROM reviews