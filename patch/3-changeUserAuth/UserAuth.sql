BEGIN;
DROP FUNCTION userLogin;

CREATE FUNCTION getUser(user_name TEXT, pass BYTEA) RETURNS setof UserView SECURITY DEFINER AS $$
DECLARE
    cnt INT;
BEGIN
    RETURN QUERY SELECT uid, userName, privilege FROM Users WHERE userName = user_name AND passWord = pass;
    GET DIAGNOSTICS cnt = ROW_COUNT;
    IF cnt > 1 THEN
        RAISE SQLSTATE 'API06' USING MESSAGE = 'too many rows affected by getUser()';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION insertUser(user_name TEXT, pass BYTEA) RETURNS INT SECURITY DEFINER AS $$
DECLARE 
    userID INT;
BEGIN
    INSERT INTO Users(userName, passWord) VALUES (user_name, pass) RETURNING uid INTO userID;
    RETURN userID;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION updateUser(userID INT, nPW BYTEA) RETURNS BOOLEAN SECURITY DEFINER AS $$
DECLARE
    cnt INT;
BEGIN
    UPDATE Users SET passWord = nPW WHERE uid = userID;
    GET DIAGNOSTICS cnt = ROW_COUNT;
    IF cnt = 0 THEN
        RETURN FALSE;
    END IF;
    IF cnt > 1 THEN
        RAISE SQLSTATE 'API07' USING MESSAGE = 'too many rows affected by updateUser()';
    END IF;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
COMMIT;