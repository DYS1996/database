BEGIN;

CREATE FUNCTION getPostByID(pid INT) RETURNS setof PostView SECURITY DEFINER AS $$
DECLARE
    cnt INT;
BEGIN
    RETURN QUERY SELECT p.postID AS postID, title, cDate, mDate, content, array_remove(array_agg(tag),NULL) AS tags 
    FROM Posts p LEFT JOIN Tags t ON p.postID = t.postID WHERE
    p.postID = pid GROUP BY p.postID;

    GET DIAGNOSTICS cnt = ROW_COUNT;
    IF cnt > 1 THEN
        RAISE SQLSTATE 'API01' USING MESSAGE = 'too many rows obtained by getPostByID()';
    END IF;
    RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION getPostsByPage(pagesize INT, page INT) RETURNS setof PostView SECURITY DEFINER AS $$
DECLARE
    ofs INT = (page - 1) * pagesize;
BEGIN
    RETURN QUERY SELECT p.postID AS postID, title, cDate, mDate, substring(content for 75) || '...', array_remove(array_agg(tag),NULL) AS tags FROM Posts p LEFT JOIN Tags t ON p.postID = t.postID GROUP BY p.postID
    ORDER BY cDate DESC, postID DESC
    LIMIT pagesize OFFSET ofs;
    RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION getPostsCount() RETURNS INT SECURITY DEFINER AS $$
DECLARE
    cnt INT;
BEGIN
    SELECT count(*) INTO cnt FROM Posts;
    RETURN cnt;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION insertPost(title TEXT, content TEXT, tags TEXT[]) RETURNS INT SECURITY DEFINER AS $$
DECLARE
    t TEXT;
    pid INT;
BEGIN
    INSERT INTO Posts(title, content) VALUES (title, content) RETURNING postID INTO pid;
    FOREACH t IN ARRAY tags
    LOOP
        INSERT INTO Tags(postID, tag) VALUES (pid, t);
    END LOOP;
    RETURN pid;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION deletePost(pid INT) RETURNS BOOLEAN SECURITY DEFINER AS $$
DECLARE
    cnt INT;
BEGIN
    DELETE FROM Posts WHERE postID = pid;
    GET DIAGNOSTICS cnt = ROW_COUNT;
    IF cnt = 0 THEN
        RETURN FALSE;
    END IF;
    IF cnt > 1 THEN
        RAISE SQLSTATE 'API02' USING MESSAGE = 'too many rows affected by deletePost()';
    END IF;
    RETURN TRUE;

END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION updatePost(pid INT, newTitle TEXT, newContent TEXT, newTags TEXT[]) RETURNS BOOLEAN SECURITY DEFINER AS $$
DECLARE
    cnt INT;
    t TEXT;
BEGIN
    UPDATE Posts SET title = newTitle, content = newContent, mDate = CURRENT_TIMESTAMP WHERE postID = pid;
    GET DIAGNOSTICS cnt = ROW_COUNT;
    IF cnt = 0 THEN
        RETURN FALSE;
    END IF;
    IF cnt > 1 THEN
        RAISE SQLSTATE 'API03' USING MESSAGE = 'too many rows affected by updatePost()';
    END IF;
    DELETE FROM Tags WHERE postID = pid;
    FOREACH t IN ARRAY newTags
    LOOP
        INSERT INTO Tags(postID, tag) VALUES (pid, t);
    END LOOP;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION getCommentsCount(pid INT) RETURNS INT SECURITY DEFINER AS $$
DECLARE
    cnt INT;
BEGIN
    SELECT count(*) INTO cnt FROM Comments WHERE postID = pid;
    RETURN cnt;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION getCommentsByPage(pid INT, pagesize INT, page INT) RETURNS setof CommentView SECURITY DEFINER AS $$
DECLARE
    ofs INT = (page - 1) * pagesize;
BEGIN
    RETURN QUERY SELECT postID, commentID, authorEmail, cDate, content FROM Comments WHERE postID = pid
    ORDER BY cDate DESC, commentID DESC
    LIMIT pagesize OFFSET ofs;
    RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION insertComment(pid INT, content TEXT, authorEmail TEXT) RETURNS INT SECURITY DEFINER AS $$
DECLARE
    cmtID INT;
BEGIN
    INSERT INTO Comments(content, authorEmail, postID) VALUES (content, authorEmail, pid) RETURNING commentID INTO cmtID;
    RETURN cmtID;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION deleteComment(cmtID INT) RETURNS BOOLEAN SECURITY DEFINER AS $$
DECLARE
    cnt INT;
BEGIN
    DELETE FROM Comments WHERE commentID = cmtID;
    GET DIAGNOSTICS cnt = ROW_COUNT;
    IF cnt = 0 THEN
        RETURN FALSE;
    END IF;
    IF cnt > 1 THEN
        RAISE SQLSTATE 'API04' USING MESSAGE = 'too many rows affected by deleteComment()';
    END IF;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION updateComment(cmtID INT, newContent TEXT, newAuthorEmail TEXT) RETURNS BOOLEAN SECURITY DEFINER AS $$
DECLARE
    cnt INT;
BEGIN
    UPDATE Comments SET content = newContent, authorEmail = newAuthorEmail WHERE commentID = cmtID;
    GET DIAGNOSTICS cnt = ROW_COUNT;
    IF cnt = 0 THEN
        RETURN FALSE;
    END IF;
    IF cnt > 1 THEN
        RAISE SQLSTATE 'API05' USING MESSAGE = 'too many rows affected by updateComment()';
    END IF;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

COMMIT;