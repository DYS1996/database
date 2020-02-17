BEGIN;

CREATE TABLE Posts(
    postID SERIAL PRIMARY KEY,
    title TEXT UNIQUE NOT NULL CONSTRAINT post_title_cannot_be_too_short_or_too_long CHECK (char_length(title) < 16 AND char_length(title) >=3),
    cDate TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    mDate TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    content TEXT NOT NULL CONSTRAINT content_cannot_be_too_long_or_too_short CHECK (char_length(content) >= 10 AND char_length(content) < 100000)
);

CREATE TABLE Tags(
    tagID SERIAL PRIMARY KEY,
    postID INT REFERENCES Posts(postID) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    tag TEXT NOT NULL CONSTRAINT tag_cannot_be_too_long_or_too_simple CHECK(char_length(tag) >= 2 AND char_length(tag) < 7),
    UNIQUE(postID, tag)
);

CREATE FUNCTION checkTagCount() RETURNS trigger SECURITY DEFINER AS $$
DECLARE
    current_tag_count INT;
BEGIN
    SELECT INTO current_tag_count count(*) FROM Tags WHERE postID = new.postID;
    IF (current_tag_count + 1) < 6 THEN
        RETURN new;
    END IF;
    RAISE SQLSTATE 'TRG01' USING MESSAGE = 'a post can have maximum 5 tags';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_tag_count BEFORE INSERT OR UPDATE ON Tags FOR EACH ROW EXECUTE FUNCTION checkTagCount();



CREATE TABLE Comments(
    commentID SERIAL PRIMARY KEY,
    postID INT REFERENCES Posts(postID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    cDate TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    authorEmail TEXT NOT NULL,
    content TEXT NOT NULL CONSTRAINT content_cannot_be_too_long_or_too_short CHECK (char_length(content) >=2 AND char_length(content) <501)
);

CREATE INDEX ON Comments(postID);

COMMIT;