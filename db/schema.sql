-- PostgreSQL Schema

-- required extensions

CREATE EXTENSION pgcrypto;
CREATE EXTENSION citext;
CREATE EXTENSION "uuid-ossp";

-- shared stored procedures

CREATE FUNCTION on_record_insert() RETURNS trigger AS $$
  BEGIN
    NEW.id         := uuid_generate_v4();
    NEW.created_at := now();
    NEW.updated_at := now();
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION on_record_update() RETURNS trigger AS $$
  BEGIN
    -- ensure IDs aren't altered on updates
    NEW.id         := OLD.id;
    -- ensure date-created isn't altered on updates
    NEW.created_at := OLD.created_at;
    NEW.updated_at := now();
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION insert_user(addr TEXT, pass TEXT) RETURNS SETOF users AS $$
  BEGIN
    RETURN QUERY
      INSERT INTO users (email, password)
      VALUES (addr, crypt(pass, gen_salt('bf', 8)))
      RETURNING id, email, password, created_at, updated_at;
    EXCEPTION WHEN unique_violation THEN
  END;
$$ LANGUAGE plpgsql;

-- the User resource

CREATE TABLE users (
  id           UUID       PRIMARY KEY,
  email        VARCHAR    NOT NULL UNIQUE,
  password     VARCHAR    NOT NULL,
  created_at   TIMESTAMP  NOT NULL,
  updated_at   TIMESTAMP  NOT NULL
);

CREATE TRIGGER users_insert
  BEFORE INSERT ON users
  FOR EACH ROW
  EXECUTE PROCEDURE on_record_insert();

CREATE TRIGGER users_update
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE PROCEDURE on_record_update();
