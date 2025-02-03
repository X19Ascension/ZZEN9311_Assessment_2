-- ZZEN9311 Assignment 2b
-- Schema for the mypics.net photo-sharing site
--
-- Written by <<YOUR NAME GOES HERE>>
--
-- Conventions:
-- * all entity table names are plural
-- * most entities have an artifical primary key called "id"
-- * foreign keys are named after the relationship they represent

-- Domains (you may add more)

create domain URLValue as
	varchar(100) check (value like 'https://%');

create domain EmailValue as
	varchar(100) check (value like '%@%.%');

create domain GenderValue as
	varchar(6) check (value in ('male','female'));

create domain GroupModeValue as
	varchar(15) check (value in ('private','by-invitation','by-request'));

create domain NameValue as varchar(50);

create domain LongNameValue as varchar(100);


-- Tables (you must add more)

create table People (
	id SERIAL PRIMARY KEY,
	name NameValue NOT NULL
);

create table Users (
	user_id SERIAL PRIMARY KEY,
	name NameValue NOT NULL,
	email EmailValue UNIQUE NOT NULL,
	password_hash TEXT NOT NULL,
	date_registered TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	website_url URLValue,
	gender GenderValue,
	birthday DATE,
	profile_image TEXT CHECK(octet_length(profile_image) <= 64000)
);

create table Groups (
	group_id SERIAL PRIMARY KEY,
	owner_id INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
	title LongNameValue NOT NULL,
	mode GroupModeValue NOT NULL
	
);

CREATE TABLE Photos (
    photo_id SERIAL PRIMARY KEY,
    uploaded_by INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    title LongNameValue NOT NULL,
    description TEXT,
    file_size INT CHECK (file_size >= 0),
    taken_date DATE,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    technical_details TEXT,
    thumbnail TEXT NOT NULL,
    safety_level TEXT CHECK (safety_level IN ('Safe', 'Moderate', 'Restricted')) NOT NULL,
    visibility TEXT CHECK (visibility IN ('Private', 'Friends', 'Family', 'Friends+Family', 'Public')) NOT NULL
);

CREATE TABLE Photo_Collections (
    collection_id SERIAL PRIMARY KEY,
    owner_id INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    title LongNameValue NOT NULL,
    description TEXT,
    key_photo_id INT REFERENCES Photos(photo_id) ON DELETE SET NULL
);

CREATE TABLE Photos_in_Collections (
    collection_id INT NOT NULL REFERENCES Photo_Collections(collection_id) ON DELETE CASCADE,
    photo_id INT NOT NULL REFERENCES Photos(photo_id) ON DELETE CASCADE,
    position INT CHECK (position >= 0),
    PRIMARY KEY (collection_id, photo_id)
);

CREATE TABLE Comments (
    comment_id SERIAL PRIMARY KEY,
    photo_id INT NOT NULL REFERENCES Photos(photo_id) ON DELETE CASCADE,
    author_id INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    parent_comment_id INT REFERENCES Comments(comment_id) ON DELETE CASCADE
);

CREATE TABLE Ratings (
    photo_id INT NOT NULL REFERENCES Photos(photo_id) ON DELETE CASCADE,
    user_id INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    rating INT CHECK (rating BETWEEN 1 AND 5) NOT NULL,
    PRIMARY KEY (photo_id, user_id)
);

CREATE TABLE Tags (
    tag_id SERIAL PRIMARY KEY,
    tag_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Photo_Tags (
    photo_id INT NOT NULL REFERENCES Photos(photo_id) ON DELETE CASCADE,
    tag_id INT NOT NULL REFERENCES Tags(tag_id) ON DELETE CASCADE,
    PRIMARY KEY (photo_id, tag_id)
);

CREATE TABLE Friend_Groups (
    group_id SERIAL PRIMARY KEY,
    owner_id INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    group_name LongNameValue NOT NULL
);

CREATE TABLE Friends (
    group_id INT NOT NULL REFERENCES Friend_Groups(group_id) ON DELETE CASCADE,
    person_id INT NOT NULL REFERENCES People(id) ON DELETE CASCADE,
    PRIMARY KEY (group_id, person_id)
);

CREATE TABLE Group_Photo_Collections (
    group_id INT NOT NULL REFERENCES Groups(group_id) ON DELETE CASCADE,
    collection_id INT NOT NULL REFERENCES Photo_Collections(collection_id) ON DELETE CASCADE,
    PRIMARY KEY (group_id, collection_id)
);

CREATE TABLE Discussion_Threads (
    thread_id SERIAL PRIMARY KEY,
    group_id INT NOT NULL REFERENCES Groups(group_id) ON DELETE CASCADE,
    title LongNameValue NOT NULL
);

CREATE TABLE Messages (
    message_id SERIAL PRIMARY KEY,
    thread_id INT NOT NULL REFERENCES Discussion_Threads(thread_id) ON DELETE CASCADE,
    author_id INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);