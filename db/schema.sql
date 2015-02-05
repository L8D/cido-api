-- PostgreSQL Schema

-- required extensions

CREATE EXTENSION pgcrypto;
CREATE EXTENSION citext;

-- shared stored procedures

CREATE FUNCTION on_record_insert() RETURNS trigger AS $$
  DECLARE
    id_sequence VARCHAR;
  BEGIN
    -- the name of the ID sequence for this table
    SELECT TG_ARGV[0] INTO id_sequence;
    -- set the ID as the next sequence value
    NEW.id         := nextval(id_sequence);
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

-- the User resource

CREATE TABLE users (
  id           INTEGER    PRIMARY KEY,
  username     VARCHAR    NOT NULL,
  password     VARCHAR    NOT NULL,
  created_at   TIMESTAMP  NOT NULL,
  updated_at   TIMESTAMP  NOT NULL
);

CREATE SEQUENCE user_ids START 1;

CREATE TRIGGER users_insert
  BEFORE INSERT ON users
  FOR EACH ROW
  EXECUTE PROCEDURE on_record_insert('user_ids');

CREATE TRIGGER users_update
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE PROCEDURE on_record_update();
