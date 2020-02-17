BEGIN;

CREATE TABLE Users(
    uid SERIAL PRIMARY KEY,
    userName TEXT UNIQUE NOT NULL CONSTRAINT
    userName_cannot_be_too_short_or_too_long CHECK (char_length(userName) >=5 AND char_length(userName) < 40),
    passWord BYTEA NOT NULL CONSTRAINT passWord_should_be_32_bytes_long CHECK(octet_length(passWord) = 32),
    privilege INT NOT NULL DEFAULT 100 CONSTRAINT
    privilege_cannot_be_too_small_or_too_large CHECK(privilege >= 0 AND privilege <= 100) 
);

CREATE TYPE UserView AS (
    uid INT,
    userName TEXT,
    privilege INT
);

INSERT INTO Users(userName, passWord, privilege) VALUES ('webAdmin', '\xe428346da0067e05c95229ee3b8e03af8a9482857d4198b990daf7e98676a15f',0);

CREATE FUNCTION userLogin(user_name TEXT, pass BYTEA) RETURNS setof UserView SECURITY DEFINER AS $$
DECLARE
    cnt INT; 
BEGIN
    RETURN QUERY SELECT uid, userName, privilege FROM Users WHERE userName = user_name AND passWord = pass;
    GET DIAGNOSTICS cnt = ROW_COUNT; 
    IF cnt > 1 THEN
        RAISE SQLSTATE 'API06' USING MESSAGE = 'too many rows affected by userLogin()';
    END IF;
    RETURN;
END;
$$ LANGUAGE plpgsql;

COMMIT;